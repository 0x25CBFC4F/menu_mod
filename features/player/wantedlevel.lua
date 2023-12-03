require 'features';

local requestedWantedLevel = 1;
local feature = NewFeature("wanted", "Wanted level");

feature.description = {
    "Sets how much police wants a piece of you."
};

---@param level number
local function ChangeHeatStage(level)
    local ps = Game.GetScriptableSystemsContainer():Get("PreventionSystem");
    ps:ChangeHeatStage(level, "");
    ShowNotification(CreateNotification(feature.name, "Wanted level set to " .. tostring(level)));
end

feature.setupHotkeys = function ()
    registerInput("clear_wanted_level", "Clear wanted level", function (pressed)
        if not pressed then return end;
        ChangeHeatStage(0);
    end)
end

feature.onDraw = function()
    local r, changed = ImGui.SliderInt("Wanted level", requestedWantedLevel, 1, 5);

    if changed then
        requestedWantedLevel = r;
    end

    if ImGui.Button("Set wanted level") then
        ChangeHeatStage(requestedWantedLevel);
    end

    ImGui.SameLine();

    if ImGui.Button("Clear wanted level") then
        ChangeHeatStage(0);
    end
end

RegisterFeature("Player", feature);
