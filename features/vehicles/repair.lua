require 'features';

local feature = NewFeature("vehiclerepair", "Repair");

feature.description = {
    "Not even grenades can ruin your day now!"
};

feature.needsEnabling = false;

local function Repair()
    ---@type VehicleObject
    local vehicle = Game.GetPlayer():GetMountedVehicle();

    if not vehicle then
        return;
    end

    vehicle.vehicleComponent:RepairVehicle();
end

feature.onDraw = function ()
    if ImGui.Button("Repair current vehicle") then
        Repair();
    end

    ImGui.SameLine();

    ImGui.Text("(not going to repair parts that fell off)");
end

RegisterFeature("Vehicles", feature);
