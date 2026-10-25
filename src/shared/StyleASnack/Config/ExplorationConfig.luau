--!strict
local ExplorationConfig = {}

export type Landmark = {
    Id: string,
    Name: string,
    Description: string,
    HiddenStickerId: string,
    Clue: string,
    Position: Vector3,
}

export type VisitorRequest = {
    Id: string,
    NpcName: string,
    Greeting: string,
    TargetSpecies: string,
    RequiredTool: string,
    RequiredItem: string?,
    Duration: number, -- 60s mini round
    RewardSparkle: number,
}

ExplorationConfig.Landmarks = {
    {
        Id = "lighthouse",
        Name = "Lighthouse",
        Description = "Towers over the northern point of the boardwalk.",
        HiddenStickerId = "star",
        Clue = "Look high up on the lighthouse observation gallery.",
        Position = Vector3.new(0, 18, 160),
    },
    {
        Id = "ferris_wheel",
        Name = "Ferris Wheel",
        Description = "A giant pastel wheel offering panoramic views of the harbor.",
        HiddenStickerId = "balloon",
        Clue = "Take a spin inside one of the wheel's sky gondolas.",
        Position = Vector3.new(35, 12, 100),
    },
    {
        Id = "candy_stand",
        Name = "Candy Stand",
        Description = "Sweet aromas of fresh sugar glaze and spun confection.",
        HiddenStickerId = "heart",
        Clue = "Peek behind the jars on the candy counter.",
        Position = Vector3.new(-22, 4, 60),
    },
    {
        Id = "fishing_dock",
        Name = "Fishing Dock",
        Description = "A quiet wooden pier extending out into the gentle bay.",
        HiddenStickerId = "fish",
        Clue = "Walk all the way to the end of the bait dock.",
        Position = Vector3.new(25, 3, 20),
    },
    {
        Id = "tide_pools",
        Name = "Tide Pools",
        Description = "Rocky coastal pools tucked beneath the boardwalk deck.",
        HiddenStickerId = "raindrop",
        Clue = "Hop down among the moist mossy rocks under the pier.",
        Position = Vector3.new(-25, 1, -20),
    },
}

ExplorationConfig.GoldenSprinkles = {
    { Id = "gold_1", Position = Vector3.new(25, 4.5, 25), LandmarkId = "fishing_dock" },
    { Id = "gold_2", Position = Vector3.new(-24, 2, -22), LandmarkId = "tide_pools" },
    { Id = "gold_3", Position = Vector3.new(2, 22, 160), LandmarkId = "lighthouse" },
}

ExplorationConfig.Visitors = {
    {
        Id = "bonnie",
        NpcName = "Baker Bonnie",
        Greeting = "Can you make my Croissant Cat look royal with a pretty Bow?",
        TargetSpecies = "croissant_cat",
        RequiredTool = "Accessory",
        RequiredItem = "bow",
        Duration = 60,
        RewardSparkle = 15,
    },
    {
        Id = "crust",
        NpcName = "Captain Crust",
        Greeting = "Ahoy! Can you style a snack with ocean Drizzle and a Fish sticker?",
        TargetSpecies = "taco_turtle",
        RequiredTool = "Sticker",
        RequiredItem = "fish",
        Duration = 60,
        RewardSparkle = 15,
    },
    {
        Id = "sally",
        NpcName = "Sweet Sally",
        Greeting = "I'd love a Mochi Bunny covered in sweet sprinkles and party colors!",
        TargetSpecies = "mochi_bunny",
        RequiredTool = "Sprinkle",
        RequiredItem = "rainbow_pill",
        Duration = 60,
        RewardSparkle = 15,
    },
}

function ExplorationConfig.getLandmark(id: string): Landmark?
    for _, l in ipairs(ExplorationConfig.Landmarks) do
        if l.Id == id then return l end
    end
    return nil
end

return ExplorationConfig
