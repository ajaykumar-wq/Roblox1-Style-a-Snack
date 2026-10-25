--!strict
local EconomyConfig = {}

EconomyConfig.ReasonCodes = {
    ROUND_PARTICIPATION = "ROUND_PARTICIPATION",
    ROUND_PLACEMENT = "ROUND_PLACEMENT",
    WARMUP = "WARMUP",
    STICKER_FOUND = "STICKER_FOUND",
    GOLDEN_SPRINKLE = "GOLDEN_SPRINKLE",
    VISITOR_REQUEST = "VISITOR_REQUEST",
    HATCH_SPEND = "HATCH_SPEND",
    HATCH_DUPLICATE_REFUND = "HATCH_DUPLICATE_REFUND",
    TESTER_KIT = "TESTER_KIT",
}

EconomyConfig.Rewards = {
    RoundParticipationSparkle = 20,
    WarmupSparkle = 20,
    StickerFoundSparkle = 10,
    GoldenSprinkleSparkle = 30,
    VisitorRequestSparkle = 15,
    PlacementBonuses = {
        [1] = 100,
        [2] = 60,
        [3] = 40,
    },
    BaseXPPerRound = 10,
    XPPerStar = 10,
}

EconomyConfig.ToolUnlocks = {
    Icing = 1,
    Sprinkle = 1,
    Sticker = 3,
    Drizzle = 6,
    Pattern = 10,
    Accessory = 15,
}

EconomyConfig.Oven = {
    FirstHatchPrice = 0,
    IntroHatchPrice = 100, -- Hatches 2 and 3
    RegularHatchPrice = 300, -- Hatch 4 onwards
    DuplicateRefund = 100,
    PityThreshold = 10, -- Guaranteed Rare or better every 10 hatches
    RarityOdds = {
        { Rarity = "Common", Weight = 0.60 },
        { Rarity = "Uncommon", Weight = 0.25 },
        { Rarity = "Rare", Weight = 0.10 },
        { Rarity = "Epic", Weight = 0.04 },
        { Rarity = "Mythic", Weight = 0.01 },
    },
}

function EconomyConfig.getXPToNextRank(rank: number): number
    if rank < 1 then rank = 1 end
    return math.floor(18 * (rank ^ 1.25))
end

function EconomyConfig.getHatchPrice(hatchCount: number): number
    if hatchCount <= 0 then
        return EconomyConfig.Oven.FirstHatchPrice
    elseif hatchCount <= 2 then
        return EconomyConfig.Oven.IntroHatchPrice
    else
        return EconomyConfig.Oven.RegularHatchPrice
    end
end

return EconomyConfig
