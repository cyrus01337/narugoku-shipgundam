--|| Services |--
local Players = game:GetService("Players")

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

--|| Directories ||--
local Server = ServerScriptService.Server
local Managers = Server.Managers

local Modules = ReplicatedStorage.Modules
local State = Server.State

local Effects = Modules.Effects
local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Shared = Modules.Shared
local CharacterData = Metadata.CharacterData

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)

local SoundManager = require(Shared.SoundManager)

local AbilityData = require(Metadata.AbilityData.AbilityData)
local CombatData = require(Metadata.CombatData.CombatData)

local CharacterInfo = require(CharacterData.CharacterInfo)

local VfxHandler = require(Effects.VfxHandler)

local StandManager = require(Managers.StandManager)
local DamageManager = require(Managers.DamageManager)
local ProfileService = require(Server.ProfileService)

local HitboxModule = require(Server.Combat.Combat.HitboxModule)
local Aerial = require(Server.Combat.Combat.Aerial)

local FreshRagdoll = require(ServerStorage.Modules.FreshRagdoll)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote

--|| Remotes ||--
local RemoteFolder = ReplicatedStorage.Remotes

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local AnimationRemote = RemoteFolder.AnimationRemote

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Map}
raycastParams.FilterType = Enum.RaycastFilterType.Include

local Variations = {
	["LLRRL"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Humanoid,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")
		
		local PlayerCombo = AbilityData.ReturnData(Player,"PlayerCombos","GlobalInformation")
		
		PlayerCombo.KeysLogged = 0
		PlayerCombo.ComboVariation = ""

		PlayerCombo.Hits = 0
		
		StateManager:ChangeState(Character,"Guardbroken",3.35)
		StateManager:ChangeState(Character,"IFrame",.35)
		
		AnimationRemote:FireClient(Player,"BarrageFinisher","Play")
		
		wait(.3)
		NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Module = "CombatVFX", Function = "StartBarrage"})			

		for Index = 1,8 do
			-- SoundManager:AddSound("BarrageSwing", {Parent = Root, Volume = 3, PlaybackSpeed = 1.4}, "Client")

			local HitObject = HitboxModule.RaycastModule(Player, {Size = 10, KeysLogged = nil, Type = "Combat"}, KeyData.SerializedKey, CharacterName)
			if HitObject.Hit then
				local Victim = HitObject.Object.Parent
				local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

				-- SoundManager:AddSound("Punched1",{Parent = Character:FindFirstChild("HumanoidRootPart"),Volume = 5},"Client")

				CameraRemote:FireClient(Player,"CameraShake",{ FirstText = 1, SecondText = 5})
				DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{Type = "Combat", KeysLogged = ExtraData.KeysLogged, Damage = .15})
			end
			wait(.135)
		end
	   coroutine.wrap(function()
			wait(.22)
			
			local HitObject = HitboxModule.RaycastModule(Player, {Size = 10, KeysLogged = math.random(1,3), Type = "Combat"}, KeyData.SerializedKey, CharacterName)
			if HitObject.Hit then
				local Victim = HitObject.Object.Parent
				local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

				-- SoundManager:AddSound("Punched1",{Parent = Character:FindFirstChild("HumanoidRootPart"),Volume = 5},"Client")
				-- SoundManager:AddSound("CombatKnockback", {Parent = Character.HumanoidRootPart, Volume = 3.75}, "Client")

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
				BodyVelocity.Velocity = CFrame.new(Root.Position,Root.Position + (Root.CFrame.lookVector * 10) + (Root.CFrame.upVector * -10) ).lookVector * 90
				BodyVelocity.Parent = VRoot
				Debris:AddItem(BodyVelocity,.25)

				FreshRagdoll.DurationRagdoll(Victim,2)
			end
			NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Module = "CombatVFX", Function = "LastBarrageHit"})			
		end)()
	end,
	
	["LLLLR"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Humanoid,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")
		
		StateManager:ChangeState(Character,"Guardbroken",1.35)
		StateManager:ChangeState(Character,"IFrame",.35)
		
		local Data = ProfileService:GetPlayerProfile(Player)
		local Type = CharacterInfo[Data.Character]["AnimationType"]
		
		local HasCombat = CharacterInfo[Data.Character]["HasCombat"]
		local SoundType = HasCombat and "Combat" or "Sword"
		
		-- SoundManager:AddSound(SoundType.."Swing", {Parent = Root}, "Client")
		
		local AnimationFinisher = Type == "Spear" and "SpearFinisher" or Type == "Sword" and "SwordFinisher" or Type == "Combat" and "FistFinisher" or "SanjiFinisher"
		AnimationRemote:FireClient(Player,AnimationFinisher,"Play")
				
		wait(.255)
		local HitResult,HitObject = HitboxModule.MagnitudeModule(Character, {Range = 6, KeysLogged = 2}, KeyData.SerializedKey, CharacterName, nil, "fap")
		if HitResult then
			local Victim = HitObject.Parent
			local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")
			
			CameraRemote:FireClient(Player, "CameraShake", {FirstText = 8, SecondText = 10})
			--CameraRemote:FireClient(Player,"CreateBlur",{Size = 12, Length = .25})
			
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
			BodyVelocity.Velocity = CFrame.new(Root.Position,Root.Position + (Root.CFrame.lookVector * 10) + (Root.CFrame.upVector * -10) ).lookVector * 80
			BodyVelocity.Parent = VRoot
			Debris:AddItem(BodyVelocity,.25)

			FreshRagdoll.DurationRagdoll(Victim,1.5)
			NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Victim = Victim, Module = "CombatVFX", Function = "LLLLR"})
		end
	end,
	
	["LRRL"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Humanoid,HumanoidRootPart = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

		local Hits = Character:FindFirstChild("Hits")

		local PlayerCombo = AbilityData.ReturnData(Player,"PlayerCombos","GlobalInformation")

		local Stands = Character

		local HasStand = Stands:FindFirstChild(Character.Name.." - Stand")

		local AerialAnims = ReplicatedStorage.Assets.Animations.Shared.Combat.Aerial

		local Number = -4

		local Data = ProfileService:GetPlayerProfile(Player)
		local AnimationIndex = CharacterInfo[Data.Character]["AerialAnimation"] or "AerialStartUp"	

		if Hits.Value >= 1 and Humanoid.JumpPower <= 0 and Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
			SpeedManager.changeSpeed(Character,11,3.25,4e4,nil,false)
			local _ = (HasStand and HasStand.Humanoid:LoadAnimation(AerialAnims["AerialStartUp"]):Play()) or (HasStand == nil and AnimationRemote:FireClient(Player, AnimationIndex, "Play", {FadeTime = .1, Weight = 1}))
			local _ = (HasStand and Number and -6.35) or (HasStand == nil and Number and -4)

			-- SoundManager:AddSound("CombatSwing", {Parent = HumanoidRootPart, Volume = .25}, "Client")
			StateManager:ChangeState(Character, "Attacking", .275)

			local CFrameTarget = HumanoidRootPart.CFrame * CFrame.new(0,12,0)
			local Calculation1,Calculation2 = HumanoidRootPart.Position , HumanoidRootPart.CFrame.upVector * 200
			local RaycastResults = workspace:Raycast(Calculation1,Calculation2,raycastParams)
			local Subtraction = HumanoidRootPart.CFrame - HumanoidRootPart.Position

			local BodyPosition = Instance.new("BodyPosition")
			BodyPosition.MaxForce = Vector3.new(9e9,9e9,9e9)
			BodyPosition.Position = HumanoidRootPart.Position
			BodyPosition.P = 2e4

			if RaycastResults and RaycastResults.Position and RaycastResults.Position and (RaycastResults.Position - Calculation1).Magnitude < 20 then
				CFrameTarget = CFrame.new(RaycastResults.Position) * Subtraction
			end

			coroutine.wrap(function()
				local HitResult,HitObject = HitboxModule.MagnitudeModule(Character, {Range = 5, KeysLogged = PlayerCombo.KeysLogged}, KeyData.SerializedKey, CharacterName,"duR")
				if HitResult then
					PlayerCombo.KeysLogged = 0
					PlayerCombo.ComboVariation = ""
					
					PlayerCombo.Hits = 0
					
				--	GUIRemote:FireClient(Player, "ComboIndicator", {
					--	Character = Player.Character,

					--	Function = "RemoveIndicator",
					--	Variation = PlayerCombo.ComboVariation
					--})
									
					local Victim = HitObject.Parent
					local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

					CameraRemote:FireClient(Player, "CameraShake", {FirstText = 12, SecondText = 8})
				--	NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, KeysLogged = PlayerCombo.KeysLogged, Victim = Victim, Module = "CombatVFX", Function = "Light"})
					

					StateManager:ChangeState(Character,"Stunned",.55)
					StateManager:ChangeState(Character,"InAir",2.25)

					StateManager:ChangeState(Victim,"InAir",2.25)
					StateManager:ChangeState(Victim,"Stunned",.85)
					
					--StateManager:ChangeState(Character,"IFrame",.35)
					--StateManager:ChangeState(Character,"Guardbroken",.5)
					--StateManager:ChangeState(Character,"InAir",2.25)

					--StateManager:ChangeState(Victim,"InAir",2.25)
					--StateManager:ChangeState(Victim,"Stunned",1.85)
					--StateManager:ChangeState(Character,"Victim",1.85)

					Aerial(Player,{
						Type = "Start",
						Victim = Victim,
						Position = CFrameTarget * CFrame.new(0,0,-5.75).p,
						Duration = 2.25,
					})

					VfxHandler.FaceVictim({Character = Character, Victim = Victim})

					BodyPosition.Parent = HumanoidRootPart
					BodyPosition.Position = CFrameTarget.p
					Debris:AddItem(BodyPosition,2.25)
				else
					BodyPosition:Destroy()
				end
			end)()
		end
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
	end,
}

return Variations