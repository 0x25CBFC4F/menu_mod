require 'features';

local feature = NewFeature("johnyui", "Enable Johnny UI");

feature.description = {
    "After enabling please do not go near any Arasaka towers."
};

feature.needsEnabling = true;

feature.onEnable = function()
    local ui = Game.GetUISystem();
    ui:SetGlobalThemeOverride("Possessed");
end

feature.onDisable = function ()
    local ui = Game.GetUISystem();
    ui:ClearGlobalThemeOverride();
end

RegisterFeature("Misc", feature);
