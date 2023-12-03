require 'features';

local updateTime = 1;
local lastUpdateTime = 0;

local feature = NewFeature("infinitehotbar", "Infinite hotbar items / cyberware");

feature.description = {
    "Now that's a lot of fun!"
};

---@type table<number, gamedataStatPoolType>
local statTypes = nil;

feature.needsEnabling = true;

feature.onInit = function ()
    statTypes = {
        gamedataStatPoolType.HealingItemsCharges,
        gamedataStatPoolType.OpticalCamoCharges,
        gamedataStatPoolType.ProjectileLauncherCharges,
        gamedataStatPoolType.CWMaskCharges,
        gamedataStatPoolType.GrenadesCharges
    };
end

-- Haven't found the better way yet, too lazy tbh
feature.onUpdate = function ()
    if (os.clock() - lastUpdateTime) <= updateTime then
        return;
    end

    lastUpdateTime = os.clock();

    local player = Game.GetPlayer();
    local entityId = player:GetEntityID();

    for _, statPoolType in pairs(statTypes) do
        Game.GetStatPoolsSystem():RequestChangingStatPoolValue(entityId, statPoolType, 100, player, false, false);
    end
end

RegisterFeature("Player", feature);
