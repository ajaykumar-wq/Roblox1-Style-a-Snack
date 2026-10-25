--!strict
local UIResultsHUD = {}
local frame: Frame? = nil

function UIResultsHUD.init(parentGui: ScreenGui, onPlayAgain: () -> (), onHome: () -> ())
    local resFrame = Instance.new("Frame")
    resFrame.Name = "ResultsHUD"
    resFrame.Size = UDim2.new(0, 560, 0, 480)
    resFrame.Position = UDim2.new(0.5, -280, 0.5, -240)
    resFrame.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
    resFrame.Visible = false
    resFrame.Parent = parentGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)
    corner.Parent = resFrame

    local title = Instance.new("TextLabel")
    title.Name = "ResultsTitle"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 28
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.Text = "🎉 Round Results! 🎉"
    title.Parent = resFrame

    local placementLabel = Instance.new("TextLabel")
    placementLabel.Name = "PlacementLabel"
    placementLabel.Size = UDim2.new(1, 0, 0, 40)
    placementLabel.Position = UDim2.new(0, 0, 0, 50)
    placementLabel.BackgroundTransparency = 1
    placementLabel.Font = Enum.Font.FredokaOne
    placementLabel.TextSize = 24
    placementLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    placementLabel.Text = "Placed 1st of 6!"
    placementLabel.Parent = resFrame

    local rubricContainer = Instance.new("Frame")
    rubricContainer.Name = "RubricContainer"
    rubricContainer.Size = UDim2.new(1, -60, 0, 160)
    rubricContainer.Position = UDim2.new(0, 30, 0, 100)
    rubricContainer.BackgroundColor3 = Color3.fromRGB(40, 33, 55)
    rubricContainer.Parent = resFrame

    local rcCorner = Instance.new("UICorner")
    rcCorner.CornerRadius = UDim.new(0, 16)
    rcCorner.Parent = rubricContainer

    local rubricNames = { "Theme Colors (Max 40)", "Full Coverage (Max 30)", "Tool Variety (Max 20)", "Occasion Match (Max 10)" }
    for i, name in ipairs(rubricNames) do
        local rLabel = Instance.new("TextLabel")
        rLabel.Name = "Rubric_" .. tostring(i)
        rLabel.Size = UDim2.new(1, -20, 0, 30)
        rLabel.Position = UDim2.new(0, 10, 0, 10 + (i - 1) * 36)
        rLabel.BackgroundTransparency = 1
        rLabel.Font = Enum.Font.FredokaOne
        rLabel.TextSize = 15
        rLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
        rLabel.TextXAlignment = Enum.TextXAlignment.Left
        rLabel.Text = name .. ": --"
        rLabel.Parent = rubricContainer
    end

    local rewardsLabel = Instance.new("TextLabel")
    rewardsLabel.Name = "RewardsLabel"
    rewardsLabel.Size = UDim2.new(1, 0, 0, 40)
    rewardsLabel.Position = UDim2.new(0, 0, 0, 275)
    rewardsLabel.BackgroundTransparency = 1
    rewardsLabel.Font = Enum.Font.FredokaOne
    rewardsLabel.TextSize = 22
    rewardsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    rewardsLabel.Text = "+20 ✨ Sparkle  |  +40 ⭐ XP"
    rewardsLabel.Parent = resFrame

    local againBtn = Instance.new("TextButton")
    againBtn.Size = UDim2.new(0, 180, 0, 50)
    againBtn.Position = UDim2.new(0.5, -190, 1, -70)
    againBtn.BackgroundColor3 = Color3.fromRGB(255, 107, 107)
    againBtn.Font = Enum.Font.FredokaOne
    againBtn.TextSize = 20
    againBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    againBtn.Text = "🔄 Play Again"
    againBtn.Parent = resFrame

    local agCorner = Instance.new("UICorner")
    agCorner.CornerRadius = UDim.new(0, 16)
    agCorner.Parent = againBtn

    againBtn.MouseButton1Click:Connect(function()
        resFrame.Visible = false
        onPlayAgain()
    end)

    local homeBtn = Instance.new("TextButton")
    homeBtn.Size = UDim2.new(0, 180, 0, 50)
    homeBtn.Position = UDim2.new(0.5, 10, 1, -70)
    homeBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    homeBtn.Font = Enum.Font.FredokaOne
    homeBtn.TextSize = 20
    homeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    homeBtn.Text = "🏠 Home Pier"
    homeBtn.Parent = resFrame

    local hmCorner = Instance.new("UICorner")
    hmCorner.CornerRadius = UDim.new(0, 16)
    hmCorner.Parent = homeBtn

    homeBtn.MouseButton1Click:Connect(function()
        resFrame.Visible = false
        onHome()
    end)

    frame = resFrame
end

function UIResultsHUD.show(resultsData: any)
    if not frame then return end
    frame.Visible = true

    local placementLabel = frame:FindFirstChild("PlacementLabel") :: TextLabel?
    if placementLabel then
        local ordinals = { "1st 🥇", "2nd 🥈", "3rd 🥉", "4th", "5th", "6th" }
        placementLabel.Text = string.format("Placement: %s out of 6!", ordinals[resultsData.Placement] or tostring(resultsData.Placement))
    end

    local rewardsLabel = frame:FindFirstChild("RewardsLabel") :: TextLabel?
    if rewardsLabel then
        rewardsLabel.Text = string.format("+%d ✨ Sparkle  |  +%d ⭐ XP", resultsData.SparkleEarned, resultsData.XPEarned)
    end

    local rubricContainer = frame:FindFirstChild("RubricContainer") :: Frame?
    if rubricContainer and resultsData.Rubric then
        local r = resultsData.Rubric
        local r1 = rubricContainer:FindFirstChild("Rubric_1") :: TextLabel?
        if r1 then
            local comment = r.JudgesFeedback and r.JudgesFeedback.PaletteJudge and r.JudgesFeedback.PaletteJudge.Comment or ""
            r1.Text = string.format("🎨 Madame Macaron: %d/40 pts — \"%s\"", r.PaletteScore or 0, comment)
        end

        local r2 = rubricContainer:FindFirstChild("Rubric_2") :: TextLabel?
        if r2 then
            local comment = r.JudgesFeedback and r.JudgesFeedback.CoverageJudge and r.JudgesFeedback.CoverageJudge.Comment or ""
            r2.Text = string.format("🧁 Coach Pretzel: %d/30 pts — \"%s\"", r.CoverageScore or 0, comment)
        end

        local r3 = rubricContainer:FindFirstChild("Rubric_3") :: TextLabel?
        if r3 then
            r3.Text = string.format("✨ Tool Variety: %d/20 pts", r.VarietyScore or 0)
        end

        local r4 = rubricContainer:FindFirstChild("Rubric_4") :: TextLabel?
        if r4 then
            local comment = r.JudgesFeedback and r.JudgesFeedback.VarietyJudge and r.JudgesFeedback.VarietyJudge.Comment or ""
            r4.Text = string.format("🏷️ DJ Boba: %d/30 pts — \"%s\"", (r.VarietyScore or 0) + (r.OccasionScore or 0), comment)
        end
    end
end

function UIResultsHUD.hide()
    if frame then frame.Visible = false end
end

return UIResultsHUD
