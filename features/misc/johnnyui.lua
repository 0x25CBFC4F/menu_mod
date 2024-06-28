require 'features';

local feature = NewFeature("johnyui", "Enable Johnny UI");

feature.description = {
    "After enabling please do not go near any Arasaka towers."
};

feature.needsEnabling = true;

feature.onInit = function()
    Override('PlayerSystem', 'OnLocalPlayerPossesionChanged',
    function (_, original)
        if feature.enabled then return end;
        return original();
    end);
end

feature.onEnable = function()
    local ui = Game.GetUISystem();
    ui:SetGlobalThemeOverride("Possessed");
end

feature.onDisable = function ()
    local ui = Game.GetUISystem();
    ui:ClearGlobalThemeOverride();
end

RegisterFeature("Misc", feature);
