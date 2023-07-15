--|| Services ||--
local Players = game:GetService("Players")

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Directories ||--
local Server = ServerScriptService.Server

local Managers = Server.Managers

local Modules = ReplicatedStorage.Modules
local Assets = ReplicatedStorage.Assets

local State = Server.State

local Effects = Modules.Effects
local Shared = Modules.Shared
local Metadata = Modules.Metadata
local Utility = Modules.Utility

local World = workspace.World
--|| Imports ||--
local VfxHandler = require(Effects.VfxHandler)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local AbilityData = require(Metadata.AbilityData.AbilityData)

local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)

local DamageManager = require(Managers.DamageManager)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)

local SoundManager = require(Shared.SoundManager)


local RaycastManager = require(Shared.RaycastManager)
local TaskScheduler = require(Utility.TaskScheduler)

local Ragdoll = require(ServerStorage.Modules.Ragdoll)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

local Guts = {
	
	["FirstAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})	
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
		
		--[[ Fire Animation ]]--
		AnimationRemote:FireClient(Player, "DemonicPound", "Play")	
		
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Distance = 100, Module = "GutsVFX", Function = "DemonicPound"})
		
		wait(0.25)
		local MAX_HEIGHT = 50
		
		local BodyPosition = Instance.new("BodyPosition")
		BodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		BodyPosition.P = 200;
		BodyPosition.D = 200;
		BodyPosition.Parent = Character.HumanoidRootPart
		BodyPosition.Position = (Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-MAX_HEIGHT)).Position
		Debris:AddItem(BodyPosition, 0.1)
		
		wait(0.5)
		BodyPosition:Destroy()
		MAX_HEIGHT = 25
		
		local BodyPosition = Instance.new("BodyPosition")
		BodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		BodyPosition.P = 200;
		BodyPosition.D = 100;
		BodyPosition.Parent = Character.HumanoidRootPart
		BodyPosition.Position = (Character.HumanoidRootPart.CFrame * CFrame.new(0,MAX_HEIGHT,0)).Position
		Debris:AddItem(BodyPosition, 0.25)
		
		wait(0.25)
		BodyPosition:Destroy()
		MAX_HEIGHT = 50
		
		local BodyPosition = Instance.new("BodyPosition")
		BodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		BodyPosition.P = 200;
		BodyPosition.D = 100;
		BodyPosition.Parent = Character.HumanoidRootPart
		BodyPosition.Position = (Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-MAX_HEIGHT)).Position
		Debris:AddItem(BodyPosition, 0.25)
	end,

	["SecondAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local HumanoidRootPart,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName) 		
	end,

	["ThirdAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local HumanoidRootPart,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName) 	
	end,

	["FourthAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
	end;
}

return Guts