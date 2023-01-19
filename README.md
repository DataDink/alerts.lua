# alerts.lua
*Simplistic alerting and logging*

## Usage

> ### Logging
> ```lua
> alerts:VERBOSE("A Noisy Message");
> alerts:INFO("A Notice");
> alerts:WARN("A Warning");
> alerts:ERROR("An Error");
> ```
>
> ### Debugging
> ```lua
> local rawData = getRawDataMethod();
> alerts("VERBOSE", function()
>   print("Dumping Raw Data:");
>   for cat,block in pairs(rawData) do
>     print("Category: "..cat);
>     for k,v in pairs(block) do
>       print(" - "..k..": "..v);
>     end
>   end
> end);
> ```
>
> ### Setting The Verbosity Level
> ```lua
> alerts.level="ERROR";
> alerts:WARN("Not Sent");
> alerts.level="WARN";
> alerts:WARN("Sent");
> ```
>
> ### Customizing Verbosity Levels
> ```lua
> alerts.levels={"NOISY", "INFORMATIVE", "CRITICAL"};
> alerts:NOISY("A Noisy Message");
> alerts:INFORMATIVE("An Informative Message");
> alerts:CRITICAL("A Critical Message");
> ```
>
> ### Customizing Log Formatting
> ```lua
> alerts.format = ">>{time}||{level}:::{message}<<";
> alerts:INFO("The Content"); -- Sends ">>123456789||INFO:::The Content<<" to alert.stdout
> ```
>
> ### Configuring Output
> ```lua
> alerts.stdout = function(message) print("My Message: "..message); end;
> alerts:INFO("The Message"); -- Prints "My Message: 123456789:INFO:The Message"
> ```

## API

> ### Logging
> *Controlling the verbosity of alerts and messaging*
>
> `(bool)sent, (string)result alerts:LEVEL((string)message)`
>
> #### Parameters
> <table>
>   <tr><th>LEVEL</th><td>function</td><td>
>     The property name can be any of the available verbosity levels.<br />
>     <em>Note: the available verbosity levels are configured with the <code>alerts.levels</code> property</em>
>   </td></tr>
>   <tr><th>message</th><td>string</td><td>
>     The content for the log<br />
>     <em>Note: the output format is configured with the <code>alerts.format</code> property</em><br />
>     <em>Note: the output method is configured with the <code>alerts.stdout</code> property</em>
>   </td></tr>
> </table>
>
> #### Returns
> <table>
>   <tr><th>sent</th><td>bool</td><td>
>     True if the message was sent
>   </td></tr>
>   <tr><th>result</th><td>string</td><td>
>     On fail this will contain the reason/error, otherwise the formatted message
>   </td></tr>
> </table>
>
> ### Debugging
> *Conditional processing based on verbosity*
>
> #### Syntax
> `(bool)executed[, ...] alerts((string/number)level, (function)action, ...)`
>
> #### Parameters
> <table>
>   <tr><th>level</th><td>string or number</td><td>
>     Specifies the level required for the process to be executed<br />
>     <em>Note: the current level is configured with the <code>alerts.level</code> property</em><br />
>     <em>Note: the available levels are configured with the <code>alerts.levels</code> property</em><br />
>   </td></tr>
>   <tr><th>action</th><td>function</td><td>
>     The action to be taken.
>   </td></tr>
>   <tr><th>...</th><td>args/any</td><td>
>     The arguments to be passed to the action when executed.
>   </td></tr>
> </table>
>
> #### Returns
> <table>
>   <tr><th>executed</th><td>bool</td><td>
>     True if the action was executed<br />
>     <em>Note: if false, a second return value will hold the reason or error</em>
>   </td></tr>
>   <tr><th>...</th><td>args/any</td><td>
>     Return values from the action (if any)
>   </td></tr>
> </table>
>
> ### Configuration
> *Customize the API*
>
> #### Settings
> <table>
>   <tr><th>alerts.level</th><td>string or number</td><td>Configures the current verbosity level</td></tr>
>   <tr><th>alerts.levels</th><td>table</td><td>
>     Configures the available verbosity levels<br /> 
>     (e.g. alerts.levels={"ONE", "TWO", "THREE"})</td></tr>
>   <tr><th>alerts.format</th><td>string</td><td>
>     Configures the log output format.<br /> 
>     (e.g. alerts.format=">>{level}>>{time}>>{message}>>")
>     <table>
>       <tr><th>time</th><td>The milisecond timestamp of the log</td></tr>
>       <tr><th>level</th><td>The verbosity level of the log</td></tr>
>       <tr><th>message</th><td>The message content of the log</td></tr>
>     </table>
>   </td></tr>
>   <tr><th>alerts.stdout</th><td>function</td><td>The function that logs will be sent to (defaults to <code>print</code>)</td></tr>
> </table>