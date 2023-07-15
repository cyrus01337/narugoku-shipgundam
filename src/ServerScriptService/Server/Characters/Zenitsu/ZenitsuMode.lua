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

	local RaycastResult = Ray.new(Root.CFrame.p, (MouseHit.Position - Root.CFrame.Position).Unit * Radius)
	local Target,Position = workspace:FindPartOnRayWithIgnoreList(RaycastResult, {Character, workspace.World.Visuals}, false, false)

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

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Map}
raycastParams.FilterType = Enum.RaycastFilterType.Include

local ZenitsuMode = {

	["Transformation"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		local Data = ProfileService:GetPlayerProfile(Player)
		
		AnimationRemote:FireClient(Player,"ZenitsuTransformation","Play")
		             		
		StateManager:ChangeState(Character,"IFrame",1.35)
		SpeedManager.changeSpeed(Character,0,1.35,4e4)
		
		TaskScheduler:AddTask(1,function() -- SoundManager:AddSound("ZenitVoiceLine",{Parent = Root, Volume = 2}, "Client") end)		
		Root.Anchored = true
		
		NetworkStream.FireClientDistance(Character, "ClientRemote", 350, {Character = Character , Module = Data.Character.."Mode", Function = "Transformation"})
		NetworkStream.FireOneClient(Player,"ClientRemote",5,{Character = Character, Module = "AokijiMode", Function = "Cutscene"})

		local CreateFrameData = {Size = UDim2.new(1,0,1,0); Position = UDim2.new(0,0,0,0); Color = Color3.fromRGB(202, 195, 89); Duration = 1}

		wait(1.15)
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "ZenitsuVFX", Function = "Rice Spirit"})		
		-- SoundManager:AddSound("Thund",{Parent = Root, PlaybackSpeed = 1 - (((1 - 1) * 3) / 10)}, "Client")

		CameraRemote:FireClient(Player,"CreateFlashUI",CreateFrameData)
		Root.Anchored = false
	end,

	["FirstAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		StateManager:ChangeState(Character,"Attacking",2)		
		AnimationRemote:FireClient(Player,"SixFold","Play")
				
		local point = Root.CFrame * CFrame.new(0,30,-64)
		local look = point.upVector * -200
		
		point = point.p		
		local center = Root.CFrame		
		
		SpeedManager.changeSpeed(Character,0,2.43,4e4)
		local CreateFrameData = {Size = UDim2.new(1,0,1,0); Position = UDim2.new(0,0,0,0); Color = Color3.fromRGB(255, 230, 101); Duration = .1}
		CameraRemote:FireClient(Player,"CreateFlashUI",CreateFrameData)
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "ZenitsuMode", Function = "TransformationOld"})	
		TaskScheduler:AddTask(.85,function()
			local CreateFrameData = {Size = UDim2.new(1,0,1,0); Position = UDim2.new(0,0,0,0); Color = Color3.fromRGB(255, 230, 101); Duration = .1}
			CameraRemote:FireClient(Player,"CreateFlashUI",CreateFrameData)
			
			HitboxModule.GetTouchingParts(Player,{Delay = 2.35, ExistTime = 5, Type = "Sword", KeysLogged = math.random(1,3), Size = Vector3.new(20.417, 4.517, 58.929), Transparency = 1, PositionCFrame = Root.CFrame * CFrame.new(0,0,18.5)},KeyData.SerializedKey,CharacterName)	
			
			NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "ZenitsuMode", Function = "TransformationOld"})
			wait(.25)			
			NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "ZenitsuMode", Function = "gitredy"})
			
			wait(.85)	
			VfxHandler.PlayerInvis({Character = Character, Duration = 1})
			local Start = Root.Position
			for Index = 1,6 do
				local radiusx,radiusy,radiusz = (math.random(1,5) * 10)+10,(math.random(1,5) * 10) + 10,(math.random(1,5) * 10) + 10
				local x,y,z = math.random(1,2),math.random(1,2),math.random(1,2)
				if x == 2 then
					x = -1
				end
				if y == 2 then
					y = 1
				end
				if z == 2 then
					z = -1
				end
				local pos = center * CFrame.new(x * radiusx, y * radiusy, z * radiusz)
				local position = pos.p
				if Index == 6 then
					position = center.p
				end
				local End = position
				
				local Beam = ReplicatedStorage.Assets.Effects.Meshes.Whirldwindball:Clone()
				Beam.BrickColor = BrickColor.new("Pastel light blue")
				Beam.Shape = "Cylinder"	
				Beam.CanCollide = false
				Beam.Anchored = true
				Beam.Material = "Neon"					
				local EndMag = (Root.CFrame.Position - CFrame.new(position).Position).Magnitude 
				Beam.Size = Vector3.new(EndMag, 5, 5)
				Beam.CFrame = CFrame.new(Root.CFrame.Position, CFrame.new(position).Position) * CFrame.new(0,0,-EndMag / 2) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)
				Beam.Parent = workspace.World.Visuals

				Debris:AddItem(Beam, .25)
				GlobalFunctions.TweenFunction({["Instance"] = Beam,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .25,},{["Size"] = Vector3.new(End,0,0)})

				NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "ZenitsuMode", Function = "SixFoldTeleport", Configurations = {Start = Start, End = End, NumberOfParts = math.clamp((Start-End).Magnitude/15,3,20)}})
				Root.CFrame = CFrame.new(position)
				Start = position
				
				local CreateFrameData = {Size = UDim2.new(1,0,1,0); Position = UDim2.new(0,0,0,0); Color = Color3.fromRGB(255, 230, 101); Duration = .1}
				CameraRemote:FireClient(Player,"CreateFlashUI",CreateFrameData)
				wait(.05)
			end
		
			wait()
			local c1,c2 = nil,nil
			local RaycastResult = workspace:Raycast(point,look,raycastParams)
			if RaycastResult and RaycastResult.Instance and (RaycastResult.Position - point).Magnitude < 100 then
				local pos = RaycastResult.Position
				local Rotation = center - center.Position
				local startcframe = center
				NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "ZenitsuVFX", Function = "Dash", Distance = 100, ContactPointCFrame = Root.CFrame})
				
				local EnemyCharacter = GetNearPlayers(Character,50)
				if EnemyCharacter then
					Root.CFrame = EnemyCharacter.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
				else
					Root.CFrame = CFrame.new(pos) * CFrame.new(0,3,0) * Rotation
				end

				HitboxModule.GetTouchingParts(Player,{Delay = .935, ExistTime = 2, Type = "Sword", KeysLogged = math.random(1,3), Size = Vector3.new(20.417, 4.517, 58.929), Transparency = 0, PositionCFrame = Root.CFrame * CFrame.new(0,0,18.5)},KeyData.SerializedKey,CharacterName)	
				NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "ZenitsuVFX", Function = "Menbere", Distance = 100, ContactPointCFrame = Root.CFrame * CFrame.new(0,0,36)})
			end
		end)
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
	end,

	["SecondAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		local MouseHit = MouseRemote:InvokeClient(Player)	

		local Victim,Position = RaycastTarget(100,Character)
		if not Victim then return end
		local VHumanoid,VRoot = Victim:FindFirstChild("Humanoid"),Victim:FindFirstChild("HumanoidRootPart")

		local UnitVector = (Root.Position - VRoot.Position).Unit
		local VictimLook = VRoot.CFrame.LookVector
		local DotVector = UnitVector:Dot(VictimLook)

		if StateManager:Peek(Victim,"Blocking") and DotVector >= -.5 then 
			NetworkStream.FireClientDistance(Character,"ClientRemote",150,{
				Character = Character,
				Victim = Victim,
				WeaponType = "Combat",
				Module = "CombatVFX",
				Function = "Block"
			}) 
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
			return 
		end
		
		StateManager:ChangeState(Character,"Stunned",3)
		StateManager:ChangeState(Character,"Guardbroken",3)
		
		TaskScheduler:AddTask(.5,function()
			NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "ZenitsuVFX", Function = "Zap", Position = VRoot.Position})	
		end)
		AnimationRemote:FireClient(Player,"RiceSpirit","Play",{AdjustSpeed = 1.15})
		
		wait(.9)
		Humanoid.AutoRotate = false
		-- SoundManager:AddSound("Lightning_Release_2",{Parent = Root},"Client")
		local Beam = ReplicatedStorage.Assets.Effects.Meshes.Whirldwindball:Clone()
		Beam.BrickColor = BrickColor.new("Pastel light blue")
		Beam.Shape = "Cylinder"	
		Beam.CanCollide = false
		Beam.Anchored = true
		Beam.Material = "Neon"					
		local End = (Root.CFrame.Position - VRoot.CFrame.Position).Magnitude 
		Beam.Size = Vector3.new(End, 5, 5)
		Beam.CFrame = CFrame.new(Root.CFrame.Position, VRoot.CFrame.Position) * CFrame.new(0,0,-End / 2) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)
		Beam.Parent = workspace.World.Visuals

		Debris:AddItem(Beam, .25)
		GlobalFunctions.TweenFunction({["Instance"] = Beam,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .25,},{["Size"] = Vector3.new(End,0,0)})
		SpeedManager.changeSpeed(Character,0,1.35,4e4)

		wait(.35)
		-- SoundManager:AddSound("UnSheath",{Parent = Root, Volume = 1},"Client")
		Humanoid.AutoRotate = true
		DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{Type = "Sword", KeysLogged = ExtraData.KeysLogged})
	
		local Part = Instance.new("Part")
		Part.Transparency = 1
		Part.Anchored = true
		Part.CanCollide = false
		Part.Parent = workspace.World.Visuals

		Part.CFrame = CFrame.new(Position)
		VRoot.Anchored = true

		local Base = Position + Vector3.new(0,-8,0)
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "ZenitsuMode", Function = "WhirlWindRelease", Part = Part})

		for Index = 1,9 do
			local RandomCalculation = math.random(1,2)

			local RandomIndex = RandomCalculation == 1 and -1 or 1
			RandomCalculation = RandomIndex

			DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{Type = "Combat", KeysLogged = math.random(1,3)})

			local Yincrement = math.random(2,5) * Index
			--if Index == 9 then Yincrement = Yincrement + 20 end
			VRoot.CFrame = CFrame.new(Base + Vector3.new(math.random(15,25) * RandomCalculation, Yincrement, math.random(15,25) * RandomCalculation))
			--
			local Beam = ReplicatedStorage.Assets.Effects.Meshes.Whirldwindball:Clone()
			Beam.BrickColor = math.random(1,2) == 1 and BrickColor.new("Pastel blue-green") or BrickColor.new("Cool yellow")
			Beam.Shape = "Cylinder"	
			Beam.CanCollide = false
			Beam.Anchored = true
			Beam.Material = "Neon"					
			local End = (Part.CFrame.Position - VRoot.CFrame.Position).Magnitude 
			Beam.Size = Vector3.new(End, 5, 5)
			Beam.CFrame = CFrame.new(Part.CFrame.Position, VRoot.CFrame.Position) * CFrame.new(0,0,-End / 2) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)
			Beam.Parent = workspace.World.Visuals

			Debris:AddItem(Beam, .25)
			GlobalFunctions.TweenFunction({["Instance"] = Beam,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .25,},{["Size"] = Vector3.new(End,0,0)})

			Part.CFrame = VRoot.CFrame * CFrame.new(0,0,-2)
			wait(.15)
		end
		VfxHandler.FaceVictim({Character = Victim, Victim = Character})

		Part.Anchored = false

		wait(.35)
		VRoot.Anchored = false	
		
		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)		
	end,
	
	["ThirdAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)		
	end,

	["FourthAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
	end

}

return ZenitsuMode