--!strict
local ProgressionConfig = {}

export type LevelDefinition = {
    Level: number,
    Title: string,
    ObjectiveText: string,
    RequirementType: "Warmup" | "ScoreStars" | "HatchOven" | "TopPlacement" | "FullCoverage",
    TargetValue: number,
    RewardSparkle: number,
    UnlockedTool: string?,
    RewardDescription: string,
}

ProgressionConfig.Levels = {
    {
        Level = 1,
        Title = "The Starter Snack",
        ObjectiveText = "Complete your first 60-second warmup round by icing your snack",
        RequirementType = "Warmup",
        TargetValue = 1,
        RewardSparkle = 20,
        UnlockedTool = "Sprinkle",
        RewardDescription = "Unlocks Sprinkles Tool + 20 ✨",
    },
    {
        Level = 2,
        Title = "Sweet Scatter",
        ObjectiveText = "Scatter sprinkles and score at least 2 Stars on the Runway",
        RequirementType = "ScoreStars",
        TargetValue = 2,
        RewardSparkle = 40,
        UnlockedTool = "Sticker",
        RewardDescription = "Unlocks Stickers Tool + 40 ✨",
    },
    {
        Level = 3,
        Title = "The Oven Baker",
        ObjectiveText = "Visit the Bakery Oven and hatch your first snack creature",
        RequirementType = "HatchOven",
        TargetValue = 1,
        RewardSparkle = 50,
        UnlockedTool = nil,
        RewardDescription = "Free Hatch + 50 ✨",
    },
    {
        Level = 4,
        Title = "Glossy Glaze",
        ObjectiveText = "Decorate matching the theme palette and score at least 3 Stars",
        RequirementType = "ScoreStars",
        TargetValue = 3,
        RewardSparkle = 60,
        UnlockedTool = "Drizzle",
        RewardDescription = "Unlocks Drizzle Tool + 60 ✨",
    },
    {
        Level = 5,
        Title = "Runway Spotlight",
        ObjectiveText = "Place in the Top 3 on the Runway podium in a live round",
        RequirementType = "TopPlacement",
        TargetValue = 3,
        RewardSparkle = 100,
        UnlockedTool = "Pattern",
        RewardDescription = "Unlocks Patterns Tool + 100 ✨",
    },
    {
        Level = 6,
        Title = "Runway Royalty",
        ObjectiveText = "Decorate all 4 regions (head, body, back, tail) and score 4+ Stars",
        RequirementType = "FullCoverage",
        TargetValue = 4,
        RewardSparkle = 150,
        UnlockedTool = "Accessory",
        RewardDescription = "Unlocks Wearable Accessories + 150 ✨",
    },
}

function ProgressionConfig.getLevel(levelNum: number): LevelDefinition?
    for _, lvl in ipairs(ProgressionConfig.Levels) do
        if lvl.Level == levelNum then return lvl end
    end
    return ProgressionConfig.Levels[#ProgressionConfig.Levels]
end

function ProgressionConfig.getObjective(levelNum: number): string
    local lvl = ProgressionConfig.getLevel(levelNum)
    return lvl and lvl.ObjectiveText or "Hatch and Style!"
end

function ProgressionConfig.getRequiredLevelForTool(toolName: string): number
    if toolName == "Icing" then return 1 end
    for _, lvl in ipairs(ProgressionConfig.Levels) do
        if lvl.UnlockedTool == toolName then
            return lvl.Level
        end
    end
    return 1
end

return ProgressionConfig
