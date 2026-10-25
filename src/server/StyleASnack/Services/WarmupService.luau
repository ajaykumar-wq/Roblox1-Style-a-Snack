--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(ReplicatedStorage.StyleASnack.Config.EconomyConfig)
local ThemeConfig = require(ReplicatedStorage.StyleASnack.Config.ThemeConfig)
local DecorationConfig = require(ReplicatedStorage.StyleASnack.Config.DecorationConfig)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local ServerJudgeService = require(script.Parent.ServerJudgeService)
local AnalyticsService = require(script.Parent.AnalyticsService)
local Remotes = require(ReplicatedStorage.StyleASnack.Network.Remotes)

local WarmupService = {}

local activeWarmups: { [number]: {
    StartTime: number,
    SpawnTime: number,
    Layers: { DecorationConfig.Layer },
    State: string,
} } = {}

function WarmupService.init()
    local function handlePlayer(player: Player)
        local spawnTime = os.time()
        -- Revised first minute (Oct 25 GDD): Creator 5-25s, Warm-up Decorate 25-50s, Runway 50-60s
        task.delay(25, function()
            if not player:IsDescendantOf(Players) then return end
            local profile = DataService.getProfile(player)
            if profile and not profile.HasCompletedWarmup then
                WarmupService.startWarmup(player, spawnTime)
            end
        end)
    end

    Players.PlayerAdded:Connect(handlePlayer)
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(handlePlayer, player)
    end
end

function WarmupService.startWarmup(player: Player, spawnTime: number)
    activeWarmups[player.UserId] = {
        StartTime = os.time(),
        SpawnTime = spawnTime,
        Layers = {},
        State = "Decorate",
    }

    local beachOccasion = ThemeConfig.getOccasionById("beach_day")
    local sunnyPalette = ThemeConfig.getPaletteById("sunny")

    Remotes.getEvent("StartWarmup"):FireClient(player, {
        Occasion = beachOccasion,
        Palette = sunnyPalette,
        Duration = 25, -- 25s warm-up decorate
    })

    -- 25s Decorate (25-50s) -> 10s Runway (50-60s) -> First score lands at 60s
    task.delay(25, function()
        if not player:IsDescendantOf(Players) then return end
        local warmup = activeWarmups[player.UserId]
        if not warmup then return end

        warmup.State = "Runway"
        Remotes.getEvent("WarmupStateChanged"):FireClient(player, "Runway", 10)

        task.delay(10, function()
            if not player:IsDescendantOf(Players) then return end
            WarmupService.completeWarmup(player)
        end)
    end)
end

function WarmupService.submitWarmupLayers(player: Player, layers: { DecorationConfig.Layer })
    local warmup = activeWarmups[player.UserId]
    if warmup and warmup.State == "Decorate" then
        warmup.Layers = layers
    end
end

function WarmupService.completeWarmup(player: Player)
    local warmup = activeWarmups[player.UserId]
    if not warmup then return end

    local rubric = ServerJudgeService.scoreEntry(warmup.Layers, "beach_day", "sunny", 2)
    local stars = rubric.Stars
    local score = rubric.TotalScore
    local secondsSinceSpawn = os.time() - warmup.SpawnTime

    -- Pay rewards
    EconomyService.grantSparkle(player, EconomyConfig.Rewards.WarmupSparkle, EconomyConfig.ReasonCodes.WARMUP)
    local xpEarned = EconomyConfig.Rewards.BaseXPPerRound + (stars * EconomyConfig.Rewards.XPPerStar)
    EconomyService.grantXP(player, xpEarned, EconomyConfig.ReasonCodes.WARMUP)

    local profile = DataService.getProfile(player)
    if profile then
        profile.HasCompletedWarmup = true
        DataService.syncProfile(player)
    end

    -- Trigger Level 1 Objective completion -> promotes to Level 2 and unlocks Sprinkles!
    DataService.checkLevelObjective(player, "WarmupCompleted", { Stars = stars })

    AnalyticsService.logEvent("first_vote_received", player, {
        secondsSinceSpawn = secondsSinceSpawn,
        stars = stars,
        score = score,
    })

    Remotes.getEvent("WarmupStateChanged"):FireClient(player, "Results", 10, stars, score)

    activeWarmups[player.UserId] = nil
end

return WarmupService
