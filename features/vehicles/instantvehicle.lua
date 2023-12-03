require 'features';

local feature = NewFeature("instantvehicle", "Instant vehicle summon");

feature.description = {
    "No more running up to summoned vehicle!"
};

feature.needsEnabling = false;

feature.onDraw = function()
    if ImGui.Button("Toggle summoning mode") then
        Game.GetVehicleSystem():ToggleSummonMode();

        ShowNotification(CreateNotification(feature.name, "Summon mode toggled"));
    end
end

RegisterFeature("Vehicles", feature);
