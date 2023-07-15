--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ContentProvider = game:GetService("ContentProvider")
local MarketPlaceService = game:GetService("MarketplaceService")

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
local ProductRemote = Remotes.ProductRemote

--|Variables|--
local PriceTable = {
	["1000"] = 1169016789,
	["3000"] = 1169017358,
	["10000"] = 1169017439,
}

local PressedTimes = 0
return {
	Title = "Bulma",
	Text = {"<AnimateStyle=Wiggle><AnimateStyleAmplitude=.7><AnimateStyleNumPeriods=1><AnimateStepFrequency=1><AnimateStyleTime=.15><AnimateStepTime=.001><TextScale=.125>Why 'ello there ! since you made you're way here I assume you want to learn more about<AnimateStyle=Rainbow><AnimateStyleTime=1> nen?<AnimateStyleTime=/><AnimateStyle=/><TextScale=/><AnimateStepTime=/><AnimateStyleTime=/><AnimateStepFrequency=/><AnimateStyleNumPeriods=/><AnimateStyleAmplitude=/><AnimateStyle=/><TextScale=/><AnimateStepTime=/><AnimateStyleTime=/><AnimateStepFrequency=/><AnimateStyleNumPeriods=/><AnimateStyleAmplitude=/><AnimateStyle=/>"},
	
	["FirstNode"] = {
		Text = "<AnimateStyle=Wiggle><AnimateStyleAmplitude=.7><AnimateStyleNumPeriods=1><AnimateStepFrequency=1><AnimateStyleTime=.15><AnimateStepTime=.001><TextScale=.25> Wanna buy sum coins >.< ",
		
		Option1 = {
			InitialText = "Buy Coins",
			PressedOn = function(Player, CurrentNode, DialogueModule)
				
				print("pressed")
				
				return DialogueModule.UpdateText, "Second"
			end,
		},
		
		Option2 = {
			InitialText = "",
			PressedOn = function(Player, CurrentNode, DialogueModule)
				
			end,
		},
		
		Option3 = {
			InitialText = "",
			PressedOn = function(Player, CurrentNode, DialogueModule)
				
			end,
		}
	},
	
	["SecondNode"] = {
		Text = "<AnimateStyle=Wiggle><AnimateStyleAmplitude=.7><AnimateStyleNumPeriods=1><AnimateStepFrequency=1><AnimateStyleTime=.15><AnimateStepTime=.001><TextScale=.25> Oki here r da prices <.< ",

		Option1 = {
			InitialText = "1000",
			PressedOn = function(Player, CurrentNode, DialogueModule)
				
				ProductRemote:FireServer(PriceTable["1000"])
				
			
			end,
		},

		Option2 = {
			InitialText = "3000",
			PressedOn = function(CurrentNode, DialogueModule)
				ProductRemote:FireServer(PriceTable["3000"])
			end,
		},
		
		Option3 = {
			InitialText = "10000",
			PressedOn = function(CurrentNode, DialogueModule)
				ProductRemote:FireServer(PriceTable["10000"])
			end,
		}
	}
	

	
	
	
}