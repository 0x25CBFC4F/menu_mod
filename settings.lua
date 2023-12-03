require 'table_dumper';

---@type table<string, any>
UserSettings = {};

local fileName = "settings.json";

-- Special thanks to anygoodname on NexusMods/Discord <3
function LoadUserSettings()
    local file = io.open(fileName, "r");

    if not file then
        return;
    end

    local jsonText = file:read("*a");
	file:close();

    local result, settings = pcall(
        function()
            return json.decode(jsonText);
        end);

	if result and type(settings) == 'table' then
        for k, v in pairs(settings) do
            UserSettings[k] = v;
        end

        return;
    end

    print("Failed to load user settings! Default settings will apply.");
end

function SaveUserSettings()
    local file = io.open(fileName, "w");

	if not file then
		return;
	end

	local jsonText = json.encode(UserSettings);
	file:write(jsonText);
	file:close();
end

---Asserts that specified value has expected type
---@param value any Value
---@param t string Type
function AssertTypeIsValid(value, t)
    if type(value) == t then return end;

    error("Value expected to be " .. t .. ", got: " .. type(value));
end

---Returns boolean from the user settings
---@param key string
---@param default boolean Default value
---@return boolean
function GetSettingBool(key, default)
    local value = UserSettings[key];

    if value == nil then
        return default;
    end

    AssertTypeIsValid(value, "boolean");

    return value;
end

---Returns number from the user settings
---@param key string
---@param default number Default value
---@return number
function GetSettingFloat(key, default)
    local value = UserSettings[key];

    if value == nil then
        return default;
    end

    AssertTypeIsValid(value, "number");

    return value;
end

---Sets setting to any value
---@param key string
---@param value any
function SetSetting(key, value)
    UserSettings[key] = value;
end