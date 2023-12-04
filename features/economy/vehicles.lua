require 'features';
require 'settings';

local updateNeeded = true;
---@type table<number, VehicleCacheEntry> | nil
local playerVehicles = nil;

local yesNoMap = {
    [true] = "yes",
    [false] = "no"
};

local lockedMap = {
    [true] = "unlocked",
    [false] = "locked"
};

---@class VehicleCacheEntry
---@field id TweakDBID
---@field displayName string
---@field modelType string
---@field isArmored boolean
---@field type string
---@field owned boolean
local function NewVehicleCacheEntry(id, displayName, modelType, isArmored, type, owned)
    return {
        id = id,
        displayName = displayName,
        modelType = modelType,
        isArmored = isArmored,
        type = type,
        owned = owned
    };
end

local feature = NewFeature("allvehicles", "Vehicles");

feature.description = {
    "Vehicle management"
};

feature.needsEnabling = false;

---@param vehicle VehicleCacheEntry
---@param enabled boolean
local function SetVehicleEnabled(vehicle, enabled)
    local vehicleSystem = Game.GetVehicleSystem();
    
    if vehicleSystem:EnablePlayerVehicle(vehicle.id.value, enabled, false) then
        ShowNotification(CreateNotification(feature.name, string.format("Vehicle '%s' %s!", vehicle.displayName, lockedMap[enabled])));
        updateNeeded = true;
    end
end

local function LockAllVehicles()
    local vehicleSystem = Game.GetVehicleSystem();
    local ownedVehicles = vehicleSystem:GetPlayerUnlockedVehicles();

    for _, v in pairs(ownedVehicles) do
        vehicleSystem:EnablePlayerVehicle(v.recordID.value, false, false);
    end

    ShowNotification(CreateNotification(feature.name, "Locked " .. #ownedVehicles .. " vehicles!"));
    updateNeeded = true;
end

local function UnlockAllVehicles()
    Game.GetVehicleSystem():EnableAllPlayerVehicles();
    ShowNotification(CreateNotification(feature.name, "All vehicles unlocked."));
    updateNeeded = true;
end

feature.onDraw = function()
    local menuEnabled = GetSettingBool("allvehicles.showMenu", false);
    local value, changed = ImGui.Checkbox("Show vehicle manager", menuEnabled);

    if changed then
        SetSetting("allvehicles.showMenu", value);
    end

    if not menuEnabled or
       not ImGui.Begin("All vehicles") then
        return;
    end

    if not menuEnabled then
        SetSetting("allvehicles.showMenu", false);
    end

    if playerVehicles == nil then
        ImGui.Text("Building vehicle cache..");
        ImGui.End();
        return;
    end

    if ImGui.Button("Refresh vehicle list") then
        updateNeeded = true;
    end

    ImGui.SameLine();

    if ImGui.Button("Lock all vehicles") then
        LockAllVehicles();
    end

    ImGui.SameLine();

    if ImGui.Button("Unlock all vehicles") then
        UnlockAllVehicles();
    end

    --- ImGui::ImGuiTableFlags.Borders = 1920
    if not ImGui.BeginTable("VehicleListTable", 5, 1920) then
        return;
    end

    ImGui.TableSetupColumn("Name");
    ImGui.TableSetupColumn("Type");
    ImGui.TableSetupColumn("Model");
    ImGui.TableSetupColumn("Is armored?");
    ImGui.TableSetupColumn("Action");
    
    ImGui.TableHeadersRow();

    for _, vehicle in ipairs(playerVehicles) do
        ImGui.TableNextRow();
        
        if not vehicle.owned then
            ImGui.TableSetBgColor(ImGuiTableBgTarget.RowBg0, ImGui.GetColorU32(181/255, 103/255, 36/255, 1));
        else
            ImGui.TableSetBgColor(ImGuiTableBgTarget.RowBg0, ImGui.GetColorU32(39/255, 174/255, 96/255, 1));
        end

        ImGui.TableNextColumn();
        ImGui.Text(vehicle.displayName);

        ImGui.TableNextColumn();
        ImGui.Text(vehicle.type);

        ImGui.TableNextColumn();
        ImGui.Text(vehicle.modelType);

        ImGui.TableNextColumn();
        ImGui.Text(yesNoMap[vehicle.isArmored]);

        ImGui.TableNextColumn();

        if not vehicle.owned then
            if ImGui.Button("Add##"..vehicle.id.value) then
                SetVehicleEnabled(vehicle, true);
            end
        else
            if ImGui.Button("Remove##"..vehicle.id.value) then
                SetVehicleEnabled(vehicle, false);
            end
        end

        ImGui.SameLine();

        if ImGui.Button("Copy vehicle ID##"..vehicle.id.value) then
            ImGui.SetClipboardText(vehicle.id.value);
        end
    end

    ImGui.EndTable();
    ImGui.End();
end

feature.onUpdate = function ()
    if not updateNeeded then return end;

    updateNeeded = false;

    local vehicleSystem = Game.GetVehicleSystem();
    local allVehicles = vehicleSystem:GetPlayerVehicles();

    local vehicleKeys = {};
    local vehicles = {};

    for _, vehicle in ipairs(allVehicles) do
        local vehicleRecord = TweakDB:GetRecord(vehicle.recordID);

        local displayName = Game.GetLocalizedTextByKey(vehicleRecord:DisplayName());
        local manufacturer = vehicleRecord:Manufacturer():EnumName();
        local model = vehicleRecord:Model():EnumName();
        local isArmored = vehicleRecord:IsArmoredVehicle();
        local type = vehicleRecord:Type():EnumName();
        local vehicleName = manufacturer .. " " .. displayName;

        local cacheEntry = NewVehicleCacheEntry(vehicle.recordID, vehicleName, model, isArmored, type, vehicle.isUnlocked);

        table.insert(vehicleKeys, vehicleName);
        vehicles[vehicleName] = cacheEntry;
    end

    table.sort(vehicleKeys);
    playerVehicles = {};

    for _, vehicleKey in ipairs(vehicleKeys) do
        table.insert(playerVehicles, vehicles[vehicleKey]);
    end
end

RegisterFeature("Economy", feature);
