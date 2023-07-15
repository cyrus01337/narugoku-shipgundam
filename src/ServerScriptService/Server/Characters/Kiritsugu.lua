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

--|| Imports ||--
local ProfileService = require(Server.ProfileService)

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

local function GetNearestFromMouse(Character, Range)	
	local MouseHit = MouseRemote:InvokeClient(Players:GetPlayerFromCharacter(Character))

	for _, Entity in ipairs(workspace.World.Live:GetChildren()) do
		if Entity:IsA("Model") and GlobalFunctions.IsAlive(Entity) and Entity ~= Character then
			local EntityPrimary = Entity:FindFirstChild("HumanoidRootPart")
			local Distance = (MouseHit.Position - EntityPrimary.Position).Magnitude

			if Distance <= Range then 
				return Entity or nil
			end
		end
	end
end

local HakiDodge = 0

local Meliodas = {
	["FirstAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
		
		local Data = ProfileService:GetPlayerProfile(Player)
	
		
		local Victim = GetNearestFromMouse(Character,8) ---GetMouseTarget(ExtraData.MouseTarget, Character) or GetNearPlayers(Character,35)
		if not Victim then return end

		local Data = Players:GetPlayerFromCharacter(Character) and ProfileService:GetPlayerProfile(Player)			

		if Data.Character == "Kiritsugu" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end 	

		
	end,

	["SecondAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local HumanoidRootPart,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		local Data = ProfileService:GetPlayerProfile(Player)

		if Data.Character == "Kiritsugu" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end 	
		
	end,

	["ThirdAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local HumanoidRootPart,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		local Data = ProfileService:GetPlayerProfile(Player)

		if Data.Character == "Kiritsugu" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end 	
	end,

	["FourthAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		

		local Data = ProfileService:GetPlayerProfile(Player)

		if Data.Character == "Kiritsugu" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end 	
		
		
		StateManager:ChangeState(Character, "IFrame", 10, {IFrameType = "ObservationHaki"})
		
		
	end;
	
	
	["ObservationHaki"] = function(Data)
		-- do ur magic here wunbo chan
		local Character = Data.Character
		local Victim = Data.Victim

		local Player = Players:FindFirstChild(Character.Name)
		--[[Server Effects here/ Camera shake to client]]--

		local direction = "Back"; 
		HakiDodge += 1
		if HakiDodge == 1 then
			direction = "Right"
		elseif HakiDodge == 2 then
			direction = "Left"
		else
			HakiDodge = 0
		end	
		AnimationRemote:FireClient(Player,"Observation"..direction,"Play", {AdjustSpeed = 1})

		NetworkStream.FireClientDistance(Character,"ClientRemote",50,{Character = Character, Module = "KiritsuguVFX", Function = "DoubleAccel"})
	end,
	
}



return Meliodas