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

return function(Data)
	local Character = Data.Character
	local Result = Data.RaycastResult
	local Size = Data.Size

	local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

	local Player = Players:GetPlayerFromCharacter(Character)

	local Distance = Data.Distance

	if GlobalFunctions.CheckDistance(Player, Distance) then
		CameraShake:Start()
		CameraShake:ShakeOnce(12, 8, 0, 1.5)
	end
	
	for _ = 1,2 do
		local Rock = Effects.Rock:Clone()
		Rock.Position = Result.Position
		Rock.Material = Result.Material;
		Rock.Color = Result.Instance.Color;
		Rock.CanCollide = false
		Rock.Size = Vector3.new(6, 6, 6)
		Rock.Orientation = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100))
		Rock.Velocity = Vector3.new(math.random(-100,100),math.random(100,100),math.random(-100,100))
		Rock.Parent = workspace.World.Visuals

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Velocity = Vector3.new(math.random(-80,80),math.random(80,120),math.random(-80,80))
		BodyVelocity.MaxForce = Vector3.new(100000,100000,100000)
		BodyVelocity.Parent = Rock
		
		local BlockTrail = Particles.BlockSmoke:Clone()
		BlockTrail.Color = ColorSequence.new(Result.Instance.Color)
		BlockTrail.Enabled = true
		BlockTrail.Parent = Rock
		
		Debris:AddItem(Rock,3)
		Debris:AddItem(BodyVelocity,.1)
	end
	
	VfxHandler.RockExplosion({
		Pos = Result.Position, 
		Quantity = 15, 
		Radius = 30,
		Size = Vector3.new(4,4,4), 
		Duration = 2, 
	})

	LightningExplosion.new(Result.Position, 5, 10, ColorSequence.new(Color3.fromRGB(255, 82, 39)), ColorSequence.new(Color3.fromRGB(255, 85, 0)), nil)

	local DustParticles = Effects.DustParticles:Clone();
	DustParticles.CFrame = CFrame.new(Result.Position + Vector3.new(0,Size/2,0));
	DustParticles.FallingDust.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,Size/2), NumberSequenceKeypoint.new(1,Size/2)})
	DustParticles.FallingDust.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Result.Instance.Color), ColorSequenceKeypoint.new(1, Result.Instance.Color)});

	DustParticles.RockParticles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,Size/12), NumberSequenceKeypoint.new(1,Size/12)})
	DustParticles.RockParticles.Speed = NumberRange.new(Size, Size)
	DustParticles.RockParticles.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Result.Instance.Color), ColorSequenceKeypoint.new(1, Result.Instance.Color)});

	DustParticles.Size = Vector3.new(1,1,1) * Size;
	DustParticles.Parent = workspace.World.Visuals

	VfxHandler.Emit(DustParticles.FallingDust, 30)
	VfxHandler.Emit(DustParticles.RockParticles, 10)
	Debris:AddItem(DustParticles, DustParticles.FallingDust.Lifetime.Max)

	local MeteorExplosion = Effects.MeteorExplosion:Clone()
	MeteorExplosion.Position = Result.Position + Vector3.new(0,Size/1.5,0)

	MeteorExplosion.Size = Vector3.new(1.5,1.5,1.5) * Size
	MeteorExplosion.Parent = workspace.World.Visuals
	Debris:AddItem(MeteorExplosion, 3.5)

	local LargerParticles = MeteorExplosion["Larger Particles"]
	LargerParticles.Speed = NumberRange.new(Size/1.5, Size)
	VfxHandler.Emit(LargerParticles, 30)

	local SmallerParticles = MeteorExplosion["Smaller Particles"]
	SmallerParticles.Speed = NumberRange.new(Size/1.5, Size)
	SmallerParticles.Parent = MeteorExplosion
	VfxHandler.Emit(SmallerParticles, 50)

	local FireParticle = Effects.FireEmit:Clone()
	FireParticle.Position = Result.Position
	FireParticle.Parent = workspace.World.Visuals
	VfxHandler.Emit(FireParticle.Attachment.ParticleEmitter, 50)

	Debris:AddItem(FireParticle,1)

	local Ring = Effects.RingInnit:Clone()
	Ring.Position = Result.Position + Vector3.new(0,16,0)
	Ring.Size = Vector3.new(15,.05,15)

	Ring.Transparency = .25
	Ring.Material = "Neon"
	Ring.BrickColor = BrickColor.new("Institutional white")

	Ring.Parent = workspace.World.Visuals

	GlobalFunctions.TweenFunction({["Instance"] = Ring,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .5,},{["CFrame"] = Ring.CFrame * CFrame.new(0,12,0), ["Transparency"] = 1, ["Size"] = Vector3.new(25,.05,25)})

	Debris:AddItem(Ring,1)

	local Cylinder = Effects.ball:Clone()
	Cylinder.BrickColor = BrickColor.new("Institutional white")
	Cylinder.Shape = "Cylinder"

	Cylinder.Transparency = 0
	Cylinder.Material = "Neon"
	Cylinder.Size = Vector3.new(500,5,5)

	Cylinder.Position = Result.Position + Vector3.new(0,100,0)
	Cylinder.CFrame = Cylinder.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(90))

	Cylinder.Parent = workspace.World.Visuals
	Debris:AddItem(Cylinder, .5)

	local ColorChange = TweenService:Create(Cylinder, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out,0,true), {Color = Color3.fromRGB(255, 93, 39)})
	ColorChange:Play()
	ColorChange:Destroy()

	GlobalFunctions.TweenFunction({["Instance"] = Cylinder,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .5,},{ ["Size"] = Vector3.new(500, 0, 0)})	

	local Number, Orbie = VfxHandler.Orbies({Parent = Result, Speed = .5, Size = Vector3.new(2, 2, 30), Cframe = CFrame.new(0,0,50), Amount = 12, Sphere = true, Type = "Yes"})

	local Sound = -- SoundManager:AddSound("tsshh", {Volume = 5, Parent = Root}, "Client")
	-- SoundManager:AddSound("Explosionbzz", {Volume = .7, Parent = Root}, "Client")

	for _ = 1,2 do
		local Shockwave = Effects.RingInnit:Clone()
		Shockwave.Position = Result.Position
		Shockwave.Parent = workspace.World.Visuals
		Debris:AddItem(Shockwave, 2)

		local RandomSize = Size * (2 + 2 * math.random());

		local ColorChange = TweenService:Create(Shockwave, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Color3.fromRGB(255, 93, 39)})
		ColorChange:Play()
		ColorChange:Destroy()

		local Expand = TweenService:Create(Shockwave, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(RandomSize, .5, RandomSize)})
		Expand:Play()
		Expand:Destroy()

		local Spin = TweenService:Create(Shockwave, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1), {Orientation = Shockwave.Orientation + Vector3.new(0,360,0)})
		Spin:Play();
		Spin:Destroy()

		local Pillow = TweenService:Create(Shockwave, TweenInfo.new(.5 + math.random(), Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false, 0), {Position = Shockwave.Position + Vector3.new(0, math.random(5,50),0), Transparency = 1})
		Pillow:Play();
		Pillow:Destroy()
		
		Debris:AddItem(Shockwave,1.15)
	end

	coroutine.resume(coroutine.create(function()
		for _ = 1,2 do
			local Shockwave = ReplicatedStorage.Assets.Effects.Meshes.ShockInnit:Clone()
			Shockwave.Position = Result.Position
			Shockwave.Size = Vector3.new(60, 10, 60)

			Shockwave.Transparency = .35
			Shockwave.Material = "Neon"

			Shockwave.Color = Color3.fromRGB(255, 110, 26)
			Shockwave.Parent = workspace.World.Visuals

			Debris:AddItem(Shockwave,3)

			GlobalFunctions.TweenFunction({["Instance"] = Shockwave,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .5,},{["Size"] = Vector3.new(35,2,35);['Transparency'] = 1;['CFrame'] = Shockwave.CFrame * CFrame.fromEulerAnglesXYZ(0,5,0)})
			wait(.1)
		end
		--	end
	end))

	local ShockwaveTing = Effects.shockwave5:Clone()
	ShockwaveTing.Position = Result.Position 
	ShockwaveTing.Size = Vector3.new(50, 100, 50)

	ShockwaveTing.Transparency = 0 
	ShockwaveTing.Material = "Neon"
	ShockwaveTing.BrickColor = BrickColor.new("Institutional white");

	ShockwaveTing.Parent = workspace.World.Visuals

	GlobalFunctions.TweenFunction({["Instance"] = ShockwaveTing,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .5,},{["CFrame"] = ShockwaveTing.CFrame * CFrame.new(0,50,0) * CFrame.fromEulerAnglesXYZ(0,5,0), ["Transparency"] = 1, ["Size"] = Vector3.new(0, 180, 0)})

	Debris:AddItem(ShockwaveTing, .5)

	for _ = 1,3 do
		local ShockWave = Effects.shockwave3:Clone()
		ShockWave.Position = Result.Position
		ShockWave.Mesh.Scale = Vector3.new(.1,.1,.1)
		ShockWave.Transparency = .5

		GlobalFunctions.TweenFunction({["Instance"] = ShockWave.Mesh,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .5,},{["Scale"] = Vector3.new(.5,.5,.5);})
		GlobalFunctions.TweenFunction({["Instance"] = ShockWave,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .5,},{["Transparency"] = 1;})

		Debris:AddItem(ShockWave, .5)
	end

	for Index = 1,2 do
		local Ring = Effects.ring:Clone()
		Ring.Color = Color3.fromRGB(225, 115, 5)
		Ring.Material = "Neon"
		Ring.Transparency = 0 

		Ring.Position = MeteorExplosion.Position
		Ring.Rotation = Vector3.new(math.random(-360, 360) * Index,math.random(-360, 360) * Index, math.random(-360, 360) * Index)
		Ring.Size = Vector3.new(40,1,40)

		Ring.Parent = workspace.World.Visuals

		GlobalFunctions.TweenFunction({["Instance"] = Ring, ["EasingStyle"] = Enum.EasingStyle.Quart,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .5,},{["Transparency"] = 1, ["Size"] = Vector3.new(50,1,50);})

		Debris:AddItem(Ring, .5)
		wait(.1)
	end	
end