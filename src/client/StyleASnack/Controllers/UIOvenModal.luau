--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EconomyConfig = require(ReplicatedStorage.StyleASnack.Config.EconomyConfig)
local SpeciesConfig = require(ReplicatedStorage.StyleASnack.Config.SpeciesConfig)
local Remotes = require(ReplicatedStorage.StyleASnack.Network.Remotes)

local UIOvenModal = {}
local modal: Frame? = nil

function UIOvenModal.init(parentGui: ScreenGui, getProfile: () -> any)
    local frame = Instance.new("Frame")
    frame.Name = "OvenModal"
    frame.Size = UDim2.new(0, 460, 0, 400)
    frame.Position = UDim2.new(0.5, -230, 0.5, -200)
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
    title.TextColor3 = Color3.fromRGB(255, 179, 71)
    title.Text = "🥐 The Bakery Oven"
    title.Parent = frame

    local priceLabel = Instance.new("TextLabel")
    priceLabel.Name = "PriceLabel"
    priceLabel.Size = UDim2.new(1, 0, 0, 40)
    priceLabel.Position = UDim2.new(0, 0, 0, 60)
    priceLabel.BackgroundTransparency = 1
    priceLabel.Font = Enum.Font.FredokaOne
    priceLabel.TextSize = 20
    priceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    priceLabel.Text = "First Hatch: FREE!"
    priceLabel.Parent = frame

    local hatchBtn = Instance.new("TextButton")
    hatchBtn.Size = UDim2.new(0, 220, 0, 60)
    hatchBtn.Position = UDim2.new(0.5, -110, 0.55, 0)
    hatchBtn.BackgroundColor3 = Color3.fromRGB(255, 107, 107)
    hatchBtn.Font = Enum.Font.FredokaOne
    hatchBtn.TextSize = 24
    hatchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    hatchBtn.Text = "🔥 Hatch!"
    hatchBtn.Parent = frame

    local hatchCorner = Instance.new("UICorner")
    hatchCorner.CornerRadius = UDim.new(0, 18)
    hatchCorner.Parent = hatchBtn

    hatchBtn.MouseButton1Click:Connect(function()
        local success, rarity, speciesId, isDup, refund, price, err = Remotes.getFunction("HatchOven"):InvokeServer()
        if success then
            local sp = SpeciesConfig.getSpeciesById(speciesId)
            priceLabel.Text = string.format("Hatched %s!\nRarity: %s %s",
                sp and sp.Name or speciesId,
                rarity,
                isDup and string.format("(Duplicate +%d ✨)", refund) or "NEW!"
            )
        else
            priceLabel.Text = "Error: " .. tostring(err)
        end
    end)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 120, 0, 40)
    closeBtn.Position = UDim2.new(0.5, -60, 0.85, 0)
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
    UIOvenModal.getProfile = getProfile
end

function UIOvenModal.open()
    if not modal then return end
    local prof = UIOvenModal.getProfile and UIOvenModal.getProfile() or {}
    local price = EconomyConfig.getHatchPrice(prof.HatchCount or 0)
    local priceLabel = modal:FindFirstChild("PriceLabel") :: TextLabel?
    if priceLabel then
        if price == 0 then
            priceLabel.Text = "First Hatch: FREE!"
        else
            priceLabel.Text = string.format("Hatch Price: %d ✨ Sparkle", price)
        end
    end
    modal.Visible = true
end

return UIOvenModal
