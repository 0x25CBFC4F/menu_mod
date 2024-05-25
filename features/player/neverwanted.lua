require 'features';

local feature = NewFeature("neverwanted", "Never wanted");

feature.description = {
    "Gives back on promise of a corrupt police in the game."
};

feature.needsEnabling = true;

feature.onInit = function()
    Override("PreventionSystem", "CanPreventionReactToInput", 
    ---@param this PreventionSystem
    function(this, wrappedMethod)
        if not feature.enabled then
            return wrappedMethod();
        end;

        return false;
    end);
end

feature.onEnable = function()
    local ps = Game.GetScriptableSystemsContainer():Get("PreventionSystem");

    ps:CancelAllDelayedEvents();
    ps:ChangeHeatStage(EPreventionHeatStage.Heat_0, "");
end

RegisterFeature("Player", feature);
