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
local Effectsz = Modules.Effects
local Shared = Modules.Shared

--|| Modules ||--
local SoundManager = require(Shared.SoundManager)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local CameraShaker = require(Effectsz.CameraShaker)
local LightningExplosion = require(Effectsz.LightningBolt.LightningExplosion)
local VfxHandler = require(Effectsz.VfxHandler)

local CurrentCamera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
end)	

--|| Variables ||--
local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local RingTween = TweenInfo.new(.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)

return function(Data)
	local Character = Data.Character
	local Root = Data.Rock
	local Size = Data.Size
	local Result = Data.RaycastResult
	local Player = Players:GetPlayerFromCharacter(Character)

	if GlobalFunctions.CheckDistance(Player, Data.Distance) then
		CameraShake:Start()
		CameraShake:ShakeOnce(5, 8, 0, 1.5)
	end

	local DustParticles = Effects.DustParticles:Clone();
	DustParticles.CFrame = CFrame.new(Result.Position + Vector3.new(0,Size/2,0));
	DustParticles.FallingDust.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,Size/2), NumberSequenceKeypoint.new(1,Size/2)})
	DustParticles.FallingDust.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Result.Instance.Color), ColorSequenceKeypoint.new(1, Result.Instance.Color)});

	DustParticles.RockParticles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,Size/12), NumberSequenceKeypoint.new(1,Size/12)})
	DustParticles.RockParticles.Speed = NumberRange.new(Size, Size)
	DustParticles.RockParticles.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Result.Instance.Color), ColorSequenceKeypoint.new(1, Result.Instance.Color)});

	VfxHandler.Emit(DustParticles.FallingDust, 30)
	--VfxHandler.Emit(DustParticles.RockParticles, 10)
	Debris:AddItem(DustParticles, DustParticles.FallingDust.Lifetime.Max)

	DustParticles.Size = Vector3.new(1,1,1) * Size;
	DustParticles.Parent = workspace.World.Visuals

	Debris:AddItem(DustParticles,2)

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

	local SecondWindShockwave = Effects.windshockwave2:Clone()
	SecondWindShockwave.BrickColor = BrickColor.new("Daisy orange")
	SecondWindShockwave.Material = "Neon"

	SecondWindShockwave.Size = Vector3.new(20,20,20)
	SecondWindShockwave.Transparency = 0
	SecondWindShockwave.Position = Result.Position

	GlobalFunctions.TweenFunction({
		["Instance"] = SecondWindShockwave,
		["EasingStyle"] = Enum.EasingStyle.Linear,
		["EasingDirection"] = Enum.EasingDirection.Out,
		["Duration"] = .35,
	},{
		["Size"] = Vector3.new(60,60,60);
		["Transparency"] = 1;
		["CFrame"] = SecondWindShockwave.CFrame * CFrame.fromEulerAnglesXYZ(0,10,0)
	})

	SecondWindShockwave.Parent = workspace.World.Visuals
	Debris:AddItem(SecondWindShockwave, .35)

	local Calculation = Data.Rock.CFrame - Data.Rock.Position	

	local RegularBall = Effects.regball:Clone()
	RegularBall.Transparency = .5
	RegularBall.Size = Vector3.new(40,40,40)

	RegularBall.Color = Color3.fromRGB(255, 120, 66)
	RegularBall.CFrame = Result.CFrame + Vector3.new(0,5,0)

	RegularBall.Parent = workspace.World.Visuals
	Debris:AddItem(RegularBall,.2)


	GlobalFunctions.TweenFunction({
		["Instance"] = RegularBall,
		["EasingStyle"] = Enum.EasingStyle.Quad,
		["EasingDirection"] = Enum.EasingDirection.Out,
		["Duration"] = .15,
	},{
		["Size"] = Vector3.new(0,0,0);
	})

	local windshockwave = Effects.windshockwave:Clone()
	windshockwave.CFrame = RegularBall.CFrame
	windshockwave.Size = Vector3.new(5,5,5)

	windshockwave.Transparency = 0 
	windshockwave.Material = "Neon" 
	windshockwave.Color = Color3.fromRGB(255, 120, 66) 

	windshockwave.Parent = workspace.World.Visuals
	Debris:AddItem(windshockwave, .35)

	GlobalFunctions.TweenFunction({
		["Instance"] = windshockwave,
		["EasingStyle"] = Enum.EasingStyle.Quad,
		["EasingDirection"] = Enum.EasingDirection.In,
		["Duration"] = .35,
	},{
		["Size"] = Vector3.new(50,50,50);
		["Transparency"] = 1;
		["CFrame"] = windshockwave.CFrame * CFrame.fromEulerAnglesXYZ(0,5,0)
	})

	local windshockwave2 = Effects.windshockwave2:Clone()
	windshockwave2.CFrame = RegularBall.CFrame
	windshockwave2.Size = Vector3.new(5,5,5)		
	windshockwave2.Transparency = 0

	windshockwave2.Material = "Neon"
	windshockwave2.Color = Color3.fromRGB(255, 120, 66)

	GlobalFunctions.TweenFunction({
		["Instance"] = windshockwave,
		["EasingStyle"] = Enum.EasingStyle.Quad,
		["EasingDirection"] = Enum.EasingDirection.In,
		["Duration"] = .35,
	},{
		["Size"] = Vector3.new(50,50,50);
		["Transparency"] = 1;
		["CFrame"] = windshockwave.CFrame * CFrame.fromEulerAnglesXYZ(0,5,0)
	})

	Debris:AddItem(windshockwave2, .35)
	windshockwave2.Parent = workspace.World.Visuals			


	coroutine.resume(coroutine.create(function()
		for Index = 1,2 do
			local RingTing = Effects.ring:Clone()						
			RingTing.Material = "Neon"
			RingTing.Transparency = 0

			RingTing.CFrame = Root.CFrame
			RingTing.Rotation = Vector3.new(math.random(-360, 360) * Index,math.random(-360, 360) * Index, math.random(-360, 360) * Index)
			RingTing.Size = Vector3.new(10,1,10)

			local _ = (Index and Index == 1 and RingTing.BrickColor and BrickColor.new("Daisy orange")) or (Index and Index == 3 and RingTing.BrickColor and BrickColor.new("Institutional white"))
			RingTing.Parent = workspace.World.Visuals
			Debris:AddItem(RingTing, .35)

			GlobalFunctions.TweenFunction({
				["Instance"] = RingTing,
				["EasingStyle"] = Enum.EasingStyle.Quart,
				["EasingDirection"] = Enum.EasingDirection.Out,
				["Duration"] = .35,
			},{
				["Size"] = Vector3.new(100,1,100);
				["Transparency"] = 1;
			})				
			wait()	
		end
	end))

	for _ = 1,2 do
		local x,y,z = math.cos(math.rad(math.random(1,6) * 60)),math.cos(math.rad(math.random(1,6 ) * 60)),math.sin(math.rad(math.random(1,6) * 60))
		local Start = Result.Position
		local End = Start + Vector3.new(x,y,z)

		local Orbie = Effects.MeshOribe:Clone()
		Orbie.CFrame = CFrame.new(Start,End)
		Orbie.Size = Vector3.new(1,2,1)

		local OrbieTweenInfo = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

		local Tween = TweenService:Create(Orbie,OrbieTweenInfo,{CFrame = CFrame.new(Start,End)*CFrame.new(0,0,-(math.random(2,5) * 18)),Size = Vector3.new(0,0,30)})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(Orbie,.2)
		Orbie.Parent = workspace.World.Visuals
	end

	if Data.Index == 2 then
		coroutine.resume(coroutine.create(function()
			for _ = 1,2 do			
				local Ring = ReplicatedStorage.Assets.Effects.Meshes.Ring2:Clone()
				Ring.Size = Vector3.new(60,3,60)
				Ring.Material = Enum.Material.Neon
				Ring.CanCollide = false
				Ring.CFrame = CFrame.new(Data.Rock.Position) * Calculation
				Ring.Anchored = true
				Ring.Parent = workspace.World.Visuals

				Debris:AddItem(Ring,.4)

				local Tween = TweenService:Create(Ring,RingTween,{CFrame = Ring.CFrame * CFrame.new(0,20,0) ,Size = Vector3.new(0,0,0)})
				Tween:Play()
				Tween:Destroy()

				wait(.2)
			end
		end))		

		for _ = 1,2 do
			local Rock = Effects.Rock:Clone()
			Rock.Position = Result.Position
			Rock.Material = Result.Material
			Rock.Color = Result.Instance.Color
			Rock.CanCollide = false
			Rock.Size = Vector3.new(4, 4, 4)
			Rock.Orientation = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100))
			Rock.Velocity = Vector3.new(math.random(-100,100),math.random(100,100),math.random(-100,100))
			Rock.Parent = workspace.World.Visuals

			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.Velocity = Vector3.new(math.random(-80,80),math.random(80,120),math.random(-80,80))
			BodyVelocity.MaxForce = Vector3.new(100000,100000,100000)
			BodyVelocity.Parent = Rock

			local FireMagicAttachment = Particles.FireMagicParticle.Attachment:Clone()
			local FireMagicParticle = FireMagicAttachment.Fire
			FireMagicParticle.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, math.random(4,6)), NumberSequenceKeypoint.new(1, 0)}
			FireMagicParticle.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, .25)}
			FireMagicParticle.Acceleration = Vector3.new(0,0,0)
			FireMagicParticle.Lifetime = NumberRange.new(.5)
			FireMagicParticle.ZOffset = -2
			FireMagicParticle.Rate = 100
			FireMagicParticle.LockedToPart = false
			FireMagicParticle.Speed = NumberRange.new(5)
			FireMagicParticle.Enabled = true
			FireMagicAttachment.Parent = Rock
			FireMagicAttachment.Parent = Rock

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
		
		for _ = 1,3 do		
			local ShockwaveTing = Effects.classicshockwave:Clone()
			ShockwaveTing.CFrame = SecondWindShockwave * CFrame.fromEulerAnglesXYZ(math.random(-360,360),math.random(-360,360),math.random(-360,360))
			ShockwaveTing.Transparency = .25
			ShockwaveTing.Parent = workspace.World.Visuals

			GlobalFunctions.TweenFunction({
				["Instance"] = ShockwaveTing.Mesh,
				["EasingStyle"] = Enum.EasingStyle.Quad,
				["EasingDirection"] = Enum.EasingDirection.Out,
				["Duration"] = .35,
			},{
				["Scale"] = Vector3.new(.5,.5,.5);
			})

			GlobalFunctions.TweenFunction({
				["Instance"] = ShockwaveTing,
				["EasingStyle"] = Enum.EasingStyle.Quad,
				["EasingDirection"] = Enum.EasingDirection.Out,
				["Duration"] = .35,
			},{
				["Size"] = Vector3.new(30,.5,30),
				["Transparency"] = 1;
			})	

			Debris:AddItem(ShockwaveTing, .35)
			wait()
		end
	end
end