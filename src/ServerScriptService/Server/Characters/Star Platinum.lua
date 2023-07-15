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
local SoundManager = require(Shared.SoundManager)
local RaycastManager = require(Shared.RaycastManager)

local SpeedManager = require(Shared.StateManager.Speed)
local MoveStand = require(Shared.StateManager.MoveStand)

local TaskScheduler = require(Utility.TaskScheduler)

local Ragdoll = require(ServerStorage.Modules.Ragdoll)

local HitboxModule = require(script.Parent.Parent.Combat.Combat.HitboxModule)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

local Star_Platinum = {
	["FirstAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
		
		local Stand = Character:FindFirstChild(Character.Name.." - Stand")
		local Weld = Stand.PrimaryPart.Weld

		StateManager:ChangeState(Character,"Stunned",3)
		
		local PlayerCombo = AbilityData.ReturnData(Player,"PlayerCombos","GlobalInformation")

		local TimeEvaluation = os.clock() - PlayerCombo.LastPressed <= .8 and true or false

		AnimationRemote:FireClient(Player,"KillerQueen","Play",{Looped = true})

		wait(.3)

		local BarrageAnimation = Stand.Humanoid:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Stands["Killer Queen"]["BarrageAnim"])
		BarrageAnimation:Play()
		BarrageAnimation.Looped = true

		coroutine.wrap(function()
			for Index = 0,2,.05 do
				for _,v in ipairs(Stand:GetChildren()) do
					if string.find(v.Name,"Arm") then
						v.Transparency = Index
						for _,Parts in pairs(v:GetDescendants()) do
							if Parts:IsA("BasePart") or Parts:IsA("Part") or Parts:IsA("UnionOperation") or Parts:IsA("MeshPart") then
								Parts.Transparency = Index
							end
						end
					end
				end
				RunService.Heartbeat:Wait()
			end
		end)()

		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "Star PlatinumVFX", Function = "Barrage"})
		SpeedManager.changeSpeed(Character,4,3,2) --function(Character,Speed,Duration,Priority)

		MoveStand.MoveStand(Character, {Priority = 2, Duration = 3})

		for _ = 1,20 do
			wait(.125)
			local NumberEvaluation = (PlayerCombo.KeysLogged < 5 and TimeEvaluation and PlayerCombo.KeysLogged + 1) or (PlayerCombo.KeysLogged > 5 and 1) or (not PlayerCombo.TimeEvaluation and 1)

			PlayerCombo.Hits += 1
			PlayerCombo.KeysLogged = NumberEvaluation

			local HitObject = HitboxModule.RaycastModule(Player, {Visualize = false, DmgType = "Snake", Size = 10, KeysLogged = math.random(1,3), Type = "Sword"}, KeyData.SerializedKey, CharacterName)
			if HitObject.Hit then
				local Victim = HitObject.Object.Parent
				local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

				CameraRemote:FireClient(Player,"CameraShake",{ FirstText = 1, SecondText = 3.5})

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
				BodyVelocity.Velocity = (VRoot.CFrame.p - Root.CFrame.p).Unit * 6
				BodyVelocity.Parent = Root
				Debris:AddItem(BodyVelocity,.25)

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
				BodyVelocity.Name = "SnakeAwakenKnockback"
				BodyVelocity.Velocity = (VRoot.CFrame.p - Root.CFrame.p).Unit * 7
				BodyVelocity.Parent = VRoot
				Debris:AddItem(BodyVelocity,.25)

				DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{Type = ExtraData.Type, KeysLogged = ExtraData.KeysLogged})
			end
		end
		BarrageAnimation:Stop()
		AnimationRemote:FireClient(Player,"KillerQueen","Stop")
		
		StateManager:ChangeState(Character,"Stunned",.5)

		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})	
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)

		for Index = 0,2,.05 do
			for _,v in ipairs(Stand:GetChildren()) do
				if string.find(v.Name,"Arm") then
					v.Transparency = 0
					for _,Parts in pairs(v:GetDescendants()) do
						if Parts:IsA("BasePart") or Parts:IsA("Part") or Parts:IsA("UnionOperation") or Parts:IsA("MeshPart") then
							Parts.Transparency = 0
						end
					end
				end
			end
			RunService.Heartbeat:Wait()
		end
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

return Star_Platinum