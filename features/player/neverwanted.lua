require 'features';

local feature = NewFeature("neverwanted", "Never wanted");

feature.description = {
    "Gives back on promise of a corrupt police in the game."
};

feature.needsEnabling = true;

feature.onEnable = function()
    local ps = Game.GetScriptableSystemsContainer():Get("PreventionSystem");

    ps:ChangeHeatStage(EPreventionHeatStage.Heat_0, "");
    ps:TogglePreventionSystem(false);
end

feature.onDisable = function ()
    local ps = Game.GetScriptableSystemsContainer():Get("PreventionSystem");
    ps:TogglePreventionSystem(true);
end

RegisterFeature("Player", feature);
