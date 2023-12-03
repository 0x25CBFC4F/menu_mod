---@class Feature
---@field id string Feature identifier. For internal use only.
---@field name string Feature name. Shown in the tab title.
---@field description string[] Feature description. Shown in the menu.
---@field needsEnabling boolean Does this feature needs 'enable' checkbox?
---@field alwaysUpdating boolean Does this feature needs to be always updated?
---@field enabled boolean Is this feature enabled?
---@field onInit function Init hook.
---@field onEnable function Enable hook.
---@field onDisable function Disable hook.
---@field getSettingsDescription function This is a function that should return a table of settings (and their values) current feature has.
---@field setupHotkeys function Setup hotkeys hook.
---@field onDraw function Draw hook.
---@field onUpdate function Update hook.
---@return Feature
function NewFeature(id, name)
    return {
        id = id,
        name = name,
        description = {},
        needsEnabling = false,
        alwaysUpdating = false,
        enabled = true,
        onInit = function() end,
        onEnable = function() end,
        onDisable = function() end,
        getSettingsDescription = function() end,
        setupHotkeys = function() end,
        onDraw = function() end,
        onUpdate = function() end
    };
end
