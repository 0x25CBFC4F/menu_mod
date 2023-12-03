require 'features';

local updateTime = 0.5;
local lastUpdateTime = 0;

local feature = NewFeature("infiniteram", "Infinite RAM");

feature.description = {
    "Militech Canto Mk.6 gon' be happy."
};

feature.needsEnabling = true;

-- Haven't found the better way yet, too lazy tbh
feature.onUpdate = function ()
    if (os.clock() - lastUpdateTime) <= updateTime then
        return;
    end

    lastUpdateTime = os.clock();

    local player = Game.GetPlayer();
    Game.GetStatPoolsSystem():RequestChangingStatPoolValue(player:GetEntityID(), gamedataStatPoolType.Memory, 1000, player, false, false);
end

RegisterFeature("Player", feature);
