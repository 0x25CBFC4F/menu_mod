require 'features';

local currentLevel = 1;
local currentStreetCred = 1;

local feature = NewFeature("progress", "Level");

feature.description = {
    "Allows you to manage player's levels."
};

feature.needsEnabling = false;

feature.onDraw = function ()
    local value, changed = ImGui.SliderInt("Player level", currentLevel, 1, 60);

    if changed then
        currentLevel = value;
    end

    local value, changed = ImGui.SliderInt("Street cred", currentStreetCred, 1, 50);

    if changed then
        currentStreetCred = value;
    end

    if ImGui.Button("Set player level") then
        Game.SetLevel("Level", currentLevel, 1);
        ShowNotification(CreateNotification(feature.name, string.format("Player's level set to %i", currentLevel)));
    end

    ImGui.SameLine();

    if ImGui.Button("Set street cred") then
        Game.SetLevel("StreetCred", currentStreetCred, 1);
        ShowNotification(CreateNotification(feature.name, string.format("Player's street cred set to %i", currentStreetCred)));
    end
end

RegisterFeature("Progress", feature);