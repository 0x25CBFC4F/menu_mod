require 'features';

local feature = NewFeature("infiniteammo", "Infinite ammo");

feature.description = {
    "You don't even need to reload!",
    "Tip: If infinite ammo persists across saves -",
    "be sure to disable this feature and switch to each of your weapons."
};

feature.needsEnabling = true;

---@type table<number, gameStatModifierData_Deprecated>
local statModifiers;

local function AddModifiers(wStatsObjId, gss)
    for _, value in pairs(statModifiers) do
        gss:AddModifier(wStatsObjId, value);
    end
end

local function RemoveModifiers(wStatsObjId, gss) 
    for _, value in pairs(statModifiers) do
        gss:RemoveModifier(wStatsObjId, value);
    end
end

---@param item ItemID?
---@param enabled boolean
---@returns nil
local function ApplyModifiers(item, enabled)
    if not item then return end;

    local gss = Game.GetStatsSystem();
    local wItemData = Game.GetTransactionSystem():GetItemData(Game.GetPlayer(), item);

    if wItemData == nil then
        return
    end

    -- Only enabling modifiers when it is request AND feature is enabled
    -- We're removing infinite ammo in any case
    enabled = enabled and feature.enabled;

    local wStatsObjId = wItemData:GetStatsObjectID();
    
    if enabled then
        AddModifiers(wStatsObjId, gss);
    else
        RemoveModifiers(wStatsObjId, gss);
    end
end

---@returns ItemID?
local function GetActiveWeaponItemId()
    local player = Game.GetPlayer();
    if not player then return end;
    local weapon = player:GetActiveWeapon();
    if not weapon then return end;

    return weapon:GetItemID();
end

feature.onInit = function ()
    statModifiers = {
        gameRPGManager.CreateStatModifier(gamedataStatType.NumShotsToFire, gameStatModifierType.Multiplier, 0)
    };

    Observe("PlayerPuppet", "OnItemEquipped",
        ---@param itemId ItemID
        function(_, _, itemId)
            ApplyModifiers(itemId, true);
        end);

    Observe("PlayerPuppet", "OnItemUnequipped",
        ---@param itemId ItemID
        function(_, _, itemId)
            ApplyModifiers(itemId, false);
        end);
end

feature.onEnable = function ()
    ApplyModifiers(GetActiveWeaponItemId(), true);
end

feature.onDisable = function ()
    ApplyModifiers(GetActiveWeaponItemId(), false);
end

RegisterFeature("Player", feature);
