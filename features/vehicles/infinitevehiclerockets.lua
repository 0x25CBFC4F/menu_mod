require 'features';

local updateTime = 3;
local lastUpdateTime = 0;

local feature = NewFeature("infinitevehiclerockets", "Infinite vehicle rockets");

feature.description = {
    "They say we come from the ocean. Why can't we breathe underneath the water then?"
};

feature.needsEnabling = true;

-- Haven't found the better way yet, too lazy tbh
feature.onUpdate = function ()
    if (os.clock() - lastUpdateTime) <= updateTime then
        return;
    end

    lastUpdateTime = os.clock();

    local player = Game.GetPlayer();
    Game.GetStatPoolsSystem():RequestChangingStatPoolValue(player:GetEntityID(), gamedataStatPoolType.VehicleMissileLauncherCharges, 100, player, false, false);
end

RegisterFeature("Vehicles", feature);
