--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ExplorationConfig = require(ReplicatedStorage.StyleASnack.Config.ExplorationConfig)

local UIMapModal = {}
local modal: Frame? = nil

function UIMapModal.init(parentGui: ScreenGui)
    local frame = Instance.new("Frame")
    frame.Name = "MapModal"
    frame.Size = UDim2.new(0, 600, 0, 460)
    frame.Position = UDim2.new(0.5, -300, 0.5, -230)
    frame.BackgroundColor3 = Color3.fromRGB(30, 38, 50)
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
    title.TextColor3 = Color3.fromRGB(110, 230, 160)
    title.Text = "🗺️ Sprinkle Harbor Map Board"
    title.Parent = frame

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -40, 0.7, 0)
    list.Position = UDim2.new(0, 20, 0, 60)
    list.BackgroundTransparency = 1
    list.Parent = frame

    for idx, lm in ipairs(ExplorationConfig.Landmarks) do
        local lmCard = Instance.new("Frame")
        lmCard.Size = UDim2.new(1, -10, 0, 60)
        lmCard.Position = UDim2.new(0, 5, 0, (idx - 1) * 70)
        lmCard.BackgroundColor3 = Color3.fromRGB(45, 55, 70)
        lmCard.Parent = list

        local lc = Instance.new("UICorner")
        lc.CornerRadius = UDim.new(0, 14)
        lc.Parent = lmCard

        local lmName = Instance.new("TextLabel")
        lmName.Size = UDim2.new(0.5, 0, 0, 26)
        lmName.Position = UDim2.new(0, 14, 0, 6)
        lmName.BackgroundTransparency = 1
        lmName.Font = Enum.Font.FredokaOne
        lmName.TextSize = 18
        lmName.TextColor3 = Color3.fromRGB(255, 255, 255)
        lmName.TextXAlignment = Enum.TextXAlignment.Left
        lmName.Text = "📍 " .. lm.Name
        lmName.Parent = lmCard

        local lmClue = Instance.new("TextLabel")
        lmClue.Size = UDim2.new(1, -28, 0, 22)
        lmClue.Position = UDim2.new(0, 14, 0, 32)
        lmClue.BackgroundTransparency = 1
        lmClue.Font = Enum.Font.FredokaOne
        lmClue.TextSize = 13
        lmClue.TextColor3 = Color3.fromRGB(255, 220, 120)
        lmClue.TextXAlignment = Enum.TextXAlignment.Left
        lmClue.Text = "Clue: " .. lm.Clue
        lmClue.Parent = lmCard
    end

    local helpBtn = Instance.new("TextButton")
    helpBtn.Size = UDim2.new(0, 150, 0, 44)
    helpBtn.Position = UDim2.new(0.5, -160, 1, -55)
    helpBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    helpBtn.Font = Enum.Font.FredokaOne
    helpBtn.TextSize = 16
    helpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    helpBtn.Text = "❓ Help (Controls)"
    helpBtn.Parent = frame

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 14)
    hCorner.Parent = helpBtn

    helpBtn.MouseButton1Click:Connect(function()
        local UIControlsCardModal = require(script.Parent.UIControlsCardModal)
        UIControlsCardModal.open()
    end)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 150, 0, 44)
    closeBtn.Position = UDim2.new(0.5, 10, 1, -55)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 85)
    closeBtn.Font = Enum.Font.FredokaOne
    closeBtn.TextSize = 18
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "Close Map"
    closeBtn.Parent = frame

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 14)
    cCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
    end)

    modal = frame
end

function UIMapModal.open()
    if modal then modal.Visible = true end
end

return UIMapModal
