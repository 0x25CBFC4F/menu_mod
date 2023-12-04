require 'features';

local feature = NewFeature("cwcapacity", "10k cyberware capacity");

feature.description = {
    "All cyberpsychos hate this one little trick.."
};

feature.needsEnabling = true;

feature.onEnable = function ()
    Game.GetStatsSystem():AddModifier(Game.GetPlayer():GetEntityID(), gameRPGManager.CreateStatModifier(gamedataStatType.Humanity, gameStatModifierType.Multiplier, 1000));
end

feature.onDisable = function ()
    Game.GetStatsSystem():RemoveModifier(Game.GetPlayer():GetEntityID(), gameRPGManager.CreateStatModifier(gamedataStatType.Humanity, gameStatModifierType.Multiplier, 1000));
end

RegisterFeature("Player", feature);
