require 'features';

local pointsTypes;

local feature = NewFeature("progress", "Proficiencies");

feature.description = {
    "Allows you to manage player's proficiencies."
};

feature.needsEnabling = false;

feature.onInit = function ()
    pointsTypes = {
        [1] = {
            text = "Headhunter",
            type = gamedataProficiencyType.CoolSkill,
            val = 1
        },
        [2] = {
            text = "Netrunner",
            type = gamedataProficiencyType.IntelligenceSkill,
            val = 1
        },
        [3] = {
            text = "Shinobi",
            type = gamedataProficiencyType.ReflexesSkill,
            val = 1
        },
        [4] = {
            text = "Solo",
            type = gamedataProficiencyType.StrengthSkill,
            val = 1
        },
        [5] = {
            text = "Engineer",
            type = gamedataProficiencyType.TechnicalAbilitySkill,
            val = 1
        }
    };
end

feature.onDraw = function ()
    for i, pointDescriptor in ipairs(pointsTypes) do
        if ImGui.Button("Set##" .. i) then
            local player = Game.GetPlayer();

            local developmentData = PlayerDevelopmentSystem.GetInstance(player):GetDevelopmentData(player);
            developmentData:SetLevel(pointDescriptor.type, pointDescriptor.val, telemetryLevelGainReason.Ignore);

            ShowNotification(CreateNotification(feature.name, string.format("Set %s to %i", pointDescriptor.text, pointDescriptor.val)));
        end

        ImGui.SameLine();

        local value, changed = ImGui.SliderInt(pointDescriptor.text, pointDescriptor.val, 1, 60);

        if changed then
            pointDescriptor.val = value;
        end
    end
end

RegisterFeature("Progress", feature);