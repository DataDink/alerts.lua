--- Simplistic alerting and logging
-- @see https://github.com/DataDink/debug.lua#README.md
return setmetatable({
  level = 4,
  levels = {"VERBOSE", "INFO", "WARN", "ERROR"},
  format = "{time}:{level}:{message}",
  stdout = print,
}, (function(safecall) return {
  safecall = safecall, -- exposed for testing
  __call = function(self, level, func, ...)
    return safecall(level, self.level, self.levels, function(reqIndex, reqName, lvlIndex, lvlName, ...)
      return func(...);
    end, ...);
  end,
  __index = function(self, key)
    return function(_, message) return safecall(key, self.level, self.levels, function(reqIndex, reqName, lvlIndex, lvlName)
      local text = self.format:gsub("{time}", os.time()):gsub("{level}", reqName):gsub("{message}", tostring(message));
      return text, self.stdout(text);
    end); end
  end,
}; end)(
  function(required, level, levels, func, ...)
    local valid = type(levels)=="table" and type(func)=="function";
    if (valid and type(required)~="number") then valid=false; for i=1,#levels do if (levels[i]==required) then required = i; valid=true; break; end end end
    if (valid and type(level)~="number") then valid=false; for i=1,#levels do if (levels[i]==level) then level = i; valid=true; break; end end end
    if ((not valid) or (level>required)) then return false, valid and "LEVEL_MISMATCH" or "LEVEL_INVALID", required, level; end
    return pcall(func, required, levels[required], level, levels[level], ...);
  end
));