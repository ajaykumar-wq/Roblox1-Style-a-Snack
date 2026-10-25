--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[Style a Snack] Initializing Client Systems...")

local Remotes = require(ReplicatedStorage:WaitForChild("StyleASnack"):WaitForChild("Network"):WaitForChild("Remotes"))
local AudioController = require(script.Parent.Controllers.AudioController)
local ViewController = require(script.Parent.Controllers.ViewController)
local DecorateController = require(script.Parent.Controllers.DecorateController)
local UIController = require(script.Parent.Controllers.UIController)

AudioController.init()
DecorateController.init()
UIController.init()
ViewController.init()

print("[Style a Snack] Client Core initialized successfully!")
