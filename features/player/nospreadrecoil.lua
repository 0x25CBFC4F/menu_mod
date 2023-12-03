require 'features';

local feature = NewFeature("nospreadrecoil", "No spread/recoil");

feature.description = {
    "Top-notch accuracy."
};

feature.needsEnabling = true;

---@type table<number, gameStatModifierData_Deprecated>
local statModifiers;

local function AddModifiers(wStatsObjId, gss)
    if statModifiers == nil then
        return;
    end

    for _, value in pairs(statModifiers) do
        gss:AddModifier(wStatsObjId, value);
    end
end

function RemoveModifiers(wStatsObjId, gss) 
    for _, value in pairs(statModifiers) do
        gss:RemoveModifier(wStatsObjId, value);
    end
end

---@param item ItemID?
---@param enabled boolean
---@returns nil
local function ApplyModifier(item, enabled)
    if not item then return end;
    if not feature.enabled then return end;

    local gss = Game.GetStatsSystem();
    local wItemData = Game.GetTransactionSystem():GetItemData(Game.GetPlayer(), item);

    if wItemData == nil then return end

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
        RPGManager.CreateStatModifier(gamedataStatType.SpreadMinX, gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.SpreadMinY, gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.SpreadMaxX, gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.SpreadMaxY, gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.SpreadAdsMinX, gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.SpreadAdsMinY, gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.SpreadAdsMaxX, gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.SpreadAdsMaxY, gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.RecoilKickMin, gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.RecoilKickMax, gameStatModifierType.Multiplier, 0),
        RPGManager.CreateStatModifier(gamedataStatType.RecoilUseDifferentStatsInADS, gameStatModifierType.Multiplier, 0)
    };

    Observe("PlayerPuppet", "OnItemEquipped",
        ---@param itemId ItemID
        function(_, _, itemId)
            if not feature.enabled then return end;
            ApplyModifier(itemId, true);
        end);

    Observe("PlayerPuppet", "OnItemUnequipped",
        ---@param itemId ItemID
        function(_, _, itemId)
            ApplyModifier(itemId, false);
        end);
end

feature.onEnable = function ()
    ApplyModifier(GetActiveWeaponItemId(), true);
end

feature.onDisable = function ()
    ApplyModifier(GetActiveWeaponItemId(), false);
end

RegisterFeature("Player", feature);
