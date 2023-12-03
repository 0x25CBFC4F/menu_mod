require 'features';

local feature = NewFeature("vehicleinstantenterexit", "Instant vehicle enter/exit");

feature.description = {
    "Feels like I ran out of the jokes"
};

feature.needsEnabling = true;

-- Haven't found the better way yet, too lazy tbh
feature.onInit = function ()
    Override("VehicleDataPackage_Record", "Entering",
    ---@param _ VehicleDataPackage_Record
    ---@param wrapped fun(): number
    function (_, wrapped)
        if not feature.enabled then
            return wrapped();
        end

        return 0;
    end);

    Override("VehicleDataPackage_Record", "ExitDelay",
    ---@param _ VehicleDataPackage_Record
    ---@param wrapped fun(): number
    function (_, wrapped)
        if not feature.enabled then
            return wrapped();
        end

        return 0;
    end);
end

RegisterFeature("Vehicles", feature);
