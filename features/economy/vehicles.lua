require 'features';

local feature = NewFeature("allvehicles", "Vehicles");

feature.description = {
    "That button gonna put AutoFixer into bankruptcy."
};

feature.needsEnabling = false;

feature.onDraw = function()
    if ImGui.Button("Unlock all vehicles") then
        Game.GetVehicleSystem():EnableAllPlayerVehicles();

        ShowNotification(CreateNotification(feature.name, "All vehicles unlocked."));
    end
end

RegisterFeature("Economy", feature);
