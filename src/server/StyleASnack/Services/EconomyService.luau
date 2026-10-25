--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(ReplicatedStorage.StyleASnack.Config.EconomyConfig)
local DataService = require(script.Parent.DataService)

local EconomyService = {}

local VALID_REASONS = {
    [EconomyConfig.ReasonCodes.ROUND_PARTICIPATION] = true,
    [EconomyConfig.ReasonCodes.ROUND_PLACEMENT] = true,
    [EconomyConfig.ReasonCodes.WARMUP] = true,
    [EconomyConfig.ReasonCodes.STICKER_FOUND] = true,
    [EconomyConfig.ReasonCodes.GOLDEN_SPRINKLE] = true,
    [EconomyConfig.ReasonCodes.VISITOR_REQUEST] = true,
    [EconomyConfig.ReasonCodes.HATCH_SPEND] = true,
    [EconomyConfig.ReasonCodes.HATCH_DUPLICATE_REFUND] = true,
    [EconomyConfig.ReasonCodes.TESTER_KIT] = true,
}

local function validateReason(reason: string)
    if not reason or not VALID_REASONS[reason] then
        error("[EconomyService] SECURITY VIOLATION: Invalid or missing reason code: " .. tostring(reason))
    end
end

function EconomyService.grantSparkle(player: Player, amount: number, reason: string): boolean
    validateReason(reason)
    if amount <= 0 then return false end

    local profile = DataService.getProfile(player)
    if not profile then return false end

    profile.Sparkle += amount

    table.insert(profile.Ledger, {
        Timestamp = os.time(),
        Type = "SPARKLE_GRANT",
        Amount = amount,
        Reason = reason,
        Balance = profile.Sparkle,
    })

    DataService.syncProfile(player)
    return true
end

function EconomyService.spendSparkle(player: Player, amount: number, reason: string): boolean
    validateReason(reason)
    if amount <= 0 then return false end

    local profile = DataService.getProfile(player)
    if not profile then return false end

    if profile.Sparkle < amount then
        return false -- Insufficient funds
    end

    profile.Sparkle -= amount

    table.insert(profile.Ledger, {
        Timestamp = os.time(),
        Type = "SPARKLE_SPEND",
        Amount = -amount,
        Reason = reason,
        Balance = profile.Sparkle,
    })

    DataService.syncProfile(player)
    return true
end

function EconomyService.grantXP(player: Player, amount: number, reason: string): boolean
    validateReason(reason)
    if amount <= 0 then return false end

    local profile = DataService.getProfile(player)
    if not profile then return false end

    profile.XP += amount

    -- Check for rank up(s)
    local xpNeeded = EconomyConfig.getXPToNextRank(profile.Rank)
    while profile.XP >= xpNeeded do
        profile.XP -= xpNeeded
        profile.Rank += 1
        xpNeeded = EconomyConfig.getXPToNextRank(profile.Rank)
    end

    table.insert(profile.Ledger, {
        Timestamp = os.time(),
        Type = "XP_GRANT",
        Amount = amount,
        Reason = reason,
        Balance = profile.XP,
    })

    DataService.syncProfile(player)
    return true
end

return EconomyService
