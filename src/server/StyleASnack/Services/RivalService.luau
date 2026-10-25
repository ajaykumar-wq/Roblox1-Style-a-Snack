--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local SpeciesConfig = require(ReplicatedStorage.StyleASnack.Config.SpeciesConfig)
local DecorationConfig = require(ReplicatedStorage.StyleASnack.Config.DecorationConfig)
local ThemeConfig = require(ReplicatedStorage.StyleASnack.Config.ThemeConfig)
local ServerJudgeService = require(script.Parent.ServerJudgeService)

local RivalService = {}

export type RivalEntry = {
    EntryId: string,
    Name: string,
    SpeciesId: string,
    Layers: { DecorationConfig.Layer },
    Rubric: ServerJudgeService.RubricReport,
    IsRival: boolean,
}

local RIVAL_NAMES = {
    "Pastry Pete",
    "Frosting Fiona",
    "Sprinkle Sam",
    "Cookie Cleo",
    "Glaze Gordon",
    "Baker Barnaby",
    "Tart Tiana",
    "Muffin Milo",
}

function RivalService.generateRivals(
    occasion: ThemeConfig.Occasion,
    palette: ThemeConfig.Palette,
    unlockedTools: { [string]: boolean },
    playerRank: number
): { RivalEntry }
    local rng = Random.new()
    local rivals: { RivalEntry } = {}

    -- Available tools that rivals can use (only what player unlocked!)
    local availableTools = { "Icing" }
    for toolName, isUnlocked in pairs(unlockedTools) do
        if isUnlocked and toolName ~= "Icing" then
            table.insert(availableTools, toolName)
        end
    end

    -- Pick 5 random unique rival names
    local namePool = table.clone(RIVAL_NAMES)
    for i = 1, 5 do
        local nameIdx = rng:NextInteger(1, #namePool)
        local rivalName = table.remove(namePool, nameIdx)

        -- Pick a species
        local spList = SpeciesConfig.List
        local species = spList[rng:NextInteger(1, #spList)]

        -- Generate believable layers
        local layers: { DecorationConfig.Layer } = {}

        -- 1. Icing (1 to 3 regions)
        local numIcing = rng:NextInteger(1, math.min(3, #SpeciesConfig.Regions))
        local regionsToIce = table.clone(SpeciesConfig.Regions)
        for _ = 1, numIcing do
            local reg = table.remove(regionsToIce, rng:NextInteger(1, #regionsToIce))
            local swatchIdx = rng:NextInteger(1, #palette.Swatches)
            table.insert(layers, {
                Id = HttpService:GenerateGUID(false),
                Tool = "Icing",
                Region = reg,
                SwatchIndex = swatchIdx,
                Color = palette.Swatches[swatchIdx],
            })
        end

        -- 2. Add other unlocked tools if available
        if table.find(availableTools, "Sprinkle") and rng:NextNumber() > 0.3 then
            table.insert(layers, {
                Id = HttpService:GenerateGUID(false),
                Tool = "Sprinkle",
                ItemId = "rainbow_pill",
                Count = rng:NextInteger(15, 40),
                Color = palette.Swatches[rng:NextInteger(1, #palette.Swatches)],
            })
        end

        if table.find(availableTools, "Sticker") and rng:NextNumber() > 0.4 then
            -- Try to match occasion tag occasionally
            local stickerItems = DecorationConfig.Tools.Sticker.Items
            local matchedSticker = nil
            for _, item in ipairs(stickerItems) do
                if item.Tag == occasion.Tag then matchedSticker = item; break end
            end
            local chosenSticker = (matchedSticker and rng:NextNumber() > 0.4) and matchedSticker or stickerItems[rng:NextInteger(1, #stickerItems)]
            table.insert(layers, {
                Id = HttpService:GenerateGUID(false),
                Tool = "Sticker",
                ItemId = chosenSticker.Id,
                Region = "head",
            })
        end

        if table.find(availableTools, "Drizzle") and rng:NextNumber() > 0.5 then
            table.insert(layers, {
                Id = HttpService:GenerateGUID(false),
                Tool = "Drizzle",
                SwatchIndex = rng:NextInteger(1, #palette.Swatches),
                Color = palette.Swatches[rng:NextInteger(1, #palette.Swatches)],
            })
        end

        -- Score rival with ServerJudge
        local rubric = ServerJudgeService.scoreEntry(layers, occasion.Id, palette.Id, #availableTools)

        -- Add slight variance (-5 to +5) for organic feel
        local variance = rng:NextInteger(-5, 5)
        rubric.TotalScore = math.clamp(rubric.TotalScore + variance, 10, 95)
        if rubric.TotalScore <= 20 then
            rubric.Stars = 1
        elseif rubric.TotalScore <= 40 then
            rubric.Stars = 2
        elseif rubric.TotalScore <= 60 then
            rubric.Stars = 3
        elseif rubric.TotalScore <= 80 then
            rubric.Stars = 4
        else
            rubric.Stars = 5
        end

        table.insert(rivals, {
            EntryId = "rival_" .. tostring(i) .. "_" .. tostring(os.time()),
            Name = rivalName,
            SpeciesId = species.Id,
            Layers = layers,
            Rubric = rubric,
            IsRival = true,
        })
    end

    return rivals
end

return RivalService
