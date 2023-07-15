--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ContentProvider = game:GetService("ContentProvider")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules
local Remotes = ReplicatedStorage.Remotes

local Metadata = Modules.Metadata
local Shared = Modules.Shared
local Utility = Modules.Utility

--|| Modules||--
local SpawnData = require(Metadata.SpawnData.SpawnData)

--||Remotes||--
local LobbyRemote = Remotes.LobbyRemote

return {
	Title = "Patricia",
	Text = {"<AnimateStyle=Wiggle><AnimateStyleAmplitude=.7><AnimateStyleNumPeriods=1><AnimateStepFrequency=1><AnimateStyleTime=.15><AnimateStepTime=.001><TextScale=.125>Why 'ello there ! since you made you're way here I assume you want to learn more about<AnimateStyle=Rainbow><AnimateStyleTime=1> nen?<AnimateStyleTime=/><AnimateStyle=/><TextScale=/><AnimateStepTime=/><AnimateStyleTime=/><AnimateStepFrequency=/><AnimateStyleNumPeriods=/><AnimateStyleAmplitude=/><AnimateStyle=/><TextScale=/><AnimateStepTime=/><AnimateStyleTime=/><AnimateStepFrequency=/><AnimateStyleNumPeriods=/><AnimateStyleAmplitude=/><AnimateStyle=/>"},
	
	["FirstNode"] = {
		Text = "<AnimateStyle=Wiggle><AnimateStyleAmplitude=.7><AnimateStyleNumPeriods=1><AnimateStepFrequency=1><AnimateStyleTime=.15><AnimateStepTime=.001><TextScale=.25>Do u wanna teleport to Yami-chan's map uwu 0-0 ",
		
		Option1 = {
			InitialText = "Teleport",
			PressedOn = function(Player, CurrentNode, DialogueModule)
				local Character = Player.Character or Player.CharacterAdded:Wait()
	
				LobbyRemote:FireServer()
				
				
				return DialogueModule.End
			end,
		},
		
		Option2 = {
			InitialText = "",
			PressedOn = function(CurrentNode, DialogueModule)
				
			end,
		},
		Option3 = {
			InitialText = "",
			PressedOn = function(CurrentNode, DialogueModule)

			end,
		}
	},
	

	
	
	
}