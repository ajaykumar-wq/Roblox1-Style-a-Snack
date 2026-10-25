--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local DecorationConfig = require(ReplicatedStorage.StyleASnack.Config.DecorationConfig)
local ThemeConfig = require(ReplicatedStorage.StyleASnack.Config.ThemeConfig)
local Remotes = require(ReplicatedStorage.StyleASnack.Network.Remotes)
local AudioController = require(script.Parent.AudioController)

local DecorateController = {}

export type DecorationLayer = DecorationConfig.Layer

local currentLayers: { DecorationLayer } = {}
local selectedTool: DecorationConfig.ToolType = "Icing"
local selectedSwatchIndex: number = 1
local selectedItemId: string? = nil
local activeCreatureModel: Model? = nil
local activePalette: ThemeConfig.Palette? = nil
local activeOccasion: ThemeConfig.Occasion? = nil

local onLayerChangedCallback: (({ DecorationLayer }) -> ())? = nil
local onTrayShakeCallback: (() -> ())? = nil

function DecorateController.init()
    -- Set default palette
    activePalette = ThemeConfig.Palettes[1]
end

function DecorateController.setPalette(palette: ThemeConfig.Palette)
    activePalette = palette
end

function DecorateController.setOccasion(occasion: ThemeConfig.Occasion)
    activeOccasion = occasion
end

function DecorateController.setTargetCreature(model: Model)
    activeCreatureModel = model
    DecorateController.renderAllLayers()
end

function DecorateController.selectTool(tool: DecorationConfig.ToolType)
    selectedTool = tool
end

function DecorateController.getSelectedTool(): DecorationConfig.ToolType
    return selectedTool
end

function DecorateController.selectSwatch(swatchIndex: number)
    selectedSwatchIndex = math.clamp(swatchIndex, 1, 8)
end

function DecorateController.getSelectedSwatchIndex(): number
    return selectedSwatchIndex
end

function DecorateController.selectItem(itemId: string)
    selectedItemId = itemId
end

function DecorateController.getCurrentColor(): Color3
    if activePalette and activePalette.Swatches[selectedSwatchIndex] then
        return activePalette.Swatches[selectedSwatchIndex]
    end
    return Color3.new(1, 1, 1)
end

function DecorateController.getLayers(): { DecorationLayer }
    return currentLayers
end

function DecorateController.onLayersChanged(callback: ({ DecorationLayer }) -> ())
    onLayerChangedCallback = callback
end

function DecorateController.onTrayShake(callback: () -> ())
    onTrayShakeCallback = callback
end

function DecorateController.applyIcing(regionName: string)
    if #currentLayers >= DecorationConfig.MaxLayersPerEntry then
        if onTrayShakeCallback then onTrayShakeCallback() end
        return
    end

    -- 1 coat per region; replace if already present
    for i = #currentLayers, 1, -1 do
        if currentLayers[i].Tool == "Icing" and currentLayers[i].Region == regionName then
            table.remove(currentLayers, i)
            break
        end
    end

    local layer: DecorationLayer = {
        Id = HttpService:GenerateGUID(false),
        Tool = "Icing",
        Region = regionName,
        SwatchIndex = selectedSwatchIndex,
        Color = DecorateController.getCurrentColor(),
    }

    table.insert(currentLayers, layer)
    AudioController.play("wet_pop")
    DecorateController.notifyChange()
end

function DecorateController.applySprinkle(shapeId: string?, count: number?)
    local sprinkleLayerCount = 0
    for _, l in ipairs(currentLayers) do
        if l.Tool == "Sprinkle" then sprinkleLayerCount += 1 end
    end
    if sprinkleLayerCount >= DecorationConfig.Tools.Sprinkle.MaxLayers then
        if onTrayShakeCallback then onTrayShakeCallback() end
        return
    end
    if #currentLayers >= DecorationConfig.MaxLayersPerEntry then
        if onTrayShakeCallback then onTrayShakeCallback() end
        return
    end

    local layer: DecorationLayer = {
        Id = HttpService:GenerateGUID(false),
        Tool = "Sprinkle",
        ItemId = shapeId or "rainbow_pill",
        Count = math.clamp(count or 30, 1, DecorationConfig.Tools.Sprinkle.MaxPiecesPerLayer),
        Color = DecorateController.getCurrentColor(),
    }

    table.insert(currentLayers, layer)
    AudioController.play("rattle")
    DecorateController.notifyChange()
end

function DecorateController.applySticker(stickerId: string, targetRegion: string)
    local stickerCount = 0
    for _, l in ipairs(currentLayers) do
        if l.Tool == "Sticker" then stickerCount += 1 end
    end
    if stickerCount >= DecorationConfig.Tools.Sticker.MaxPerEntry then
        if onTrayShakeCallback then onTrayShakeCallback() end
        return
    end
    if #currentLayers >= DecorationConfig.MaxLayersPerEntry then
        if onTrayShakeCallback then onTrayShakeCallback() end
        return
    end

    local layer: DecorationLayer = {
        Id = HttpService:GenerateGUID(false),
        Tool = "Sticker",
        ItemId = stickerId,
        Region = targetRegion,
    }

    table.insert(currentLayers, layer)
    AudioController.play("pop")
    DecorateController.notifyChange()
end

function DecorateController.applyDrizzle()
    local drizzleCount = 0
    for _, l in ipairs(currentLayers) do
        if l.Tool == "Drizzle" then drizzleCount += 1 end
    end
    if drizzleCount >= DecorationConfig.Tools.Drizzle.MaxLines then
        if onTrayShakeCallback then onTrayShakeCallback() end
        return
    end
    if #currentLayers >= DecorationConfig.MaxLayersPerEntry then
        if onTrayShakeCallback then onTrayShakeCallback() end
        return
    end

    local layer: DecorationLayer = {
        Id = HttpService:GenerateGUID(false),
        Tool = "Drizzle",
        SwatchIndex = selectedSwatchIndex,
        Color = DecorateController.getCurrentColor(),
    }

    table.insert(currentLayers, layer)
    AudioController.play("hum")
    DecorateController.notifyChange()
end

function DecorateController.applyPattern(patternId: string, regionName: string)
    if #currentLayers >= DecorationConfig.MaxLayersPerEntry then
        if onTrayShakeCallback then onTrayShakeCallback() end
        return
    end

    -- 1 pattern per region; replace if already present
    for i = #currentLayers, 1, -1 do
        if currentLayers[i].Tool == "Pattern" and currentLayers[i].Region == regionName then
            table.remove(currentLayers, i)
            break
        end
    end

    local layer: DecorationLayer = {
        Id = HttpService:GenerateGUID(false),
        Tool = "Pattern",
        ItemId = patternId,
        Region = regionName,
        SwatchIndex = selectedSwatchIndex,
        Color = DecorateController.getCurrentColor(),
    }

    table.insert(currentLayers, layer)
    AudioController.play("unroll")
    DecorateController.notifyChange()
end

function DecorateController.applyAccessory(accessoryId: string, attachmentName: string)
    local accCount = 0
    for _, l in ipairs(currentLayers) do
        if l.Tool == "Accessory" then accCount += 1 end
    end
    if accCount >= DecorationConfig.Tools.Accessory.MaxPerEntry then
        if onTrayShakeCallback then onTrayShakeCallback() end
        return
    end
    if #currentLayers >= DecorationConfig.MaxLayersPerEntry then
        if onTrayShakeCallback then onTrayShakeCallback() end
        return
    end

    local layer: DecorationLayer = {
        Id = HttpService:GenerateGUID(false),
        Tool = "Accessory",
        ItemId = accessoryId,
        Attachment = attachmentName,
        Color = DecorateController.getCurrentColor(),
    }

    table.insert(currentLayers, layer)
    AudioController.play("click")
    DecorateController.notifyChange()
end

function DecorateController.undoLayer(layerId: string)
    for i, l in ipairs(currentLayers) do
        if l.Id == layerId then
            table.remove(currentLayers, i)
            DecorateController.notifyChange()
            break
        end
    end
end

function DecorateController.clearAll()
    currentLayers = {}
    DecorateController.notifyChange()
end

function DecorateController.notifyChange()
    DecorateController.renderAllLayers()
    if onLayerChangedCallback then
        onLayerChangedCallback(currentLayers)
    end
    -- Push diff to server
    pcall(function()
        Remotes.getFunction("SubmitDecorationDiff"):InvokeServer(currentLayers)
    end)
end

function DecorateController.renderAllLayers()
    if not activeCreatureModel then return end

    -- Clean up previous decorations
    local decFolder = activeCreatureModel:FindFirstChild("AppliedDecorations")
    if decFolder then
        decFolder:Destroy()
    end
    decFolder = Instance.new("Folder")
    decFolder.Name = "AppliedDecorations"
    decFolder.Parent = activeCreatureModel

    -- Render layers according to LayerRenderPriority
    local sortedLayers = table.clone(currentLayers)
    table.sort(sortedLayers, function(a, b)
        local pA = DecorationConfig.LayerRenderPriority[a.Tool] or 99
        local pB = DecorationConfig.LayerRenderPriority[b.Tool] or 99
        return pA < pB
    end)

    for _, layer in ipairs(sortedLayers) do
        if layer.Tool == "Icing" and layer.Region then
            local part = activeCreatureModel:FindFirstChild(layer.Region)
            if part and part:IsA("BasePart") then
                part.Color = layer.Color or Color3.new(1, 1, 1)
                part.Material = Enum.Material.SmoothPlastic
            end
        elseif layer.Tool == "Pattern" and layer.Region then
            local part = activeCreatureModel:FindFirstChild(layer.Region)
            if part and part:IsA("BasePart") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "PatternHighlight"
                highlight.FillColor = layer.Color or Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.4
                highlight.OutlineTransparency = 0.8
                highlight.Adornee = part
                highlight.Parent = decFolder
            end
        elseif layer.Tool == "Accessory" and layer.Attachment then
            local part = activeCreatureModel:FindFirstChild(layer.Attachment) or activeCreatureModel.PrimaryPart
            if part and part:IsA("BasePart") then
                local accPart = Instance.new("Part")
                accPart.Name = "Acc_" .. tostring(layer.ItemId)
                accPart.Size = Vector3.new(0.6, 0.6, 0.6)
                accPart.Color = layer.Color or Color3.fromHex("#FFD700")
                accPart.Material = Enum.Material.Neon
                accPart.CanCollide = false
                accPart.CFrame = part.CFrame * CFrame.new(0, 0.8, 0)

                local weld = Instance.new("WeldConstraint")
                weld.Part0 = part
                weld.Part1 = accPart
                weld.Parent = accPart
                accPart.Parent = decFolder
            end
        elseif layer.Tool == "Sprinkle" then
            local emitter = Instance.new("ParticleEmitter")
            emitter.Name = "SprinkleEmitter"
            emitter.Rate = 0
            emitter.Speed = NumberRange.new(0.5, 1)
            emitter.Size = NumberSequence.new(0.2)
            emitter.Color = ColorSequence.new(layer.Color or Color3.new(1, 0.5, 0.8))
            local root = activeCreatureModel.PrimaryPart or activeCreatureModel:FindFirstChildWhichIsA("BasePart")
            if root then
                emitter.Parent = root
                emitter:Emit(layer.Count or 30)
            end
        end
    end
end

return DecorateController
