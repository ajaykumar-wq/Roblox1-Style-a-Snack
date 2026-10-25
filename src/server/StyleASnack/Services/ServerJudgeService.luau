--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ThemeConfig = require(ReplicatedStorage.StyleASnack.Config.ThemeConfig)
local DecorationConfig = require(ReplicatedStorage.StyleASnack.Config.DecorationConfig)
local SpeciesConfig = require(ReplicatedStorage.StyleASnack.Config.SpeciesConfig)

local ServerJudgeService = {}

export type DecorationLayer = DecorationConfig.Layer

export type RubricReport = {
    PaletteScore: number,   -- Max 40
    CoverageScore: number,  -- Max 30
    VarietyScore: number,   -- Max 20
    OccasionScore: number,  -- Max 10
    TotalScore: number,     -- Max 100
    Stars: number,          -- 1 to 5
}

function ServerJudgeService.scoreEntry(
    layers: { DecorationLayer },
    occasionId: string,
    paletteId: string,
    unlockedToolCount: number
): RubricReport
    local occasion = ThemeConfig.getOccasionById(occasionId)
    local palette = ThemeConfig.getPaletteById(paletteId)

    if #layers == 0 then
        return {
            PaletteScore = 0,
            CoverageScore = 0,
            VarietyScore = 0,
            OccasionScore = 0,
            TotalScore = 0,
            Stars = 1,
        }
    end

    -- 1. Palette adherence (40 points)
    -- In prototype, swatches are chosen from theme palette
    local paletteScore = 40

    -- 2. Coverage (30 points)
    -- Share of 4 regions (head, body, back, tail) that carry at least one layer
    local regionsCovered: { [string]: boolean } = {}
    for _, layer in ipairs(layers) do
        if layer.Region then
            regionsCovered[layer.Region] = true
        end
    end
    local coveredCount = 0
    for _, regionName in ipairs(SpeciesConfig.Regions) do
        if regionsCovered[regionName] then
            coveredCount += 1
        end
    end
    local coverageScore = math.floor((coveredCount / #SpeciesConfig.Regions) * 30)

    -- 3. Variety (20 points)
    -- Distinct tool types used, out of those unlocked
    local toolsUsed: { [string]: boolean } = {}
    for _, layer in ipairs(layers) do
        toolsUsed[layer.Tool] = true
    end
    local distinctToolCount = 0
    for _ in pairs(toolsUsed) do
        distinctToolCount += 1
    end
    local maxTools = math.clamp(unlockedToolCount or 2, 1, 6)
    local varietyScore = math.floor(math.clamp(distinctToolCount / maxTools, 0, 1) * 20)

    -- 4. Occasion match (10 points)
    -- At least one sticker or accessory whose tag matches the occasion
    local occasionScore = 0
    if occasion then
        for _, layer in ipairs(layers) do
            if layer.Tool == "Sticker" and layer.ItemId then
                local item = DecorationConfig.getStickerById(layer.ItemId)
                if item and item.Tag == occasion.Tag then
                    occasionScore = 10
                    break
                end
            elseif layer.Tool == "Accessory" and layer.ItemId then
                local item = DecorationConfig.getAccessoryById(layer.ItemId)
                if item and item.Tag == occasion.Tag then
                    occasionScore = 10
                    break
                end
            end
        end
    end

    local totalScore = math.clamp(paletteScore + coverageScore + varietyScore + occasionScore, 0, 100)

    -- Rubric Mapping: 0 to 20 is 1 star, 21 to 40 two, 41 to 60 three, 61 to 80 four, 81 to 100 five
    local stars = 1
    if totalScore <= 20 then
        stars = 1
    elseif totalScore <= 40 then
        stars = 2
    elseif totalScore <= 60 then
        stars = 3
    elseif totalScore <= 80 then
        stars = 4
    else
        stars = 5
    end

    return {
        PaletteScore = paletteScore,
        CoverageScore = coverageScore,
        VarietyScore = varietyScore,
        OccasionScore = occasionScore,
        TotalScore = totalScore,
        Stars = stars,
    }
end

return ServerJudgeService
