--- Notifications helper.

---@enum NotificationType Type of the toast
local NotificationType = {
    ["Notification"] = 1,
    ["Progress"] = 2
};

NotificationSettings = {
    NotificationExpirationSeconds = 2
};

---@type table<number, NotificationToast | ProgressNotification>
local currentNotifications = {};

---@class NotificationToast Toast notification
---@field id number Notification ID
---@field type NotificationType Type of the toast - always ToastType.Notification
---@field title string Title of the notification
---@field text string Text of the notification
---@field created number Creation time
function CreateNotification(title, text)
    return {
        id = math.random() * 100000000000000,
        type = NotificationType.Notification,
        title = title,
        text = text,
        created = os.clock()
    };
end

---@class ProgressNotification Progress notification
---@field id number Notification ID
---@field type NotificationType Type of the toast - always ToastType.Notification
---@field title string Title of the notification
---@field text string Text of the notification
---@field progress number Current progress (0.0 - 1.0)
---@field created number Creation time
function CreateProgressNotification(title, text)
    return {
        id = math.random() * 100000000000000,
        type = NotificationType.Progress,
        title = title,
        text = text,
        progress = 0,
        created = os.clock()
    };
end

---Shows toast to the user
---@param notification NotificationToast | ProgressNotification
function ShowNotification(notification)
    if currentNotifications[notification.id] ~= nil then
        print(string.format("Notification warning: Notification with ID #%i (%s) is already shown!", notification.id, notification.title));
        return;
    end

    currentNotifications[notification.id] = notification;
end

-- This variable is combined flags of
-- - ImGuiWindowFlags.NoFocusOnAppearing
-- - ImGuiWindowFlags.NoMove
-- - ImGuiWindowFlags.AlwaysAutoResize
-- - ImGuiWindowFlags.NoCollapse
local windowFlags = 4196;

function OnToastDraw()
    local screenWidth, screenHeight = GetDisplayResolution();
    local currentY = screenHeight - 10;

    local sorted = {};

    for _, notification in pairs(currentNotifications) do
        table.insert(sorted, notification);
    end

    table.sort(sorted, function (a, b)
        return a.created < b.created;
    end);

    for _, notification in ipairs(sorted) do
        if not ImGui.Begin(notification.title .. "##" .. notification.id, windowFlags) then
            goto continue;
        end

        if notification.type == NotificationType.Notification then
            ImGui.Text(notification.text);

            local aliveFor = os.clock() - notification.created;
            local leftToLive = NotificationSettings.NotificationExpirationSeconds - aliveFor;
            local leftToLivePercent = (aliveFor / NotificationSettings.NotificationExpirationSeconds);
            local progressBarValue = math.max(1 - leftToLivePercent, 0);

            ImGui.ProgressBar(progressBarValue, 0, 3, "");

            if leftToLive <= 0 then
                currentNotifications[notification.id] = nil;
            end
        end

        if notification.type == NotificationType.Progress then
            ImGui.ProgressBar(notification.progress, 0, 25, string.format("%s (%i%%)", notification.text, notification.progress * 100));

            if notification.progress >= 1 then
                currentNotifications[notification.id] = nil;
            end
        end

        local windowWidth, windowHeight = ImGui.GetWindowSize();
        local newWindowX = screenWidth - windowWidth - 5;
        local newWindowY = currentY - windowHeight;

        ImGui.SetWindowPos(newWindowX, newWindowY);

        currentY = newWindowY - 5;

        ImGui.End();

        ::continue::
    end
end
