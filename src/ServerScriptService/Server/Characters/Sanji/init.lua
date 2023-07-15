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

local HitboxModule = require(script.Parent.Parent.Combat.Combat.HitboxModule)

local ProfileService = require(Server.ProfileService)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

local Sanji = {
	["FirstAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
		
		StateManager:ChangeState(Character,"IFrame",.35, {IFrameType = ""})
		StateManager:ChangeState(Character,"Stunned",4e4)
		AnimationRemote:FireClient(Player,"PartyTable","Play")
		
		wait(.35)
		NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Module = "SanjiVFX", Function = "PartyTable"})
		
		local Data = ProfileService:GetPlayerProfile(Player)
		if Data.Character == "Sanji" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end
		
		for Index = 1,15 do
			-- SoundManager:AddSound("BarrageSwing", {Parent = Root, Volume = 3, PlaybackSpeed = 1.4}, "Client")
			local HitResult,HitObject = HitboxModule.MagnitudeModule(Character, {Delay = 0, Range = 5, KeysLogged = math.random(1,3), Type = "Combat"}, KeyData.SerializedKey, CharacterName)
			if HitResult then
				local Victim = HitObject.Parent

				local VRoot,VHum = Victim:FindFirstChild("HumanoidRootPart"),Victim:FindFirstChild("Humanoid")
				CameraRemote:FireClient(Player,"CameraShake",{ FirstText = 1, SecondText = 5})

				-- SoundManager:AddSound("Punched1",{Parent = Character:FindFirstChild("HumanoidRootPart"),Volume = 5},"Client")

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
				BodyVelocity.Velocity = (VRoot.CFrame.p - Root.CFrame.p).Unit * 8
				BodyVelocity.Parent = Root
				Debris:AddItem(BodyVelocity,.25)					

				local Look = CFrame.new(VRoot.Position,Root.Position).lookVector

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,0,4e4)
				BodyVelocity.Velocity = Look * -10
				BodyVelocity.Parent = VRoot
				Debris:AddItem(BodyVelocity,.2)					
			end
			wait(.125)
		end
		StateManager:ChangeState(Character,"Stunned",.35)
		SpeedManager.changeSpeed(Character,0,1,3) --function(Character,Speed,Duration,Priority)
	end,

	["SecondAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local HumanoidRootPart,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		local Data = ProfileService:GetPlayerProfile(Player)
		if Data.Character == "Sanji" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end 

		AnimationRemote:FireClient(Player,"AntiManner","Play")

		-- SoundManager:AddSound("CombatSwing",{Parent = HumanoidRootPart, Volume = 5}, "Client")
		StateManager:ChangeState(Character,"Attacking",.5)

		wait(.25)
		local HitResult,HitObject = HitboxModule.MagnitudeModule(Character,{Range = 5, Type = "Combat"}, KeyData.SerializedKey, CharacterName)
		if HitResult then
			local Victim = HitObject.Parent
			local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.Velocity = Vector3.new(0,50,0)
			BodyVelocity.MaxForce = Vector3.new(100000,100000,100000)
			BodyVelocity.Parent = VRoot

			Debris:AddItem(BodyVelocity,.3)	

			StateManager:ChangeState(Character,"Stunned",.5)
			NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Module = "SanjiVFX", Function = "Anti_Manner_Kick_Course"})
		end			
	end,

	["ThirdAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local HumanoidRootPart,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		local Data = ProfileService:GetPlayerProfile(Player)
		if Data.Character == "Sanji" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end 

		AnimationRemote:FireClient(Player,"Spectre","Play",{Looped = true})
		NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Module = "SanjiVFX", Function = "Spectre"})

		StateManager:ChangeState(Character,"Stunned",4e4)
		SpeedManager.changeSpeed(Character,4,1.5,3) --function(Character,Speed,Duration,Priority)

		local PlayerCombo = AbilityData.ReturnData(Player,"PlayerCombos","GlobalInformation")

		for Index = 1,15 do
			-- SoundManager:AddSound("BarrageSwing", {Parent = Humanoid, Volume = 3, PlaybackSpeed = 1.4}, "Client")

			local HitObject = HitboxModule.RaycastModule(Player, {Visualize = false, Size = 10, KeysLogged = PlayerCombo.KeysLogged, Type = "Combat"}, KeyData.SerializedKey, CharacterName)
			if HitObject.Hit then
				local Victim = HitObject.Object.Parent
				local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")
				
				-- SoundManager:AddSound("Punched1",{Parent = Character:FindFirstChild("HumanoidRootPart"),Volume = 5},"Client")

				CameraRemote:FireClient(Player,"CameraShake",{ FirstText = 1, SecondText = 5})
				DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{Type = "Combat", KeysLogged = ExtraData.KeysLogged})
			end
			wait(.1)
		end
		StateManager:ChangeState(Character,"Stunned",1)
		AnimationRemote:FireClient(Player,"Spectre","Stop")
	end,

	["FourthAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		local Data = ProfileService:GetPlayerProfile(Player)
		if Data.Character == "Sanji" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end 
		
		StateManager:ChangeState(Character,"Attacking",.5)
		-- SoundManager:AddSound("CombatSwing",{Parent = Root, Volume = 5}, "Client")

		AnimationRemote:FireClient(Player,"Coiler","Play")
		wait(.25)

		local HitResult,HitObject = HitboxModule.MagnitudeModule(Character,{Range = 8, Type = "Combat", SecondType = "SlamDown"}, KeyData.SerializedKey, CharacterName)
		if HitResult then
			local Victim = HitObject.Parent
			local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

			ClientRemote:FireAllClients{Character = Character, Module = "SanjiVFX"; Function = "Coiler"; Victim = Victim}
			
			local Anim = VHum:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Misc.SlamDown)
			Anim:Play(.1,1)		
			
			wait(1)			
			Anim:Stop()
		end
	end,
}

return Sanji