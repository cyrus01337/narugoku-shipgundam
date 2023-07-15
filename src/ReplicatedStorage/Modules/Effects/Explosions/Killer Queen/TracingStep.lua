--|| Services ||--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Effects = Modules.Effects
local Shared = Modules.Shared

--|| Modules ||--
local SoundManager = require(Shared.SoundManager)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local CameraShaker = require(Effects.CameraShaker)
local LightningExplosion = require(Effects.LightningBolt.LightningExplosion)
local VfxHandler = require(Effects.VfxHandler)

local CurrentCamera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
end)

--|| Variables ||--
local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Visuals}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local RingTween = TweenInfo.new(.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)

return function(Data)
	local Character = Data.Character
	local Result = Data.ContactPointCFrame
	
	local Player = Players:GetPlayerFromCharacter(Character)

	local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

	VfxHandler.RockExplosion({
		Pos = Result.Position, 
		Quantity = 8, 
		Radius = 15,
		Size = Vector3.new(2.5,2.5,2.5), 
		Duration = 2, 
	})
	
	-- SoundManager:AddSound("Explosiongrz",{Parent = Root, Volume = 1.5}, "Client")
	
	local ExplosionEffect = script.explosion:Clone()
	ExplosionEffect.CFrame = Result
	ExplosionEffect.Parent = workspace.World.Visuals
	
	Debris:AddItem(ExplosionEffect,3)
	
	VfxHandler.Emit(ExplosionEffect.Spark,30)
	VfxHandler.Emit(ExplosionEffect.Spark2,30)
	VfxHandler.Emit(ExplosionEffect.Smoke,30)

	if GlobalFunctions.CheckDistance(Player, Data.Distance) then
		CameraShake:Start()
		CameraShake:ShakeOnce(8, 35, 0, 1.5)
	end

	for _ = 1,math.random(6,8) do
		local x,y,z = math.cos(math.rad(math.random(1,6) * 60)),math.cos(math.rad(math.random(1,6 ) * 60)),math.sin(math.rad(math.random(1,6) * 60))
		local Start = Result.Position
		local End = Start + Vector3.new(x,y,z)

		local Orbie = Effects.MeshOribe:Clone()
		Orbie.CFrame = CFrame.new(Start,End)
		Orbie.Size = Vector3.new(1,2,1)

		local OrbieTweenInfo = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

		local Tween = TweenService:Create(Orbie,OrbieTweenInfo,{CFrame = CFrame.new(Start,End) * CFrame.new(0,0,-(math.random(2,5) * 10)),Size = Vector3.new(0,0,24)})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(Orbie,.2)
		Orbie.Parent = workspace.World.Visuals
	end
end	
