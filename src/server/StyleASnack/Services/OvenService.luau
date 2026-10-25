--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(ReplicatedStorage.StyleASnack.Config.EconomyConfig)
local SpeciesConfig = require(ReplicatedStorage.StyleASnack.Config.SpeciesConfig)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local Remotes = require(ReplicatedStorage.StyleASnack.Network.Remotes)

local OvenService = {}

function OvenService.init()
    local hatchFunc = Remotes.getFunction("HatchOven")
    hatchFunc.OnServerInvoke = function(player: Player)
        return OvenService.hatch(player)
    end
end

function OvenService.hatch(player: Player): (boolean, string?, string?, boolean?, number?, number?, string?)
    local profile = DataService.getProfile(player)
    if not profile then
        return false, nil, nil, nil, nil, nil, "Profile not loaded"
    end

    local price = EconomyConfig.getHatchPrice(profile.HatchCount)

    -- Spend Sparkle if not free
    if price > 0 then
        if profile.Sparkle < price then
            return false, nil, nil, nil, nil, nil, "Insufficient Sparkle"
        end
        EconomyService.spendSparkle(player, price, EconomyConfig.ReasonCodes.HATCH_SPEND)
    end

    profile.HatchCount += 1
    profile.PityCounter += 1

    -- Roll Rarity
    local rng = Random.new()
    local roll = rng:NextNumber()
    local rolledRarity: SpeciesConfig.Rarity = "Common"

    -- Pity check: guaranteed Rare or better every 10 hatches
    if profile.PityCounter >= EconomyConfig.Oven.PityThreshold then
        rolledRarity = "Rare"
        profile.PityCounter = 0
    else
        local cumulative = 0
        for _, odd in ipairs(EconomyConfig.Oven.RarityOdds) do
            cumulative += odd.Weight
            if roll <= cumulative then
                rolledRarity = odd.Rarity :: SpeciesConfig.Rarity
                break
            end
        end
    end

    -- In prototype: Epic and Mythic roll but resolve to Rare Dumpling Duck
    local grantedRarity = rolledRarity
    if rolledRarity == "Epic" or rolledRarity == "Mythic" then
        grantedRarity = "Rare"
    end

    if grantedRarity == "Rare" or grantedRarity == "Epic" or grantedRarity == "Mythic" then
        profile.PityCounter = 0
    end

    -- Pick a species of that rarity
    local candidateSpecies = SpeciesConfig.getSpeciesByRarity(grantedRarity)
    if #candidateSpecies == 0 then
        candidateSpecies = SpeciesConfig.getSpeciesByRarity("Common")
    end

    local chosenSpecies = candidateSpecies[rng:NextInteger(1, #candidateSpecies)]
    local isDuplicate = profile.OwnedSpecies[chosenSpecies.Id] == true
    local refundAmount = 0

    if isDuplicate then
        -- Rule: duplicate refunds 100 Sparkle
        refundAmount = EconomyConfig.Oven.DuplicateRefund
        EconomyService.grantSparkle(player, refundAmount, EconomyConfig.ReasonCodes.HATCH_DUPLICATE_REFUND)
    else
        profile.OwnedSpecies[chosenSpecies.Id] = true
    end

    DataService.syncProfile(player)

    -- Trigger Level 3 Objective completion if hatching for the first time
    DataService.checkLevelObjective(player, "HatchCompleted", { SpeciesId = chosenSpecies.Id })

    return true, rolledRarity, chosenSpecies.Id, isDuplicate, refundAmount, price, nil
end

return OvenService
