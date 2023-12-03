require 'feature';
require 'features';
require 'settings';
require 'vector_utils';

local forwards = false;
local backwards = false;
local left = false;
local right = false;
local upwards = false;
local downwards = false;
local lastUpdateTime = 0;
local currentZ = 0;

local feature = NewFeature("noclip", "NoClip/Fly Mode");

feature.description = {
    "This is a basic noclip with ability to move forwards, backwards, left, right, upwards or downwards.",
    "After enabling this feature make sure you bound the corresponding keys in the 'Bindings' section of CET.",
    "",
    "Tip: Unable to noclip through something? Increase the speed."
};

feature.getSettingsDescription = function ()
    return string.format("Speed: %.2f", GetSettingFloat("noclip.speed", 2));
end

feature.needsEnabling = true;

-- Storing original vertical coordinate when feature is enabled
feature.onEnable = function()
    currentZ = Game.GetPlayer():GetWorldPosition().z;
end

-- Hotkeys
feature.setupHotkeys = function(_)
    registerInput("noclip_forwards", "NoClip forwards", function (pressed)
        forwards = pressed;
    end)

    registerInput("noclip_backwards", "NoClip backwards", function(pressed)
        backwards = pressed;
    end);
    
    registerInput("noclip_upwards", "NoClip upwards", function (pressed)
        upwards = pressed;
    end)
    
    registerInput("noclip_downwards", "NoClip downwards", function(pressed)
        downwards = pressed;
    end)

    registerInput("noclip_left", "NoClip left", function(pressed)
        left = pressed;
    end);

    registerInput("noclip_right", "NoClip right", function(pressed)
        right = pressed;
    end);
    
    registerInput("noclip_increase_speed", "Increase NoClip speed", function (pressed)
        if not pressed then return end;
    
        SetSetting("noclip.speed", GetSettingFloat("noclip.speed", 2) + 0.5);
    end)
    
    registerInput("noclip_decrease_speed", "Decrease NoClip speed", function (pressed)
        if not pressed then return end;
    
        local newValue = GetSettingFloat("noclip.speed", 2) - 0.5;

        if newValue < 0 then
            newValue = 0;
        end

        SetSetting("noclip.speed", newValue);
    end)
end

feature.onUpdate = function(_)
    local times = Game.GetTimeSystem();

    if((times:GetGameTimeStamp() - lastUpdateTime) < 0.5) then
        return;
    end

    lastUpdateTime = times:GetGameTimeStamp();
    local player = Game.GetPlayer();

    if not player then
        return
    end;

    local nextVector = ToVector4({ x = 0, y = 0, z = 0, w = 1 });

    if upwards then
        local up = player:GetWorldUp();
        nextVector = AddVectors(nextVector, up);
    end

    if downwards then
        local down = NegateVector(player:GetWorldUp());
        nextVector = AddVectors(nextVector, down);
    end

    if forwards then
        nextVector = AddVectors(nextVector, player:GetWorldForward());
    end

    if backwards then
        local back = NegateVector(player:GetWorldForward());
        nextVector = AddVectors(nextVector, back);
    end

    if left then
        local left = NegateVector(player:GetWorldRight());
        nextVector = AddVectors(nextVector, left);
    end

    if right then
        nextVector = AddVectors(nextVector, player:GetWorldRight());
    end

    if not IsVectorEmpty(nextVector) then
        TeleportRelative(nextVector);
    else
        -- Keeping our Z coordinate steady
        local currentPosition = player:GetWorldPosition();
        local position = ToVector4({ x = currentPosition.x, y = currentPosition.y, z = currentZ, w = 1 });
        TeleportTo(position);
    end
end

feature.onDraw = function(_)
    local value, changed = ImGui.SliderFloat("NoClip speed", GetSettingFloat("noclip.speed", 2), 0, 15);

    if changed then
        SetSetting("noclip.speed", value);
    end
end

-- Functions
---@param vector Vector4
function TeleportRelative(vector)
    local tp = Game.GetTeleportationFacility();
    local player = Game.GetPlayer();
    local pos = player:GetWorldPosition();
    local orientation = player:GetWorldOrientation():ToEulerAngles();
    local speed = GetSettingFloat("noclip.speed", 2);

    local nxpos = pos.x + (vector.x * speed);
    local nypos = pos.y + (vector.y * speed);
    local nzpos = pos.z + (vector.z * speed);
    local npos = Vector4.new(nxpos, nypos, nzpos, pos.w);

    -- Storing new Z position
    currentZ = nzpos;

    tp:Teleport(Game.GetPlayer(), npos, orientation);
end

-- Functions
---@param position Vector4
function TeleportTo(position)
    local tp = Game.GetTeleportationFacility();
    local player = Game.GetPlayer();
    local orientation = player:GetWorldOrientation():ToEulerAngles();

    tp:Teleport(Game.GetPlayer(), position, orientation);
end

RegisterFeature("Movement", feature);
