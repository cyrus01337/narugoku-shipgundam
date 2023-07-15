--||Services||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--||Directories||--
local Server = ServerScriptService.Server

local Managers = Server.Managers

local Modules = ReplicatedStorage.Modules
local Assets = ReplicatedStorage.Assets

local State = Server.State

local Shared = Modules.Shared
local Metadata = Modules.Metadata
local Utility = Modules.Utility
----A
local RaycastManager = require(Shared.RaycastManager)
local TaskScheduler = require(Utility.TaskScheduler)

--|| Imports ||--
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

--||Remotes||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse
-----Functions
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
local Kizaru = {
	["FirstAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		local Sword = Character:FindFirstChild("KizaruSword")
		if not Sword then return end

		-- SoundManager:AddSound("FlameBurst2",{Parent = Root, Volume = 1},"Client")

		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)

		--UnkowningFire,1
		AnimationRemote:FireClient(Player,"UnkowningFire","Play",{AdjustSpeed = .85})

		SpeedManager.changeSpeed(Character,8,1,1)
		StateManager:ChangeState(Character,"Guardbroken",1)				

		wait(.25)
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KizaruVFX", Function = "WaterStuff", Duration = .35})
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KizaruVFX", Function = "Trail", Sword = Sword, Duration = .6})

		CameraRemote:FireClient(Player, "CameraShake", {FirstText = 8, SecondText = 10})

		HitboxModule.GetTouchingParts(Player,{Delay = .225, ExistTime = 2, Type = "Sword", Size = Vector3.new(8.999, 4.517, 38.5), Transparency = 1, PositionCFrame = Root.CFrame * CFrame.new(0,0,-15)},KeyData.SerializedKey,CharacterName)

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Parent = Root
		BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4)
		BodyVelocity.Velocity = Root.CFrame.lookVector * 95
		Debris:AddItem(BodyVelocity,.3)

		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KizaruVFX", Function = "WaterSurfaceSlash", Sword = Sword})

		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName) 
	end,

	["SecondAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local HumanoidRootPart,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		local Sword = Character:FindFirstChild("KizaruSword")
		if not Sword then return end

		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KizaruVFX", Function = "Trail", Sword = Sword, Duration = .75, Bubbles = "fdsf", TrailFloor = "sdfsf"})
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KizaruVFX", Function = "WaterStuff", Duration = .5})

		SpeedManager.changeSpeed(Character,8,1,1)
		StateManager:ChangeState(Character,"Guardbroken",1)

		-- SoundManager:AddSound("FlameBurst2",{Parent = HumanoidRootPart, Volume = 1},"Client")
		-- SoundManager:AddSound("FlameMagic",{Parent = HumanoidRootPart, Volume = 1},"Client")

		AnimationRemote:FireClient(Player,"ScorchingFlame","Play")

		wait(.55)
		HitboxModule.MagnitudeModule(Character, {Delay = 0, Range = 10, KeysLogged = 1, Type = "Sword"}, KeyData.SerializedKey, CharacterName)
		CameraRemote:FireClient(Player, "CameraShake", {FirstText = 6, SecondText = 8})

		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KizaruVFX", Function = "secondform"})

		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName) 	
	end,

	["ThirdAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		local Victim = RaycastTarget(300,Character) or GetNearestFromMouse(Character,25)
		if not Victim then return end
		StateManager:ChangeState(Character,"Guardbroken",1.5)

		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})	
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)

		StateManager:ChangeState(Character,"IFrame",.65, {IFrameType = ""})
		SpeedManager.changeSpeed(Character,2,1.5,5) --function(Character,Speed,Duration,Priority)

		--Hum.AutoRotate = false

		Victim.Humanoid.WalkSpeed = 3
		TaskScheduler:AddTask(.5,function()
			Victim.Humanoid.WalkSpeed = 14
		end)

		--[[ Fire Animation ]]--
		AnimationRemote:FireClient(Player, "LightStars", "Play")	

		--Hum.AutoRotate = false

		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Distance = 100, Enemy = Victim, Module = "KizaruVFX", Function = "Light"})
		wait(.75)
		Root.CFrame = Victim.HumanoidRootPart.CFrame * CFrame.new(0,0,4)

		wait(.45)
		NetworkStream.FireClientDistance(Character,"ClientRemote",5,{Character = Character, Distance = 100, Module = "KizaruVFX", Function = "HieiScreen"})

		wait(.1)
		--[[ Screen Shake ]]--
		CameraRemote:FireClient(Player,"CameraShake",{
			FirstText = 6,
			SecondText = 3
		})
		DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{Type = "Sword", KeysLogged = ExtraData.KeysLogged})

		wait(.55)
		--Hum.AutoRotate = true
	end,

	["FourthAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
	end
}

return Kizaru