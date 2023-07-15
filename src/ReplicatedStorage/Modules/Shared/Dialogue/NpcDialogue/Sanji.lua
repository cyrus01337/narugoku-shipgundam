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
	Title = "Sanji",
	Text = {"<AnimateStyle=Wiggle><AnimateStyleAmplitude=.7><AnimateStyleNumPeriods=1><AnimateStepFrequency=1><AnimateStyleTime=.15><AnimateStepTime=.001><TextScale=.125>Why 'ello there ! since you made you're way here I assume you want to learn more about<AnimateStyle=Rainbow><AnimateStyleTime=1> nen?<AnimateStyleTime=/><AnimateStyle=/><TextScale=/><AnimateStepTime=/><AnimateStyleTime=/><AnimateStepFrequency=/><AnimateStyleNumPeriods=/><AnimateStyleAmplitude=/><AnimateStyle=/><TextScale=/><AnimateStepTime=/><AnimateStyleTime=/><AnimateStepFrequency=/><AnimateStyleNumPeriods=/><AnimateStyleAmplitude=/><AnimateStyle=/>"},
	
	["FirstNode"] = {
		Text = "<AnimateStyle=Wiggle><AnimateStyleAmplitude=.7><AnimateStyleNumPeriods=1><AnimateStepFrequency=1><AnimateStyleTime=.15><AnimateStepTime=.001><TextScale=.25>U wanna buy da cool skiins >.< ",
		
		Option1 = {
			InitialText = "Yes",
			PressedOn = function(Player, CurrentNode, DialogueModule)
				local Character = Player.Character or Player.CharacterAdded:Wait()
				
				
				
				
				return DialogueModule.UpdateText, "Second"
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
	
	["SecondNode"] = {
		Text = "<AnimateStyle=Wiggle><AnimateStyleAmplitude=.7><AnimateStyleNumPeriods=1><AnimateStepFrequency=1><AnimateStyleTime=.15><AnimateStepTime=.001><TextScale=.25> ok here r da options",
		
		
		Option1 = {
			InitialText = "Skin Box #1",
			PressedOn = function(Player, CurrentNode, DialogueModule)
				
			end,
		},
		
		Option2 = {
			InitialText = "Skin Box #2",
			PressedOn = function(Player, CurrentNode, DialogueModule)

			end,
		},
		
		Option3 = {
			InitialText = "Skin Box #3",
			PressedOn = function(Player, CurrentNode, DialogueModule)

			end,
		}
	}
	
	
	
}