--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(ReplicatedStorage.StyleASnack.Config.EconomyConfig)
local ProgressionConfig = require(ReplicatedStorage.StyleASnack.Config.ProgressionConfig)
local Remotes = require(ReplicatedStorage.StyleASnack.Network.Remotes)

local DataService = {}

export type PlayerProfile = {
    UserId: number,
    Sparkle: number,
    XP: number,
    Rank: number,
    CurrentLevel: number,
    OwnedSpecies: { [string]: boolean },
    EquippedSpecies: string,
    HatchCount: number,
    PityCounter: number,
    CompletedRounds: number,
    HasCompletedWarmup: boolean,
    HasTesterKit: boolean,
    DailyThemeSkipUsed: boolean,
    CreatorData: {
        Family: string,
        Flavor: string,
        EyeShape: string,
        Name: string,
    }?,
    UnlockedTools: { [string]: boolean },
    FirstJoinTime: number,
    Ledger: { { Timestamp: number, Type: string, Amount: number, Reason: string, Balance: number } },
}

local profiles: { [number]: PlayerProfile } = {}

function DataService.init()
    Players.PlayerAdded:Connect(function(player)
        DataService.loadProfile(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        DataService.unloadProfile(player)
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        DataService.loadProfile(player)
    end

    local getProfileFunc = Remotes.getFunction("GetProfile")
    getProfileFunc.OnServerInvoke = function(player)
        return DataService.getProfile(player)
    end

    local submitCreatorFunc = Remotes.getFunction("SubmitCreatorData")
    submitCreatorFunc.OnServerInvoke = function(player, data)
        DataService.setCreatorData(player, data)
        return true
    end
end

function DataService.loadProfile(player: Player): PlayerProfile
    if profiles[player.UserId] then
        return profiles[player.UserId]
    end

    local starterSpecies = "croissant_cat"

    local newProfile: PlayerProfile = {
        UserId = player.UserId,
        Sparkle = 0,
        XP = 0,
        Rank = 1,
        CurrentLevel = 1,
        OwnedSpecies = {
            [starterSpecies] = true,
        },
        EquippedSpecies = starterSpecies,
        HatchCount = 0,
        PityCounter = 0,
        CompletedRounds = 0,
        HasCompletedWarmup = false,
        HasTesterKit = false,
        DailyThemeSkipUsed = false,
        CreatorData = nil,
        UnlockedTools = {
            Icing = true,
            Sprinkle = false,
            Sticker = false,
            Drizzle = false,
            Pattern = false,
            Accessory = false,
        },
        FirstJoinTime = os.time(),
        Ledger = {},
    }

    profiles[player.UserId] = newProfile
    DataService.syncProfile(player)
    return newProfile
end

function DataService.unloadProfile(player: Player)
    profiles[player.UserId] = nil
end

function DataService.getProfile(player: Player): PlayerProfile
    local profile = profiles[player.UserId]
    if not profile then
        profile = DataService.loadProfile(player)
    end
    return profile
end

function DataService.syncProfile(player: Player)
    local profile = profiles[player.UserId]
    if profile then
        Remotes.getEvent("ProfileUpdated"):FireClient(player, profile)
    end
end

function DataService.isToolUnlocked(player: Player, toolName: string): boolean
    local profile = profiles[player.UserId]
    if not profile then return false end

    if profile.HasTesterKit then
        return true
    end

    if toolName == "Icing" then return true end

    return profile.UnlockedTools[toolName] == true
end

function DataService.setCreatorData(player: Player, data: { Family: string, Flavor: string, EyeShape: string, Name: string })
    local profile = profiles[player.UserId]
    if not profile then return end

    profile.CreatorData = data
    DataService.syncProfile(player)
end

function DataService.canUseDailySkip(player: Player): boolean
    local profile = profiles[player.UserId]
    if not profile then return false end
    return not profile.DailyThemeSkipUsed
end

function DataService.consumeDailySkip(player: Player): boolean
    local profile = profiles[player.UserId]
    if not profile or profile.DailyThemeSkipUsed then return false end
    profile.DailyThemeSkipUsed = true
    DataService.syncProfile(player)
    return true
end

function DataService.advanceLevel(player: Player)
    local profile = profiles[player.UserId]
    if not profile then return end

    local currentLvlDef = ProgressionConfig.getLevel(profile.CurrentLevel)
    if not currentLvlDef then return end

    -- Grant Level Outcome Rewards
    if currentLvlDef.RewardSparkle > 0 then
        profile.Sparkle += currentLvlDef.RewardSparkle
        table.insert(profile.Ledger, {
            Timestamp = os.time(),
            Type = "LEVEL_REWARD",
            Amount = currentLvlDef.RewardSparkle,
            Reason = "LEVEL_" .. tostring(profile.CurrentLevel) .. "_CLEAR",
            Balance = profile.Sparkle,
        })
    end

    if currentLvlDef.UnlockedTool then
        profile.UnlockedTools[currentLvlDef.UnlockedTool] = true
    end

    profile.CurrentLevel += 1
    profile.Rank = profile.CurrentLevel

    print(string.format("[Progression] %s advanced to Level %d (%s)!",
        player.Name,
        profile.CurrentLevel,
        currentLvlDef.RewardDescription
    ))

    DataService.syncProfile(player)
end

function DataService.checkLevelObjective(player: Player, eventType: string, eventData: { [string]: any })
    local profile = profiles[player.UserId]
    if not profile then return end

    local lvlDef = ProgressionConfig.getLevel(profile.CurrentLevel)
    if not lvlDef then return end

    if lvlDef.RequirementType == "Warmup" and eventType == "WarmupCompleted" then
        DataService.advanceLevel(player)
    elseif lvlDef.RequirementType == "HatchOven" and eventType == "HatchCompleted" then
        DataService.advanceLevel(player)
    elseif lvlDef.RequirementType == "ScoreStars" and eventType == "RoundFinished" then
        local stars = eventData.Stars or 0
        if stars >= lvlDef.TargetValue then
            DataService.advanceLevel(player)
        end
    elseif lvlDef.RequirementType == "TopPlacement" and eventType == "RoundFinished" then
        local placement = eventData.Placement or 99
        if placement <= lvlDef.TargetValue then
            DataService.advanceLevel(player)
        end
    elseif lvlDef.RequirementType == "FullCoverage" and eventType == "RoundFinished" then
        local coverageCount = eventData.CoverageCount or 0
        local stars = eventData.Stars or 0
        if coverageCount >= 4 and stars >= lvlDef.TargetValue then
            DataService.advanceLevel(player)
        end
    end
end

function DataService.incrementCompletedRounds(player: Player)
    local profile = profiles[player.UserId]
    if not profile then return end

    profile.CompletedRounds += 1

    if profile.CompletedRounds >= 3 and not profile.HasTesterKit then
        profile.HasTesterKit = true
        for toolName in pairs(profile.UnlockedTools) do
            profile.UnlockedTools[toolName] = true
        end
        table.insert(profile.Ledger, {
            Timestamp = os.time(),
            Type = "FLAG",
            Amount = 0,
            Reason = EconomyConfig.ReasonCodes.TESTER_KIT,
            Balance = profile.Sparkle,
        })
        print(string.format("[TesterKit] Tester kit unlocked for %s after round 3!", player.Name))
    end

    DataService.syncProfile(player)
end

return DataService
