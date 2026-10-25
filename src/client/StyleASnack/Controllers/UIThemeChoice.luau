--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.StyleASnack.Network.Remotes)

local UIThemeChoice = {}
local modal: Frame? = nil

function UIThemeChoice.init(parentGui: ScreenGui, onThemeSelected: (any) -> ())
    local frame = Instance.new("Frame")
    frame.Name = "ThemeChoiceModal"
    frame.Size = UDim2.new(0, 640, 0, 420)
    frame.Position = UDim2.new(0.5, -320, 0.5, -210)
    frame.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
    frame.Visible = false
    frame.Parent = parentGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 28
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.Text = "✨ Choose Your Round Theme ✨"
    title.Parent = frame

    local cardsContainer = Instance.new("Frame")
    cardsContainer.Name = "CardsContainer"
    cardsContainer.Size = UDim2.new(1, -40, 0, 250)
    cardsContainer.Position = UDim2.new(0, 20, 0, 60)
    cardsContainer.BackgroundTransparency = 1
    cardsContainer.Parent = frame

    local backBtn = Instance.new("TextButton")
    backBtn.Size = UDim2.new(0, 140, 0, 44)
    backBtn.Position = UDim2.new(0.5, -70, 1, -60)
    backBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 75)
    backBtn.Font = Enum.Font.FredokaOne
    backBtn.TextSize = 18
    backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    backBtn.Text = "Back to Pier"
    backBtn.Parent = frame

    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(0, 14)
    backCorner.Parent = backBtn

    backBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
    end)

    modal = frame
    UIThemeChoice.onSelected = onThemeSelected
end

function UIThemeChoice.open()
    if not modal then return end
    modal.Visible = true
    local cardsContainer = modal:FindFirstChild("CardsContainer") :: Frame?
    if not cardsContainer then return end
    cardsContainer:ClearAllChildren()

    local cards = Remotes.getFunction("RequestThemeCards"):InvokeServer()
    if not cards then return end

    for i, cardData in ipairs(cards) do
        local occ = cardData.Occasion
        local pal = cardData.Palette

        local card = Instance.new("TextButton")
        card.Size = UDim2.new(0, 190, 0, 230)
        card.Position = UDim2.new(0, (i - 1) * 205, 0, 10)
        card.BackgroundColor3 = Color3.fromRGB(45, 38, 55)
        card.Text = ""
        card.Parent = cardsContainer

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 18)
        cCorner.Parent = card

        local occName = Instance.new("TextLabel")
        occName.Size = UDim2.new(1, -20, 0, 36)
        occName.Position = UDim2.new(0, 10, 0, 10)
        occName.BackgroundTransparency = 1
        occName.Font = Enum.Font.FredokaOne
        occName.TextSize = 20
        occName.TextColor3 = Color3.fromRGB(255, 255, 255)
        occName.Text = occ.Name
        occName.Parent = card

        local palName = Instance.new("TextLabel")
        palName.Size = UDim2.new(1, -20, 0, 24)
        palName.Position = UDim2.new(0, 10, 0, 46)
        palName.BackgroundTransparency = 1
        palName.Font = Enum.Font.FredokaOne
        palName.TextSize = 14
        palName.TextColor3 = Color3.fromRGB(255, 215, 0)
        palName.Text = "Palette: " .. pal.Name
        palName.Parent = card

        local swatchRow = Instance.new("Frame")
        swatchRow.Size = UDim2.new(1, -20, 0, 50)
        swatchRow.Position = UDim2.new(0, 10, 0, 80)
        swatchRow.BackgroundTransparency = 1
        swatchRow.Parent = card

        for sIdx = 1, 8 do
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 18, 0, 18)
            dot.Position = UDim2.new(0, ((sIdx - 1) % 4) * 42 + 8, 0, math.floor((sIdx - 1) / 4) * 24)
            dot.BackgroundColor3 = pal.Swatches[sIdx] or Color3.new(1, 1, 1)
            dot.BorderSizePixel = 0
            dot.Parent = swatchRow

            local dCorner = Instance.new("UICorner")
            dCorner.CornerRadius = UDim.new(0, 9)
            dCorner.Parent = dot
        end

        local startLabel = Instance.new("TextLabel")
        startLabel.Size = UDim2.new(1, -20, 0, 40)
        startLabel.Position = UDim2.new(0, 10, 1, -50)
        startLabel.BackgroundColor3 = Color3.fromRGB(255, 107, 107)
        startLabel.Font = Enum.Font.FredokaOne
        startLabel.TextSize = 18
        startLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        startLabel.Text = "▶ Start Round"
        startLabel.Parent = card

        local sCorner = Instance.new("UICorner")
        sCorner.CornerRadius = UDim.new(0, 12)
        sCorner.Parent = startLabel

        card.MouseButton1Click:Connect(function()
            modal.Visible = false
            if UIThemeChoice.onSelected then
                UIThemeChoice.onSelected(cardData)
            end
        end)
    end
end

return UIThemeChoice
