require 'features'
require 'settings'

local feature = NewFeature("customvehiclelights", "Custom vehicle lights")

feature.description = {
    "Even fancier??"
}

feature.needsEnabling = true;

local updateTime = 1;
local lastUpdateTime = 0;

local r = 255;
local g = 255;
local b = 255;
local a = 255;

feature.onInit = function ()
    r = GetSettingFloat("customvehiclelights.red", 255);
    g = GetSettingFloat("customvehiclelights.green", 255);
    b = GetSettingFloat("customvehiclelights.blue", 255);
    a = GetSettingFloat("customvehiclelights.alpha", 255);
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

    local color = Color.new();
    color.Red = math.floor(r);
    color.Green = math.floor(g);
    color.Blue = math.floor(b);
    color.Alpha = math.floor(a);

    if vehicle.vehicleComponent and vehicle.vehicleComponent.vehicleController then
        vehicle.vehicleComponent.vehicleController:SetLightColor(vehicleELightType.Default, color, 0);
    end
end

feature.onDraw = function ()
    if not feature.enabled then return end;

    local floats, changed = ImGui.ColorEdit4("<- Click here", {r/255, g/255, b/255, a/255});

    if changed then
        r = floats[1] * 255;
        g = floats[2] * 255;
        b = floats[3] * 255;
        a = floats[4] * 255;

        SetSetting("customvehiclelights.red", r);
        SetSetting("customvehiclelights.green", g);
        SetSetting("customvehiclelights.blue", b);
        SetSetting("customvehiclelights.alpha", a);
    end
end

feature.onDisable = function()
    ---@type VehicleObject
    local vehicle = Game.GetPlayer():GetMountedVehicle();

    if vehicle.vehicleComponent and vehicle.vehicleComponent.vehicleController then
        vehicle.vehicleComponent.vehicleController:ResetLightColor(vehicleELightType.Default, 0);
    end
end

RegisterFeature("Vehicles", feature)
