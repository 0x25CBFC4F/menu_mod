require 'features';

local pointsTypes;

local feature = NewFeature("progress", "Development points");

feature.description = {
    "Allows you to manage player's development points."
};

feature.needsEnabling = false;

feature.onInit = function ()
    pointsTypes = {
        [1] = {
            text = "Attribute points",
            type = gamedataDevelopmentPointType.Attribute,
            val = 1
        },
        [2] = {
            text = "Perk points",
            type = gamedataDevelopmentPointType.Primary,
            val = 1
        },
        [3] = {
            text = "Relic points",
            type = gamedataDevelopmentPointType.Espionage,
            val = 1
        }
    };
end

feature.onDraw = function ()
    for i, pointDescriptor in ipairs(pointsTypes) do
        if ImGui.Button("+##" .. i) then
            local player = Game.GetPlayer();

            local developmentData = PlayerDevelopmentSystem.GetInstance(player):GetDevelopmentData(player);
            developmentData:AddDevelopmentPoints(pointDescriptor.val, pointDescriptor.type);

            ShowNotification(CreateNotification(feature.name, string.format("Added %i %s", pointDescriptor.val, pointDescriptor.text)));
        end

        ImGui.SameLine();

        if ImGui.Button("-##" .. i) then
            local player = Game.GetPlayer();

            local developmentData = PlayerDevelopmentSystem.GetInstance(player):GetDevelopmentData(player);
            developmentData:SpendDevelopmentPoint(pointDescriptor.type, pointDescriptor.val);

            ShowNotification(CreateNotification(feature.name, string.format("Removed %i %s", pointDescriptor.val, pointDescriptor.text)));
        end

        ImGui.SameLine();

        local value, changed = ImGui.SliderInt(pointDescriptor.text, pointDescriptor.val, 1, 1000);

        if changed then
            pointDescriptor.val = value;
        end
    end
end

RegisterFeature("Progress", feature);