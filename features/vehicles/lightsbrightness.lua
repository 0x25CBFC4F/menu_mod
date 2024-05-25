require 'features'
require 'settings'

local feature = NewFeature("lightsbrightness", "Custom vehicle lights brightness");

feature.description = {
    "Blind everyone with this one simple trick!"
}

feature.needsEnabling = true;

local updateTime = 1;
local lastUpdateTime = 0;

local brightness = 1;

feature.onInit = function ()
    brightness = GetSettingFloat("lightsbrightness.brightness", 1);
end

feature.onUpdate = function ()
    if (os.clock() - lastUpdateTime) <= updateTime then
        return;
    end

    lastUpdateTime = os.clock();

    ---@type VehicleObject
    local vehicle = Game.GetPlayer():GetMountedVehicle();

    if not vehicle then
        return;
    end

    if vehicle.vehicleComponent and vehicle.vehicleComponent.vehicleController then
        vehicle.vehicleComponent.vehicleController:SetLightStrength(vehicleELightType.Default, brightness, 0);
    end
end

feature.onDraw = function ()
    if not feature.enabled then return end;

    local newBrightness, changed = ImGui.SliderFloat("Brightness", brightness, 1, 1000);

    if changed then
        brightness = newBrightness;
        SetSetting("lightsbrightness.brightness", newBrightness);
    end

    ImGui.SameLine();

    if ImGui.Button(" + ") then
        brightness = math.min(brightness + 1.0, 1000);
    end

    ImGui.SameLine();

    if ImGui.Button(" - ") then
        brightness = math.max(brightness - 1.0, 0);
    end
end

feature.onDisable = function()
    ---@type VehicleObject
    local vehicle = Game.GetPlayer():GetMountedVehicle();

    if vehicle.vehicleComponent and vehicle.vehicleComponent.vehicleController then
        vehicle.vehicleComponent.vehicleController:ResetLightStrength(vehicleELightType.Default, 0);
    end
end

RegisterFeature("Vehicles", feature)
