--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.StyleASnack.Network.Remotes)

local AnalyticsService = {}

function AnalyticsService.init()
    local analyticsEvent = Remotes.getEvent("AnalyticsEvent")
    analyticsEvent.OnServerEvent:Connect(function(player: Player, eventName: string, eventData: { [string]: any })
        AnalyticsService.logEvent(eventName, player, eventData)
    end)

    Players.PlayerAdded:Connect(function(player)
        AnalyticsService.logEvent("session_start", player, {
            JoinTime = os.time(),
        })
    end)

    Players.PlayerRemoving:Connect(function(player)
        AnalyticsService.logEvent("session_end", player, {
            LeaveTime = os.time(),
        })
    end)
end

function AnalyticsService.logEvent(eventName: string, player: Player?, data: { [string]: any }?)
    local payload = data or {}
    if player then
        payload.UserId = player.UserId
        payload.Username = player.Name
    end
    payload.Timestamp = os.time()

    print(string.format("[Analytics] Event: %s | User: %s | Data: %s",
        eventName,
        player and player.Name or "System",
        game:GetService("HttpService"):JSONEncode(payload)
    ))
end

return AnalyticsService
