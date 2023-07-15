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

local RotatedRegion3 = require(Shared.RotatedRegion3)
local SoundManager = require(Shared.SoundManager)

local HitboxModule = require(script.Parent.Parent.Combat.Combat.HitboxModule)

local RaycastManager = require(Shared.RaycastManager)
local TaskScheduler = require(Utility.TaskScheduler)

local Ragdoll = require(ServerStorage.Modules.Ragdoll)

local ProfileService = require(Server.ProfileService)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Map}
raycastParams.FilterType = Enum.RaycastFilterType.Include

local CreateFrameData = { Size = UDim2.new(1,0,1,0); Position = UDim2.new(0,0,0,0);	Color = Color3.fromRGB(0, 0, 0);	Duration = 1}

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

local Pain = {
	["FirstAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
		
		local Data = ProfileService:GetPlayerProfile(Player)
		if Data.Character == "Pain" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end

		local Aiming = GlobalFunctions.NewInstance("BoolValue",{Parent = Character, Name = "Aiming"}, .3)

		StateManager:ChangeState(Character,"Attacking",.75)
		SpeedManager.changeSpeed(Character,4,2,2.5)

		AnimationRemote:FireClient(Player,"PainPush","Play")

		-- SoundManager:AddSound("Pain",{TimePosition = .2, Parent = Root, Volume = 10, Looped = true}, "Client", {Duration = .5})

		wait(.3)
		local HitResult,ValidEntities = HitboxModule.GetTouchingParts(Player,{ExistTime = 2, Type = "Combat", KeysLogged = 1, Size = Vector3.new(12.565, 10.009, 30.62), Transparency = 1, PositionCFrame = Root.CFrame * CFrame.new(0,0,-10)},KeyData.SerializedKey,CharacterName)
		if HitResult then
			for Index = 1, #ValidEntities do
				local Entity = ValidEntities[Index]

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
				BodyVelocity.Velocity = CFrame.new(Root.Position,Root.Position + (Root.CFrame.lookVector * 10) + (Root.CFrame.upVector * -10) ).lookVector * 80
				BodyVelocity.Parent = Entity:FindFirstChild("HumanoidRootPart")
				Debris:AddItem(BodyVelocity,.25)

				Ragdoll.DurationRagdoll(Entity,1)
				
				local _ = Players:GetPlayerFromCharacter(Entity) and CameraRemote:FireClient(Players:GetPlayerFromCharacter(Entity), "CameraShake", {FirstText = 8, SecondText = 10})
			end
		end
		-- SoundManager:AddSound("Pull",{Parent = Root, Volume = 1}, "Client")
		CameraRemote:FireClient(Player, "CameraShake", {FirstText = 8, SecondText = 10})

		NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {Character = Character, Module = "PainVFX", Function = "Push"})	
	end,

	["SecondAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local HumanoidRootPart,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		local Data = ProfileService:GetPlayerProfile(Player)
		if Data.Character == "Pain" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end

		Humanoid.AutoRotate = false
		StateManager:ChangeState(Character,"Attacking",2)
		SpeedManager.changeSpeed(Character,2,2,3.5)

		CameraRemote:FireClient(Player,"CameraShake",{ FirstText = 2, SecondText = 12, Amount = 20, Time = .1, Type = "Loop"})
		-- SoundManager:AddSound("Charge",{Parent = HumanoidRootPart, Volume = .85}, "Client")
		-- SoundManager:AddSound("Paingain",{Parent = HumanoidRootPart, Volume = 8}, "Client")
		AnimationRemote:FireClient(Player,"AlShamac","Play")

		CameraRemote:FireClient(Player,"TweenObject",{
			LifeTime = .225,
			EasingStyle = Enum.EasingStyle.Linear,
			EasingDirection = Enum.EasingDirection.Out,
			Return = false,
			Properties = {FieldOfView = 120}
		})	

		CameraRemote:FireClient(Player, "AddGradient",{ Type = "Add", Length = .75})

		NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {Character = Character, Module = "PainVFX", Function = "Al~Shamac"})
		StateManager:ChangeState(Character,"IFrame",1.65, {IFrameType = ""})
		
		TaskScheduler:AddTask(1.65,function()
			CameraRemote:FireClient(Player,"TweenObject",{LifeTime = .1,EasingStyle = Enum.EasingStyle.Linear,EasingDirection = Enum.EasingDirection.Out, Return = false,Properties = {FieldOfView = 70}})		
			CameraRemote:FireClient(Player, "AddGradient",{ Type = "Remove", Length = .75})

			wait(.1)
			Humanoid.AutoRotate = true 

			-- SoundManager:AddSound("Pull",{Parent = HumanoidRootPart, Volume = 1}, "Client")

			CameraRemote:FireClient(Player,"TweenObject",{LifeTime = .225,EasingStyle = Enum.EasingStyle.Linear,EasingDirection = Enum.EasingDirection.Out, Return = true,Properties = {FieldOfView = 100}})		
			CameraRemote:FireClient(Player, "CameraShake", {FirstText = 8, SecondText = 10})
			
			CameraRemote:FireClient(Player, "CreateFlashUI", CreateFrameData)

			local HitResult,ValidEntities = HitboxModule.GetTouchingParts(Player,{ExistTime = 1, Type = "Combat", KeysLogged = 1, Size = Vector3.new(30,30,30), Transparency = 1, PositionCFrame = HumanoidRootPart.CFrame},KeyData.SerializedKey,CharacterName)
			if HitResult then
				-- SoundManager:AddSound("iceagin", {Parent = HumanoidRootPart, Volume = 2}, "Client")

				for Index = 1, #ValidEntities do
					local Victim = ValidEntities[Index]
					local VRoot,VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")
					
					local UnitVector = (HumanoidRootPart.Position - VRoot.Position).Unit
					local VictimLook = VRoot.CFrame.LookVector
					local DotVector = UnitVector:Dot(VictimLook)
					
					if StateManager:Peek(Victim,"Blocking") and DotVector >= -.5 then return end
					
					StateManager:ChangeState(Character,"Attacking",.35)

					wait(.325)
					for _,Instances in ipairs(Victim:GetChildren()) do
						if Instances:IsA("BasePart")  then
							Instances.Anchored = true
						end
					end

					NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {Character = Character, Victim = Victim,  Module = "PainVFX", Function = "shamac~hit"})

					StateManager:ChangeState(Victim,"Attacking",4)
					StateManager:ChangeState(Victim,"Frozen",4)
					local _ = Players:GetPlayerFromCharacter(Victim) and CameraRemote:FireClient(Players:GetPlayerFromCharacter(Victim), "CreateFlashUI", CreateFrameData)

					while not StateManager:Peek(Victim,"Frozen") do
						RunService.Heartbeat:Wait()					
					end
					
					for _,Instances in ipairs(Victim:GetChildren()) do
						if Instances:IsA("BasePart") then
							Instances.Anchored = false
						end
					end
					NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {Character = Character, Victim = Victim,  Module = "PainVFX", Function = "brekapart"})
				end
			end
		end)
	end,

	["ThirdAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local HumanoidRootPart,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		local Data = ProfileService:GetPlayerProfile(Player)	
		if Data.Character == "Pain" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end	
		
		StateManager:ChangeState(Character,"Attacking",4)				
		StateManager:ChangeState(Character, "ForceField", true)
		coroutine.wrap(function()
			wait(4)
			StateManager:ChangeState(Character, "ForceField", false)
		end)()
		NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {Character = Character, Module = "PainVFX", Function = "cast shield"})

--		SpeedManager.changeSpeed(Character,2,4,3.5)
		HumanoidRootPart.Anchored = true
		
		local function RemoveBall()
			NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {Character = Character, Module = "PainVFX", Function = "removbal"})
			CameraRemote:FireClient(Player, "CameraShake", {FirstText = 2, SecondText = 10})
			CameraRemote:FireClient(Player, "AddGradient",{ Type = "Remove", Length = .75})
			CameraRemote:FireClient(Player,"TweenObject",{
				LifeTime = .225,
				EasingStyle = Enum.EasingStyle.Linear,
				EasingDirection = Enum.EasingDirection.Out,
				Return = true,
				Properties = {FieldOfView = 120}
			})	
			StateManager:ChangeState(Character, "Attacking", 1.35, {AllowedSkills = {["Dash"] = true}})
			SpeedManager.changeSpeed(Character,2,.01,4.5)
			StateManager:ChangeState(Character, "IFrame", .5, {IFrameType = ""})
			HumanoidRootPart.Anchored = false			
		end

		AnimationRemote:FireClient(Player,"betricbarrier","Play")

		CameraRemote:FireClient(Player, "AddGradient",{ Type = "Add", Length = .75})

		while StateManager:Peek(Character,"ForceField") and Player do
			local SkillData = StateManager:ReturnData(Character,"LastSkill")
			RunService.Heartbeat:Wait()
			if SkillData.Skill == "Swing" then 
				AnimationRemote:FireClient(Player,"betricbarrier","Stop")
				break
			end
		end
		RemoveBall()
	end,

	["FourthAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		local Victim = GetNearestFromMouse(Character,8) ---GetMouseTarget(ExtraData.MouseTarget, Character) or GetNearPlayers(Character,35)
		if not Victim then return end
		
		local Data = Players:GetPlayerFromCharacter(Character) and ProfileService:GetPlayerProfile(Player)			
		if Data.Character == "Pain" then 
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
		end		

		local BezierBallData = AbilityData.ReturnData(Player,"FourthAbility","Pain")
		local Aiming = GlobalFunctions.NewInstance("BoolValue",{Parent = Character, Name = "Aiming"}, 1)

		StateManager:ChangeState(Character,"Attacking",1)	
		
		for Index = 1,3 do
			BezierBallData.ZeBall = Index

			local ChosenBall = BezierBallData.ZeBall == 1 and "Color1Betrice" or BezierBallData.ZeBall == 2 and "Color2Betrice" or BezierBallData.ZeBall == 3 and "Color3Betrice" or "Color1Betrice"

			AnimationRemote:FireClient(Player, "Thunderbolt", "Play", "AdjustSpeed")
			NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Victim = Victim, Distance = 100, Module = "PainVFX", Function = "bezierballs", WhichBall = ChosenBall})		
			
			local BallTing = script.beizerBalls[ChosenBall]:Clone()
			BallTing.Transparency = 1			
			BallTing.CFrame = Root.CFrame * CFrame.Angles(math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)))
			BallTing.Rocket.Target = Victim:FindFirstChild("HumanoidRootPart")
			BallTing.Velocity = Vector3.new(math.random(-75, 75), math.random(25, 75), math.random(-75, 75))
			BallTing.Rocket.MaxSpeed = math.random(75, 125)
			BallTing.Parent = workspace.World.Visuals
			
			local _ = BallTing:FindFirstChild("Rocket") and BallTing.Rocket:Fire()
			local Connection; Connection = BallTing.Rocket.ReachedTarget:Connect(function()			
				Connection:Disconnect()
				Connection = nil
				
				BallTing:Destroy()
				
				DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName, {Type = "Combat"})
			end)
			wait(.25)
		end
		BezierBallData.ZeBall = 0
	end;
}



return Pain