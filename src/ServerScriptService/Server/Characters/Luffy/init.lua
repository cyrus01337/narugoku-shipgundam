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

local ProfileService = require(Server.ProfileService)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

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

local function GetMouseTarget(Target,Character,Radius)
	local MouseHit = MouseRemote:InvokeClient(Players:GetPlayerFromCharacter(Character))

	local Root = Character:FindFirstChild("HumanoidRootPart")
	if (Root.Position - MouseHit.Position).Magnitude > Radius then return end	

	if Target and Target.Parent:FindFirstChild("Humanoid") and Target:IsA("BasePart") and not Target:IsDescendantOf(Character) and GlobalFunctions.IsAlive(Target.Parent) then
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

local Luffy = {

	["FirstAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
		
		local Victim = GetNearestFromMouse(Character,20) ---GetMouseTarget(ExtraData.MouseTarget, Character) or GetNearPlayers(Character,35)
		if not Victim then return end
		
		local Mouse = MouseRemote:InvokeClient(Player)
		if (Root.Position - Mouse.Position).Magnitude > 45 then return end
		
		local Data = ProfileService:GetPlayerProfile(Player)	
		if Data.Character == "Luffy" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end

		local VRoot,VHum = Victim:FindFirstChild("HumanoidRootPart"),Victim:FindFirstChild("Humanoid")

		SpeedManager.changeSpeed(Character,0,.925,2.5) --function(Character,Speed,Duration,Priority)
		StateManager:ChangeState(Character,"Guardbroken",.85)

		GlobalFunctions.NewInstance("StringValue",{Parent = Character, Name = "Aiming", Value = Victim.Name},.75)

		AnimationRemote:FireClient(Player, "GomuPistole", "Play")

		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Distance = 100, Module = "LuffyVFX", Function = "Pistole"})
		Hum.AutoRotate = false

		wait(.75)

		TaskScheduler:AddTask(.35,function()
			Hum.AutoRotate = true
		end)

		if StateManager:Peek(Character,"Stunned") then
			AnimationRemote:FireClient(Player, "GomuPistole", "Stop")
			return 
		end

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
		BodyVelocity.Velocity = (VRoot.CFrame.p - Root.CFrame.p).Unit * 30
		BodyVelocity.Parent = VRoot
		Debris:AddItem(BodyVelocity,.25)

		SpeedManager.changeSpeed(Character,5,1,3.5) --function(Character,Speed,Duration,Priority)
		StateManager:ChangeState(Character,"Stunned",1)

		DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{Type = "Combat", KeysLogged = 1})

		CameraRemote:FireClient(Player, "CameraShake", {FirstText = 9, SecondText = 6})		
	end,

	["SecondAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		GlobalFunctions.NewInstance("BoolValue",{Name = "Aiming",Parent = Character},.85)
		
		local Data = ProfileService:GetPlayerProfile(Player)
		if Data.Character == "Luffy" then 
		    CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName) 
		end		
	
		--[[ Fire Animation ]]--
		StateManager:ChangeState(Character,"Guardbroken",.85)
		AnimationRemote:FireClient(Player, "GomuAxe", "Play")

		--[[ Fire Cero Client ]]--
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Distance = 100, Module = "LuffyVFX", Function = "Axe"})
		Humanoid.AutoRotate = false

		wait(.75)
		Humanoid.AutoRotate = true
		local ValidEntities = RaycastManager:GetEntitiesFromPoint(Root.Position, workspace.World.Live:GetChildren(), {[Character] = true}, 18)
		for Index = 1, #ValidEntities do
			local Entity = ValidEntities[Index]

			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
			BodyVelocity.Velocity = CFrame.new(Root.Position,Root.Position + (Root.CFrame.lookVector * 10) + (Root.CFrame.upVector * -10) ).lookVector * 80
			BodyVelocity.Parent = Entity.HumanoidRootPart
			Debris:AddItem(BodyVelocity,.25)

			Ragdoll.DurationRagdoll(Entity,1)

			DamageManager.DeductDamage(Character,Entity,KeyData.SerializedKey, CharacterName, {Type = "Combat"})
		end
		SpeedManager.changeSpeed(Character,4,1.5,3.5) --function(Character,Speed,Duration,Priority)
		StateManager:ChangeState(Character,"Stunned",1.5)

		-- SoundManager:AddSound("BOOM!",{Parent = Root, Volume = 3}, "Client")

		CameraRemote:FireClient(Player, "CameraShake", {FirstText = 6, SecondText = 12})
	end,

	["ThirdAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local HumanoidRootPart,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		local Mouse = MouseRemote:InvokeClient(Player)
		
		local Data = ProfileService:GetPlayerProfile(Player)	
		if Data.Character == "Luffy" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end
		
		StateManager:ChangeState(Character,"Guardbroken",1.75)
		GlobalFunctions.NewInstance("BoolValue",{Name = "Aiming",Parent = Character},.85)
		
		--[[ Fire Animation ]]--
		AnimationRemote:FireClient(Player, "GomuBazooka", "Play")

		--[[ Fire Cero Client ]]--
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Distance = 100, Module = "LuffyVFX", Function = "Bazooka"})

		wait(.75)
		local StartPoint = HumanoidRootPart.CFrame

		local Size = Assets.Models.Misc.Volleyballs.volleyball2.Size

		local Points = RaycastManager:GetSquarePoints(StartPoint, Size.X * 2, Size.X * 2)

		local MouseHit = MouseRemote:InvokeClient(Player)

		local Direction = (MouseHit.Position - StartPoint.Position).Unit
		RaycastManager:CastProjectileHitbox({
			Points = Points,
			Direction =  Direction,
			Velocity = 200,
			Lifetime = .85,
			Iterations = 50,
			Visualize = false,
			Function = function(RaycastResult)
				local ValidEntities = RaycastManager:GetEntitiesFromPoint(RaycastResult.Position, workspace.World.Live:GetChildren(), {[Character] = true}, 5)
				for Index = 1, #ValidEntities do
					local Entity = ValidEntities[Index]
					if not StateManager:Peek(Entity,"Blocking") then
						local BodyVelocity = Instance.new("BodyVelocity")
						BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
						BodyVelocity.Velocity = CFrame.new(HumanoidRootPart.Position,HumanoidRootPart.Position + (HumanoidRootPart.CFrame.lookVector * 10) + (HumanoidRootPart.CFrame.upVector * -10) ).lookVector * 100
						BodyVelocity.Parent = Entity.HumanoidRootPart
						Debris:AddItem(BodyVelocity,.25)

						Ragdoll.DurationRagdoll(Entity,1)
					end	
					DamageManager.DeductDamage(Character,Entity,KeyData.SerializedKey,CharacterName, {Type = "Combat"})
				end
			end,
			Ignore = {Character, workspace.World.Visuals}
		})
		CameraRemote:FireClient(Player, "CameraShake", {FirstText = 5, SecondText = 8})
	end,

	["FourthAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		local Data = ProfileService:GetPlayerProfile(Player)
		if Data.Character == "Luffy" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end

		--[[ Set States ]]--
		StateManager:ChangeState(Character,"Guardbroken",2.5)
		SpeedManager.changeSpeed(Character,4,2.5,3.5) --function(Character,Speed,Duration,Priority)

		--GlobalFunctions.NewInstance("BoolValue",{Name = "Aiming",Parent = Character},3)

		--[[ Fire Clients ]]--
		AnimationRemote:FireClient(Player,"GomuGatling","Play")
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Distance = 100, Module = "LuffyVFX", Function = "Gatling"})

		local PlayerCombo = AbilityData.ReturnData(Player,"PlayerCombos","GlobalInformation")

		local TimeEvaluation = os.clock() - PlayerCombo.LastPressed <= .8 and true or false

		for _ = 1,15 do
			wait(.125)
			local NumberEvaluation = (PlayerCombo.KeysLogged < 5 and TimeEvaluation and PlayerCombo.KeysLogged + 1) or (PlayerCombo.KeysLogged > 5 and 1) or (not PlayerCombo.TimeEvaluation and 1)

			PlayerCombo.Hits += 1
			PlayerCombo.KeysLogged = NumberEvaluation

			local HitObject = HitboxModule.RaycastModule(Player, {Visualize = false, DmgType = "Snake", Size = 20, KeysLogged = PlayerCombo.KeysLogged, Type = "Sword"}, KeyData.SerializedKey, CharacterName)
			if HitObject.Hit then
				local Victim = HitObject.Object.Parent
				local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

				CameraRemote:FireClient(Player,"CameraShake",{ FirstText = 1, SecondText = 5})
				NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Victim = Victim, Module = "LuffyVFX", Function = "GatlingHitVFX"})

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
				BodyVelocity.Velocity = (VRoot.CFrame.p - Root.CFrame.p).Unit * 5
				BodyVelocity.Parent = Root
				Debris:AddItem(BodyVelocity,.25)

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
				BodyVelocity.Name = "SnakeAwakenKnockback"
				BodyVelocity.Velocity = (VRoot.CFrame.p - Root.CFrame.p).Unit * 6
				BodyVelocity.Parent = VRoot
				Debris:AddItem(BodyVelocity,.25)

				DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{Type = ExtraData.Type, KeysLogged = ExtraData.KeysLogged})
			end
			SpeedManager.changeSpeed(Character,3,.225,3.5) --function(Character,Speed,Duration,Priority)
			StateManager:ChangeState(Character,"Stunned",.225)
		end
	end
}

return Luffy