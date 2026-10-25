--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Remotes = require(ReplicatedStorage.StyleASnack.Network.Remotes)

local UIThemeChoice = {}
local modal: Frame? = nil
local countdownThread: thread? = nil
local currentDealtCard: any = nil

function UIThemeChoice.init(parentGui: ScreenGui, onThemeSelected: (any) -> ())
    local frame = Instance.new("Frame")
    frame.Name = "ThemeRevealModal"
    frame.Size = UDim2.new(0, 480, 0, 400)
    frame.Position = UDim2.new(0.5, -240, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(30, 25, 42)
    frame.Visible = false
    frame.Parent = parentGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)
    corner.Parent = frame

    local drumrollHeader = Instance.new("TextLabel")
    drumrollHeader.Name = "DrumrollHeader"
    drumrollHeader.Size = UDim2.new(1, 0, 0, 45)
    drumrollHeader.Position = UDim2.new(0, 0, 0, 10)
    drumrollHeader.BackgroundTransparency = 1
    drumrollHeader.Font = Enum.Font.FredokaOne
    drumrollHeader.TextSize = 24
    drumrollHeader.TextColor3 = Color3.fromRGB(255, 215, 0)
    drumrollHeader.Text = "🥁 THEME DROP 🥁"
    drumrollHeader.Parent = frame

    local cardContainer = Instance.new("Frame")
    cardContainer.Name = "CardContainer"
    cardContainer.Size = UDim2.new(1, -40, 0, 240)
    cardContainer.Position = UDim2.new(0, 20, 0, 55)
    cardContainer.BackgroundColor3 = Color3.fromRGB(45, 38, 58)
    cardContainer.Parent = frame

    local ccCorner = Instance.new("UICorner")
    ccCorner.CornerRadius = UDim.new(0, 18)
    ccCorner.Parent = cardContainer

    local occTitle = Instance.new("TextLabel")
    occTitle.Name = "OccasionTitle"
    occTitle.Size = UDim2.new(1, -20, 0, 36)
    occTitle.Position = UDim2.new(0, 10, 0, 12)
    occTitle.BackgroundTransparency = 1
    occTitle.Font = Enum.Font.FredokaOne
    occTitle.TextSize = 26
    occTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    occTitle.Text = "Beach Day"
    occTitle.Parent = cardContainer

    local occDesc = Instance.new("TextLabel")
    occDesc.Name = "OccasionDesc"
    occDesc.Size = UDim2.new(1, -20, 0, 24)
    occDesc.Position = UDim2.new(0, 10, 0, 48)
    occDesc.BackgroundTransparency = 1
    occDesc.Font = Enum.Font.FredokaOne
    occDesc.TextSize = 14
    occDesc.TextColor3 = Color3.fromRGB(180, 180, 200)
    occDesc.Text = "Sunshine, sand, and seaside snacks"
    occDesc.Parent = cardContainer

    local palLabel = Instance.new("TextLabel")
    palLabel.Name = "PaletteLabel"
    palLabel.Size = UDim2.new(1, -20, 0, 24)
    palLabel.Position = UDim2.new(0, 10, 0, 80)
    palLabel.BackgroundTransparency = 1
    palLabel.Font = Enum.Font.FredokaOne
    palLabel.TextSize = 15
    palLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    palLabel.Text = "Curated Palette: Sunny"
    palLabel.Parent = cardContainer

    local swatchesFrame = Instance.new("Frame")
    swatchesFrame.Name = "SwatchesFrame"
    swatchesFrame.Size = UDim2.new(1, -20, 0, 60)
    swatchesFrame.Position = UDim2.new(0, 10, 0, 110)
    swatchesFrame.BackgroundTransparency = 1
    swatchesFrame.Parent = cardContainer

    for i = 1, 8 do
        local dot = Instance.new("Frame")
        dot.Name = "Swatch_" .. tostring(i)
        dot.Size = UDim2.new(0, 32, 0, 32)
        dot.Position = UDim2.new(0, ((i - 1) % 4) * 54 + 20, 0, math.floor((i - 1) / 4) * 38)
        dot.BackgroundColor3 = Color3.new(1, 1, 1)
        dot.Parent = swatchesFrame

        local dCorner = Instance.new("UICorner")
        dCorner.CornerRadius = UDim.new(0, 16)
        dCorner.Parent = dot
    end

    local timerNotice = Instance.new("TextLabel")
    timerNotice.Name = "TimerNotice"
    timerNotice.Size = UDim2.new(1, -20, 0, 24)
    timerNotice.Position = UDim2.new(0, 10, 1, -30)
    timerNotice.BackgroundTransparency = 1
    timerNotice.Font = Enum.Font.FredokaOne
    timerNotice.TextSize = 14
    timerNotice.TextColor3 = Color3.fromRGB(130, 225, 130)
    timerNotice.Text = "Round begins in 3s..."
    timerNotice.Parent = cardContainer

    -- Action Buttons (Skip once today vs Start Now)
    local buttonRow = Instance.new("Frame")
    buttonRow.Name = "ButtonRow"
    buttonRow.Size = UDim2.new(1, -40, 0, 48)
    buttonRow.Position = UDim2.new(0, 20, 1, -65)
    buttonRow.BackgroundTransparency = 1
    buttonRow.Parent = frame

    local skipBtn = Instance.new("TextButton")
    skipBtn.Name = "SkipButton"
    skipBtn.Size = UDim2.new(0.48, 0, 1, 0)
    skipBtn.Position = UDim2.new(0, 0, 0, 0)
    skipBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 75)
    skipBtn.Font = Enum.Font.FredokaOne
    skipBtn.TextSize = 15
    skipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    skipBtn.Text = "Skip Once Today (1x)"
    skipBtn.Parent = buttonRow

    local skCorner = Instance.new("UICorner")
    skCorner.CornerRadius = UDim.new(0, 14)
    skCorner.Parent = skipBtn

    local startBtn = Instance.new("TextButton")
    startBtn.Name = "StartButton"
    startBtn.Size = UDim2.new(0.48, 0, 1, 0)
    startBtn.Position = UDim2.new(0.52, 0, 0, 0)
    startBtn.BackgroundColor3 = Color3.fromRGB(255, 107, 107)
    startBtn.Font = Enum.Font.FredokaOne
    startBtn.TextSize = 16
    startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    startBtn.Text = "Start Round"
    startBtn.Parent = buttonRow

    local stCorner = Instance.new("UICorner")
    stCorner.CornerRadius = UDim.new(0, 14)
    stCorner.Parent = startBtn

    modal = frame
    UIThemeChoice.onSelected = onThemeSelected

    skipBtn.MouseButton1Click:Connect(function()
        local newCard = Remotes.getFunction("SkipDealtTheme"):InvokeServer()
        if newCard then
            currentDealtCard = newCard
            UIThemeChoice.displayCard(newCard)
            skipBtn.Visible = false
        end
    end)

    startBtn.MouseButton1Click:Connect(function()
        UIThemeChoice.closeAndStart()
    end)
end

function UIThemeChoice.displayCard(cardData: any)
    if not modal then return end
    currentDealtCard = cardData

    local occ = cardData.Occasion
    local pal = cardData.Palette
    local canSkip = cardData.CanSkip

    local cardContainer = modal:FindFirstChild("CardContainer") :: Frame?
    if not cardContainer then return end

    local occTitle = cardContainer:FindFirstChild("OccasionTitle") :: TextLabel?
    if occTitle then occTitle.Text = occ.Name end

    local occDesc = cardContainer:FindFirstChild("OccasionDesc") :: TextLabel?
    if occDesc then occDesc.Text = occ.Description end

    local palLabel = cardContainer:FindFirstChild("PaletteLabel") :: TextLabel?
    if palLabel then palLabel.Text = "Curated Palette: " .. pal.Name end

    local swatchesFrame = cardContainer:FindFirstChild("SwatchesFrame") :: Frame?
    if swatchesFrame then
        for i = 1, 8 do
            local dot = swatchesFrame:FindFirstChild("Swatch_" .. tostring(i)) :: Frame?
            if dot and pal.Swatches and pal.Swatches[i] then
                dot.BackgroundColor3 = pal.Swatches[i]
            end
        end
    end

    local buttonRow = modal:FindFirstChild("ButtonRow") :: Frame?
    if buttonRow then
        local skipBtn = buttonRow:FindFirstChild("SkipButton") :: TextButton?
        if skipBtn then
            skipBtn.Visible = canSkip == true
        end
    end
end

function UIThemeChoice.open()
    if not modal then return end
    modal.Visible = true

    -- Drop-in bounce animation
    modal.Position = UDim2.new(0.5, -240, 0, -420)
    TweenService:Create(modal, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -240, 0.5, -200),
    }):Play()

    -- Request the auto-dealt theme card
    local dealtCard = Remotes.getFunction("RequestDealtTheme"):InvokeServer()
    if not dealtCard then return end

    UIThemeChoice.displayCard(dealtCard)

    if countdownThread then
        task.cancel(countdownThread)
    end

    countdownThread = task.spawn(function()
        local cardContainer = modal:FindFirstChild("CardContainer") :: Frame?
        local timerNotice = cardContainer and cardContainer:FindFirstChild("TimerNotice") :: TextLabel?
        for remaining = 3, 1, -1 do
            if timerNotice then
                timerNotice.Text = string.format("Round begins in %ds...", remaining)
            end
            task.wait(1)
            if not modal or not modal.Visible then return end
        end
        UIThemeChoice.closeAndStart()
    end)
end

function UIThemeChoice.closeAndStart()
    if not modal or not modal.Visible then return end
    if countdownThread then
        task.cancel(countdownThread)
        countdownThread = nil
    end

    modal.Visible = false
    if UIThemeChoice.onSelected and currentDealtCard then
        UIThemeChoice.onSelected(currentDealtCard)
    end
end

return UIThemeChoice
