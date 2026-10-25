--!strict
local DecorationConfig = {}

export type ToolType = "Icing" | "Sprinkle" | "Sticker" | "Drizzle" | "Pattern" | "Accessory"

export type Layer = {
    Id: string,
    Tool: ToolType,
    Region: string?,         -- "head" | "body" | "back" | "tail"
    Attachment: string?,     -- "head" | "back" | "tail" | "paws"
    SwatchIndex: number?,    -- 1 to 8
    Color: Color3?,
    ItemId: string?,         -- Sticker id, pattern id, accessory id, or sprinkle shape
    Position: Vector3?,
    Points: { Vector3 }?,    -- For drizzle lines or sprinkle points
    Count: number?,          -- For sprinkles (max 60)
}

DecorationConfig.MaxLayersPerEntry = 12

DecorationConfig.LayerRenderPriority = {
    Icing = 1,
    Pattern = 2,
    Drizzle = 3,
    Sprinkle = 4,
    Sticker = 5,
    Accessory = 6,
}

DecorationConfig.Tools = {
    Icing = {
        Name = "Icing",
        Slot = 1,
        UnlockRank = 1,
        Sound = "wet_pop",
        MaxPerRegion = 1,
        AllowedRegions = { "head", "body", "back", "tail" },
        Description = "Fills a region with smooth, shiny frosting.",
    },
    Sprinkle = {
        Name = "Sprinkle",
        Slot = 2,
        UnlockRank = 1,
        Sound = "rattle",
        MaxLayers = 2,
        MaxPiecesPerLayer = 60,
        Shapes = {
            { Id = "rainbow_pill", Name = "Rainbow Pills" },
            { Id = "star_pearl", Name = "Star Pearls" },
            { Id = "chocolate_flake", Name = "Chocolate Flakes" },
        },
        Description = "Scatter sweet crunchy sprinkles over your snack.",
    },
    Sticker = {
        Name = "Sticker",
        Slot = 3,
        UnlockRank = 3,
        Sound = "pop",
        MaxPerEntry = 4,
        Items = {
            { Id = "star", Name = "Golden Star", Tag = "space" },
            { Id = "heart", Name = "Sugar Heart", Tag = "birthday" },
            { Id = "bow", Name = "Silk Ribbon Bow", Tag = "royal" },
            { Id = "lightning", Name = "Spark Bolt", Tag = "sports" },
            { Id = "cloud", Name = "Fluffy Cloud", Tag = "rain" },
            { Id = "flower", Name = "Blossom Flower", Tag = "garden" },
            { Id = "crown", Name = "Royal Tiara", Tag = "royal" },
            { Id = "sun", Name = "Sunny Sun", Tag = "beach" },
            { Id = "raindrop", Name = "Dew Drop", Tag = "rain" },
            { Id = "balloon", Name = "Party Balloon", Tag = "birthday" },
            { Id = "leaf", Name = "Tea Leaf", Tag = "tea" },
            { Id = "fish", Name = "Little Fish", Tag = "beach" },
        },
        Description = "Apply colorful themed badges and stickers.",
    },
    Drizzle = {
        Name = "Drizzle",
        Slot = 4,
        UnlockRank = 6,
        Sound = "hum",
        MaxLines = 3,
        MaxDurationSeconds = 2.0,
        Description = "Drag rich glossy syrup across your creature.",
    },
    Pattern = {
        Name = "Pattern",
        Slot = 5,
        UnlockRank = 10,
        Sound = "unroll",
        MaxPerRegion = 1,
        Items = {
            { Id = "dots", Name = "Polka Dots" },
            { Id = "stripes", Name = "Candy Stripes" },
            { Id = "checks", Name = "Picnic Checks" },
            { Id = "hearts", Name = "Sweet Hearts" },
            { Id = "waves", Name = "Ocean Waves" },
            { Id = "confetti", Name = "Carnival Confetti" },
        },
        Description = "Stamps tiled decorative textures across a region.",
    },
    Accessory = {
        Name = "Accessory",
        Slot = 6,
        UnlockRank = 15,
        Sound = "click",
        MaxPerEntry = 2,
        AllowedAttachments = { "head", "back", "tail", "paws" },
        Items = {
            { Id = "bow", Name = "Velvet Bow", PreferredAttachment = "head", Tag = "royal" },
            { Id = "mini_hat", Name = "Chef Mini Hat", PreferredAttachment = "head", Tag = "tea" },
            { Id = "bell_collar", Name = "Golden Bell Collar", PreferredAttachment = "head", Tag = "garden" },
            { Id = "backpack", Name = "Picnic Backpack", PreferredAttachment = "back", Tag = "picnic" },
            { Id = "tail_ribbon", Name = "Satin Tail Ribbon", PreferredAttachment = "tail", Tag = "carnival" },
            { Id = "sunglasses", Name = "Cool Sunglasses", PreferredAttachment = "head", Tag = "beach" },
        },
        Description = "Clip on cute wearable props and accessories.",
    },
}

function DecorationConfig.getStickerById(id: string)
    for _, item in ipairs(DecorationConfig.Tools.Sticker.Items) do
        if item.Id == id then return item end
    end
    return nil
end

function DecorationConfig.getAccessoryById(id: string)
    for _, item in ipairs(DecorationConfig.Tools.Accessory.Items) do
        if item.Id == id then return item end
    end
    return nil
end

return DecorationConfig
