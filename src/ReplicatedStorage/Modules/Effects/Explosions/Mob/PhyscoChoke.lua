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
	local Victim = Data.Victim
	local Player = Players:GetPlayerFromCharacter(Character)

	local Root,VRoot = Character:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("HumanoidRootPart")

	if GlobalFunctions.CheckDistance(Player, Data.Distance) then
		CameraShake:Start()
		CameraShake:ShakeOnce(30, 10, 0, 1.5)
	end

	-- SoundManager:AddSound("Explosion",{Parent = Root, Volume = 1}, "Client")
	VfxHandler.RockTing(VRoot.CFrame,1)

	local Ring = Effects.RingInnit:Clone()
	Ring.CFrame = VRoot.CFrame * CFrame.new(0,-16,0)
	Ring.Size = Vector3.new(15,.05,15)
	Ring.Transparency = .25
	Ring.Material = "Neon"
	Ring.BrickColor = BrickColor.new("Institutional white")
	Ring.Parent = workspace.World.Visuals

	Debris:AddItem(Ring,1)
	GlobalFunctions.TweenFunction({
		["Instance"] = Ring,
		["EasingStyle"] = Enum.EasingStyle.Quad,
		["EasingDirection"] = Enum.EasingDirection.Out,
		["Duration"] = .5,
	},{
		["Size"] = Vector3.new(25,.05,25);
		["Transparency"] = 1;
		["CFrame"] = Ring.CFrame * CFrame.new(0,12,0)
	})

	for _ = 1, 10 do
		local Shockwave = Effects.shockwave3:Clone()
		Shockwave.CFrame = VRoot.CFrame * CFrame.fromEulerAnglesXYZ(math.random(-360,360),math.random(-360,360),math.random(-360,360))
		Shockwave.Mesh.Scale = Vector3.new(.1,.1,.1)
		Shockwave.Transparency = .5
		Shockwave.Parent = workspace.World.Visuals

		GlobalFunctions.TweenFunction({
			["Instance"] = Shockwave.Mesh,
			["EasingStyle"] = Enum.EasingStyle.Quad,
			["EasingDirection"] = Enum.EasingDirection.Out,
			["Duration"] = .5,
		},{
			["Scale"] = Vector3.new(.5,.5,.5);
		})

		GlobalFunctions.TweenFunction({
			["Instance"] = Shockwave,
			["EasingStyle"] = Enum.EasingStyle.Quad,
			["EasingDirection"] = Enum.EasingDirection.Out,
			["Duration"] = .5,
		},{
			["Transparency"] = 1;
		})

		Debris:AddItem(Shockwave, .5)
	end

	local Cylinder = Effects.ball:Clone()
	Cylinder.BrickColor = BrickColor.new("Institutional white")
	Cylinder.Shape = "Cylinder"
	Cylinder.Transparency = 0
	Cylinder.Material = "Neon"
	Cylinder.Size = Vector3.new(500,5,5)
	Cylinder.Position = VRoot.Position + Vector3.new(0,100,0)
	Cylinder.CFrame = Cylinder.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(90))		
	Cylinder.Parent = workspace.World.Visuals

	GlobalFunctions.TweenFunction({
		["Instance"] = Cylinder,
		["EasingStyle"] = Enum.EasingStyle.Quad,
		["EasingDirection"] = Enum.EasingDirection.Out,
		["Duration"] = .5,
	},{
		["Size"] = Vector3.new(500, 0, 0); 
		["CFrame"] = Ring.CFrame * CFrame.new(0,12,0)
	})

	VfxHandler.Orbies({Parent = VRoot, Speed = .8, Size = Vector3.new(2, 2, 30), Cframe = CFrame.new(0,0,30), Amount = 10, Sphere = true})

	local ShockWave = Effects.shockwave5:Clone()
	ShockWave.CFrame = VRoot.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(90), 0)
	ShockWave.Size = Vector3.new(50, 100, 50)
	ShockWave.Transparency = 0
	ShockWave.Material = "Neon"
	ShockWave.BrickColor = BrickColor.new("Institutional white")
	ShockWave.Parent = workspace.World.Visuals

	GlobalFunctions.TweenFunction({
		["Instance"] = ShockWave,
		["EasingStyle"] = Enum.EasingStyle.Quad,
		["EasingDirection"] = Enum.EasingDirection.Out,
		["Duration"] = .5,
	},{
		["Transparency"] = 1;
		["Size"] = Vector3.new(0, 180, 0); 
		["CFrame"] = ShockWave.CFrame * CFrame.new(0,50,0) * CFrame.fromEulerAnglesXYZ(0,5,0)
	})

	Debris:AddItem(Cylinder, .5)
	Debris:AddItem(ShockWave, .5)

	local Dust = Effects.Dust:Clone()
	Dust.CFrame = VRoot.CFrame * CFrame.new(0,-1,0)
	Dust.Particle.SpreadAngle = Vector2.new(0, 200)

	Dust.Size = Vector3.new(0,0,0)
	Dust.Particle.EmissionDirection = "Back"
	Dust.Particle.Speed = NumberRange.new(75)

	Dust.Particle.Lifetime = NumberRange.new(.44)
	Dust.Particle.Drag = 1

	Dust.Particle.Enabled = true
	Dust.Particle:Clear()
	Dust.Particle:Emit(200)		

	Dust.Parent = workspace.World.Visuals
	Debris:AddItem(Dust, 2.5)

	local RayParams = RaycastParams.new()
	RayParams.FilterType = Enum.RaycastFilterType.Exclude
	RayParams.FilterDescendantsInstances = { Character, workspace.World.Visuals }

	local RaycastResult = workspace:Raycast(VRoot.Position, Vector3.yAxis * -1000, RayParams)
	local Part, Position = RaycastResult.Instance, RaycastResult.Position
	
	if Part then

		local CrashSmoke = Effects.CrashSmoke:Clone()
		CrashSmoke.Position = Position or VRoot.CFrame.p
		CrashSmoke.Smoke.Color = ColorSequence.new(Part.Color)
		CrashSmoke.Smoke:Emit(30)
		CrashSmoke.Anchored = true
		CrashSmoke.Parent = workspace.World.Visuals

		delay(1,function() CrashSmoke.Smoke.Enabled = false end)
		Debris:AddItem(CrashSmoke,3)

		local OGShockwave = Effects.shockwaveOG:Clone()
		OGShockwave.Position = Position or VRoot.CFrame.p
		OGShockwave.Size = Vector3.new(20, 10, 20)
		OGShockwave.Transparency = 0
		OGShockwave.Material = "Neon"
		OGShockwave.BrickColor = BrickColor.new("Institutional white")
		OGShockwave.Parent = workspace.World.Visuals

		GlobalFunctions.TweenFunction({
			["Instance"] = OGShockwave,
			["EasingStyle"] = Enum.EasingStyle.Quad,
			["EasingDirection"] = Enum.EasingDirection.Out,
			["Duration"] = .5,
		},{
			["Transparency"] = 1;
			["Size"] = Vector3.new(30,8,30); 
			["CFrame"] = OGShockwave.CFrame * CFrame.fromEulerAnglesXYZ(0,5,0)
		})

		Debris:AddItem(OGShockwave, .5)

		for _ = 1, 10 do
			local size = math.random(3,6)

			local Rock = Effects.block:Clone()
			Rock.Size = Vector3.new(3,3,3)
			Rock.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
			Rock.Anchored = false
			Rock.CanCollide = false
			Rock.Velocity = Vector3.new(math.random(-80,80),math.random(80,100),math.random(-80,80))

			delay(.25,function() Rock.CanCollide = true end)
			Rock.BrickColor = Part.BrickColor
			Rock.Material = Part.Material

			Rock.Position = Position or VRoot.CFrame.p
			Rock.Parent = workspace.World.Visuals

			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BodyVelocity.Velocity = Vector3.new(math.random(-60,60),math.random(60,100),math.random(-60,60))
			BodyVelocity.P = 100000
			BodyVelocity.Parent = Rock

			local BlockTrail = Particles.BlockSmoke:Clone()
			BlockTrail.Color = ColorSequence.new(Part.Color)
			BlockTrail.Enabled = true
			BlockTrail.Parent = Rock

			Debris:AddItem(BodyVelocity, .1)
			Debris:AddItem(Rock , 3)
		end	
	end	
end