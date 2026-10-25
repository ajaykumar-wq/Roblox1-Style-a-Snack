--!strict
local TweenService = game:GetService("TweenService")

local UIControlsCardModal = {}
local modal: Frame? = nil
local onDismissCallback: (() -> ())? = nil

function UIControlsCardModal.init(parentGui: ScreenGui, onDismiss: () -> ())
    local frame = Instance.new("Frame")
    frame.Name = "ControlsCardModal"
    frame.Size = UDim2.new(0, 560, 0, 360)
    frame.Position = UDim2.new(0.5, -280, 0.5, -180)
    frame.BackgroundColor3 = Color3.fromRGB(32, 26, 44)
    frame.Visible = false
    frame.Parent = parentGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 26
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.Text = "📖 Three Things to Know"
    title.Parent = frame

    local cardsRow = Instance.new("Frame")
    cardsRow.Name = "CardsRow"
    cardsRow.Size = UDim2.new(1, -40, 0, 160)
    cardsRow.Position = UDim2.new(0, 20, 0, 60)
    cardsRow.BackgroundTransparency = 1
    cardsRow.Parent = frame

    local steps = {
        {
            Icon = "🚶",
            Title = "1. Walk",
            Desc = "Thumb on left half\nWASD or Left Stick",
        },
        {
            Icon = "🎨",
            Title = "2. Decorate",
            Desc = "Tap a tool on right,\nthen tap/drag creature",
        },
        {
            Icon = "↩️",
            Title = "3. Undo",
            Desc = "Tap a layer chip on left\nNothing is lost for good",
        },
    }

    for i, step in ipairs(steps) do
        local stepBox = Instance.new("Frame")
        stepBox.Size = UDim2.new(0, 160, 1, 0)
        stepBox.Position = UDim2.new(0, (i - 1) * 180, 0, 0)
        stepBox.BackgroundColor3 = Color3.fromRGB(45, 38, 58)
        stepBox.Parent = cardsRow

        local sbCorner = Instance.new("UICorner")
        sbCorner.CornerRadius = UDim.new(0, 16)
        sbCorner.Parent = stepBox

        local sIcon = Instance.new("TextLabel")
        sIcon.Size = UDim2.new(1, 0, 0, 40)
        sIcon.Position = UDim2.new(0, 0, 0, 10)
        sIcon.BackgroundTransparency = 1
        sIcon.Font = Enum.Font.FredokaOne
        sIcon.TextSize = 32
        sIcon.Text = step.Icon
        sIcon.Parent = stepBox

        local sTitle = Instance.new("TextLabel")
        sTitle.Size = UDim2.new(1, -10, 0, 24)
        sTitle.Position = UDim2.new(0, 5, 0, 52)
        sTitle.BackgroundTransparency = 1
        sTitle.Font = Enum.Font.FredokaOne
        sTitle.TextSize = 16
        sTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
        sTitle.Text = step.Title
        sTitle.Parent = stepBox

        local sDesc = Instance.new("TextLabel")
        sDesc.Size = UDim2.new(1, -16, 0, 60)
        sDesc.Position = UDim2.new(0, 8, 0, 80)
        sDesc.BackgroundTransparency = 1
        sDesc.Font = Enum.Font.FredokaOne
        sDesc.TextSize = 12
        sDesc.TextColor3 = Color3.fromRGB(200, 200, 220)
        sDesc.Text = step.Desc
        sDesc.TextWrapped = true
        sDesc.Parent = stepBox
    end

    local shortcutsNotice = Instance.new("TextLabel")
    shortcutsNotice.Size = UDim2.new(1, -40, 0, 24)
    shortcutsNotice.Position = UDim2.new(0, 20, 0, 230)
    shortcutsNotice.BackgroundTransparency = 1
    shortcutsNotice.Font = Enum.Font.FredokaOne
    shortcutsNotice.TextSize = 13
    shortcutsNotice.TextColor3 = Color3.fromRGB(160, 160, 180)
    shortcutsNotice.Text = "Keyboard: 1-6 tools, Ctrl+Z undo | Gamepad: Right stick tool wheel, B undo"
    shortcutsNotice.Parent = frame

    local gotItBtn = Instance.new("TextButton")
    gotItBtn.Size = UDim2.new(0, 160, 0, 48)
    gotItBtn.Position = UDim2.new(0.5, -80, 1, -65)
    gotItBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    gotItBtn.Font = Enum.Font.FredokaOne
    gotItBtn.TextSize = 20
    gotItBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    gotItBtn.Text = "Got it! ▶"
    gotItBtn.Parent = frame

    local giCorner = Instance.new("UICorner")
    giCorner.CornerRadius = UDim.new(0, 14)
    giCorner.Parent = gotItBtn

    gotItBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
        if onDismissCallback then
            onDismissCallback()
        end
    end)

    onDismissCallback = onDismiss
    modal = frame
end

function UIControlsCardModal.open(callback: (() -> ())?)
    if not modal then return end
    if callback then
        onDismissCallback = callback
    end
    modal.Visible = true
    modal.Position = UDim2.new(0.5, -280, 0, -400)
    TweenService:Create(modal, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -280, 0.5, -180),
    }):Play()
end

function UIControlsCardModal.hide()
    if modal then modal.Visible = false end
end

return UIControlsCardModal
