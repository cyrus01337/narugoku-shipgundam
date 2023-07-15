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
	local Position = Data.Position
	
	local Color = Data.Color

	local Player = Players:GetPlayerFromCharacter(Character)

	local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

	local Ball = ReplicatedStorage.Assets.Effects.Meshes.regball:Clone()
	Ball.Material = Enum.Material.ForceField
	Ball.Transparency = 0
	Ball.Position = Position
	Ball.Size = Vector3.new(5,5,5)
	Ball.Color = Color
	Ball.Parent = workspace.World.Visuals

	local Tween = TweenService:Create(Ball, TweenInfo.new(2.35, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {["Size"] = Vector3.new(15,15,15), ["Transparency"] = 1})
	Tween:Play()
	Tween:Destroy()

	Debris:AddItem(Ball,3)	
	
	local Ball = Effects.ball:Clone()
	Ball.Color = Color
	Ball.Material = Enum.Material.ForceField
	Ball.Transparency = 0
	Ball.Size = Vector3.new(20, 20, 20)
	Ball.Position = Position
	Ball.Parent = workspace.World.Visuals

	local Tween = TweenService:Create(Ball, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Size"] = Ball.Size * 4})
	Tween:Play()
	Tween:Destroy()
	
	Debris:AddItem(Ball, 0.45)

	local Sphere = Effects.Sphere:Clone()
	Sphere.Color = Color
	Sphere.Material = Enum.Material.Neon
	Sphere.Transparency = 0
	Sphere.Mesh.Scale = Vector3.new(25, 100, 25)
	Sphere.Position = Position
	Sphere.Parent = workspace.World.Visuals

	local Tween = TweenService:Create(Sphere.Mesh, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Scale"] = Vector3.new(0,Sphere.Mesh.Scale.Y,0)})
	Tween:Play()
	Tween:Destroy()

	Debris:AddItem(Sphere, 0.1)
	
	if Data.Ball.Color == Color3.fromRGB(96, 107, 255) then
		VfxHandler.RockExplosion({
			Pos = Position, 
			Quantity = 8, 
			Radius = 15,
			Size = Vector3.new(2.5,2.5,2.5), 
			Duration = 2, 
		})	
	end
	
	local Size = 7
	
	local ExplosionParticles = script.explos:Clone()
	ExplosionParticles.Position = Position + Vector3.new(0,Size/2,0);
	ExplosionParticles.Parent = workspace.World.Visuals
	
	Debris:AddItem(ExplosionParticles, 3)

	local LargerParticles = ExplosionParticles["Larger Particles"]
	LargerParticles.Color = ColorSequence.new(Color)
	VfxHandler.Emit(LargerParticles, 180)
	
	local Part = Instance.new("Part")
	Part.Anchored = true
	Part.Position = Position
	Part.Transparency = 1
	Part.Orientation = Vector3.new(3.87, -4.36, -2.25)
	Part.Parent = workspace.World.Visuals

	Debris:AddItem(Part,2)
	
	local Dust = script.dust:Clone()
	Dust.Rate = 0
	Dust.Parent = Part
	
	VfxHandler.Emit(Dust,5)
	Debris:AddItem(Dust,3)

	local Calculation = Part.CFrame - Part.CFrame.Position

	coroutine.resume(coroutine.create(function()
		for _ = 1,2 do			
			local Ring = ReplicatedStorage.Assets.Effects.Meshes.Ring2:Clone()
			Ring.Size = Vector3.new(80,3,80)
			Ring.Material = Enum.Material.Neon
			Ring.Color = Color
			Ring.CanCollide = false
			Ring.CFrame = CFrame.new(Position) * Calculation
			Ring.Anchored = true
			Ring.Parent = workspace.World.Visuals

			Debris:AddItem(Ring,.4)

			local Tween = TweenService:Create(Ring,RingTween,{CFrame = Ring.CFrame * CFrame.new(0,25,0) ,Size = Vector3.new(0,0,0)})
			Tween:Play()
			Tween:Destroy()

			wait(.2)
		end
	end))

	LightningExplosion.new(Position, .5, 3, ColorSequence.new(Color), ColorSequence.new(Color), nil)

	local Result = workspace:Raycast(Position, Data.Ball.CFrame.upVector * -15, raycastParams)
	if Result and Result.Instance then
		local GroundEffect = Particles.GroundSlamThing:Clone()
		GroundEffect.CFrame = CFrame.new(Result.Position,Result.Position - Result.Normal) * CFrame.Angles(math.pi/2,0,0)
		GroundEffect.ParticleEmitter.Color = ColorSequence.new(Result.Instance.Color)
		GroundEffect.Rocks.Color = ColorSequence.new(Result.Instance.Color)

		GroundEffect.Parent = workspace.World.Visuals

		GroundEffect.ParticleEmitter:Emit(18)
		GroundEffect.Rocks:Emit(20)
		
		Debris:AddItem(GroundEffect,3)

		for _ = 1, 6 do
			local Rock = Effects.Rock:Clone()
			Rock.Position = Position
			Rock.Material = Result.Material;
			Rock.Color = Result.Instance.Color;
			Rock.CanCollide = false
			Rock.Size = Vector3.new(2, 2, 2)
			Rock.Orientation = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100))
			Rock.Velocity = Vector3.new(math.random(-100,100),math.random(100,100),math.random(-100,100))
			Rock.Parent = workspace.World.Visuals

			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.Velocity = Vector3.new(math.random(-40,40),math.random(40,75),math.random(-40,40))
			BodyVelocity.MaxForce = Vector3.new(100000,100000,100000)
			BodyVelocity.Parent = Rock

			local BlockTrail = Particles.BlockSmoke:Clone()
			BlockTrail.Color = ColorSequence.new(Result.Instance.Color)
			BlockTrail.Enabled = true
			BlockTrail.Parent = Rock

			Debris:AddItem(Rock,3)
			Debris:AddItem(BodyVelocity,.1)
		end		
	end
	
	if GlobalFunctions.CheckDistance(Player, Data.Distance) then
		CameraShake:Start()
		CameraShake:ShakeOnce(3, 5, 0, 1.5)
	end

	for _ = 1,math.random(4,6) do
		local x,y,z = math.cos(math.rad(math.random(1,6) * 60)),math.cos(math.rad(math.random(1,6 ) * 60)),math.sin(math.rad(math.random(1,6) * 60))
		local Start = Position
		local End = Start + Vector3.new(x,y,z)

		local Orbie = Effects.MeshOribe:Clone()
		Orbie.Color = Color
		Orbie.CFrame = CFrame.new(Start,End)
		Orbie.Size = Vector3.new(1,2,1)

		local OrbieTweenInfo = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

		local Tween = TweenService:Create(Orbie,OrbieTweenInfo,{CFrame = CFrame.new(Start,End) * CFrame.new(0,0,-(math.random(2,5) * 10)),Size = Vector3.new(0,0,24)})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(Orbie,.2)
		Orbie.Parent = workspace.World.Visuals
	end

	-- SoundManager:AddSound("explode", {Parent = Root, Volume = .85}, "Client")
	
	for Index = 1,3 do
		local RingTing = script.ring:Clone()
		RingTing.Color = Color
		RingTing.Material = "Neon"

		RingTing.Transparency = 0
		RingTing.Position = Position + Vector3.new(0,10,0)
		RingTing.Rotation = Vector3.new(math.random(-360, 360) * Index,math.random(-360, 360) * Index, math.random(-360, 360) * Index);
		RingTing.Size = Vector3.new(20,1,20)

		RingTing.Parent = workspace.World.Visuals
		Debris:AddItem(RingTing, .5)

		local Tween = TweenService:Create(RingTing,TweenInfo.new(.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = Vector3.new(45,1,45), Transparency = 1})
		Tween:Play()
		Tween:Destroy()
		wait(.1)
	end	
	
	Data.Ball:Destroy()
end	
