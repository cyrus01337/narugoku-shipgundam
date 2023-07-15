--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Variables ||--
local Modules = ReplicatedStorage.Modules

local Server = ServerScriptService.Server

local Effects = Modules.Effects
local Utility = Modules.Utility
local Shared = Modules.Shared
local Metadata = Modules.Metadata

--|| Remotes ||--
local RemoteFolder = ReplicatedStorage.Remotes

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local AnimationRemote = RemoteFolder.AnimationRemote

--|| Imports ||--
local DebounceManager = require(Server.State.DebounceManager)

local SoundManager = require(Shared.SoundManager)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)

local AbilityData = require(Metadata.AbilityData.AbilityData)

local VfxHandler = require(Effects.VfxHandler)

local NetworkStream = require(Utility.NetworkStream)

local HitboxModule = require(script.Parent.HitboxModule)

return function(Player,Data)
	local Character = Player.Character

	local Victim = Data.Victim

	local Position = Data.Position
	local Duration = Data.Duration

	local VRoot,Hum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

	if Victim then
		if Players:GetPlayerFromCharacter(Victim) == nil and Victim and Player then
			if VRoot and VRoot.Anchored == false then
				for _,v in ipairs(Victim:GetChildren()) do
					if v:IsA("BasePart") and v.Anchored == false then
						v:SetNetworkOwner(Player)
					end
				end
			end
		end

		if Player and Victim then
			local BodyPosition = Instance.new("BodyPosition")
			BodyPosition.MaxForce = Vector3.new(9e9,9e9,9e9)
			BodyPosition.P = 2e4
			BodyPosition.Position = VRoot.Position
			BodyPosition.Parent = VRoot
			BodyPosition.Position = Position
			Debris:AddItem(BodyPosition,Duration)
		end
	end
end