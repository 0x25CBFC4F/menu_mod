-- Thank you, psiberx <3
local gameSession = require 'GameSession';

require 'feature';
require 'features';
require 'settings';

require 'notifications';

-- Movement
require 'features/movement/noclip';

-- Player
require 'features/player/godmode';
require 'features/player/wantedlevel';
require 'features/player/neverwanted';
require 'features/player/infiniteammo';
require 'features/player/nospreadrecoil';
require 'features/player/infinitestamina';
require 'features/player/infiniteoxygen';
require 'features/player/infiniteram';
require 'features/player/infiniteconsumables';
require 'features/player/cwcapacity';
require 'features/player/noreveal';

-- Economy
require 'features/economy/money';
require 'features/economy/vehicles';
require 'features/economy/godvendor';

-- Progress
require 'features/progress/level';
require 'features/progress/points';
require 'features/progress/proficiency';

-- Vehicles
require 'features/vehicles/infinitevehiclerockets';
require 'features/vehicles/vehiclegodmode';
require 'features/vehicles/instantvehicle';
require 'features/vehicles/repair';
require 'features/vehicles/instantenterexit';
require 'features/vehicles/rainbowlights';
require 'features/vehicles/customvehiclelights';
require 'features/vehicles/lightsbrightness';

-- Misc
require 'features/misc/johnnyui';

SortSections();

local mainSection = "MAIN";
local selectedSection = mainSection;

table.insert(SectionKeysSorted, 1, mainSection);

local menuShown = false;
local playerIsInGame = false;

---Helper function for enabling/disabling features
---@param feature Feature
---@param enabled boolean
function SetFeatureEnabled(feature, enabled)
    feature.enabled = enabled;
    SetSetting(feature.id .. ".enabled", feature.enabled);

    if enabled then
        feature:onEnable();
        ShowNotification(CreateNotification(feature.name, "Feature was enabled."));
    else
        feature:onDisable();
        ShowNotification(CreateNotification(feature.name, "Feature was disabled."));
    end
end

-- Setting up hotkeys
for _, feature in pairs(Features) do

    if(feature.needsEnabling) then
        registerInput("toggle_" .. feature.id, "Toggle " .. feature.name, function (pressed)
            if not pressed then return end;
            SetFeatureEnabled(feature, not feature.enabled);
        end)
    end

    feature:setupHotkeys();
end

-- Functions for enabling/disabling features on game session change
function GameHasStarted()
    playerIsInGame = true;

    for _, feature in pairs(Features) do
        if feature.enabled then
            feature:onEnable();
        end
    end
end

function GameHasEnded()
    playerIsInGame = false;

    for _, feature in pairs(Features) do
        if feature.enabled then
            feature:onDisable();
        end
    end

    selectedSection = mainSection;
end

-- Settings load/save
registerForEvent("onInit", function ()
    LoadUserSettings();

    for _, feature in pairs(Features) do
        local isEnabled = GetSettingBool(feature.id .. ".enabled", false);
        feature.enabled = isEnabled;
        feature:onInit();
    end

    gameSession.Listen(gameSession.Event.Start, GameHasStarted);
    gameSession.Listen(gameSession.Event.End, GameHasEnded);

    if gameSession.IsLoaded() then
        GameHasStarted();
    end
end);

registerForEvent("onShutdown", function ()
    SaveUserSettings();
end);

-- Menu handling
registerForEvent("onOverlayOpen", function()
    menuShown = true;
end);

registerForEvent("onOverlayClose", function()
    menuShown = false;
end);

-- Combined flags of:
-- - ImGuiWindowFlags.NoBackground
-- - ImGuiWindowFlags.NoTitleBar
-- - ImGuiWindowFlags.AlwaysAutoResize
local featureWindowFlags = 193;

local function DrawMainSection()
    ImGui.Text("Hey! Thank you for using my mod.");
    ImGui.Text("Also don't forget to check 'Bindings' section of CET.");
    ImGui.Text("Credits: 3xnull (me), psiberx, CP2077 modding\ncommunity on discord.");

    ImGui.NewLine();

    ImGui.Text("Force load/save settings:");

    if ImGui.Button("Force load settings") then
        LoadUserSettings();
    end

    ImGui.SameLine();

    if ImGui.Button("Force save settings") then
        SaveUserSettings();
    end

    ImGui.NewLine();

    local newValue, changed = ImGui.Checkbox("Show 'Features/Settings' window", GetSettingBool("menu.showFeatureStatus", true));

    if changed then
        SetSetting("menu.showFeatureStatus", newValue);
    end;

    local value, changed = ImGui.Checkbox("Bigger navigation bar (for 2K resolution and up)", GetSettingBool("menu.biggerNavBar", false));

    if changed then
        SetSetting("menu.biggerNavBar", value);
    end

    ImGui.NewLine();

    if not playerIsInGame then
        ImGui.NewLine();
        ImGui.TextColored(255, 0, 0, 1, "Please load your save to reveal other tabs.");
    end
end

local function DrawFeaturesMenu()
    if GetSettingBool("menu.showFeatureStatus", true) and
        playerIsInGame and
        ImGui.Begin("Features", featureWindowFlags) then

        for _, section in ipairs(SectionKeysSorted) do
            local anyEnableable = false;
            local features = Sections[section];

            if features == nil then
                goto continue;
            end

            for _, feature in ipairs(features) do
                if feature.needsEnabling then
                    anyEnableable = true;
                    goto found;
                end
            end

            ::found::

            if anyEnableable then
                ImGui.Text(section);
                ImGui.Text("=======================");

                for _, feature in pairs(features) do
                    if not feature.needsEnabling then goto continue end;

                    local colorR = 255;
                    local colorG = 0;

                    if feature.enabled then
                        colorR = 0;
                        colorG = 255;
                    end

                    local text = feature.name;
                    local settings = feature:getSettingsDescription();

                    if settings ~= nil then
                        text = text .. " (" .. settings .. ")";
                    end

                    ImGui.TextColored(colorR, colorG, 0, 1, text);

                    ::continue::
                end
            end;

            ImGui.NewLine();

            ::continue::
        end

        ImGui.End();
    end
end

registerForEvent("onDraw", function ()
    OnToastDraw();
    DrawFeaturesMenu();

    if not menuShown then return end;

    ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 15, 15);

    if not ImGui.Begin("Menu mod") then
        ImGui.PopStyleVar();
        return;
    end

    ImGui.SetWindowSize(600, 600, ImGuiCond.Appearing);

    if not ImGui.BeginTable("Table", 2) then
        return;
    end

    local navSize = 100;
    local navItemSpacing = 15;

    if GetSettingBool("menu.biggerNavBar", false) then
        navSize = 300;
        navItemSpacing = 30;
    end

    ImGui.PushStyleVar(ImGuiStyleVar.ItemSpacing, 15, navItemSpacing);

    ImGui.TableSetupColumn("nav", ImGuiTableColumnFlags.WidthFixed, navSize);
    --ImGui.TableSetupColumn("cat", ImGuiTableColumnFlags.WidthFixed, 400);
    ImGui.TableNextColumn();

    if playerIsInGame then
        for _, sectionKey in ipairs(SectionKeysSorted) do
            ImGui.Separator();

            if ImGui.Selectable(sectionKey) then
                selectedSection = sectionKey;
            end
        end
    else
        ImGui.Separator();
        ImGui.Selectable(mainSection);
    end

    ImGui.Separator();
    ImGui.PopStyleVar();
    ImGui.TableNextColumn();
    ImGui.Indent();

    -- A shitty way to do it, but I don't want to extend sections
    -- with a custom onDraw methods
    if selectedSection == mainSection then
        DrawMainSection();

        ImGui.PopStyleVar();
        ImGui.EndTable();
        ImGui.End();

        return;
    end

    ImGui.Text(selectedSection);
    ImGui.NewLine();

    local features = Sections[selectedSection];
    ---@type table<number, Feature>
    local simpleFeatures = {};
    ---@type table<number, Feature>
    local complexFeatures = {};

    for _, feature in ipairs(features) do
        if feature.needsEnabling then
            table.insert(simpleFeatures, feature);
        else
            table.insert(complexFeatures, feature);
        end
    end

    local featuresDrawn = 1;

    ImGui.PushStyleVar(ImGuiStyleVar.ItemSpacing, 15, 10);

    for _, feature in ipairs(simpleFeatures) do
        featuresDrawn = featuresDrawn + 1;

        local value, pressed = ImGui.Checkbox(feature.name, feature.enabled);

        if ImGui.IsItemHovered() then
            ImGui.PopStyleVar(2);

            ImGui.BeginTooltip();
            for _, s in ipairs(feature.description) do
                ImGui.Text(s);
            end
            ImGui.EndTooltip();

            ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 25, 25);
            ImGui.PushStyleVar(ImGuiStyleVar.ItemSpacing, 15, 10);
        end

        feature:onDraw();

        if pressed then
            SetFeatureEnabled(feature, value);
        end
    end

    ImGui.PopStyleVar();

    for _, feature in ipairs(complexFeatures) do
        if ImGui.CollapsingHeader(feature.name) then
            for _, s in ipairs(feature.description) do
                ImGui.Text(s);
            end

            feature:onDraw();
        end
    end

    ImGui.PopStyleVar();
    ImGui.EndTable();
    ImGui.End();
end)

-- Updates handling
registerForEvent("onUpdate", function ()
    if not playerIsInGame then return end;
    if Game.GetPlayer() == nil then return end;

    for _, feature in pairs(Features) do
        if feature.needsEnabling and not feature.enabled then goto continue end;

        local result = pcall(function() feature:onUpdate(); end);

        if not result then
            print("Feature " .. feature.id .. " crashed!");
        end

        ::continue::
    end
end)

