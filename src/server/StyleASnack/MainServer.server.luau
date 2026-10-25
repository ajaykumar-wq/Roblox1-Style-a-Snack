--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

print("[Style a Snack] Initializing Stage 1 Single-Player Systems...")

local Remotes = require(ReplicatedStorage.StyleASnack.Network.Remotes)
Remotes.init()

local DataService = require(ServerScriptService.StyleASnack.Services.DataService)
local EconomyService = require(ServerScriptService.StyleASnack.Services.EconomyService)
local ServerJudgeService = require(ServerScriptService.StyleASnack.Services.ServerJudgeService)
local RivalService = require(ServerScriptService.StyleASnack.Services.RivalService)
local ExplorationService = require(ServerScriptService.StyleASnack.Services.ExplorationService)
local OvenService = require(ServerScriptService.StyleASnack.Services.OvenService)
local AnalyticsService = require(ServerScriptService.StyleASnack.Services.AnalyticsService)
local WarmupService = require(ServerScriptService.StyleASnack.Services.WarmupService)
local RoundService = require(ServerScriptService.StyleASnack.Services.RoundService)

DataService.init()
AnalyticsService.init()
ExplorationService.init()
OvenService.init()
WarmupService.init()
RoundService.init()

print("[Style a Snack] Stage 1 Single-Player Core initialized successfully!")
