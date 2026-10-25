--!strict
local SpeciesConfig = {}

export type Rarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Mythic"

export type Species = {
    Id: string,
    Name: string,
    Family: string,
    Rarity: Rarity,
    Description: string,
    SilhouetteNote: string,
    BaseColor: Color3,
    Regions: { string },
    Attachments: { string },
}

SpeciesConfig.Regions = { "head", "body", "back", "tail" }
SpeciesConfig.Attachments = { "head", "back", "tail", "paws" }

SpeciesConfig.Rarities = {
    Common = { Name = "Common", Color = Color3.fromHex("#9E9E9E"), Order = 1 },
    Uncommon = { Name = "Uncommon", Color = Color3.fromHex("#4CAF50"), Order = 2 },
    Rare = { Name = "Rare", Color = Color3.fromHex("#2196F3"), Order = 3 },
    Epic = { Name = "Epic", Color = Color3.fromHex("#9C27B0"), Order = 4 },
    Mythic = { Name = "Mythic", Color = Color3.fromHex("#FF9800"), Order = 5 },
}

SpeciesConfig.List = {
    {
        Id = "croissant_cat",
        Name = "Croissant Cat",
        Family = "Bakery",
        Rarity = "Common",
        Description = "Flaky, buttery layers with cute cat ears and a curled tail.",
        SilhouetteNote = "Layered crescent body, cat ears",
        BaseColor = Color3.fromHex("#E5A96A"),
        Regions = SpeciesConfig.Regions,
        Attachments = SpeciesConfig.Attachments,
    },
    {
        Id = "donut_pup",
        Name = "Donut Pup",
        Family = "Bakery",
        Rarity = "Common",
        Description = "Sweet glazed ring body with adorable floppy puppy ears.",
        SilhouetteNote = "Ring body, floppy ears, glazed top",
        BaseColor = Color3.fromHex("#D79F6E"),
        Regions = SpeciesConfig.Regions,
        Attachments = SpeciesConfig.Attachments,
    },
    {
        Id = "taco_turtle",
        Name = "Taco Turtle",
        Family = "Savory",
        Rarity = "Common",
        Description = "Golden folded shell with a crisp lettuce frill collar.",
        SilhouetteNote = "Shell is the folded tortilla, lettuce frill",
        BaseColor = Color3.fromHex("#F4C46A"),
        Regions = SpeciesConfig.Regions,
        Attachments = SpeciesConfig.Attachments,
    },
    {
        Id = "mochi_bunny",
        Name = "Mochi Bunny",
        Family = "Sweets",
        Rarity = "Uncommon",
        Description = "Soft, pillowy rice-dough bunny with velvety powdered cheeks.",
        SilhouetteNote = "Round, soft, long ears; powdered matte surface",
        BaseColor = Color3.fromHex("#FFF0F5"),
        Regions = SpeciesConfig.Regions,
        Attachments = SpeciesConfig.Attachments,
    },
    {
        Id = "popsicle_penguin",
        Name = "Popsicle Penguin",
        Family = "Frozen",
        Rarity = "Uncommon",
        Description = "Chilled fruity treat with frosty wings and a wooden stick tail.",
        SilhouetteNote = "Tall, stick tail, frosty sheen",
        BaseColor = Color3.fromHex("#70D6FF"),
        Regions = SpeciesConfig.Regions,
        Attachments = SpeciesConfig.Attachments,
    },
    {
        Id = "dumpling_duck",
        Name = "Dumpling Duck",
        Family = "Street food",
        Rarity = "Rare",
        Description = "Warm steamed dumpling with delicate pleats forming an elegant crest.",
        SilhouetteNote = "Pleated top as a crest; the prototype's reveal Rare",
        BaseColor = Color3.fromHex("#FBF7E4"),
        Regions = SpeciesConfig.Regions,
        Attachments = SpeciesConfig.Attachments,
    },
}

function SpeciesConfig.getSpeciesById(id: string): Species?
    for _, sp in ipairs(SpeciesConfig.List) do
        if sp.Id == id then return sp end
    end
    return nil
end

function SpeciesConfig.getSpeciesByRarity(rarity: Rarity): { Species }
    local result = {}
    for _, sp in ipairs(SpeciesConfig.List) do
        if sp.Rarity == rarity then
            table.insert(result, sp)
        end
    end
    return result
end

return SpeciesConfig
