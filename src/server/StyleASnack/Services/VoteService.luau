--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerJudgeService = require(script.Parent.ServerJudgeService)
local DecorationConfig = require(ReplicatedStorage.StyleASnack.Config.DecorationConfig)
local Remotes = require(ReplicatedStorage.StyleASnack.Network.Remotes)

local VoteService = {}

export type Entry = {
    EntryId: string,
    UserId: number,
    Player: Player?,
    SpeciesId: string,
    Layers: { DecorationConfig.Layer },
    SubmissionTime: number,
    Votes: { [number]: number }, -- VoterUserId -> stars (1-5)
    FinalStars: number,
    Score: number,
}

local currentEntries: { [string]: Entry } = {}
local entryOrder: { string } = {} -- Random order for runway

function VoteService.init()
    local castVoteFunc = Remotes.getFunction("CastVote")
    castVoteFunc.OnServerInvoke = function(voter: Player, targetEntryId: string, stars: number)
        return VoteService.castVote(voter, targetEntryId, stars)
    end
end

function VoteService.resetEntries()
    currentEntries = {}
    entryOrder = {}
end

function VoteService.registerEntry(player: Player, speciesId: string, layers: { DecorationConfig.Layer }): string
    local entryId = "entry_" .. tostring(player.UserId) .. "_" .. tostring(os.time())
    local entry: Entry = {
        EntryId = entryId,
        UserId = player.UserId,
        Player = player,
        SpeciesId = speciesId,
        Layers = layers,
        SubmissionTime = os.clock(),
        Votes = {},
        FinalStars = 1,
        Score = 0,
    }

    currentEntries[entryId] = entry
    table.insert(entryOrder, entryId)
    return entryId
end

function VoteService.finalizeRunwayOrder(): { Entry }
    -- Randomize order for runway (Fisher-Yates shuffle)
    local rng = Random.new()
    for i = #entryOrder, 2, -1 do
        local j = rng:NextInteger(1, i)
        entryOrder[i], entryOrder[j] = entryOrder[j], entryOrder[i]
    end

    local orderedList: { Entry } = {}
    for _, id in ipairs(entryOrder) do
        table.insert(orderedList, currentEntries[id])
    end
    return orderedList
end

function VoteService.castVote(voter: Player, targetEntryId: string, stars: number): (boolean, string?)
    local entry = currentEntries[targetEntryId]
    if not entry then
        return false, "Entry not found"
    end

    -- Rule: Self-votes blocked!
    if entry.UserId == voter.UserId then
        return false, "Cannot vote for your own entry"
    end

    -- Rule: 1 to 5 stars
    stars = math.clamp(math.floor(stars), 1, 5)

    -- Rule: One vote per voter per entry
    if entry.Votes[voter.UserId] ~= nil then
        return false, "Already voted on this entry"
    end

    entry.Votes[voter.UserId] = stars
    return true, nil
end

function VoteService.calculateResults(occasionId: string, paletteId: string): { Entry }
    local results: { Entry } = {}

    for _, entry in pairs(currentEntries) do
        local voteList = {}
        for _, stars in pairs(entry.Votes) do
            table.insert(voteList, stars)
        end

        table.sort(voteList)

        -- Rule: Fewer than 4 valid votes falls back to the server judge
        if #voteList < 4 then
            local _, judgeStars = ServerJudgeService.scoreEntry(entry.Layers, occasionId, paletteId, 6)
            entry.FinalStars = judgeStars
            entry.Score = judgeStars * 20
        else
            -- Calculate Median
            local count = #voteList
            if count % 2 == 1 then
                entry.FinalStars = voteList[math.ceil(count / 2)]
            else
                local mid1 = voteList[count / 2]
                local mid2 = voteList[(count / 2) + 1]
                entry.FinalStars = math.round((mid1 + mid2) / 2)
            end
            entry.Score = entry.FinalStars * 20
        end

        table.insert(results, entry)
    end

    -- Sort placements: highest final stars first, ties broken by earlier submission time
    table.sort(results, function(a, b)
        if a.FinalStars == b.FinalStars then
            return a.SubmissionTime < b.SubmissionTime
        end
        return a.FinalStars > b.FinalStars
    end)

    return results
end

return VoteService
