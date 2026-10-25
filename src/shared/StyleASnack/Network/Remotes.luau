--!strict
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local FOLDER_NAME = "StyleASnackRemotes"

local REMOTE_EVENTS = {
    "RoundStateChanged",
    "ProfileUpdated",
    "StartWarmup",
    "WarmupStateChanged",
    "WarmupCompleted",
    "RunwayFocusChanged",
    "ShowResults",
    "AnalyticsEvent",
    "StickerFoundNotification",
    "GoldenSprinkleNotification",
}

local REMOTE_FUNCTIONS = {
    "RequestThemeCards",
    "StartSoloRound",
    "SubmitDecorationDiff",
    "FinishRoundDecorate",
    "AbandonRound",
    "HatchOven",
    "GetProfile",
    "CollectHiddenSticker",
    "CollectGoldenSprinkle",
    "AcceptVisitorRequest",
}

function Remotes.init()
    local folder = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
    if not folder then
        if RunService:IsServer() then
            folder = Instance.new("Folder")
            folder.Name = FOLDER_NAME
            folder.Parent = ReplicatedStorage
        else
            folder = ReplicatedStorage:WaitForChild(FOLDER_NAME, 10)
            if not folder then
                error("StyleASnackRemotes folder not found in ReplicatedStorage!")
            end
        end
    end

    if RunService:IsServer() then
        for _, name in ipairs(REMOTE_EVENTS) do
            if not folder:FindFirstChild(name) then
                local event = Instance.new("RemoteEvent")
                event.Name = name
                event.Parent = folder
            end
        end

        for _, name in ipairs(REMOTE_FUNCTIONS) do
            if not folder:FindFirstChild(name) then
                local func = Instance.new("RemoteFunction")
                func.Name = name
                func.Parent = folder
            end
        end
    end
end

function Remotes.getEvent(name: string): RemoteEvent
    local folder = ReplicatedStorage:WaitForChild(FOLDER_NAME, 10) :: Folder
    local event = folder:WaitForChild(name, 5)
    if not event or not event:IsA("RemoteEvent") then
        error("RemoteEvent '" .. name .. "' not found!")
    end
    return event :: RemoteEvent
end

function Remotes.getFunction(name: string): RemoteFunction
    local folder = ReplicatedStorage:WaitForChild(FOLDER_NAME, 10) :: Folder
    local func = folder:WaitForChild(name, 5)
    if not func or not func:IsA("RemoteFunction") then
        error("RemoteFunction '" .. name .. "' not found!")
    end
    return func :: RemoteFunction
end

return Remotes
