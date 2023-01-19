local unit = require('luaunit');

function testSafecallIsFunction()
  local unitType = type(getmetatable(dofile('alerts.lua')).safecall);
  unit.assertEquals(unitType, "function", "This blocks testing");
end

function testSafecallNoArgs()
  local success, error = getmetatable(dofile('alerts.lua'))
    .safecall();
  unit.assertFalse(success, tostring(error));
  unit.assertEquals(error, "LEVEL_INVALID");
end

function testSafecallInvalidReq()
  local success, error = getmetatable(dofile('alerts.lua'))
    .safecall("INVALID", 1, {"VERBOSE", "INFO", "WARN", "ERROR"}, function() end);
  unit.assertFalse(success, tostring(error));
  unit.assertEquals(error, "LEVEL_INVALID");
end

function testSafecallInvalidLevel()
  local success, error = getmetatable(dofile('alerts.lua'))
    .safecall(1, "INVALID", {"VERBOSE", "INFO", "WARN", "ERROR"}, function() end);
  unit.assertFalse(success, tostring(error));
  unit.assertEquals(error, "LEVEL_INVALID");
end

function testSafecallInvalidLevels()
  local success, error = getmetatable(dofile('alerts.lua'))
    .safecall(1, 1, "INVALID", function() end);
  unit.assertFalse(success, tostring(error));
  unit.assertEquals(error, "LEVEL_INVALID");
end

function testSafecallInvalidFunc()
  local success, error = getmetatable(dofile('alerts.lua'))
    .safecall(1, 1, {"VERBOSE", "INFO", "WARN", "ERROR"}, "INVALID");
  unit.assertFalse(success, tostring(error));
  unit.assertEquals(error, "LEVEL_INVALID");
end

function testSafecallReqHigh()
  local success, error = getmetatable(dofile('alerts.lua'))
    .safecall(2, 1, {"VERBOSE", "INFO", "WARN", "ERROR"}, function() end);
  unit.assertTrue(success, tostring(error));
  unit.assertIsNil(error);
end

function testSafecallReqLow()
  local success, error = getmetatable(dofile('alerts.lua'))
    .safecall(1, 2, {"VERBOSE", "INFO", "WARN", "ERROR"}, function() end);
  unit.assertFalse(success, tostring(error));
  unit.assertEquals(error, "LEVEL_MISMATCH");
end

function testSafecallReqEqual()
  local success, error = getmetatable(dofile('alerts.lua'))
    .safecall(1, 1, {"VERBOSE", "INFO", "WARN", "ERROR"}, function() end);
  unit.assertTrue(success, tostring(error));
  unit.assertIsNil(error);
end

function testSafecallReqNameHigh()
  local success, error = getmetatable(dofile('alerts.lua'))
    .safecall("INFO", "VERBOSE", {"VERBOSE", "INFO", "WARN", "ERROR"}, function() end);
  unit.assertTrue(success, tostring(error));
  unit.assertIsNil(error);
end

function testSafecallReqNameLow()
  local success, error = getmetatable(dofile('alerts.lua'))
    .safecall("INFO", "WARN", {"VERBOSE", "INFO", "WARN", "ERROR"}, function() end);
  unit.assertFalse(success, tostring(error));
  unit.assertEquals(error, "LEVEL_MISMATCH");
end

function testSafecallReqNameEqual()
  local success, error = getmetatable(dofile('alerts.lua'))
    .safecall("INFO", "INFO", {"VERBOSE", "INFO", "WARN", "ERROR"}, function() end);
  unit.assertTrue(success, tostring(error));
  unit.assertIsNil(error);
end

function testSafecallExpectedArgs()
  local args = {};
  local success, error = getmetatable(dofile('alerts.lua'))
    .safecall(3, 1, {"VERBOSE", "INFO", "WARN", "ERROR"}, function(reqIndex, reqName, lvlIndex, lvlName, ...)
      args = {reqIndex, reqName, lvlIndex, lvlName, ...};
    end, 1, 2, 3);
  unit.assertTrue(success, tostring(error));
  unit.assertEquals(args, {3, "WARN", 1, "VERBOSE", 1, 2, 3});
end

function testSafecallExceptedReturn()
  local results = {getmetatable(dofile('alerts.lua'))
    .safecall(3, 1, {"VERBOSE", "INFO", "WARN", "ERROR"}, function()
      return 1, 2, 3;
    end)};
  unit.assertEquals(#results, 4, results);
  unit.assertTrue(results[1], results);
  unit.assertEquals(results[2], 1, results);
  unit.assertEquals(results[3], 2, results);
  unit.assertEquals(results[4], 3, results);
end

function testAlertsHasDefaultLevel()
  local alerts = dofile('alerts.lua');
  unit.assertEquals(type(alerts.level), "number");
  unit.assertTrue(alerts.level > 0);
end

function testAlertsHasDefaultLevels()
  local alerts = dofile('alerts.lua');
  unit.assertEquals(type(alerts.levels), "table");
  unit.assertTrue(#alerts.levels > 0);
end

function testAlertsHasDefaultLevelNames()
  for _,level in ipairs(dofile('alerts.lua').levels) do
    unit.assertEquals(type(level), "string");
  end
end

function testAlertsHasDefaultFormat()
  local alerts = dofile('alerts.lua');
  unit.assertEquals(type(alerts.format), "string");
  unit.assertStrContains(alerts.format, "{time}");
  unit.assertStrContains(alerts.format, "{level}");
  unit.assertStrContains(alerts.format, "{message}");
end

function testAlertsHasDefaultStdout()
  local alerts = dofile('alerts.lua');
  unit.assertEquals(type(alerts.stdout), "function");
end

function testAlertsCanCall()
  local alerts = dofile('alerts.lua');
  local called = false;
  alerts(alerts.level, function() called = true; end);
  unit.assertTrue(called);
end

function testAlertsNotCall()
  local alerts = dofile('alerts.lua');
  local called = false;
  alerts(alerts.level-1, function() called = true; end);
  unit.assertFalse(called);
end

function testAlertsCanFail()
  local alerts = dofile('alerts.lua');
  local success, error = alerts(alerts.level, function() error("TEST"); end);
  unit.assertFalse(success, tostring(error));
  unit.assertEquals(type(error), "string");
  unit.assertStrContains(error, "TEST");
end

function testAlertsCanSucceed()
  local alerts = dofile('alerts.lua');
  local success, error = alerts(alerts.level, function() return "TEST"; end);
  unit.assertTrue(success, tostring(error));
  unit.assertEquals(error, "TEST");
end

function testAlertsHasLevelMethods()
  local alerts = dofile('alerts.lua');
  alerts.levels = {"Test1", "Test2", "Test3"};
  for _,level in ipairs(alerts.levels) do
    unit.assertEquals(type(alerts[level]), "function");
  end
end

function testAlertsCanLog()
  local alerts = dofile('alerts.lua');
  local called = false;
  alerts.level = 0;
  alerts.levels = {"TEST"};
  alerts.stdout = function(message) called = true; end;
  local success, error = alerts:TEST();
  unit.assertTrue(success, tostring(error));
  unit.assertTrue(called);
end

function testAlertsCanNotLog()
  local alerts = dofile('alerts.lua');
  local called = false;
  alerts.level = 2;
  alerts.levels = {"TEST"};
  alerts.stdout = function(message) called = true; end;
  local success, error = alerts:TEST();
  unit.assertFalse(success, tostring(error));
  unit.assertEquals(error, "LEVEL_MISMATCH");
  unit.assertFalse(called);
end

function testLogUsesFormat()
  local alerts = dofile('alerts.lua');
  local expected = "%d+XXTESTXXTest";
  alerts.level = 0;
  alerts.levels = {"TEST"};
  alerts.format = "{time}XX{level}XX{message}";
  alerts.stdout = function(message) unit.assertStrMatches(message, expected); end;
  local success, message = alerts:TEST("Test");
  unit.assertTrue(success, tostring(message));
  unit.assertStrMatches(message, expected);
end

os.exit(unit.LuaUnit.run());