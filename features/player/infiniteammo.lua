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
---@returns nil
local function ApplyModifiers(item)
    if not item then return end;

    local enabled = feature.enabled;

    local gss = Game.GetStatsSystem();
    local wItemData = Game.GetTransactionSystem():GetItemData(Game.GetPlayer(), item);

    if wItemData == nil then
        return
    end

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

    local player = Game.GetPlayer();
    Game.GetStatPoolsSystem():RequestChangingStatPoolValue(player:GetEntityID(), gamedataStatPoolType.Health, -100, player, false, false);

    return weapon:GetItemID();
end

feature.onInit = function ()
    statModifiers = {
        gameRPGManager.CreateStatModifier(gamedataStatType.NumShotsToFire, gameStatModifierType.Multiplier, 0)
    };

    Observe("PlayerPuppet", "OnItemEquipped",
        ---@param itemId ItemID
        function(_, _, itemId)
            ApplyModifiers(itemId);
        end);

    Observe("PlayerPuppet", "OnItemUnequipped",
        ---@param itemId ItemID
        function(_, _, itemId)
            ApplyModifiers(itemId);
        end);
end

feature.onEnable = function ()
    ApplyModifiers(GetActiveWeaponItemId());
end

feature.onDisable = function ()
    ApplyModifiers(GetActiveWeaponItemId());
end

RegisterFeature("Player", feature);
