require 'features';

local feature = NewFeature("vehiclegodmode", "Invulnerable vehicles");

feature.description = {
    "Not even grenades can ruin your day now!"
};

feature.needsEnabling = true;

local function EnableGodmode(enable)
    local player = Game.GetPlayer();

    if not player then return end;

    ---@type VehicleObject
    local vehicle = player:GetMountedVehicle();

    if not vehicle then
        return;
    end

    local gms = Game.GetGodModeSystem();
    local vId = vehicle:GetEntityID();
    local godmodeCount = gms:GetGodModeCount(vId, gameGodModeType.Invulnerable);
    local hasGodmode = godmodeCount > 0;

    if enable then
        if not hasGodmode then
            gms:AddGodMode(vId, gameGodModeType.Invulnerable, "");
        end
    else
        if hasGodmode then
            for _ = 1, godmodeCount, 1 do
                gms:RemoveGodMode(vId, gameGodModeType.Invulnerable, "");
            end
        end
    end
end

feature.onInit = function ()
    ObserveAfter("PlayerPuppet", "OnMountingEvent",
    function ()
        if not feature.enabled then
            return;
        end

        EnableGodmode(true);
    end);

    ObserveBefore("PlayerPuppet", "OnUnmountingEvent",
    function ()
        if not feature.enabled then
            return;
        end

        EnableGodmode(false);
    end);
end

feature.onEnable = function()
    EnableGodmode(true);
end

feature.onDisable = function ()
    EnableGodmode(false);
end

RegisterFeature("Vehicles", feature);
