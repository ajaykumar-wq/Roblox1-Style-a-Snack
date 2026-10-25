--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local ThemeConfig = require(ReplicatedStorage.StyleASnack.Config.ThemeConfig)
local SpeciesConfig = require(ReplicatedStorage.StyleASnack.Config.SpeciesConfig)
local DecorationConfig = require(ReplicatedStorage.StyleASnack.Config.DecorationConfig)
local EconomyConfig = require(ReplicatedStorage.StyleASnack.Config.EconomyConfig)
local ProgressionConfig = require(ReplicatedStorage.StyleASnack.Config.ProgressionConfig)
local ExplorationConfig = require(ReplicatedStorage.StyleASnack.Config.ExplorationConfig)
local Remotes = require(ReplicatedStorage.StyleASnack.Network.Remotes)

local AudioController = require(script.Parent.AudioController)
local ViewController = require(script.Parent.ViewController)
local DecorateController = require(script.Parent.DecorateController)

local UIThemeChoice = require(script.Parent.UIThemeChoice)
local UIMapModal = require(script.Parent.UIMapModal)
local UIResultsHUD = require(script.Parent.UIResultsHUD)
local UIOvenModal = require(script.Parent.UIOvenModal)
local UIIndexModal = require(script.Parent.UIIndexModal)

local UIController = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui: ScreenGui? = nil

-- Profile Cache
local profileData = {
    Sparkle = 0,
    Rank = 1,
    CurrentLevel = 1,
    XP = 0,
    OwnedSpecies = { croissant_cat = true },
    HatchCount = 0,
    UnlockedTools = { Icing = true },
}

local currentRoundState = "Lobby"
local currentTheme: ThemeConfig.Occasion? = nil
local currentPalette: ThemeConfig.Palette? = nil
local currentRunwayEntry: any = nil
local timerCountdownThread: thread? = nil

local homeFrame: Frame
local decorateFrame: Frame
local runwayFrame: Frame
local bannerFrame: Frame

local sparkleLabel: TextLabel
local rankLabel: TextLabel
local objectiveLabel: TextLabel
local timerLabel: TextLabel
local runwayNameLabel: TextLabel
local bannerLabel: TextLabel
local trayButtons: { [string]: TextButton } = {}
local lockOverlays: { [string]: Frame } = {}

function UIController.init()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StyleASnackGui"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui

    -- Initialize sub-modals
    UIThemeChoice.init(screenGui, function(chosenCard)
        Remotes.getFunction("StartSoloRound"):InvokeServer(chosenCard)
    end)

    UIMapModal.init(screenGui)

    UIResultsHUD.init(screenGui, function()
        -- Play Again
        UIThemeChoice.open()
    end, function()
        -- Home Pier
        UIController.handleStateTransition("Lobby", 0)
    end)

    UIOvenModal.init(screenGui, function()
        return profileData
    end)

    UIIndexModal.init(screenGui)

    -- Build Base HUDs
    UIController.createHomeHUD()
    UIController.createDecorateHUD()
    UIController.createRunwayHUD()
    UIController.createBannerToast()

    -- Target creature binding
    local creature = Workspace:FindFirstChild("PreviewCreature")
    if creature and creature:IsA("Model") then
        DecorateController.setTargetCreature(creature)
    end

    -- Setup Click-to-Decorate raycast on creature
    UIController.setupCreatureInteraction()

    -- Network Listeners
    Remotes.getEvent("ProfileUpdated").OnClientEvent:Connect(function(newProfile)
        profileData = newProfile
        UIController.updateHeaderChips()
        UIController.updateToolTrayLocks()
    end)

    Remotes.getEvent("RoundStateChanged").OnClientEvent:Connect(function(data)
        currentRoundState = data.State
        currentTheme = data.Occasion
        currentPalette = data.Palette

        if currentPalette then
            DecorateController.setPalette(currentPalette)
        end
        if currentTheme then
            DecorateController.setOccasion(currentTheme)
        end

        UIController.handleStateTransition(data.State, data.Duration, data.PhaseEndTime)
    end)

    Remotes.getEvent("RunwayFocusChanged").OnClientEvent:Connect(function(idx, total, entryData)
        currentRunwayEntry = entryData
        UIController.showRunwayEntry(idx, total, entryData)
    end)

    Remotes.getEvent("ShowResults").OnClientEvent:Connect(function(resultsData)
        UIController.showResultsScreen(resultsData)
    end)

    -- Warmup Support (Gate 1 first 60s)
    Remotes.getEvent("StartWarmup").OnClientEvent:Connect(function(data)
        currentRoundState = "Decorate"
        if data.Palette then DecorateController.setPalette(data.Palette) end
        if data.Occasion then DecorateController.setOccasion(data.Occasion) end
        UIController.handleStateTransition("Decorate", data.Duration)
    end)

    Remotes.getEvent("WarmupStateChanged").OnClientEvent:Connect(function(newState, duration, stars, score)
        currentRoundState = newState
        UIController.handleStateTransition(newState, duration)
        if newState == "Results" then
            UIController.showFloatingBanner(string.format("🌟 Warmup Completed! %d Stars! (+50 ✨, +100 ⭐)", stars or 3))
            task.delay(4, function()
                UIController.handleStateTransition("Lobby", 0)
            end)
        end
    end)

    Remotes.getEvent("WarmupCompleted").OnClientEvent:Connect(function(warmupData)
        UIController.showFloatingBanner(string.format("🌟 Warmup Completed! (+%d ✨, +%d ⭐)", warmupData.Sparkle or 50, warmupData.XP or 100))
        task.delay(3, function()
            UIController.handleStateTransition("Lobby", 0)
        end)
    end)

    -- Exploration Notifications
    Remotes.getEvent("StickerFoundNotification").OnClientEvent:Connect(function(stickerId, reward)
        UIController.showFloatingBanner(string.format("⭐ Hidden Sticker Found: %s! (+%d ✨)", string.upper(stickerId), reward))
    end)

    Remotes.getEvent("GoldenSprinkleNotification").OnClientEvent:Connect(function(sprinkleId, reward)
        UIController.showFloatingBanner(string.format("✨ Golden Sprinkle Collected! (+%d ✨)", reward))
    end)

    DecorateController.onLayersChanged(function(layers)
        UIController.renderLayerChips(layers)
    end)

    DecorateController.onTrayShake(function()
        UIController.shakeTray()
    end)

    -- Initial Profile Fetch
    task.spawn(function()
        local p = Remotes.getFunction("GetProfile"):InvokeServer()
        if p then
            profileData = p
            UIController.updateHeaderChips()
            UIController.updateToolTrayLocks()
        end
    end)
end

function UIController.pulseButton(btn: GuiObject)
    AudioController.play("vote_tap")
    local origSize = btn.Size
    local pulseSize = UDim2.new(origSize.X.Scale, origSize.X.Offset * 1.08, origSize.Y.Scale, origSize.Y.Offset * 1.08)

    local tween1 = TweenService:Create(btn, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = pulseSize })
    local tween2 = TweenService:Create(btn, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = origSize })

    tween1:Play()
    tween1.Completed:Connect(function()
        tween2:Play()
    end)
end

-- ==================== SCREEN CREATION ====================

function UIController.createHomeHUD()
    homeFrame = Instance.new("Frame")
    homeFrame.Name = "HomeHUD"
    homeFrame.Size = UDim2.new(1, 0, 1, 0)
    homeFrame.BackgroundTransparency = 1
    homeFrame.Parent = screenGui

    -- Top Left: Sparkle & Rank Chip
    local headerChip = Instance.new("Frame")
    headerChip.Size = UDim2.new(0, 260, 0, 56)
    headerChip.Position = UDim2.new(0, 24, 0, 20)
    headerChip.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
    headerChip.BorderSizePixel = 0
    headerChip.Parent = homeFrame

    local chipCorner = Instance.new("UICorner")
    chipCorner.CornerRadius = UDim.new(0, 16)
    chipCorner.Parent = headerChip

    sparkleLabel = Instance.new("TextLabel")
    sparkleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    sparkleLabel.BackgroundTransparency = 1
    sparkleLabel.Font = Enum.Font.FredokaOne
    sparkleLabel.TextSize = 22
    sparkleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    sparkleLabel.Text = "✨ 0"
    sparkleLabel.Parent = headerChip

    rankLabel = Instance.new("TextLabel")
    rankLabel.Size = UDim2.new(0.5, 0, 1, 0)
    rankLabel.Position = UDim2.new(0.5, 0, 0, 0)
    rankLabel.BackgroundTransparency = 1
    rankLabel.Font = Enum.Font.FredokaOne
    rankLabel.TextSize = 22
    rankLabel.TextColor3 = Color3.fromRGB(130, 220, 255)
    rankLabel.Text = "⭐ Level 1"
    rankLabel.Parent = headerChip

    -- Top Center: Objective Pill
    local objectiveCard = Instance.new("Frame")
    objectiveCard.Name = "ObjectiveCard"
    objectiveCard.Size = UDim2.new(0, 520, 0, 48)
    objectiveCard.Position = UDim2.new(0.5, -260, 0, 20)
    objectiveCard.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
    objectiveCard.BorderSizePixel = 0
    objectiveCard.Parent = homeFrame

    local objCorner = Instance.new("UICorner")
    objCorner.CornerRadius = UDim.new(0, 14)
    objCorner.Parent = objectiveCard

    objectiveLabel = Instance.new("TextLabel")
    objectiveLabel.Size = UDim2.new(1, -20, 1, 0)
    objectiveLabel.Position = UDim2.new(0, 10, 0, 0)
    objectiveLabel.BackgroundTransparency = 1
    objectiveLabel.Font = Enum.Font.FredokaOne
    objectiveLabel.TextSize = 15
    objectiveLabel.TextColor3 = Color3.fromRGB(255, 230, 130)
    objectiveLabel.Text = "🎯 Goal: Complete Warmup Round"
    objectiveLabel.Parent = objectiveCard

    -- Bottom Right Dock: 4 Pier Buttons (Decorate, Oven, Index, Map)
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(0, 540, 0, 80)
    btnContainer.Position = UDim2.new(1, -560, 1, -100)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = homeFrame

    local function makeButton(text: string, color: Color3, pos: UDim2, onClick: () -> ())
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 125, 0, 64)
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.Font = Enum.Font.FredokaOne
        btn.TextSize = 19
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = text
        btn.Parent = btnContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            UIController.pulseButton(btn)
            onClick()
        end)
        return btn
    end

    makeButton("🎨 Decorate", Color3.fromRGB(255, 107, 107), UDim2.new(0, 0, 0, 0), function()
        UIThemeChoice.open()
    end)

    makeButton("🥐 Oven", Color3.fromRGB(255, 159, 67), UDim2.new(0, 135, 0, 0), function()
        UIOvenModal.open()
    end)

    makeButton("📖 Index", Color3.fromRGB(72, 219, 251), UDim2.new(0, 270, 0, 0), function()
        UIIndexModal.open()
    end)

    makeButton("🗺️ Map", Color3.fromRGB(46, 204, 113), UDim2.new(0, 405, 0, 0), function()
        UIMapModal.open()
    end)
end

function UIController.createDecorateHUD()
    decorateFrame = Instance.new("Frame")
    decorateFrame.Name = "DecorateHUD"
    decorateFrame.Size = UDim2.new(1, 0, 1, 0)
    decorateFrame.BackgroundTransparency = 1
    decorateFrame.Visible = false
    decorateFrame.Parent = screenGui

    -- Timer (top center, 180s)
    local timerCard = Instance.new("Frame")
    timerCard.Size = UDim2.new(0, 160, 0, 48)
    timerCard.Position = UDim2.new(0.5, -80, 0, 16)
    timerCard.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
    timerCard.Parent = decorateFrame

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 16)
    tCorner.Parent = timerCard

    timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(1, 0, 1, 0)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Font = Enum.Font.FredokaOne
    timerLabel.TextSize = 24
    timerLabel.TextColor3 = Color3.fromRGB(76, 175, 80)
    timerLabel.Text = "03:00"
    timerLabel.Parent = timerCard

    -- Right Edge: Tool Tray (6 slots)
    local toolTray = Instance.new("Frame")
    toolTray.Name = "ToolTray"
    toolTray.Size = UDim2.new(0, 84, 0, 480)
    toolTray.Position = UDim2.new(1, -96, 0.5, -240)
    toolTray.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
    toolTray.Parent = decorateFrame

    local trayCorner = Instance.new("UICorner")
    trayCorner.CornerRadius = UDim.new(0, 20)
    trayCorner.Parent = toolTray

    local toolList = { "Icing", "Sprinkle", "Sticker", "Drizzle", "Pattern", "Accessory" }
    local toolIcons = { Icing = "🧁", Sprinkle = "✨", Sticker = "⭐", Drizzle = "🍯", Pattern = "🏁", Accessory = "🎀" }

    for i, toolName in ipairs(toolList) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 72, 0, 72)
        btn.Position = UDim2.new(0, 6, 0, 6 + (i - 1) * 78)
        btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(255, 107, 107) or Color3.fromRGB(60, 50, 75)
        btn.Font = Enum.Font.FredokaOne
        btn.TextSize = 20
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = toolIcons[toolName] .. "\n" .. toolName
        btn.Parent = toolTray

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 14)
        btnCorner.Parent = btn

        local lockOverlay = Instance.new("Frame")
        lockOverlay.Name = "LockOverlay"
        lockOverlay.Size = UDim2.new(1, 0, 1, 0)
        lockOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
        lockOverlay.BackgroundTransparency = 0.5
        lockOverlay.Visible = false
        lockOverlay.Parent = btn

        local lockCorner = Instance.new("UICorner")
        lockCorner.CornerRadius = UDim.new(0, 14)
        lockCorner.Parent = lockOverlay

        local lockIcon = Instance.new("TextLabel")
        lockIcon.Size = UDim2.new(1, 0, 1, 0)
        lockIcon.BackgroundTransparency = 1
        lockIcon.Font = Enum.Font.FredokaOne
        lockIcon.TextSize = 24
        lockIcon.Text = "🔒"
        lockIcon.Parent = lockOverlay

        trayButtons[toolName] = btn
        lockOverlays[toolName] = lockOverlay

        btn.MouseButton1Click:Connect(function()
            if lockOverlay.Visible then
                AudioController.play("shake")
                UIController.showFloatingBanner(string.format("🔒 %s unlocks at Level %d!", toolName, ProgressionConfig.getRequiredLevelForTool(toolName)))
                return
            end

            UIController.pulseButton(btn)
            DecorateController.selectTool(toolName :: any)
            for _, b in pairs(trayButtons) do
                b.BackgroundColor3 = Color3.fromRGB(60, 50, 75)
            end
            btn.BackgroundColor3 = Color3.fromRGB(255, 107, 107)

            -- Auto-apply preview actions for tap-and-apply tools
            if toolName == "Sprinkle" then
                DecorateController.applySprinkle("rainbow_pill", 30)
            elseif toolName == "Drizzle" then
                DecorateController.applyDrizzle()
            end
        end)
    end

    -- Swatches Bar (8 swatches, 56px)
    local swatchBar = Instance.new("Frame")
    swatchBar.Name = "SwatchBar"
    swatchBar.Size = UDim2.new(0, 480, 0, 56)
    swatchBar.Position = UDim2.new(0.5, -240, 0, 72)
    swatchBar.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
    swatchBar.Parent = decorateFrame

    local swatchCorner = Instance.new("UICorner")
    swatchCorner.CornerRadius = UDim.new(0, 16)
    swatchCorner.Parent = swatchBar

    local defaultPalette = ThemeConfig.Palettes[1]
    for idx = 1, 8 do
        local swatchBtn = Instance.new("TextButton")
        swatchBtn.Name = "Swatch_" .. tostring(idx)
        swatchBtn.Size = UDim2.new(0, 48, 0, 48)
        swatchBtn.Position = UDim2.new(0, 10 + (idx - 1) * 58, 0, 4)
        swatchBtn.BackgroundColor3 = defaultPalette.Swatches[idx]
        swatchBtn.Text = ""
        swatchBtn.Parent = swatchBar

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = swatchBtn

        swatchBtn.MouseButton1Click:Connect(function()
            UIController.pulseButton(swatchBtn)
            DecorateController.selectSwatch(idx)
        end)
    end

    -- Left Edge: Layer Stack Counter & Chips
    local layerList = Instance.new("ScrollingFrame")
    layerList.Name = "LayerChips"
    layerList.Size = UDim2.new(0, 170, 0, 360)
    layerList.Position = UDim2.new(0, 20, 0.5, -180)
    layerList.BackgroundTransparency = 1
    layerList.ScrollBarThickness = 4
    layerList.Parent = decorateFrame

    -- Bottom Controls: Turn View, Done, Abandon
    local turnBtn = Instance.new("TextButton")
    turnBtn.Size = UDim2.new(0, 60, 0, 60)
    turnBtn.Position = UDim2.new(0, 20, 1, -80)
    turnBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 65)
    turnBtn.Font = Enum.Font.FredokaOne
    turnBtn.TextSize = 28
    turnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    turnBtn.Text = "🔄"
    turnBtn.Parent = decorateFrame

    local turnCorner = Instance.new("UICorner")
    turnCorner.CornerRadius = UDim.new(0, 16)
    turnCorner.Parent = turnBtn

    turnBtn.MouseButton1Click:Connect(function()
        UIController.pulseButton(turnBtn)
        ViewController.togglePresetAngle()
    end)

    local doneBtn = Instance.new("TextButton")
    doneBtn.Size = UDim2.new(0, 140, 0, 56)
    doneBtn.Position = UDim2.new(1, -260, 1, -80)
    doneBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    doneBtn.Font = Enum.Font.FredokaOne
    doneBtn.TextSize = 20
    doneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    doneBtn.Text = "✅ Done"
    doneBtn.Parent = decorateFrame

    local doneCorner = Instance.new("UICorner")
    doneCorner.CornerRadius = UDim.new(0, 16)
    doneCorner.Parent = doneBtn

    doneBtn.MouseButton1Click:Connect(function()
        UIController.pulseButton(doneBtn)
        Remotes.getFunction("FinishRoundDecorate"):InvokeServer(DecorateController.getLayers())
        UIController.showFloatingBanner("✨ Decoration Submitted! Heading to the runway...")
    end)

    local pauseBtn = Instance.new("TextButton")
    pauseBtn.Size = UDim2.new(0, 50, 0, 50)
    pauseBtn.Position = UDim2.new(1, -70, 0, 16)
    pauseBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 75)
    pauseBtn.Font = Enum.Font.FredokaOne
    pauseBtn.TextSize = 22
    pauseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    pauseBtn.Text = "⏸️"
    pauseBtn.Parent = decorateFrame

    local pauseCorner = Instance.new("UICorner")
    pauseCorner.CornerRadius = UDim.new(0, 14)
    pauseCorner.Parent = pauseBtn

    pauseBtn.MouseButton1Click:Connect(function()
        UIController.pulseButton(pauseBtn)
        Remotes.getFunction("AbandonRound"):InvokeServer()
        UIController.handleStateTransition("Lobby", 0)
    end)
end

function UIController.createRunwayHUD()
    runwayFrame = Instance.new("Frame")
    runwayFrame.Name = "RunwayHUD"
    runwayFrame.Size = UDim2.new(1, 0, 1, 0)
    runwayFrame.BackgroundTransparency = 1
    runwayFrame.Visible = false
    runwayFrame.Parent = screenGui

    runwayNameLabel = Instance.new("TextLabel")
    runwayNameLabel.Size = UDim2.new(0, 420, 0, 54)
    runwayNameLabel.Position = UDim2.new(0.5, -210, 0, 30)
    runwayNameLabel.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
    runwayNameLabel.Font = Enum.Font.FredokaOne
    runwayNameLabel.TextSize = 22
    runwayNameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    runwayNameLabel.Text = "🌟 Runway Judging in Progress 🌟"
    runwayNameLabel.Parent = runwayFrame

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 16)
    rCorner.Parent = runwayNameLabel
end

function UIController.createBannerToast()
    bannerFrame = Instance.new("Frame")
    bannerFrame.Name = "BannerToast"
    bannerFrame.Size = UDim2.new(0, 480, 0, 50)
    bannerFrame.Position = UDim2.new(0.5, -240, 0, -60)
    bannerFrame.BackgroundColor3 = Color3.fromRGB(255, 107, 107)
    bannerFrame.Parent = screenGui

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 14)
    bCorner.Parent = bannerFrame

    bannerLabel = Instance.new("TextLabel")
    bannerLabel.Size = UDim2.new(1, -20, 1, 0)
    bannerLabel.Position = UDim2.new(0, 10, 0, 0)
    bannerLabel.BackgroundTransparency = 1
    bannerLabel.Font = Enum.Font.FredokaOne
    bannerLabel.TextSize = 17
    bannerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    bannerLabel.Text = ""
    bannerLabel.Parent = bannerFrame
end

function UIController.showFloatingBanner(text: string)
    if not bannerFrame or not bannerLabel then return end
    bannerLabel.Text = text
    AudioController.play("fanfare")

    local openTween = TweenService:Create(bannerFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -240, 0, 24)
    })
    openTween:Play()

    task.delay(3.5, function()
        local closeTween = TweenService:Create(bannerFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -240, 0, -60)
        })
        closeTween:Play()
    end)
end

-- ==================== CREATURE INTERACTION ====================

function UIController.setupCreatureInteraction()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if currentRoundState ~= "Decorate" then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mousePos = UserInputService:GetMouseLocation()
            local cam = Workspace.CurrentCamera
            if not cam then return end

            local ray = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Include

            local creature = Workspace:FindFirstChild("PreviewCreature")
            if not creature then return end
            raycastParams.FilterDescendantsInstances = { creature }

            local hit = Workspace:Raycast(ray.Origin, ray.Direction * 100, raycastParams)
            if hit and hit.Instance then
                local hitPart = hit.Instance
                local regionName = hitPart.Name

                -- Apply selected tool to clicked region
                local selectedTool = DecorateController.getSelectedTool and DecorateController.getSelectedTool() or "Icing"
                if selectedTool == "Icing" then
                    DecorateController.applyIcing(regionName)
                elseif selectedTool == "Pattern" then
                    DecorateController.applyPattern("dots", regionName)
                elseif selectedTool == "Sticker" then
                    DecorateController.applySticker("star", regionName)
                elseif selectedTool == "Accessory" then
                    DecorateController.applyAccessory("bow", regionName)
                end
            end
        end
    end)
end

-- ==================== STATE MANAGEMENT ====================

function UIController.handleStateTransition(state: string, duration: number?, phaseEndTime: number?)
    currentRoundState = state

    if timerCountdownThread then
        task.cancel(timerCountdownThread)
        timerCountdownThread = nil
    end

    if state == "Lobby" then
        homeFrame.Visible = true
        decorateFrame.Visible = false
        runwayFrame.Visible = false
        UIResultsHUD.hide()
        ViewController.setMode("Lobby")

    elseif state == "Theme" then
        homeFrame.Visible = false
        decorateFrame.Visible = false
        runwayFrame.Visible = false
        UIResultsHUD.hide()
        AudioController.play("theme_reveal")

    elseif state == "Decorate" then
        homeFrame.Visible = false
        decorateFrame.Visible = true
        runwayFrame.Visible = false
        UIResultsHUD.hide()

        local creature = Workspace:FindFirstChild("PreviewCreature")
        ViewController.setMode("Round", creature)
        DecorateController.clearAll()

        -- Update Swatches to current theme palette
        if currentPalette then
            local swatchBar = decorateFrame:FindFirstChild("SwatchBar")
            if swatchBar then
                for idx = 1, 8 do
                    local btn = swatchBar:FindFirstChild("Swatch_" .. tostring(idx)) :: TextButton?
                    if btn and currentPalette.Swatches[idx] then
                        btn.BackgroundColor3 = currentPalette.Swatches[idx]
                    end
                end
            end
        end

        -- Countdown Timer
        local remaining = duration or 180
        timerLabel.Text = string.format("%02d:%02d", math.floor(remaining / 60), remaining % 60)
        timerCountdownThread = task.spawn(function()
            while remaining > 0 do
                task.wait(1)
                remaining -= 1
                timerLabel.Text = string.format("%02d:%02d", math.floor(remaining / 60), remaining % 60)
                if remaining <= 10 then
                    timerLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                else
                    timerLabel.TextColor3 = Color3.fromRGB(76, 175, 80)
                end
            end
        end)

    elseif state == "Lock" then
        timerLabel.Text = "LOCKED"
        timerLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        AudioController.play("pencils_down")
        UIController.showFloatingBanner("🛑 Pencils Down! Preparing the runway...")

    elseif state == "Judging" or state == "Vote" then
        homeFrame.Visible = false
        decorateFrame.Visible = false
        runwayFrame.Visible = true
        UIResultsHUD.hide()
        ViewController.setMode("Runway")

    elseif state == "Results" then
        homeFrame.Visible = false
        decorateFrame.Visible = false
        runwayFrame.Visible = false
        ViewController.setMode("Results")
    end
end

function UIController.showRunwayEntry(index: number, total: number, entryData: any)
    if not runwayNameLabel then return end
    local isSelf = entryData.IsSelf
    local name = entryData.Name or "Stylist"
    local species = SpeciesConfig.getSpeciesById(entryData.SpeciesId)
    local speciesName = species and species.Name or "Snackimal"

    runwayNameLabel.Text = string.format("Runway %d/%d: %s's %s %s", index, total, name, speciesName, isSelf and "(YOU!)" or "")
    AudioController.play("camera_shutter")
end

function UIController.showResultsScreen(resultsData: any)
    UIResultsHUD.show(resultsData)
    if resultsData.Placement <= 3 then
        AudioController.play("confetti")
    else
        AudioController.play("fanfare")
    end
end

-- ==================== CHIPS & UI HELPERS ====================

function UIController.updateHeaderChips()
    if sparkleLabel then
        sparkleLabel.Text = string.format("✨ %d", profileData.Sparkle or 0)
    end
    if rankLabel then
        rankLabel.Text = string.format("⭐ Level %d", profileData.CurrentLevel or 1)
    end
    if objectiveLabel then
        local objText = ProgressionConfig.getObjective(profileData.CurrentLevel or 1)
        objectiveLabel.Text = "🎯 Goal: " .. (objText or "Hatch and Style!")
    end
end

function UIController.updateToolTrayLocks()
    local unlocked = profileData.UnlockedTools or { Icing = true }
    for toolName, overlay in pairs(lockOverlays) do
        overlay.Visible = not unlocked[toolName]
    end
end

function UIController.renderLayerChips(layers: { DecorationConfig.Layer })
    if not decorateFrame then return end
    local layerList = decorateFrame:FindFirstChild("LayerChips") :: ScrollingFrame?
    if not layerList then return end

    layerList:ClearAllChildren()

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.Text = string.format("Layers: %d/12", #layers)
    title.Parent = layerList

    for i, l in ipairs(layers) do
        local chip = Instance.new("TextButton")
        chip.Size = UDim2.new(1, -10, 0, 32)
        chip.Position = UDim2.new(0, 5, 0, 32 + (i - 1) * 36)
        chip.BackgroundColor3 = Color3.fromRGB(50, 42, 65)
        chip.Font = Enum.Font.FredokaOne
        chip.TextSize = 14
        chip.TextColor3 = Color3.fromRGB(240, 240, 255)
        chip.Text = string.format("%d. %s (%s) ✕", i, l.Tool, l.Region or "creature")
        chip.Parent = layerList

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 8)
        cCorner.Parent = chip

        chip.MouseButton1Click:Connect(function()
            UIController.pulseButton(chip)
            DecorateController.undoLayer(l.Id)
        end)
    end
end

function UIController.shakeTray()
    if not decorateFrame then return end
    local tray = decorateFrame:FindFirstChild("ToolTray") :: Frame?
    if not tray then return end

    AudioController.play("shake")
    local origPos = tray.Position
    local t1 = TweenService:Create(tray, TweenInfo.new(0.05), { Position = origPos + UDim2.new(0, -10, 0, 0) })
    local t2 = TweenService:Create(tray, TweenInfo.new(0.05), { Position = origPos + UDim2.new(0, 10, 0, 0) })
    local t3 = TweenService:Create(tray, TweenInfo.new(0.05), { Position = origPos })

    t1:Play()
    t1.Completed:Connect(function()
        t2:Play()
        t2.Completed:Connect(function()
            t3:Play()
        end)
    end)
end

return UIController
