--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules
local Remotes = ReplicatedStorage.Remotes

local Metadata = Modules.Metadata
local Shared = Modules.Shared
local Utility = Modules.Utility

--|| Imports ||--
local ControlData = require(Metadata.ControlData.ControlData)
local AnimationManager = require(Shared.AnimationManager)
local Signal = require(Utility.Signal)
local StateDictionary = require(script.Variations)

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Mouse = Player:GetMouse()

_G.StateSignal = Signal.New()

_G.StateSignal:Connect(function(Data)
	local State, StateData = Data.ChosenState, Data.ChosenStateData
	
	local _ = StateDictionary[Data.ChosenState] and StateDictionary[Data.ChosenState](StateData) or warn"no dict vers"
end)