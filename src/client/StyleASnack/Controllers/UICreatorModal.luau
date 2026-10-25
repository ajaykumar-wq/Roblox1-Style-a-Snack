--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Remotes = require(ReplicatedStorage.StyleASnack.Network.Remotes)

local UICreatorModal = {}
local modal: Frame? = nil

local FAMILIES = {
    { Id = "Bakery", Name = "Bakery", Species = "croissant_cat", Icon = "🥐", Desc = "Flaky & buttery" },
    { Id = "Sweets", Name = "Sweets", Species = "mochi_bunny", Icon = "🍡", Desc = "Soft & powdered" },
    { Id = "Savory", Name = "Savory", Species = "taco_turtle", Icon = "🌮", Desc = "Crisp & golden" },
    { Id = "Frozen", Name = "Frozen", Species = "popsicle_penguin", Icon = "🍧", Desc = "Frosty sheen" },
    { Id = "Street food", Name = "Street food", Species = "dumpling_duck", Icon = "🥟", Desc = "Pleated crest" },
}

local FLAVORS = {
    { Id = "Classic", Name = "Classic Glaze", Color = Color3.fromHex("#E5A96A") },
    { Id = "Strawberry", Name = "Strawberry Pink", Color = Color3.fromHex("#FF8DA1") },
    { Id = "Matcha", Name = "Matcha Green", Color = Color3.fromHex("#8BC34A") },
}

local EYE_SHAPES = { "Round", "Almond" }

local CURATED_NAMES = {
    Bakery = { "Buttercup", "Biscuit", "Fluffy", "Crumb", "Croissant", "Puff", "Brioche", "Cookie", "Muffin", "Bagel" },
    Sweets = { "Mochi", "Sugar", "Caramel", "Marshmallow", "Berry", "Honey", "Taffy", "Cotton", "Gummy", "Jelly" },
    Savory = { "Nacho", "Nori", "Pepper", "Chip", "Taco", "Cheesy", "Salsa", "Sesame", "Toast", "Crisp" },
    Frozen = { "Frosty", "Snowball", "Sherbet", "Chilly", "Popsicle", "Minty", "Glacier", "Sorbet", "Icee", "Sundae" },
    ["Street food"] = { "Dumpling", "Bao", "Wonton", "Boba", "Gyoza", "Panko", "Katsu", "Roll", "Dimsum", "Ginger" },
}

local selectedFamily = FAMILIES[1]
local selectedFlavor = FLAVORS[1]
local selectedEyeShape = EYE_SHAPES[1]
local selectedName = "Buttercup"

function UICreatorModal.init(parentGui: ScreenGui, onCompleted: (any) -> ())
    local frame = Instance.new("Frame")
    frame.Name = "CreatorModal"
    frame.Size = UDim2.new(0, 580, 0, 460)
    frame.Position = UDim2.new(0.5, -290, 0.5, -230)
    frame.BackgroundColor3 = Color3.fromRGB(30, 24, 40)
    frame.Visible = false
    frame.Parent = parentGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 46)
    title.Position = UDim2.new(0, 0, 0, 8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 26
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.Text = "✨ Meet Your Snackimal ✨"
    title.Parent = frame

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 24)
    subtitle.Position = UDim2.new(0, 0, 0, 48)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.FredokaOne
    subtitle.TextSize = 14
    subtitle.TextColor3 = Color3.fromRGB(200, 195, 220)
    subtitle.Text = "Pick a food family, look, and name before your first round!"
    subtitle.Parent = frame

    -- Step 1: Family Selection
    local familyFrame = Instance.new("Frame")
    familyFrame.Name = "FamilyFrame"
    familyFrame.Size = UDim2.new(1, -40, 0, 90)
    familyFrame.Position = UDim2.new(0, 20, 0, 80)
    familyFrame.BackgroundColor3 = Color3.fromRGB(42, 34, 56)
    familyFrame.Parent = frame

    local ffCorner = Instance.new("UICorner")
    ffCorner.CornerRadius = UDim.new(0, 14)
    ffCorner.Parent = familyFrame

    local familyButtons = {}
    for i, fam in ipairs(FAMILIES) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 96, 0, 70)
        btn.Position = UDim2.new(0, 10 + (i - 1) * 105, 0, 10)
        btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(255, 107, 107) or Color3.fromRGB(60, 50, 75)
        btn.Font = Enum.Font.FredokaOne
        btn.TextSize = 13
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = fam.Icon .. "\n" .. fam.Name
        btn.Parent = familyFrame

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 12)
        bCorner.Parent = btn

        table.insert(familyButtons, btn)

        btn.MouseButton1Click:Connect(function()
            selectedFamily = fam
            for _, otherBtn in ipairs(familyButtons) do
                otherBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 75)
            end
            btn.BackgroundColor3 = Color3.fromRGB(255, 107, 107)
            local names = CURATED_NAMES[fam.Id] or CURATED_NAMES.Bakery
            selectedName = names[1]
        end)
    end

    -- Step 2: Flavor & Look
    local lookFrame = Instance.new("Frame")
    lookFrame.Name = "LookFrame"
    lookFrame.Size = UDim2.new(1, -40, 0, 80)
    lookFrame.Position = UDim2.new(0, 20, 0, 180)
    lookFrame.BackgroundColor3 = Color3.fromRGB(42, 34, 56)
    lookFrame.Parent = frame

    local lfCorner = Instance.new("UICorner")
    lfCorner.CornerRadius = UDim.new(0, 14)
    lfCorner.Parent = lookFrame

    local flavorLabel = Instance.new("TextLabel")
    flavorLabel.Size = UDim2.new(0, 140, 0, 30)
    flavorLabel.Position = UDim2.new(0, 15, 0, 25)
    flavorLabel.BackgroundTransparency = 1
    flavorLabel.Font = Enum.Font.FredokaOne
    flavorLabel.TextSize = 16
    flavorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    flavorLabel.Text = "Flavor Glaze:"
    flavorLabel.Parent = lookFrame

    for fIdx, flv in ipairs(FLAVORS) do
        local fBtn = Instance.new("TextButton")
        fBtn.Size = UDim2.new(0, 100, 0, 44)
        fBtn.Position = UDim2.new(0, 150 + (fIdx - 1) * 115, 0, 18)
        fBtn.BackgroundColor3 = flv.Color
        fBtn.Font = Enum.Font.FredokaOne
        fBtn.TextSize = 13
        fBtn.TextColor3 = Color3.fromRGB(40, 20, 10)
        fBtn.Text = flv.Name
        fBtn.Parent = lookFrame

        local fbCorner = Instance.new("UICorner")
        fbCorner.CornerRadius = UDim.new(0, 10)
        fbCorner.Parent = fBtn

        fBtn.MouseButton1Click:Connect(function()
            selectedFlavor = flv
        end)
    end

    -- Step 3: Name Selection Display
    local nameFrame = Instance.new("Frame")
    nameFrame.Name = "NameFrame"
    nameFrame.Size = UDim2.new(1, -40, 0, 70)
    nameFrame.Position = UDim2.new(0, 20, 0, 270)
    nameFrame.BackgroundColor3 = Color3.fromRGB(42, 34, 56)
    nameFrame.Parent = frame

    local nfCorner = Instance.new("UICorner")
    nfCorner.CornerRadius = UDim.new(0, 14)
    nfCorner.Parent = nameFrame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -20, 1, 0)
    nameLabel.Position = UDim2.new(0, 10, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.FredokaOne
    nameLabel.TextSize = 20
    nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    nameLabel.Text = "Companion Name: " .. selectedName
    nameLabel.Parent = nameFrame

    -- Bottom Buttons: "Surprise Me!" (Big) + "Ready!"
    local bottomRow = Instance.new("Frame")
    bottomRow.Size = UDim2.new(1, -40, 0, 55)
    bottomRow.Position = UDim2.new(0, 20, 1, -70)
    bottomRow.BackgroundTransparency = 1
    bottomRow.Parent = frame

    local surpriseBtn = Instance.new("TextButton")
    surpriseBtn.Size = UDim2.new(0.48, 0, 1, 0)
    surpriseBtn.Position = UDim2.new(0, 0, 0, 0)
    surpriseBtn.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
    surpriseBtn.Font = Enum.Font.FredokaOne
    surpriseBtn.TextSize = 18
    surpriseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    surpriseBtn.Text = "🎲 Surprise Me!"
    surpriseBtn.Parent = bottomRow

    local spCorner = Instance.new("UICorner")
    spCorner.CornerRadius = UDim.new(0, 16)
    spCorner.Parent = surpriseBtn

    local readyBtn = Instance.new("TextButton")
    readyBtn.Size = UDim2.new(0.48, 0, 1, 0)
    readyBtn.Position = UDim2.new(0.52, 0, 0, 0)
    readyBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    readyBtn.Font = Enum.Font.FredokaOne
    readyBtn.TextSize = 20
    readyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    readyBtn.Text = "Ready! ▶"
    readyBtn.Parent = bottomRow

    local rdCorner = Instance.new("UICorner")
    rdCorner.CornerRadius = UDim.new(0, 16)
    rdCorner.Parent = readyBtn

    local function finalizeSelection()
        frame.Visible = false
        local data = {
            Family = selectedFamily.Id,
            Flavor = selectedFlavor.Id,
            EyeShape = selectedEyeShape,
            Name = selectedName,
        }
        Remotes.getFunction("SubmitCreatorData"):InvokeServer(data)
        if onCompleted then
            onCompleted(data)
        end
    end

    surpriseBtn.MouseButton1Click:Connect(function()
        local rng = Random.new()
        selectedFamily = FAMILIES[rng:NextInteger(1, #FAMILIES)]
        selectedFlavor = FLAVORS[rng:NextInteger(1, #FLAVORS)]
        selectedEyeShape = EYE_SHAPES[rng:NextInteger(1, #EYE_SHAPES)]
        local names = CURATED_NAMES[selectedFamily.Id] or CURATED_NAMES.Bakery
        selectedName = names[rng:NextInteger(1, #names)]
        finalizeSelection()
    end)

    readyBtn.MouseButton1Click:Connect(finalizeSelection)

    modal = frame
end

function UICreatorModal.open()
    if not modal then return end
    modal.Visible = true
    modal.Position = UDim2.new(0.5, -290, 0, -480)
    TweenService:Create(modal, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -290, 0.5, -230),
    }):Play()
end

function UICreatorModal.hide()
    if modal then modal.Visible = false end
end

return UICreatorModal
