--|| Services ||--
local Players = game:GetService("Players")

local TweenService = game:GetService("TweenService")

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Directories ||--
local Server = ServerScriptService.Server

local Managers = Server.Managers

local Modules = ReplicatedStorage.Modules
local State = Server.State

local Effects = Modules.Effects
local Shared = Modules.Shared
local Metadata = Modules.Metadata
local Utility = Modules.Utility

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local AbilityData = require(Metadata.AbilityData.AbilityData)

local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)

local RaycastManager = require(Shared.RaycastManager)

local HitboxModule = require(script.Parent.Parent.Combat.Combat.HitboxModule)

local DamageManager = require(Managers.DamageManager)

local VfxHandler = require(Effects.VfxHandler)

local Ragdoll = require(ServerStorage.Modules.Ragdoll)

local ProfileService = require(Server.ProfileService)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local MouseRemote = ReplicatedStorage.Remotes.GetMouse
local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote
local GUIRemote = ReplicatedStorage.Remotes.GUIRemote

--|| Functions ||--
local Trash = {}

local function RemoveTrash(Trash)
	for Index = 1,#Trash do
		local Item = Trash[Index]
		if Item and Item.Parent then
			Item:Destroy()
		end
	end
end

local Killua = {

	["FirstAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		
		local Data = ProfileService:GetPlayerProfile(Player)	
		if Data.Character == "Killua" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end
		
		local Root,Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
		local LeftArm,RightArm = Character["Left Arm"], Character["Right Arm"]

		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KilluaVFX", Function = "Snake Awakens"})
		StateManager:ChangeState(Character,"Guardbroken",3)
		SpeedManager.changeSpeed(Character,4,2.85,2) --function(Character,Speed,Duration,Priority)
		AnimationRemote:FireClient(Player,"SnakeAwakensOld","Play", {Looped = true})	

		CameraRemote:FireClient(Player, "AddGradient",{ Type = "Add", Length = .75})

		local PlayerCombo = AbilityData.ReturnData(Player,"PlayerCombos","GlobalInformation")

		local TimeEvaluation = os.clock() - PlayerCombo.LastPressed <= .8 and true or false

		VfxHandler.RemoveBodyMover(Character)
		Hum.AutoRotate = true

		coroutine.wrap(function()
			for Index = 0,2,.05 do
				for _,v in ipairs(Character:GetChildren()) do
					if string.find(v.Name,"Arm") then
						v.Transparency = Index
					end
				end
				RunService.Heartbeat:Wait()
			end
		end)()

		for _ = 1,20 do
			wait(.125)
			local NumberEvaluation = (PlayerCombo.KeysLogged < 5 and TimeEvaluation and PlayerCombo.KeysLogged + 1) or (PlayerCombo.KeysLogged > 5 and 1) or (not PlayerCombo.TimeEvaluation and 1)

			PlayerCombo.Hits += 1
			PlayerCombo.KeysLogged = NumberEvaluation

			local HitObject = HitboxModule.RaycastModule(Player, {Visualize = false, DmgType = "Snake", Size = 10, KeysLogged = PlayerCombo.KeysLogged, Type = "Sword"}, KeyData.SerializedKey, CharacterName)
			if HitObject.Hit then
				local Victim = HitObject.Object.Parent
				local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")
				
				if not StateManager:Peek(Character,"InAir") then
					VfxHandler.RemoveBodyMover(Victim)
					VfxHandler.RemoveBodyMover(Character)
				end

				CameraRemote:FireClient(Player,"CameraShake",{ FirstText = 1, SecondText = 5})
				NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Victim = Victim, Module = "KilluaVFX", Function = "Snake Awakens HitVFX"})

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
				BodyVelocity.Velocity = (VRoot.CFrame.p - Root.CFrame.p).Unit * 10
				BodyVelocity.Parent = Root
				Debris:AddItem(BodyVelocity,.25)

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
				BodyVelocity.Name = "SnakeAwakenKnockback"
				BodyVelocity.Velocity = (VRoot.CFrame.p - Root.CFrame.p).Unit * 12
				BodyVelocity.Parent = VRoot
				Debris:AddItem(BodyVelocity,.25)

				DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{Type = ExtraData.Type, KeysLogged = ExtraData.KeysLogged})
			end
		end
		StateManager:ChangeState(Character,"Guardbroken",.35)
		SpeedManager.changeSpeed(Character,14,1.75,3.5) --function(Character,Speed,Duration,Priority)

		Hum.AutoRotate = true
		LeftArm.Transparency = 0
		RightArm.Transparency = 0

		CameraRemote:FireClient(Player, "AddGradient",{ Type = "Remove", Length = .75})
		AnimationRemote:FireClient(Player,"SnakeAwakensOld","Stop")
	end,

	["SecondAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character

		local Data = ProfileService:GetPlayerProfile(Player)	
		if Data.Character == "Killua" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end

		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		AnimationRemote:FireClient(Player, "LightningPalm", "Play", {AdjustSpeed = .125})
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KilluaVFX", Function = "LightningPalmStart"})

		StateManager:ChangeState(Character,"Guardbroken",1.5)

		SpeedManager.changeSpeed(Character,4,2,1.5) --function(Character,Speed,Duration,Priority)

		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KilluaVFX", Function = "LightningDash", ContactPointCFrame = Root.CFrame})

		wait(.315)
		if StateManager:Peek(Character,"Stunned") then
			AnimationRemote:FireClient(Player, "LightningPalm", "Stop")
			return 
		end

		local TargetPosition = ReplicatedStorage.Assets.Models.Misc.BP:Clone()
		TargetPosition.CFrame = Root.CFrame * CFrame.new(0,0,-25)
		TargetPosition.Parent = workspace.World.Visuals

		local BodyPosition = Instance.new("BodyPosition")
		BodyPosition.Position = TargetPosition.Position
		BodyPosition.MaxForce = Vector3.new(250,250,250) * 125
		BodyPosition.D = 500
		BodyPosition.Parent = Root

		Debris:AddItem(TargetPosition,.05)
		Debris:AddItem(BodyPosition,.35)

		AnimationRemote:FireClient(Player, "LightningPalm", "Play", {AdjustSpeed = 5})

		wait(.3)
		CameraRemote:FireClient(Player, "CameraShake", {FirstText = 8, SecondText = 10})
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KilluaVFX", Function = "LightningPalmAOE"})

		HitboxModule.MagnitudeModule(Character, {Range = 18, KeysLogged = 1, Type = "Combat"}, KeyData.SerializedKey, CharacterName)
	end,

	["ThirdAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		local Data = ProfileService:GetPlayerProfile(Player)
		if Data.Character == "Killua" then
		    CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
		end
		
		local Mouse = MouseRemote:InvokeClient(Player)

		StateManager:ChangeState(Character,"Attacking",.75)

		AnimationRemote:FireClient(Player, "Thunderbolt", "Play", "AdjustSpeed", 15) 
		Root.CFrame = CFrame.new(Root.Position, Root.Position + Vector3.new(Mouse.lookVector.X, Mouse.lookVector.Y, Mouse.lookVector.Z))

		local Beam = ReplicatedStorage.Assets.Effects.Meshes.goddsdpeedball:Clone()
		Beam.Name = Character.Name.. " - ThunderBeam"
		Beam.Size = Vector3.new(5,2,5)	

		Beam.Transparency = 1
		Beam.Material = "Neon"	
		Beam.CFrame = Root.CFrame * CFrame.new(0,5,-30)		

		Beam.Parent = workspace.World.Visuals
		Debris:AddItem(Beam, 1)

		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{
			Character = Character,
			Module = "KilluaVFX", 
			Function = "ThunderPalmRelease",
		})

		CameraRemote:FireClient(Player,"CameraShake",{FirstText = 4, SecondText = 6, ThirdText = 0, FourthText = 2})
		CameraRemote:FireClient(Player,"TweenObject",{LifeTime = .1, EasingStyle = Enum.EasingStyle.Linear, EasingDirection = Enum.EasingDirection.Out, Return = true, Properties = {FieldOfView = 120}})

		local HitResult,ValidEntities = HitboxModule.GetTouchingParts(Player,{ExistTime = 2, Type = "Combat", KeysLogged = 1, Size = Vector3.new(8.999, 4.517, 38.284), Transparency = 1, PositionCFrame = Root.CFrame * CFrame.new(0,0,-15)},KeyData.SerializedKey,CharacterName)
		if HitResult then
			for Index = 1, #ValidEntities do
				local Victim = ValidEntities[Index]

				local VHumanoid = Victim:FindFirstChild("Humanoid")
				local VRoot = Victim:FindFirstChild("HumanoidRootPart")	

				VfxHandler.LightningProc({Character = Character, Victim = Victim, Speed = .5, StunTime = .15, Duration  = 5})
			end
		else
			SpeedManager.changeSpeed(Character,6,1.75,4) --function(Character,Speed,Duration,Priority)
			StateManager:ChangeState(Character,"Stunned",1.75)
		end
	end,

	["FourthAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
			
		StateManager:ChangeState(Character,"IFrame",.35)
		StateManager:ChangeState(Character,"Attacking",6)
		
		VfxHandler.RemoveBodyMover(Character)

		local Skateboard = ReplicatedStorage.Assets.Models.Misc.KilluaSkateboard:Clone()
		Skateboard.Parent = workspace.World.Visuals

		AnimationRemote:FireClient(Player,"Skateboard", "Play", {Looped = true})

		local Weld = Instance.new("Weld")
		Weld.Part0 = Root
		Weld.Part1 = Skateboard
		Weld.C1 = CFrame.new(0,3,0)
		Weld.Parent = Root

		CameraRemote:FireClient(Player,"TweenObject",{
			LifeTime = .225,
			EasingStyle = Enum.EasingStyle.Linear,
			EasingDirection = Enum.EasingDirection.Out,
			Return = false,
			Properties = {FieldOfView = 100}
		})

		NetworkStream.FireClientDistance(Character,"ClientRemote",500,{Character = Character, Module = "KilluaVFX", Function = "Skateboard", Skateboard = Skateboard})

		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.MaxTorque = Vector3.new(12, 15555, 12)
		BodyGyro.P = 10000
		BodyGyro.Parent = Root
		Trash[#Trash + 1] = BodyGyro

		Debris:AddItem(BodyGyro,6)

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Name = "SkateBoard"
		BodyVelocity.MaxForce = Vector3.new(2e4,0,2e4)
		BodyVelocity.Parent = Root
		Trash[#Trash + 1] = BodyVelocity

		Debris:AddItem(BodyVelocity,6)

		while BodyVelocity and RunService.Stepped:Wait() do
			local SkillData = StateManager:ReturnData(Character,"LastSkill")
		
			pcall(function()
				local MouseHit = MouseRemote:InvokeClient(Player)

				BodyGyro.CFrame = CFrame.lookAt(Root.CFrame.Position, MouseHit.Position + Vector3.new(0,2,0))
				BodyVelocity.Velocity = MouseHit.LookVector * 50
			end)
			if Root:FindFirstChild("SkateBoard") == nil or SkillData.Skill == "Swing" or StateManager:Peek(Character,"Stunned") then break end
		end
		StateManager:ChangeState(Character,"Attacking",.1)
		RemoveTrash(Trash)

		AnimationRemote:FireClient(Player,"Skateboard", "Stop", {Looped = false})

		CameraRemote:FireClient(Player,"TweenObject",{
			LifeTime = .225,
			EasingStyle = Enum.EasingStyle.Linear,
			EasingDirection = Enum.EasingDirection.Out,
			Return = false,
			Properties = {FieldOfView = 70}
		})
		
		local Data = ProfileService:GetPlayerProfile(Player)	
		if Data.Character == "Killua" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end
		
		for Index = 0,2,.15 do
			Skateboard.Transparency = Index
			RunService.Heartbeat:Wait()
		end
		Debris:AddItem(Skateboard,.75)
	end
}

return Killua