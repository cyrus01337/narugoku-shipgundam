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
local ProfileService = require(Server.ProfileService)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local HitboxModule = require(Server.Combat.Combat.HitboxModule)

local AbilityData = require(Metadata.AbilityData.AbilityData)

local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)
local TaskScheduler = require(Utility.TaskScheduler)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)
local SoundManager = require(Shared.SoundManager)

local RaycastManager = require(Shared.RaycastManager)

local DamageManager = require(Managers.DamageManager)

local VfxHandler = require(Effects.VfxHandler)

local Ragdoll = require(ServerStorage.Modules.Ragdoll)

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

local function GetNearPlayers(Character,Radius)
	local ChosenVictim;
	local Live = workspace.World.Live

	local HumanoidRootPart = Character.PrimaryPart

	for _,Victim in ipairs(Live:GetChildren()) do
		if Victim:FindFirstChild("Humanoid") and Victim.Humanoid.Health > 0 then
			local EnemyRootPart = Victim:FindFirstChild("PrimaryPart") or Victim:FindFirstChild("HumanoidRootPart");

			if (EnemyRootPart.Position - HumanoidRootPart.Position).Magnitude <= Radius then
				if Victim ~= Character then
					ChosenVictim = Victim 
				end
			end
		end
	end
	return ChosenVictim
end

local function RaycastTarget(Radius,Character)
	local MouseHit = MouseRemote:InvokeClient(Players:GetPlayerFromCharacter(Character))	
	
	local Root = Character:FindFirstChild("HumanoidRootPart")
	local RayParam = RaycastParams.new()
	RayParam.FilterDescendantsInstances = { Character, workspace.World.Visuals }
	RayParam.FilterType = Enum.RaycastFilterType.Exclude

	local RaycastResult = workspace:Raycast(Root.Position, (MouseHit.Position - Root.Position).Unit * Radius, RayParam)
	local Target, Position = RaycastResult.Instance, RaycastResult.Position 

	if Target and Target:FindFirstAncestorWhichIsA("Model"):FindFirstChild("Humanoid") then
		local Victim = Target:FindFirstAncestorWhichIsA("Model")
		if Victim ~= Character then 
			return Victim,Position or nil
		end
	end	
end

local function GetMouseTarget(Target,Character)
	local MouseHit = MouseRemote:InvokeClient(Players:GetPlayerFromCharacter(Character))

	local Root = Character:FindFirstChild("HumanoidRootPart")
	if (Root.Position - MouseHit.Position).Magnitude > 80 then return end	

	if Target and Target:IsA("BasePart") and not Target:IsDescendantOf(Character) and GlobalFunctions.IsAlive(Target.Parent) then
		return Target.Parent or nil
	end
end

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

local AokijiMode = {

	["Transformation"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		local Data = ProfileService:GetPlayerProfile(Player)
		
		AnimationRemote:FireClient(Player,"AokijiTransformation","Play")
		             		
		StateManager:ChangeState(Character,"IFrame",1.35)
		SpeedManager.changeSpeed(Character,0,1.35,4e4)

		Root.Anchored = true
		
		NetworkStream.FireClientDistance(Character, "ClientRemote", 350, {Character = Character , Module = Data.Character.."Mode", Function = "Transformation"})
		NetworkStream.FireOneClient(Player,"ClientRemote",5,{Character = Character, Module = "AokijiMode", Function = "Cutscene"})

		local CreateFrameData = {Size = UDim2.new(1,0,1,0); Position = UDim2.new(0,0,0,0); Color = Color3.fromRGB(110, 153, 202); Duration = 1}

		TaskScheduler:AddTask(1.15,function()
			CameraRemote:FireClient(Player,"CreateFlashUI",CreateFrameData)
			Root.Anchored = false
		end)
	end,

	["FirstAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		local Hits = Character:FindFirstChild("Hits")

		if Hits and Hits.Value >= 1 then
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			
			local HitResult,HitObject = HitboxModule.MagnitudeModule(Character, {Delay = 2, Range = 7, KeysLogged = math.random(1,3)}, KeyData.SerializedKey, CharacterName)
			if HitResult then
				AnimationRemote:FireClient(Player,"KillerQueenGrab","Play")
				wait(.225)
				local Victim = HitObject.Parent
				local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

				StateManager:ChangeState(Character,"Stunned",2)
				StateManager:ChangeState(Character, "IFrame", 2, {IFrameType = ""})

				NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Victim = Victim, Module = "AokijiMode", Function = "FreezingGrab"})

				local Weld = Instance.new("Weld")
				Weld.Part0 = Root
				Weld.Part1 = VRoot
				Weld.C0 = CFrame.new(0,0,-3.05) * CFrame.Angles(0,math.rad(-180),0)
				Weld.Parent = VRoot

				Debris:AddItem(Weld,1.85)

				Humanoid.AutoRotate = false
				Root.Anchored = true

				local Anim = VHum:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Stands["Killer Queen"]["TracedStepsVictim"])
				Anim:Play()
				Anim:AdjustSpeed(.75)

				CameraRemote:FireClient(Player,"CameraShake",{FirstText = 3, SecondText = 12})
				StateManager:ChangeState(Victim,"Stunned",2)

				coroutine.wrap(function()
					for _ = 1,16 do
						DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{SecondType = "Choke", Type = "Combat", KeysLogged = 3})
						wait(.1175)
					end
				end)()

				wait(1.775)
				NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Victim = Victim, Module = "AokijiMode", Function = "FreezeStop", Distance = 100})

				Humanoid.AutoRotate = true

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.Velocity = Vector3.new(0,35,math.random(1,2) == 1 and -15 or 15)
				BodyVelocity.MaxForce = Vector3.new(100000,100000,100000)
				BodyVelocity.Parent = Victim.PrimaryPart

				Debris:AddItem(BodyVelocity,.3)
				Ragdoll.DurationRagdoll(Victim, 1)
				VfxHandler.IceProc(Victim,1)

				AnimationRemote:FireClient(Player,"KillerQueenGrab","Stop")

				wait(.2)				
				Root.Anchored = false
			end
		end
	end,

	["SecondAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)		
		
		StateManager:ChangeState(Character,"Guardbroken",.5)
		StateManager:ChangeState(Character,"IFrame",.35)

		AnimationRemote:FireClient(Player,"SpearThrow","Play",{AdjustSpeed = .5})		
		wait(.35)
		NetworkStream.FireClientDistance(Character,"ClientRemote",500,{Character = Character, Module = "AokijiMode", Function = "Ice Bird"})
		
		local Velocity = 100
		local Lifetime = 10
		
		local StartPoint = Root.CFrame * CFrame.new(0,-1,0)

		local Size = ReplicatedStorage.Assets.Models.Misc.Volleyballs.volleyball2.Size

		local Points = RaycastManager:GetSquarePoints(StartPoint, Size.X * 2, Size.X * 2)		

		local MouseHit = MouseRemote:InvokeClient(Player)
		local Direction = (MouseHit.Position - StartPoint.Position).Unit

		local Direction = (Root.CFrame * CFrame.new(0,0,-4e4).Position - StartPoint.Position).Unit

		RaycastManager:CastProjectileHitbox({
			Points = Points,
			Direction = Direction,
			Velocity = Velocity,
			Lifetime = Lifetime,
			Iterations = 100,
			Visualize = false,
			Function = function(RaycastResult)
				local ValidEntities = RaycastManager:GetEntitiesFromPoint(RaycastResult.Position, workspace.World.Live:GetChildren(), {[Character] = true}, 8)
				for Index = 1, #ValidEntities do
					local Entity = ValidEntities[Index]
					local VRoot = Entity:FindFirstChild("HumanoidRootPart")
					local EnemyHumanoid = Entity:FindFirstChild("Humanoid")

					VfxHandler.IceProc(Entity,1)
					DamageManager.DeductDamage(Character,Entity,KeyData.SerializedKey,CharacterName,{Type = "Combat"})
				end
			end,
			Ignore = {Character, workspace.World.Visuals}
		})			
	end,

	["ThirdAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		if Root:FindFirstChild("IceSlide") then return end	
		
		VfxHandler.RemoveBodyMover(Character)
		AnimationRemote:FireClient(Player,"IceSlide", "Play", {Looped = true})

		CameraRemote:FireClient(Player,"TweenObject",{
			LifeTime = .225,
			EasingStyle = Enum.EasingStyle.Linear,
			EasingDirection = Enum.EasingDirection.Out,
			Return = false,
			Properties = {FieldOfView = 100}
		})

		NetworkStream.FireClientDistance(Character,"ClientRemote",500,{Character = Character, Module = "AokijiMode", Function = "Ice Slide"})

		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.MaxTorque = Vector3.new(12, 15555, 12)
		BodyGyro.P = 10000
		BodyGyro.Parent = Root
		Trash[#Trash + 1] = BodyGyro

		Debris:AddItem(BodyGyro,6)

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Name = "IceSlide"
		BodyVelocity.MaxForce = Vector3.new(2e4,0,2e4)
		BodyVelocity.Parent = Root
		Trash[#Trash + 1] = BodyVelocity

		Debris:AddItem(BodyVelocity,6)

		while BodyVelocity and RunService.Stepped:Wait() do
			local SkillData = StateManager:ReturnData(Character,"LastSkill")

			pcall(function()
				local MouseHit = MouseRemote:InvokeClient(Player)

				BodyGyro.CFrame = CFrame.lookAt(Root.CFrame.Position, MouseHit.Position + Vector3.new(0,2,0))
				BodyVelocity.Velocity = MouseHit.LookVector * 60
			end)
			if Root:FindFirstChild("IceSlide") == nil or SkillData.Skill == "Swing" or StateManager:Peek(Character,"Stunned") then break end
		end
		StateManager:ChangeState(Character,"Attacking",.1)
		RemoveTrash(Trash)

		AnimationRemote:FireClient(Player,"IceSlide", "Stop", {Looped = false})

		CameraRemote:FireClient(Player,"TweenObject",{
			LifeTime = .225,
			EasingStyle = Enum.EasingStyle.Linear,
			EasingDirection = Enum.EasingDirection.Out,
			Return = false,
			Properties = {FieldOfView = 70}
		})	
		
		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
	end,

	["FourthAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
		
		SpeedManager.changeSpeed(Character,0,.85,4e4)		
		AnimationRemote:FireClient(Player,"IceAge","Play")
		
		wait(.5)		
		
		if StateManager:Peek(Character,"Stunned") then return end
		NetworkStream.FireClientDistance(Character,"ClientRemote",400,{Character = Character, Module = "AokijiMode", Function = "Ice Age"})
		
		wait(.35)
		local HitResult,ValidEntities = HitboxModule.GetTouchingParts(Player,{ExistTime = 2, Type = "Combat", Size = Vector3.new(88.719, 48.896, 85.933), Transparency = 1, PositionCFrame = Root.CFrame},KeyData.SerializedKey,CharacterName)
		if HitResult then			
			for Index = 1, #ValidEntities do
				local Victim = ValidEntities[Index]
				
				VfxHandler.IceProc(Victim,3)

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.Velocity = Vector3.new(0,45,math.random(1,2) == 1 and -50 or 50)
				BodyVelocity.MaxForce = Vector3.new(100000,100000,100000)
				BodyVelocity.Parent = Victim.PrimaryPart

				Debris:AddItem(BodyVelocity,.3)
				Ragdoll.DurationRagdoll(Victim, 3)
			end
		end	
	end

}

return AokijiMode