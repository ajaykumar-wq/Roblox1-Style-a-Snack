--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpeciesConfig = require(ReplicatedStorage.StyleASnack.Config.SpeciesConfig)

local UIIndexModal = {}
local modal: Frame? = nil

function UIIndexModal.init(parentGui: ScreenGui)
    local frame = Instance.new("Frame")
    frame.Name = "IndexModal"
    frame.Size = UDim2.new(0, 560, 0, 420)
    frame.Position = UDim2.new(0.5, -280, 0.5, -210)
    frame.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
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
    title.TextColor3 = Color3.fromRGB(130, 220, 255)
    title.Text = "📖 Species Index"
    title.Parent = frame

    local grid = Instance.new("ScrollingFrame")
    grid.Size = UDim2.new(1, -40, 0.65, 0)
    grid.Position = UDim2.new(0, 20, 0, 60)
    grid.BackgroundTransparency = 1
    grid.Parent = frame

    for idx, sp in ipairs(SpeciesConfig.List) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, 150, 0, 100)
        card.Position = UDim2.new(0, ((idx - 1) % 3) * 165, 0, math.floor((idx - 1) / 3) * 115)
        card.BackgroundColor3 = Color3.fromRGB(50, 45, 65)
        card.Parent = grid

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 14)
        cardCorner.Parent = card

        local cardLabel = Instance.new("TextLabel")
        cardLabel.Size = UDim2.new(1, 0, 1, 0)
        cardLabel.BackgroundTransparency = 1
        cardLabel.Font = Enum.Font.FredokaOne
        cardLabel.TextSize = 16
        cardLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        cardLabel.Text = sp.Name .. "\n(" .. sp.Rarity .. ")"
        cardLabel.Parent = card
    end

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 120, 0, 40)
    closeBtn.Position = UDim2.new(0.5, -60, 0.88, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 75)
    closeBtn.Font = Enum.Font.FredokaOne
    closeBtn.TextSize = 18
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "Close"
    closeBtn.Parent = frame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 12)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
    end)

    modal = frame
end

function UIIndexModal.open()
    if modal then modal.Visible = true end
end

return UIIndexModal
