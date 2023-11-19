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

	local RaycastResult = workspace:Raycast(Root.Position, (MouseHit.Position - Root.Position).Unit * Radius, RayParam) or {}
	local Target, Position = RaycastResult.Instance, RaycastResult.Position 

	if Target and Target:IsDescendantOf(workspace.World.Live) then
		local Victim = Target:FindFirstAncestorWhichIsA("Model")
		if Victim ~= Character then 
			return Victim,Position or nil
		end
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

local function GetMouseTarget(Target,Character)
	local MouseHit = MouseRemote:InvokeClient(Players:GetPlayerFromCharacter(Character))

	local Root = Character:FindFirstChild("HumanoidRootPart")
	if (Root.Position - MouseHit.Position).Magnitude > 80 then return end	

	if Target and Target:IsA("BasePart") and not Target:IsDescendantOf(Character) and GlobalFunctions.IsAlive(Target.Parent) then
		return Target.Parent or nil
	end
end

local SanjiMode = {

	["Transformation"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		AnimationRemote:FireClient(Player,"SanjiMode","Play", {AdjustSpeed = 1.35})
		
		CameraRemote:FireClient(Player,"SanjiCutscene")
		CameraRemote:FireClient(Player,"HideUI",{Value = "Hide"})
		
		StateManager:ChangeState(Character,"IFrame",3, {IFrameType = ""})
		
		NetworkStream.FireClientDistance(Character, "ClientRemote", 350, {Character = Character , Module = "SanjiVFX", Function = "Transformation"})
		SpeedManager.changeSpeed(Character,0,3,2)
		
		wait(1.5)				
		ClientRemote:FireAllClients{Character = Character, Module = "SanjiVFX"; Function = "AscendTrail"}
		CameraRemote:FireClient(Player,"HideUI",{Value = "RePeek"})
	end,

	["FirstAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		local Data = ProfileService:GetPlayerProfile(Player)
		if Data.Character == "Sanji" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end 

		StateManager:ChangeState(Character,"Attacking",2.5)
		AnimationRemote:FireClient(Player,"PartyTable","Play")

		wait(.35)
		NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Module = "SanjiModeVFX", Function = "PartyTable"})
		for Index = 1,15 do
			-- SoundManager:AddSound("BarrageSwing", {Parent = Root, Volume = 3, PlaybackSpeed = 1.4}, "Client")
			local HitResult,HitObject = HitboxModule.MagnitudeModule(Character, {Delay = 0, Range = 5, KeysLogged = math.random(1,3), Type = "Combat"}, KeyData.SerializedKey, CharacterName)
			if HitResult then
				local Victim = HitObject.Parent

				local VRoot,VHum = Victim:FindFirstChild("HumanoidRootPart"),Victim:FindFirstChild("Humanoid")
				CameraRemote:FireClient(Player,"CameraShake",{ FirstText = 1, SecondText = 5})

				-- SoundManager:AddSound("Punched1",{Parent = Character:FindFirstChild("HumanoidRootPart"),Volume = 8},"Client")

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
			NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Module = "SanjiModeVFX", Function = "Anti_Manner_Kick_Course"})
			
			VfxHandler.FireProc({Character = Character, Victim = Victim, Damage = 1, Duration = 3})
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
		NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Module = "SanjiModeVFX", Function = "Spectre"})

		StateManager:ChangeState(Character,"Attacking",1.5)

		SpeedManager.changeSpeed(Character,4,1.5,3) --function(Character,Speed,Duration,Priority)

		local PlayerCombo = AbilityData.ReturnData(Player,"PlayerCombos","GlobalInformation")

		for Index = 1,15 do
			-- SoundManager:AddSound("BarrageSwing", {Parent = Humanoid, Volume = 3, PlaybackSpeed = 1.4}, "Client")

			local HitObject = HitboxModule.RaycastModule(Player, {Visualize = false, Size = 10, KeysLogged = PlayerCombo.KeysLogged, Type = "Combat"}, KeyData.SerializedKey, CharacterName)
			if HitObject.Hit then
				local Victim = HitObject.Object.Parent
				local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")
				
				-- SoundManager:AddSound("Punched1",{Parent = Character:FindFirstChild("HumanoidRootPart"),Volume = 8},"Client")
				
				CameraRemote:FireClient(Player,"CameraShake",{ FirstText = 1, SecondText = 5})
				DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{Type = "Combat", KeysLogged = ExtraData.KeysLogged})
				local _ = Index == 15 and VfxHandler.FireProc({Character = Character, Victim = Victim, Damage = 1, Duration = 3})
			end
			wait(.1)
		end
		AnimationRemote:FireClient(Player,"Spectre","Stop")
	end,

	["FourthAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		local Victim = RaycastTarget(80,Character) or GetNearestFromMouse(Character,8)
		if not Victim then return end
		
		local Data = ProfileService:GetPlayerProfile(Player)
		if Data.Character == "Sanji" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end 		
		
		Victim:FindFirstChild("Humanoid").AutoRotate = false
		StateManager:ChangeState(Character,"IFrame",3, {IFrameType = ""})
		StateManager:ChangeState(Character,"Stunned",3)
		
		StateManager:ChangeState(Victim,"Stunned",4)
		StateManager:ChangeState(Victim,"IFrame",1, {IFrameType = ""})
		
		Victim:FindFirstChild("Humanoid").WalkSpeed = 0
		Root.Anchored = true
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = Root
		Weld.Part1 = Victim:FindFirstChild("HumanoidRootPart")
		Weld.C0 = CFrame.new(0,0,-3.05) * CFrame.Angles(0,math.rad(-180),0)
		Weld.Parent = Victim:FindFirstChild("HumanoidRootPart")

		Debris:AddItem(Weld,3.5)
		
		local Root = Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character:FindFirstChild("Humanoid")

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(1,1,1) * 50000
		BodyVelocity.Velocity = Vector3.new(0,0,0)
		BodyVelocity.Parent = Root

		Debris:AddItem(BodyVelocity,.425)

		AnimationRemote:FireClient(Player,"SanjiDashUlt","Play")
		
		NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Module = "SanjiModeVFX", Function = "SetDash"})
		NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Module = "SanjiModeVFX", Function = "AscendTrail"})

		Humanoid.AutoRotate = false

		wait(.275)
		NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Victim = Victim, Module = "SanjiModeVFX", Function = "TeleportKick"})
		
		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.MaxTorque = Vector3.new(12, 15555, 12)
		BodyGyro.P = 10000
		BodyGyro.CFrame = CFrame.lookAt(Root.CFrame.Position, Victim:FindFirstChild("HumanoidRootPart").Position + Vector3.new(0,2,0))
		BodyGyro.Parent = Root

		Debris:AddItem(BodyGyro,.35) 
		
		wait(.65)
		AnimationRemote:FireClient(Player,"SanjiDashUlt","Stop")
		AnimationRemote:FireClient(Player,"SanjiKickUlt","Play")
		
		Weld:Destroy()
		
		if Victim and Victim:FindFirstChild("Humanoid") then
			Victim.Humanoid.WalkSpeed = 14
			DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{Type = "Combat", KeysLogged = ExtraData.KeysLogged})			
		end
		
		wait(.85)		
		NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Module = "SanjiModeVFX", Function = "AscendKick"})
		NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Victim = Victim, Module = "SanjiModeVFX", Function = "DemonAxeExplode"})
		
		NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Victim = Victim, Module = "SanjiModeVFX", Function = "FLASHKICKHITTTTT"})
		
		DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{Type = "Combat"})

		Ragdoll.DurationRagdoll(Victim,1.35)

		wait(1.5)
		Root.Anchored = false
		Humanoid.AutoRotate = true
		
		Victim:FindFirstChild("Humanoid").AutoRotate = true
	end
}

return SanjiMode