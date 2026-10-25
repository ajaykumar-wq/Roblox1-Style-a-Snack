--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(ReplicatedStorage.StyleASnack.Config.EconomyConfig)
local ThemeConfig = require(ReplicatedStorage.StyleASnack.Config.ThemeConfig)
local DecorationConfig = require(ReplicatedStorage.StyleASnack.Config.DecorationConfig)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local ServerJudgeService = require(script.Parent.ServerJudgeService)
local RivalService = require(script.Parent.RivalService)
local AnalyticsService = require(script.Parent.AnalyticsService)
local Remotes = require(ReplicatedStorage.StyleASnack.Network.Remotes)

local RoundService = {}

export type SoloRoundSession = {
    Player: Player,
    RoundId: number,
    State: string,
    Occasion: ThemeConfig.Occasion,
    Palette: ThemeConfig.Palette,
    Layers: { DecorationConfig.Layer },
    Rivals: { RivalService.RivalEntry },
    StartTime: number,
    PhaseEndTime: number,
}

local activeSessions: { [number]: SoloRoundSession } = {}
local roundCounter = 0

-- Repeat guards
local pastOccasions: { string } = {}
local pastPalettes: { string } = {}

function RoundService.init()
    local themeCardsFunc = Remotes.getFunction("RequestThemeCards")
    themeCardsFunc.OnServerInvoke = function(player: Player)
        return RoundService.generateThemeCards()
    end

    local startRoundFunc = Remotes.getFunction("StartSoloRound")
    startRoundFunc.OnServerInvoke = function(player: Player, themeCard: any)
        return RoundService.startSoloRound(player, themeCard)
    end

    local submitDiffFunc = Remotes.getFunction("SubmitDecorationDiff")
    submitDiffFunc.OnServerInvoke = function(player: Player, layers: { DecorationConfig.Layer })
        local session = activeSessions[player.UserId]
        if session and session.State == "Decorate" then
            if #layers <= DecorationConfig.MaxLayersPerEntry then
                session.Layers = layers
                return true, nil
            else
                return false, "Exceeded 12 layers"
            end
        end
        return false, "Not in decorate phase"
    end

    local finishFunc = Remotes.getFunction("FinishRoundDecorate")
    finishFunc.OnServerInvoke = function(player: Player, layers: { DecorationConfig.Layer }?)
        local session = activeSessions[player.UserId]
        if session and session.State == "Decorate" then
            if layers and #layers <= DecorationConfig.MaxLayersPerEntry then
                session.Layers = layers
            end
            task.spawn(function()
                RoundService.executeJudgingAndResults(player, session)
            end)
            return true, nil
        end
        return false, "Not in decorate phase"
    end

    local abandonFunc = Remotes.getFunction("AbandonRound")
    abandonFunc.OnServerInvoke = function(player: Player)
        if activeSessions[player.UserId] then
            activeSessions[player.UserId] = nil
            Remotes.getEvent("RoundStateChanged"):FireClient(player, {
                State = "Lobby",
                Duration = 0,
            })
            return true
        end
        return false
    end
end

function RoundService.generateThemeCards(): { { Occasion: ThemeConfig.Occasion, Palette: ThemeConfig.Palette } }
    local rng = Random.new()
    local cards = {}

    local validOccasions = table.clone(ThemeConfig.Occasions)
    local validPalettes = table.clone(ThemeConfig.Palettes)

    for i = 1, 3 do
        local occIdx = rng:NextInteger(1, #validOccasions)
        local occ = table.remove(validOccasions, occIdx) or ThemeConfig.Occasions[1]

        local palIdx = rng:NextInteger(1, #validPalettes)
        local pal = table.remove(validPalettes, palIdx) or ThemeConfig.Palettes[1]

        table.insert(cards, {
            Occasion = occ,
            Palette = pal,
        })
    end

    return cards
end

function RoundService.startSoloRound(player: Player, chosenCard: { Occasion: ThemeConfig.Occasion, Palette: ThemeConfig.Palette })
    roundCounter += 1
    local profile = DataService.getProfile(player)
    local unlockedTools = profile and profile.UnlockedTools or { Icing = true }
    local rank = profile and profile.CurrentLevel or 1

    -- Generate 5 Rival Entries for this chosen theme!
    local rivals = RivalService.generateRivals(chosenCard.Occasion, chosenCard.Palette, unlockedTools, rank)

    local session: SoloRoundSession = {
        Player = player,
        RoundId = roundCounter,
        State = "Theme",
        Occasion = chosenCard.Occasion,
        Palette = chosenCard.Palette,
        Layers = {},
        Rivals = rivals,
        StartTime = os.time(),
        PhaseEndTime = os.time() + 3,
    }

    activeSessions[player.UserId] = session

    -- 1. THEME REVEAL (3s)
    Remotes.getEvent("RoundStateChanged"):FireClient(player, {
        State = "Theme",
        Duration = 3,
        PhaseEndTime = session.PhaseEndTime,
        Occasion = session.Occasion,
        Palette = session.Palette,
        RoundId = session.RoundId,
    })

    task.delay(3, function()
        if activeSessions[player.UserId] ~= session then return end

        -- 2. DECORATE (180s)
        session.State = "Decorate"
        session.PhaseEndTime = os.time() + 180
        Remotes.getEvent("RoundStateChanged"):FireClient(player, {
            State = "Decorate",
            Duration = 180,
            PhaseEndTime = session.PhaseEndTime,
            Occasion = session.Occasion,
            Palette = session.Palette,
            RoundId = session.RoundId,
        })

        task.delay(180, function()
            if activeSessions[player.UserId] ~= session then return end
            RoundService.executeJudgingAndResults(player, session)
        end)
    end)

    return true, session.RoundId
end

function RoundService.executeJudgingAndResults(player: Player, session: SoloRoundSession)
    -- 3. LOCK (2s) - Pencils Down
    session.State = "Lock"
    Remotes.getEvent("RoundStateChanged"):FireClient(player, {
        State = "Lock",
        Duration = 2,
    })

    task.wait(2)
    if activeSessions[player.UserId] ~= session then return end

    -- 4. JUDGING RUNWAY (20s)
    session.State = "Judging"
    Remotes.getEvent("RoundStateChanged"):FireClient(player, {
        State = "Judging",
        Duration = 20,
    })

    -- Score Player's Entry with ServerJudge
    local profile = DataService.getProfile(player)
    local playerRubric = ServerJudgeService.scoreEntry(session.Layers, session.Occasion.Id, session.Palette.Id, 6)

    local playerEntry = {
        EntryId = "player_" .. tostring(player.UserId),
        Name = player.Name,
        SpeciesId = profile and profile.EquippedSpecies or "croissant_cat",
        Layers = session.Layers,
        Rubric = playerRubric,
        IsRival = false,
    }

    -- Combine Player + 5 Rivals = 6 total entries
    local allEntries = { playerEntry }
    for _, riv in ipairs(session.Rivals) do
        table.insert(allEntries, riv)
    end

    -- Randomize runway presentation order
    local rng = Random.new()
    for i = #allEntries, 2, -1 do
        local j = rng:NextInteger(1, i)
        allEntries[i], allEntries[j] = allEntries[j], allEntries[i]
    end

    -- Runway spotlights: present each entry in sequence
    task.spawn(function()
        for idx, entry in ipairs(allEntries) do
            if activeSessions[player.UserId] ~= session then break end
            Remotes.getEvent("RunwayFocusChanged"):FireClient(player, idx, #allEntries, {
                EntryId = entry.EntryId,
                Name = entry.Name,
                SpeciesId = entry.SpeciesId,
                Layers = entry.Layers,
                IsSelf = not entry.IsRival,
                Stars = entry.Rubric.Stars,
            })
            task.wait(3)
        end
    end)

    task.wait(20)
    if activeSessions[player.UserId] ~= session then return end

    -- 5. RESULTS (10s)
    session.State = "Results"

    -- Sort all 6 entries by TotalScore descending
    table.sort(allEntries, function(a, b)
        return a.Rubric.TotalScore > b.Rubric.TotalScore
    end)

    local playerPlacement = 6
    for idx, e in ipairs(allEntries) do
        if not e.IsRival then
            playerPlacement = idx
            break
        end
    end

    -- Process rewards
    EconomyService.grantSparkle(player, EconomyConfig.Rewards.RoundParticipationSparkle, EconomyConfig.ReasonCodes.ROUND_PARTICIPATION)
    local placementBonus = EconomyConfig.Rewards.PlacementBonuses[playerPlacement] or 0
    if placementBonus > 0 then
        EconomyService.grantSparkle(player, placementBonus, EconomyConfig.ReasonCodes.ROUND_PLACEMENT)
    end

    local xpEarned = EconomyConfig.Rewards.BaseXPPerRound + (playerRubric.Stars * EconomyConfig.Rewards.XPPerStar)
    EconomyService.grantXP(player, xpEarned, EconomyConfig.ReasonCodes.ROUND_PARTICIPATION)

    -- Check Level progression objectives
    local regionsCovered = {}
    for _, l in ipairs(session.Layers) do
        if l.Region then regionsCovered[l.Region] = true end
    end
    local covCount = 0
    for _ in pairs(regionsCovered) do covCount += 1 end

    DataService.checkLevelObjective(player, "RoundFinished", {
        Stars = playerRubric.Stars,
        Placement = playerPlacement,
        CoverageCount = covCount,
    })
    DataService.incrementCompletedRounds(player)

    local updatedProfile = DataService.getProfile(player)

    Remotes.getEvent("ShowResults"):FireClient(player, {
        Placement = playerPlacement,
        TotalEntries = #allEntries,
        Stars = playerRubric.Stars,
        Rubric = playerRubric,
        SparkleEarned = EconomyConfig.Rewards.RoundParticipationSparkle + placementBonus,
        XPEarned = xpEarned,
        CurrentLevel = updatedProfile and updatedProfile.CurrentLevel or 1,
        AllEntries = allEntries,
    })

    Remotes.getEvent("RoundStateChanged"):FireClient(player, {
        State = "Results",
        Duration = 10,
    })
end

return RoundService
