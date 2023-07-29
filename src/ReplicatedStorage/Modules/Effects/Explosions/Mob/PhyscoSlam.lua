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

local RingTween = TweenInfo.new(.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)

return function(Data)
	local Character = Data.Character
	local Victim = Data.Victim
	local Player = Players:GetPlayerFromCharacter(Character)

	local Root,VRoot = Character:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("HumanoidRootPart")

	if GlobalFunctions.CheckDistance(Player, Data.Distance) then
		CameraShake:Start()
		CameraShake:ShakeOnce(30, 10, 0, 1.5)
	end

	-- SoundManager:AddSound("tsshh", {Volume = 5, Parent = Root}, "Client")
	-- SoundManager:AddSound("Explosion",{Parent = Root, Volume = 1}, "Client")
	VfxHandler.RockExplosion({ Pos = VRoot.CFrame.Position,  Quantity = 6,  Radius = 10, Size = Vector3.new(2.25,2.25,2.25),  Duration = 2})	

	local WindShockwave = Effects.windshockwave2:Clone()
	WindShockwave.BrickColor = BrickColor.new("Institutional white")
	WindShockwave.Material = "Neon"

	WindShockwave.Transparency = .5	
	WindShockwave.Size = Vector3.new(45,45,45)
	WindShockwave.CFrame = VRoot.CFrame

	WindShockwave.Parent = workspace.World.Visuals
	Debris:AddItem(WindShockwave, 1)

	GlobalFunctions.TweenFunction({["Instance"] = WindShockwave,["EasingStyle"] = Enum.EasingStyle.Linear,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .5,},{["Size"] = Vector3.new(50,50,50);['Transparency'] = 1;['CFrame'] = WindShockwave.CFrame * CFrame.fromEulerAnglesXYZ(0,1,0)})

	local MeteorExplosion = Effects.MeteorExplosion:Clone()
	MeteorExplosion.Position = VRoot.Position + Vector3.new(0,5 / 1.5,0)

	MeteorExplosion.Size = Vector3.new(1.5,1.5,1.5) * 5
	MeteorExplosion.Parent = workspace.World.Visuals
	Debris:AddItem(MeteorExplosion, 3.5)

	local LargerParticles = MeteorExplosion["Larger Particles"]
	LargerParticles.Speed = NumberRange.new(5/1.5, 5)
	VfxHandler.Emit(LargerParticles, 30)

	local SmallerParticles = MeteorExplosion["Smaller Particles"]
	SmallerParticles.Speed = NumberRange.new(5/1.5, 5)
	SmallerParticles.Parent = MeteorExplosion
	VfxHandler.Emit(SmallerParticles, 45)

	local FireParticle = Effects.FireEmit:Clone()
	FireParticle.Position = VRoot.Position
	FireParticle.Parent = workspace.World.Visuals
	VfxHandler.Emit(FireParticle.Attachment.ParticleEmitter, 100)

	Debris:AddItem(FireParticle,1)

	coroutine.resume(coroutine.create(function()
		for Index = 1,2 do
			local RingTing = Effects.RingTing:Clone()
			RingTing.Color = Color3.fromRGB(225, 115, 5)
			RingTing.Material = "Neon"

			RingTing.Transparency = 0
			RingTing.Position = VRoot.CFrame.p
			RingTing.Rotation = Vector3.new(math.random(-360, 360) * Index,math.random(-360, 360) * Index, math.random(-360, 360) * Index);
			RingTing.Size = Vector3.new(20,1,20)

			RingTing.Parent = workspace.World.Visuals
			Debris:AddItem(RingTing, .5)

			local Tween = TweenService:Create(RingTing,TweenInfo.new(.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = Vector3.new(20,1,20)})
			Tween:Play()
			Tween:Destroy()
			wait(.1)
		end	
	end))

	for _ = 1,3 do
		local x,y,z = math.cos(math.rad(math.random(1,6) * 60)),math.cos(math.rad(math.random(1,6 ) * 60)),math.sin(math.rad(math.random(1,6) * 60))
		local Start = VRoot.CFrame.p
		local End = Start +  Vector3.new(x,y,z)

		local Orbie = Effects.MeshOribe:Clone()
		Orbie.CFrame = CFrame.new(Start,End)
		Orbie.Size = Vector3.new(1,2,1)

		local OrbieTweenInfo = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

		local Tween = TweenService:Create(Orbie,OrbieTweenInfo,{CFrame = CFrame.new(Start,End)*CFrame.new(0,0,-(math.random(2,5) * 10)),Size = Vector3.new(0,0,24)})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(Orbie,.2)
		Orbie.Parent = workspace.World.Visuals
	end

	coroutine.resume(coroutine.create(function()
		local Calculation = Root.CFrame - Root.Position
		for _ = 1,2 do			
			local Ring = ReplicatedStorage.Assets.Effects.Meshes.Ring2:Clone()
			Ring.Size = Vector3.new(50,3,50)
			Ring.Material = Enum.Material.Neon
			Ring.CanCollide = false
			Ring.CFrame = CFrame.new(Root.Position) * Calculation
			Ring.Anchored = true
			Ring.Parent = workspace.World.Visuals

			Debris:AddItem(Ring,.4)

			local Tween = TweenService:Create(Ring,RingTween,{CFrame = Ring.CFrame * CFrame.new(0,15,0) ,Size = Vector3.new(0,0,0)})
			Tween:Play()
			Tween:Destroy()

			wait(.2)
		end
	end))

	local RayParam = RaycastParams.new()
	RayParam.FilterType = Enum.RaycastFilterType.Exclude
	RayParam.FilterDescendantsInstances = { Character, workspace.World.Visuals }

	local RaycastResult = workspace:Raycast(VRoot.Position, Vector3.yAxis * -1000, RayParam) or {}
	local Part, Position = RaycastResult.Instance, RaycastResult.Position

	if Part then
		local GroundEffect = Particles.GroundSlamThing:Clone()
		GroundEffect.Position = Position or VRoot.CFrame.p
		GroundEffect.ParticleEmitter.Color = ColorSequence.new(Part.Color)
		GroundEffect.Rocks.Color = ColorSequence.new(Part.Color)

		GroundEffect.Parent = workspace.World.Visuals

		GroundEffect.ParticleEmitter:Emit(18)
		GroundEffect.Rocks:Emit(20)

		Debris:AddItem(GroundEffect,2)

		coroutine.resume(coroutine.create(function()
			for Index = 1,2 do
				local Shockwave = ReplicatedStorage.Assets.Effects.Meshes.ShockInnit:Clone()
				Shockwave.Position = Position or VRoot.CFrame.p
				Shockwave.Size = Vector3.new(45, 10, 45)
				Shockwave.Transparency = .35
				Shockwave.Material = "Neon"
				Shockwave.Color = Color3.fromRGB(255, 255, 255)
				Shockwave.Parent = workspace.World.Visuals
				Debris:AddItem(Shockwave,3)

				if Index >= 3 then
					local Tween = TweenService:Create(Shockwave,RingTween,{Color = Color3.fromRGB(255, 96, 33)})
					Tween:Play()
					Tween:Destroy()
				end

				GlobalFunctions.TweenFunction({["Instance"] = Shockwave,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .5,},{["Size"] = Vector3.new(35,2,35);['Transparency'] = 1;['CFrame'] = Shockwave.CFrame * CFrame.fromEulerAnglesXYZ(0,5,0)})
				wait(.1)
			end
		end))

		for _ = 1, 4 do
			local Rock = Effects.block:Clone()
			Rock.Size = Vector3.new(3,3,3)
			Rock.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
			Rock.Anchored = false
			Rock.CanCollide = false
			Rock.Velocity = Vector3.new(math.random(-80,80),math.random(80,100),math.random(-80,80))

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
		
		for _ = 1,2 do
			-- TODO: Add MiscMeshes, whatever that is

			--local RingTing = ReplicatedStorage.Assets.MiscMeshes.RingInnit:Clone()
			--RingTing.Material = Part.Material
			--RingTing.Color = Part.Color 

			--RingTing.Anchored = true 
			--RingTing.CFrame = VRoot.CFrame * CFrame.new(0,-3,0)		
			--RingTing.Size = Vector3.new(15,.05,15)
			--RingTing.Transparency = .25

			--RingTing.Parent = workspace.World.Visuals
			--Debris:AddItem(RingTing,1.25)

			--GlobalFunctions.TweenFunction({["Instance"] = RingTing,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .5,},{["Size"] = Vector3.new(18,.05,28);['Transparency'] = 1;['CFrame'] = Shockwave.CFrame * CFrame.fromEulerAnglesXYZ(0,5,0)})
			wait(.25)
		end
	end
end