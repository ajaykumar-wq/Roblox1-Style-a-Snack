--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ExplorationConfig = require(ReplicatedStorage.StyleASnack.Config.ExplorationConfig)
local EconomyConfig = require(ReplicatedStorage.StyleASnack.Config.EconomyConfig)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local Remotes = require(ReplicatedStorage.StyleASnack.Network.Remotes)

local ExplorationService = {}

-- Player exploration state: [UserId] -> { FoundStickers: { [string]: boolean }, CollectedSprinkles: { [string]: boolean } }
local explorationState: { [number]: {
    FoundStickers: { [string]: boolean },
    CollectedSprinkles: { [string]: boolean },
} } = {}

function ExplorationService.init()
    local function initPlayerState(player: Player)
        if not explorationState[player.UserId] then
            explorationState[player.UserId] = {
                FoundStickers = {},
                CollectedSprinkles = {},
            }
        end
    end

    Players.PlayerAdded:Connect(initPlayerState)
    for _, player in ipairs(Players:GetPlayers()) do
        initPlayerState(player)
    end

    Players.PlayerRemoving:Connect(function(player)
        explorationState[player.UserId] = nil
    end)

    local collectStickerFunc = Remotes.getFunction("CollectHiddenSticker")
    collectStickerFunc.OnServerInvoke = function(player: Player, stickerId: string)
        return ExplorationService.collectHiddenSticker(player, stickerId)
    end

    local collectSprinkleFunc = Remotes.getFunction("CollectGoldenSprinkle")
    collectSprinkleFunc.OnServerInvoke = function(player: Player, sprinkleId: string)
        return ExplorationService.collectGoldenSprinkle(player, sprinkleId)
    end

    local acceptVisitorFunc = Remotes.getFunction("AcceptVisitorRequest")
    acceptVisitorFunc.OnServerInvoke = function(player: Player, visitorId: string)
        return ExplorationService.acceptVisitorRequest(player, visitorId)
    end
end

function ExplorationService.collectHiddenSticker(player: Player, stickerId: string): (boolean, number?, string?)
    local state = explorationState[player.UserId]
    if not state then
        state = { FoundStickers = {}, CollectedSprinkles = {} }
        explorationState[player.UserId] = state
    end

    if state.FoundStickers[stickerId] then
        return false, nil, "Sticker already discovered!"
    end

    state.FoundStickers[stickerId] = true

    -- Grant 10 Sparkle
    local reward = EconomyConfig.Rewards.StickerFoundSparkle
    EconomyService.grantSparkle(player, reward, EconomyConfig.ReasonCodes.STICKER_FOUND)

    -- Notify client
    Remotes.getEvent("StickerFoundNotification"):FireClient(player, stickerId, reward)

    print(string.format("[Exploration] %s found hidden sticker '%s'! (+%d Sparkle)", player.Name, stickerId, reward))
    return true, reward, nil
end

function ExplorationService.collectGoldenSprinkle(player: Player, sprinkleId: string): (boolean, number?, string?)
    local state = explorationState[player.UserId]
    if not state then
        state = { FoundStickers = {}, CollectedSprinkles = {} }
        explorationState[player.UserId] = state
    end

    if state.CollectedSprinkles[sprinkleId] then
        return false, nil, "Already collected today!"
    end

    state.CollectedSprinkles[sprinkleId] = true

    -- Grant 30 Sparkle
    local reward = EconomyConfig.Rewards.GoldenSprinkleSparkle
    EconomyService.grantSparkle(player, reward, EconomyConfig.ReasonCodes.GOLDEN_SPRINKLE)

    -- Notify client
    Remotes.getEvent("GoldenSprinkleNotification"):FireClient(player, sprinkleId, reward)

    print(string.format("[Exploration] %s collected Golden Sprinkle '%s'! (+%d Sparkle)", player.Name, sprinkleId, reward))
    return true, reward, nil
end

function ExplorationService.acceptVisitorRequest(player: Player, visitorId: string): (boolean, any?, string?)
    local visitor = nil
    for _, v in ipairs(ExplorationConfig.Visitors) do
        if v.Id == visitorId then visitor = v; break end
    end
    if not visitor then return false, nil, "Visitor not found" end

    return true, visitor, nil
end

return ExplorationService
