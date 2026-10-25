--!strict
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ViewController = {}

local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

export type CameraMode = "Lobby" | "Round" | "Runway" | "Results"

local currentMode: CameraMode = "Lobby"
local currentPresetAngleIndex = 1
local renderConn: RBXScriptConnection? = nil

-- Preset camera offsets relative to creature center
local PRESET_OFFSETS = {
    [1] = Vector3.new(4, 2.5, 6),   -- Front-right 3/4 view
    [2] = Vector3.new(-4, 2.5, 6),  -- Front-left 3/4 view
}

function ViewController.init()
    ViewController.setMode("Lobby")
end

function ViewController.setMode(mode: CameraMode, targetFocus: Instance?)
    currentMode = mode

    if renderConn then
        renderConn:Disconnect()
        renderConn = nil
    end

    camera.CameraType = Enum.CameraType.Scriptable

    if mode == "Lobby" then
        -- Fixed-follow third person behind character
        camera.CameraType = Enum.CameraType.Custom
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                camera.CameraSubject = hum
            end
        end

    elseif mode == "Round" or mode == "Results" then
        -- Locked 3/4 view focused on decorated creature
        local focusPart: BasePart? = nil
        if targetFocus and targetFocus:IsA("BasePart") then
            focusPart = targetFocus
        elseif targetFocus and targetFocus:IsA("Model") then
            focusPart = targetFocus.PrimaryPart or targetFocus:FindFirstChildWhichIsA("BasePart")
        end

        local centerPos = focusPart and focusPart.Position or Vector3.new(0, 5, 0)

        local function updateCamera()
            local offset = PRESET_OFFSETS[currentPresetAngleIndex]
            local camPos = centerPos + offset
            camera.CFrame = CFrame.new(camPos, centerPos + Vector3.new(0, 0.5, 0))
        end

        updateCamera()
        renderConn = RunService.RenderStepped:Connect(updateCamera)

    elseif mode == "Runway" then
        -- Scripted dolly camera past entry in spotlight
        local centerPos = Vector3.new(0, 5, 20)
        local startPos = centerPos + Vector3.new(6, 2, 8)
        local endPos = centerPos + Vector3.new(-6, 2, 8)

        camera.CFrame = CFrame.new(startPos, centerPos)
        local tween = TweenService:Create(camera, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            CFrame = CFrame.new(endPos, centerPos),
        })
        tween:Play()
    end
end

function ViewController.toggleAngle()
    currentPresetAngleIndex = (currentPresetAngleIndex % #PRESET_OFFSETS) + 1
end

ViewController.togglePresetAngle = ViewController.toggleAngle

return ViewController
