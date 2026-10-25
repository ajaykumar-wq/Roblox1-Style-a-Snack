--!strict
local ThemeConfig = {}

export type Occasion = {
    Id: string,
    Name: string,
    Tag: string,
    Description: string,
}

export type Palette = {
    Id: string,
    Name: string,
    Swatches: { Color3 },
    SwatchNames: { string },
    NeutralIndices: { number },
}

ThemeConfig.Occasions = {
    { Id = "beach_day", Name = "Beach day", Tag = "beach", Description = "Sunshine, sand, and seaside snacks" },
    { Id = "royal_gala", Name = "Royal gala", Tag = "royal", Description = "Crowns, jewels, and royal feasts" },
    { Id = "rainy_monday", Name = "Rainy Monday", Tag = "rain", Description = "Cozy puddles, clouds, and sweet treats" },
    { Id = "birthday", Name = "Birthday", Tag = "birthday", Description = "Candles, balloons, and celebration cakes" },
    { Id = "picnic", Name = "Picnic", Tag = "picnic", Description = "Checkered blankets, sunshine, and park snacks" },
    { Id = "space_camp", Name = "Space camp", Tag = "space", Description = "Cosmic frostings, stars, and alien treats" },
    { Id = "garden_party", Name = "Garden party", Tag = "garden", Description = "Blooms, butterflies, and floral pastries" },
    { Id = "pajama_night", Name = "Pajama night", Tag = "pajama", Description = "Midnight cookies, slippers, and lullabies" },
    { Id = "winter_market", Name = "Winter market", Tag = "winter", Description = "Snowflakes, hot cocoa, and frosted pies" },
    { Id = "carnival", Name = "Carnival", Tag = "carnival", Description = "Ferris wheels, candy swirl, and popcorn joy" },
    { Id = "tea_time", Name = "Tea time", Tag = "tea", Description = "Fine china, macaron pastels, and biscuits" },
    { Id = "sports_day", Name = "Sports day", Tag = "sports", Description = "Energy snacks, ribbons, and championship frostings" },
}

ThemeConfig.Palettes = {
    {
        Id = "sunny",
        Name = "Sunny",
        Swatches = {
            Color3.fromHex("#FF6F59"), -- coral
            Color3.fromHex("#FFF176"), -- lemon
            Color3.fromHex("#81D4FA"), -- sky
            Color3.fromHex("#A7FFEB"), -- mint
            Color3.fromHex("#FFCCBC"), -- peach
            Color3.fromHex("#E1BEE7"), -- lilac
            Color3.fromHex("#FFFDD0"), -- cream (neutral)
            Color3.fromHex("#5D4037"), -- cocoa (neutral)
        },
        SwatchNames = { "Coral", "Lemon", "Sky", "Mint", "Peach", "Lilac", "Cream", "Cocoa" },
        NeutralIndices = { 7, 8 },
    },
    {
        Id = "royal",
        Name = "Royal",
        Swatches = {
            Color3.fromHex("#8E24AA"), -- plum
            Color3.fromHex("#FFD700"), -- gold
            Color3.fromHex("#1A237E"), -- navy
            Color3.fromHex("#C2185B"), -- ruby
            Color3.fromHex("#F8BBD0"), -- blush
            Color3.fromHex("#00897B"), -- teal
            Color3.fromHex("#FFFFF0"), -- ivory (neutral)
            Color3.fromHex("#212121"), -- charcoal (neutral)
        },
        SwatchNames = { "Plum", "Gold", "Navy", "Ruby", "Blush", "Teal", "Ivory", "Charcoal" },
        NeutralIndices = { 7, 8 },
    },
    {
        Id = "rain",
        Name = "Rain",
        Swatches = {
            Color3.fromHex("#78909C"), -- slate
            Color3.fromHex("#1565C0"), -- denim
            Color3.fromHex("#558B2F"), -- moss
            Color3.fromHex("#FBC02D"), -- mustard
            Color3.fromHex("#EC407A"), -- rose
            Color3.fromHex("#E0F7FA"), -- ice
            Color3.fromHex("#CFD8DC"), -- fog (neutral)
            Color3.fromHex("#1A1A24"), -- ink (neutral)
        },
        SwatchNames = { "Slate", "Denim", "Moss", "Mustard", "Rose", "Ice", "Fog", "Ink" },
        NeutralIndices = { 7, 8 },
    },
    {
        Id = "party",
        Name = "Party",
        Swatches = {
            Color3.fromHex("#FF4081"), -- bubblegum
            Color3.fromHex("#FF6D00"), -- tangerine
            Color3.fromHex("#76FF03"), -- lime
            Color3.fromHex("#00E5FF"), -- cyan
            Color3.fromHex("#7C4DFF"), -- violet
            Color3.fromHex("#FFFF00"), -- banana
            Color3.fromHex("#FFFFFF"), -- white (neutral)
            Color3.fromHex("#3E2723"), -- chocolate (neutral)
        },
        SwatchNames = { "Bubblegum", "Tangerine", "Lime", "Cyan", "Violet", "Banana", "White", "Chocolate" },
        NeutralIndices = { 7, 8 },
    },
}

ThemeConfig.RepeatGuards = {
    OccasionMemory = 30, -- Do not repeat occasion within 30 rounds
    PaletteMemory = 10,  -- Do not repeat palette within 10 rounds
}

function ThemeConfig.getOccasionById(id: string): Occasion?
    for _, occ in ipairs(ThemeConfig.Occasions) do
        if occ.Id == id then return occ end
    end
    return nil
end

function ThemeConfig.getPaletteById(id: string): Palette?
    for _, pal in ipairs(ThemeConfig.Palettes) do
        if pal.Id == id then return pal end
    end
    return nil
end

return ThemeConfig
