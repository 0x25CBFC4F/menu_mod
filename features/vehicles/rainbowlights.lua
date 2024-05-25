require 'features'

local feature = NewFeature("rainbowlights", "Rainbow vehicle lights")

feature.description = {
    "Fancy!"
}

feature.needsEnabling = true;

local r = 255;
local g = 0;
local b = 0;
local updateTime = 0.01;
local lastUpdateTime = 0;

local function getNextColor()
    if r > 0 and b == 0 then
        r = r - 1;
        g = g + 1;
    elseif g > 0 and r == 0 then
        g = g - 1;
        b = b + 1;
    elseif b > 0 and g == 0 then
        r = r + 1;
        b = b - 1;
    end

    local color = Color.new();
    color.Red = r;
    color.Green = g;
    color.Blue = b;
    color.Alpha = 255;

    return color;
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

    local nextColor = getNextColor();

    if vehicle.vehicleComponent and vehicle.vehicleComponent.vehicleController then
        vehicle.vehicleComponent.vehicleController:SetLightColor(vehicleELightType.Default, nextColor, 0);
    end
end

RegisterFeature("Vehicles", feature)
