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

function VelocityCalculation(End,Start,Gravity,Time)
	return (End - Start - .5 * Gravity * Time * Time) / Time
end

local RingTween = TweenInfo.new(.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)

return function(Data)
	local Character,Victim = Data.Character,Data.Victim
	local Result = Data.RaycastResult
	
	local Player = Players:GetPlayerFromCharacter(Character)
	
	local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
	local VRoot,VHumanoid = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {Character, workspace.World.Visuals}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	-- SoundManager:AddSound("BOOM!", {Parent = Root, Volume = 2}, "Client")

	if GlobalFunctions.CheckDistance(Player, Data.Distance) then
		CameraShake:Start()
		CameraShake:ShakeOnce(8, 15, 0, 1.5)
	end 

	local Calculation = VRoot.CFrame - VRoot.Position
	
	local Part = Instance.new("Part")
	Part.Anchored = true
	Part.CFrame = VRoot.CFrame * CFrame.new(0,-3,0)
	Part.Transparency = 1
	Part.Orientation = Vector3.new(3.87, -4.36, -2.25)
	Part.Parent = workspace.World.Visuals

	Debris:AddItem(Part,2)
	
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

	Debris:AddItem(ShockWave, .5)
	
	coroutine.resume(coroutine.create(function()
		for _ = 1,2 do 			
			local ball = Effects.regball:Clone()
			ball.Transparency = .5
			ball.Size = Vector3.new(15,15,15) -- 100,100,100
			ball.BrickColor = BrickColor.new("Institutional white")
			ball.CFrame = Part.CFrame * CFrame.new(0,0,0)
			ball.Parent = workspace.World.Visuals
			
			GlobalFunctions.TweenFunction({
				["Instance"] = ball,
				["EasingStyle"] = Enum.EasingStyle.Quad,
				["EasingDirection"] = Enum.EasingDirection.Out,
				["Duration"] = .15,
			},{
				["Size"] = Vector3.new(0,0,0),
			})

			local windshockwave = Effects.windshockwave:Clone()
			windshockwave.CFrame = ball.CFrame
			windshockwave.Size = Vector3.new(5,5,5)
			windshockwave.Transparency = 0
			windshockwave.Material = "Neon"
			windshockwave.BrickColor = BrickColor.new("Institutional white")
			windshockwave.Parent = workspace.World.Visuals	
			
			GlobalFunctions.TweenFunction({
				["Instance"] = windshockwave,
				["EasingStyle"] = Enum.EasingStyle.Quad,
				["EasingDirection"] = Enum.EasingDirection.Out,
				["Duration"] = .35,
			},{
				["Transparency"] = 1,
				["Size"] = Vector3.new(15,15,15), -- 60,60,60
				["CFrame"] = windshockwave.CFrame * CFrame.fromEulerAnglesXYZ(0,5,0)
			})

			local windshockwave2 = Effects.windshockwave2:Clone()
			windshockwave2.CFrame = ball.CFrame
			windshockwave2.Size = Vector3.new(5,5,5)
			windshockwave2.Transparency = 0
			windshockwave2.Material = "Neon"
			windshockwave2.BrickColor = BrickColor.new("Institutional white")
			windshockwave2.Parent = workspace.World.Visuals	
			
			GlobalFunctions.TweenFunction({
				["Instance"] = windshockwave2,
				["EasingStyle"] = Enum.EasingStyle.Quad,
				["EasingDirection"] = Enum.EasingDirection.Out,
				["Duration"] = .35,
			},{
				["Transparency"] = 1,
				["Size"] = Vector3.new(15,15,15), --60,60,60
				["CFrame"] = windshockwave2.CFrame * CFrame.fromEulerAnglesXYZ(0,5,0)
			})
			
			Debris:AddItem(ball, .35)
			Debris:AddItem(windshockwave, .35)
			Debris:AddItem(windshockwave2, .35)
			wait(.15)
		end	
	end))

	local ShockwaveTing = Effects.shockwaveOG:Clone()
	ShockwaveTing.Position = Part.Position + Vector3.new(0,3,0)
	ShockwaveTing.Size = Vector3.new(30, 5, 30) --60,10,60
	ShockwaveTing.Transparency = 0
	ShockwaveTing.Material = "Neon"
	ShockwaveTing.BrickColor = BrickColor.new("Institutional white")
	ShockwaveTing.Parent = workspace.World.Visuals

	GlobalFunctions.TweenFunction({
		["Instance"] = ShockwaveTing,
		["EasingStyle"] = Enum.EasingStyle.Quad,
		["EasingDirection"] = Enum.EasingDirection.Out,
		["Duration"] = .5,
	},{
		["Transparency"] = 1,
		["Size"] = Vector3.new(45,12,45), --60,20,60
		["CFrame"] = ShockwaveTing.CFrame * CFrame.fromEulerAnglesXYZ(0,5,0)
	})
	
	Debris:AddItem(ShockwaveTing,.5)

	VfxHandler.RockExplosion({
		Pos = Part.Position, 
		Quantity = 8, 
		Radius = 15,
		Size = Vector3.new(2.5,2.5,2.5), 
		Duration = 2, 
	})	

	for _ = 1,12 do
		local Rock = Effects.Rock:Clone()
		Rock.Position = Part.Position
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

	local GroundEffect = Particles.GroundSlamThing:Clone()
	GroundEffect.CFrame = CFrame.new(Part.Position,Part.Position - Result.Normal) * CFrame.Angles(math.pi/2,0,0)
	GroundEffect.ParticleEmitter.Color = ColorSequence.new(Result.Instance.Color)
	GroundEffect.Rocks.Color = ColorSequence.new(Result.Instance.Color)

	GroundEffect.Parent = workspace.World.Visuals

	GroundEffect.ParticleEmitter:Emit(18)
	GroundEffect.Rocks:Emit(20)

	if GlobalFunctions.CheckDistance(Player, Data.Distance) then
		CameraShake:Start()
		CameraShake:ShakeOnce(3, 5, 0, 1.5)
	end

	for _ = 1,math.random(6,8) do
		local x,y,z = math.cos(math.rad(math.random(1,6) * 60)),math.cos(math.rad(math.random(1,6 ) * 60)),math.sin(math.rad(math.random(1,6) * 60))
		local Start = Part.Position
		local End = Start + Vector3.new(x,y,z)

		local Orbie = Effects.MeshOribe:Clone()
		Orbie.CFrame = CFrame.new(Start,End)
		Orbie.Size = Vector3.new(1,2,1)

		local OrbieTweenInfo = TweenInfo.new(.75,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

		local Tween = TweenService:Create(Orbie,OrbieTweenInfo,{CFrame = CFrame.new(Start,End)*CFrame.new(0,0,-(math.random(2,5) * 10)),Size = Vector3.new(0,0,24)})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(Orbie,.2)
		Orbie.Parent = workspace.World.Visuals
	end

	Debris:AddItem(GroundEffect,3)
	
	for _ = 1,2 do			
		local Ring = ReplicatedStorage.Assets.Effects.Meshes.Ring2:Clone()
		Ring.Size = Vector3.new(80,3,80) --50,3,50
		Ring.Material = Enum.Material.Neon
		Ring.CanCollide = false
		Ring.CFrame = CFrame.new(Part.Position) * Calculation
		Ring.Anchored = true
		Ring.Parent = workspace.World.Visuals

		Debris:AddItem(Ring,.4)

		local Tween = TweenService:Create(Ring,RingTween,{CFrame = Ring.CFrame * CFrame.new(0,12,0) ,Size = Vector3.new(0,0,0)})
		Tween:Play()
		Tween:Destroy()

		wait(.2)
	end
end	
