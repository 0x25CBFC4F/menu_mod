require 'features';

local amount = 1;

local feature = NewFeature("money", "Money");

feature.description = {
    "Johnny would dislike your love for money."
};

feature.needsEnabling = false;

---Sends EquipmentUIBBRequest event
---@param player PlayerPuppet
function SendUIEvent(player)
    local request = EquipmentUIBBRequest.new();
    request.owner = player;
    Game.GetScriptableSystemsContainer():Get("EquipmentSystem"):QueueRequest(request);
end

feature.onDraw = function()
    local value, used = ImGui.SliderInt("Amount", amount, 1, 500000);

    if used then
        amount = value;
    end

    if ImGui.Button("Add money") then
        local player = Game.GetPlayer();

        Game.GetTransactionSystem():GiveItem(player, ItemID.FromTDBID(TDBID.Create("Items.money")), amount);
        SendUIEvent(player);

        ShowNotification(CreateNotification(feature.name, string.format("Added %i V-Bucks.", amount)));
    end

    ImGui.SameLine();

    if ImGui.Button("Remove money") then
        local player = Game.GetPlayer();

        Game.GetTransactionSystem():RemoveItem(player, ItemID.FromTDBID(TDBID.Create("Items.money")), amount);
        SendUIEvent(player);

        ShowNotification(CreateNotification(feature.name, string.format("Removed %i V-Bucks.", amount)));
    end

    ImGui.SameLine();

    if ImGui.Button("Rob me!") then
        local player = Game.GetPlayer();

        Game.GetTransactionSystem():RemoveItem(player, ItemID.FromTDBID(TDBID.Create("Items.money")), 99999999999);
        SendUIEvent(player);

        ShowNotification(CreateNotification(feature.name, "Arasaka called. Said they want your money."));
    end
end

RegisterFeature("Economy", feature);
