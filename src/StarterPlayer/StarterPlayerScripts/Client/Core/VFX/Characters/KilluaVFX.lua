--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local EffectModules = Modules.Effects
local Metadata = Modules.Metadata
local Shared = Modules.Shared
local Utility = Modules.Utility

local HitPart2 = Models.Misc.HitPart2

--|| Imports ||--
local SoundManager = require(Shared.SoundManager)

local Explosions = require(EffectModules.Explosions)
local VfxHandler = require(EffectModules.VfxHandler)
local LightningModule = require(EffectModules.LightningBolt)
local LightningExplosion = require(EffectModules.LightningBolt.LightningExplosion)

local TaskScheduler = require(Utility.TaskScheduler)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local PlayerGui = Player:WaitForChild("PlayerGui")
local HUD = PlayerGui:WaitForChild("HUD")

local Mouse = Player:GetMouse()
local MouseHit = Mouse.Hit

local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local Humanoid = Character:WaitForChild("Humanoid")

local Trash = {}

local function RemoveTrash(Trash)
	for Index = 1,#Trash do
		local Item = Trash[Index]
		if Item and Item.Parent then
			Item:Destroy()
		end
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Map}
raycastParams.FilterType = Enum.RaycastFilterType.Include

local KilluaVFX = {

	["WhirldWindSlam"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		if GlobalFunctions.CheckDistance(Player, 35) then
			GlobalFunctions.FreshShake(100,30,1,.2,0)
		end

		local RayParam = RaycastParams.new()
		RayParam.FilterType = Enum.RaycastFilterType.Exclude
		RayParam.FilterDescendantsInstances = { Character, workspace.World.Visuals }

		local RaycastResult = workspace:Raycast(Root.Position, Vector3.new(0, -1000, 500), RayParam) or {}
		local Target, Position = RaycastResult.Instance, RaycastResult.Position

		if Target then
			for Index = 1,math.random(6,10) do
				local x,y,z = math.cos(math.rad(math.random(1,6) * 60)),math.cos(math.rad(math.random(1,6 ) * 60)),math.sin(math.rad(math.random(1,6) * 60))
				local Start = Position
				local End = Start + Vector3.new(x,y,z)

				local ColorIndex = Index >= 3 and Data.Color or Color3.fromRGB(117, 237, 255) or Color3.fromRGB(255,255,255)

				local Orbie = Effects.MeshOribe:Clone()
				Orbie.Color = ColorIndex
				Orbie.CFrame = CFrame.new(Start,End)
				Orbie.Size = Vector3.new(1,2,1)

				local OrbieTweenInfo = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

				local Tween = TweenService:Create(Orbie,OrbieTweenInfo,{CFrame = CFrame.new(Start,End) * CFrame.new(0,0,-(math.random(2,5) * 10)),Size = Vector3.new(0,0,24)})
				Tween:Play()
				Tween:Destroy()

				Debris:AddItem(Orbie,.2)
				Orbie.Parent = workspace.World.Visuals
			end

			local CrashSmoke = ReplicatedStorage.Assets.Effects.Particles.CrashSmoke:Clone()
			CrashSmoke.Size = Vector3.new(12, 1, 12)
			CrashSmoke.Position = Position
			CrashSmoke.Smoke.Color = ColorSequence.new(Target.Color)
			VfxHandler.Emit(CrashSmoke.Smoke, 15)
			CrashSmoke.Parent = workspace.World.Visuals
			TaskScheduler:AddTask(1,function()
				CrashSmoke.Smoke.Enabled = false
			end)
			Debris:AddItem(CrashSmoke,3)

			VfxHandler.RockExplosion({
				Pos = Position,
				Quantity = 8,
				Radius = 15,
				Size = Vector3.new(2.5,2.5,2.5),
				Duration = 2,
			})

			for _ = 1, 10 do
				local Rock = Effects.Rock:Clone()
				Rock.Position = Root.Position
				Rock.Material = Target.Material;
				Rock.Color = Target.Color;
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
				BlockTrail.Color = ColorSequence.new(Target.Color)
				BlockTrail.Enabled = true
				BlockTrail.Parent = Rock

				Debris:AddItem(Rock,3)
				Debris:AddItem(BodyVelocity,.1)
			end
		end
		local Result = workspace:Raycast(Root.Position, Root.CFrame.upVector * -100, raycastParams)
		if Result and Result.Instance then
		end
	end,

	["WhirlWindHit"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		local contactPointCFrame = Data.ContactPointCFrame.CFrame

		if GlobalFunctions.CheckDistance(Player, 35) then
			GlobalFunctions.FreshShake(85,25,1,.2,0)
		end

		VfxHandler.Orbies({
			Parent = contactPointCFrame,
			Size = Vector3.new(0,0,math.random(1.8,3.5)),
			Color = Color3.fromRGB(0,0,0),
			Speed = .35,
			Cframe = CFrame.new(0,0,50),
			Amount = 15,
			Circle = true
		})
		-- SoundManager:AddSound("Thunder_explosion",{Parent = Root, Volume = 5},"Client")

		local Dust = Effects.Dust:Clone()
		Dust.CFrame = contactPointCFrame * CFrame.new(0,-1,0)
		Dust.Orientation = Vector3.new(0,0,0)
		Dust.Parent = workspace.World.Visuals
		Dust.Particle.SpreadAngle = Vector2.new(-360, 360)
		Dust.Size = Vector3.new(0,0,0)
		Dust.Particle.EmissionDirection = "Back"
		Dust.Particle.Speed = NumberRange.new(60)
		Dust.Particle.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 3)}
		Dust.Particle.Lifetime = NumberRange.new(1.5)
		Dust.Particle.Drag = 2
		Dust.Particle.Enabled = true
		Dust.Particle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		Dust.Particle:Clear()

		VfxHandler.Emit(Dust.Particle,100)
		Debris:AddItem(Dust, 3)

		local Dust2 = Effects.Dust:Clone()
		Dust2.CFrame = contactPointCFrame * CFrame.new(0,-1,0)
		Dust2.Parent = workspace.World.Visuals
		Dust2.Particle.SpreadAngle = Vector2.new(0, 180)
		Dust2.Size = Vector3.new(0,0,0)
		Dust2.Particle.EmissionDirection = "Back"
		Dust2.Particle.Speed = NumberRange.new(50)
		Dust2.Particle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		Dust2.Particle.Lifetime = NumberRange.new(1)
		Dust2.Particle.Enabled = true
		Dust2.Particle:Clear()
		Dust2.Particle:Emit(100)
		Debris:AddItem(Dust2, 2)

		local GroundDebris = Effects.grounddebris:Clone()
		GroundDebris.CFrame = contactPointCFrame
		GroundDebris.Parent = workspace.World.Visuals
		GlobalFunctions.TweenFunction({
			["Instance"] = GroundDebris,
			["EasingStyle"] = Enum.EasingStyle.Quad,
			["EasingDirection"] = Enum.EasingDirection.Out,
			["Duration"] = .35,
		},{
			["Transparency"] = 1,
			["Size"] = GroundDebris.Size + Vector3.new(60,0,60),
		})

		Debris:AddItem(GroundDebris, .35)

		--
		local windshockwave = Effects.windshockwave:Clone()
		windshockwave.CFrame = contactPointCFrame
		windshockwave.Size = Vector3.new(10, 10, 10)
		windshockwave.Transparency = 0
		windshockwave.Material = "Neon"
		windshockwave.BrickColor = BrickColor.new("Pastel blue-green")
		windshockwave.Parent = workspace.World.Visuals

		local windshockwave2 = Effects.windshockwave2:Clone()
		windshockwave2.CFrame = contactPointCFrame
		windshockwave2.Size = Vector3.new(10, 10, 10)
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
			["Size"] = Vector3.new(80,80,80),
			["CFrame"] = windshockwave2.CFrame * CFrame.fromEulerAnglesXYZ(0,10,0)
		})

		GlobalFunctions.TweenFunction({
			["Instance"] = windshockwave,
			["EasingStyle"] = Enum.EasingStyle.Quad,
			["EasingDirection"] = Enum.EasingDirection.Out,
			["Duration"] = .35,
		},{
			["Transparency"] = 1,
			["Size"] = Vector3.new(80,80,80),
			["CFrame"] = windshockwave.CFrame * CFrame.fromEulerAnglesXYZ(0,10,0)
		})

		Debris:AddItem(windshockwave2, .35)
		Debris:AddItem(windshockwave, .35)


		local Result = workspace:Raycast(Root.Position, Root.CFrame.upVector * -15, raycastParams)
		if Result and Result.Instance then
			Dust.Particle.Color = ColorSequence.new(Result.Instance.Color)
			Dust2.Particle.Color = ColorSequence.new(Result.Instance.Color)

			Dust.Position = Result.Position
			Dust2.Position = Result.Position

			for _ = 1, 10 do
				local Rock = Effects.Rock:Clone()
				Rock.Position = Result.Position
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
	end,

	["WhirlWindRelease"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		for Index = 1, 9 do
			-- SoundManager:AddSound("Lightning_Release",{Parent = Root, Volume = 4},"Client")

			-- SoundManager:AddSound("LightningExplosion2",{Parent = Root,Volume = 2},"Client")

			if GlobalFunctions.CheckDistance(Player, 35) then
				GlobalFunctions.FreshShake(100,30,1,.2,0)
			end

			local ColorIndex = Index >= 4 and Color3.fromRGB(117, 237, 255) or Color3.fromRGB(255,255,255)

			coroutine.resume(coroutine.create(function()
				for _ = 1, 3 do
					local OriginalPosition = Root.Position

					local Orbie = Effects.block:Clone()
					Orbie.Size = Vector3.new(2, 2, 20)
					Orbie.Material = "Neon"
					Orbie.Color = ColorIndex
					Orbie.Transparency = 0
					Orbie.CFrame = CFrame.new(OriginalPosition + Vector3.new(math.random(-1,1),math.random(-1,1),math.random(-1,1)), OriginalPosition)

					local SpecialMesh = Instance.new("SpecialMesh")
					SpecialMesh.MeshType = "Sphere"
					SpecialMesh.Parent = Orbie

					Orbie.Parent = workspace.World.Visuals

					GlobalFunctions.TweenFunction({
						["Instance"] = Orbie,
						["EasingStyle"] = Enum.EasingStyle.Quad,
						["EasingDirection"] = Enum.EasingDirection.Out,
						["Duration"] = .35,
					},{
						["Size"] = Orbie.Size + Vector3.new(0,0,math.random(1.8,3.5)),
						["CFrame"] = Orbie.CFrame * CFrame.new(0,0,40)
					})

					GlobalFunctions.TweenFunction({
						["Instance"] = Orbie,
						["EasingStyle"] = Enum.EasingStyle.Quad,
						["EasingDirection"] = Enum.EasingDirection.Out,
						["Duration"] = .35,
					},{
						["Transparency"] = .8,
						["Size"] = Vector3.new(0,0,.8)
					})

					Debris:AddItem(Orbie,.35)
				end
			end))
			local Slash = Effects.slash:Clone()
			Slash.Material = "Neon"
			Slash.Color = math.random(1,2) == 1 and Color3.fromRGB(117, 237, 255) or Color3.fromRGB(255,255,255)
			Slash.Size = Vector3.new(5,5,5)
			Slash.CFrame = Root.CFrame * CFrame.fromEulerAnglesXYZ(math.random(-360,360),math.random(-360,360),math.random(-360,360))
			Slash.Transparency = 0
			Slash.Parent = workspace.World.Visuals

			GlobalFunctions.TweenFunction({
				["Instance"] = Slash,
				["EasingStyle"] = Enum.EasingStyle.Quad,
				["EasingDirection"] = Enum.EasingDirection.Out,
				["Duration"] = .25,
			},{
				["Transparency"] = 1,
				["Size"] = Vector3.new(30,30,30)
			})

			Debris:AddItem(Slash, .25)

			local SwingShockwave = Effects.SwingShockwave:Clone()
			SwingShockwave.Color = ColorIndex
			SwingShockwave.Material = "Neon"
			SwingShockwave.CFrame = Root.CFrame
			SwingShockwave.Rotation = Vector3.new(math.random(-60,60) * Index,math.random(-60,60) * Index, math.random(-60,60) * Index)
			SwingShockwave.Parent = workspace.World.Visuals

			GlobalFunctions.TweenFunction({
				["Instance"] = SwingShockwave,
				["EasingStyle"] = Enum.EasingStyle.Quad,
				["EasingDirection"] = Enum.EasingDirection.Out,
				["Duration"] = .25,
			},{
				["Transparency"] = 1,
				["Size"] = Vector3.new(50, 0.05, 50),
				["CFrame"] = SwingShockwave.CFrame * CFrame.fromEulerAnglesXYZ(0,10,0)
			})

			Debris:AddItem(SwingShockwave,.25)

			local Ring = Effects.ring:Clone()
			Ring.Color = math.random(1,2) == 1 and Color3.fromRGB(117, 237, 255) or Color3.fromRGB(255,255,255)
			Ring.Material = "Neon"
			Ring.Transparency = 0
			Ring.CFrame = Root.CFrame
			Ring.Size = Vector3.new(5,1,5)
			Ring.Parent = workspace.World.Visuals

			local OutRing = Ring:Clone()
			OutRing.Material = "Neon"
			OutRing.Color = ColorIndex
			OutRing.Size = Vector3.new(10,1,10)
			OutRing.CFrame = Root.CFrame * CFrame.new(0,5,0) * CFrame.fromEulerAnglesXYZ(math.random(-360,360),math.random(-360,360),math.random(-360,360))
			OutRing.Parent = Ring

			Debris:AddItem(Ring, 1)

			GlobalFunctions.TweenFunction({["Instance"] = Ring,["EasingStyle"] = Enum.EasingStyle.Quart,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .5,},{["Size"] = Vector3.new(15,1,15), ["CFrame"] = Ring.CFrame * CFrame.fromEulerAnglesXYZ(0,100,0)})
			GlobalFunctions.TweenFunction({["Instance"] = OutRing,["EasingStyle"] = Enum.EasingStyle.Quart,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .5,},{["Size"] = Vector3.new(30,1,30),["CFrame"] = OutRing.CFrame * CFrame.fromEulerAnglesXYZ(0,100,0)})

			GlobalFunctions.TweenFunction({["Instance"] = Ring,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .25,},{["Transparency"] = 1, ["CFrame"] = Ring.CFrame * CFrame.fromEulerAnglesXYZ(0,100,0)})
			GlobalFunctions.TweenFunction({["Instance"] = OutRing,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .25,},{["Transparency"] = 1, ["CFrame"] = OutRing.CFrame * CFrame.fromEulerAnglesXYZ(0,100,0)})
			wait(.15)
		end
	end,

	["Skateboard"] = function(PathData)
		local Character = PathData.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		local Skateboard = PathData.Skateboard
		local LastRushEff = 0;

		-- SoundManager:AddSound("StandSummon", {Parent = Skateboard, Volume = 1.75}, "Client")
		-- local Sound = SoundManager:AddSound("Skateboard", {Parent = Root, Volume = .5, TimePosition = .1}, "Client")

		local Sparks = Particles["PE1"]:Clone()
		Sparks:Emit(35)
		Sparks.Parent = Skateboard

		Debris:AddItem(Sparks,1)

		local Result = workspace:Raycast(Root.Position, Root.CFrame.upVector * -15, raycastParams)
		if Result and Result.Instance then
			local DirtStep = ReplicatedStorage.Assets.Effects.Particles.DirtStep:Clone()
			DirtStep.ParticleEmitter.Enabled = true
			DirtStep.CFrame = Root.CFrame * CFrame.new(0,-1.85,.225)
			DirtStep.ParticleEmitter.Rate = 12
			DirtStep.ParticleEmitter.Color = ColorSequence.new(Result.Instance.Color)
			DirtStep.Parent = Root

			local WeldConstraint = Instance.new("WeldConstraint");
			WeldConstraint.Part0 = Root
			WeldConstraint.Part1 = DirtStep;
			WeldConstraint.Parent = DirtStep

			Trash[#Trash + 1] = DirtStep
		end

		--HUD.RushEffect.ImageTransparency = 1 - (300 -20) / 250;

		while wait() do
			VfxHandler.ImpactLines({Character = Character, Amount = 1, Color = BrickColor.new("Really black")})
		--[[if os.clock() - LastRushEff > .1 then
				LastRushEff = os.clock()
				HUD.RushEffect.Rotation = math.random() * 360
			end ]]
			if Root:FindFirstChild("SkateBoard") == nil then break end
		end
	--	HUD.RushEffect.ImageTransparency = 1;
		-- Sound:Destroy()
		-- SoundManager:AddSound("StandPoof", {Parent = Root, Volume = 1}, "Client")

		local Sparks = Particles["PE1"]:Clone()
		Sparks:Emit(35)
		Sparks.Parent = Skateboard

		Debris:AddItem(Sparks,1)

		if Root:FindFirstChild("DirtStep") then
			if Root.DirtStep:FindFirstChild("ParticleEmitter") then
				Root.DirtStep.ParticleEmitter.Enabled = false
			end
		end
		wait(1)
		RemoveTrash(Trash)
	end,

	["LightningPalmAOE"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		-- SoundManager:AddSound("LightningExplosion", {Parent = Root, Volume = math.random(4,5)}, "Client")
		Explosions.LightningPalm({Character = Character})
	end,

	["ThunderPalmRelease"] = function(BackData)
		local Character = BackData.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")
		VfxHandler.RemoveBodyMover(Character)

		-- SoundManager:AddSound("LightningExplosion", {Parent = Root, Volume = 2.5}, "Client")

		local Result = workspace:Raycast(Root.Position, Root.CFrame.upVector * -15, raycastParams)
		if Result and Result.Instance then
			local Clone = Particles.LightningBeamParticles:Clone()
			Clone.Transparency = 1
			Clone.CFrame = Root.CFrame * CFrame.new(0,2,1)

			Clone.Anchored = false
			Clone.CanCollide = true

			Clone.Attachment.Rocks:Emit(15)
			Clone.Smoke:Emit(10)
			Clone.Smoke.Color = ColorSequence.new(Result.Instance.Color)
			Clone.Parent = workspace.World.Visuals

			Debris:AddItem(Clone,3)
		end

		local Circle = Effects.CircleRing:Clone()
		Circle.Transparency = 0
		Circle.Material = Enum.Material.Neon
		Circle.CFrame = Root.CFrame * CFrame.Angles(math.rad(89.84),math.rad(180),math.rad(180))* CFrame.new(0,5,0)

		Circle.Size = Vector3.new(12.679, 0.055, 12.8)
		Circle.BrickColor = BrickColor.new("Pastel blue-green")
		Circle.CanCollide = false

		Circle.Parent = workspace.World.Visuals
		Debris:AddItem(Circle,.5)

		GlobalFunctions.TweenFunction({["Instance"] = Circle, ["EasingStyle"] = Enum.EasingStyle.Quad, ["EasingDirection"] = Enum.EasingDirection.Out, ["Duration"] = .35,},{["Transparency"] = 1;})

		wait(.05)
		local Beam = workspace.World.Visuals:FindFirstChild(Character.Name.. " - ThunderBeam")

		local PointLight = Instance.new("PointLight")
		PointLight.Color = Color3.fromRGB(110, 153, 202)
		PointLight.Brightness = 20
		PointLight.Range = 40;

		PointLight.Parent = Beam
		Debris:AddItem(PointLight,.2)

		local PointLight2 = Instance.new("PointLight")
		PointLight2.Color = Color3.fromRGB(110, 153, 202)
		PointLight2.Brightness = 10
		PointLight2.Range = 40

		PointLight2.Parent = Root
		Debris:AddItem(PointLight2,.2)

		for _ = 1, 10 do
			local startPos = Root.Position
			local endPos = (Beam.CFrame * CFrame.new(0,0,-5)).p
			local amount = 15
			local width = .5
			local offsetRange = 2

			local Model = VfxHandler.Lightning({
				StartPosition = startPos,
				EndPosition = endPos,
				Amount = amount,
				Width = width,
				OffsetRange = offsetRange,
				Color = "Pastel blue-green"
			})

			for _,Part in ipairs(Model:GetChildren()) do
				GlobalFunctions.TweenFunction({["Instance"] = Part,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.In,["Duration"] = .1,},{["Size"] = Vector3.new(0,0,0)})
			end

			Debris:AddItem(Model, .1)
			Debris:AddItem(PointLight, .1)

			PointLight2.Brightness = PointLight2.Brightness - 1
			PointLight.Brightness = PointLight.Brightness - 1
			wait(.01)
		end
	end;

	["LightningDash"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		local Light = Instance.new("PointLight")
		Light.Color = Color3.fromRGB(110, 153, 202)
		Light.Brightness = 10
		Light.Range = 40
		Light.Parent = Root

		local Result = workspace:Raycast(Root.Position, Root.CFrame.upVector * -15, raycastParams)
		if Result and Result.Instance then
			local DirtStep = Particles.LightningSmokeDash:Clone()
			DirtStep.ParticleEmitter.Enabled = true
			DirtStep.CFrame = Root.CFrame * CFrame.new(0,-1.85,.225)
			DirtStep.ParticleEmitter.Color = ColorSequence.new(Result.Instance.Color)
			DirtStep.CanCollide = false
			DirtStep.Parent = Root

			local WeldConstraint = Instance.new("WeldConstraint");
			WeldConstraint.Part0 = Root
			WeldConstraint.Part1 = DirtStep;
			WeldConstraint.Parent = DirtStep

			delay(1,function() DirtStep.ParticleEmitter.Enabled = false end)
			Debris:AddItem(DirtStep,2)
		end

		local Max = 200
		wait(.425)
		for _ = 1,10 do
			local Max = Max - 10
			local startPos = Data.ContactPointCFrame.p
			local endPos = Character.HumanoidRootPart.CFrame.p
			local amount = 10
			local width = .5
			local offsetRange = 2

			local Model = VfxHandler.Lightning({
				StartPosition = startPos,
				EndPosition = endPos,
				Amount = amount,
				Width = width,
				OffsetRange = offsetRange,
				Color = "Pastel blue-green"
			})

			for _,Part in ipairs(Model:GetChildren()) do
				Part.CanCollide = false
				GlobalFunctions.TweenFunction({["Instance"] = Part,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.In,["Duration"] = .1,},{["Size"] = Vector3.new(0,0,0)})
			end
			Debris:AddItem(Model, .1)
			Debris:AddItem(Light, .1)
			Light.Brightness = Light.Brightness - 1
			wait(.01)
		end
	end,

	["LightningPalmStart"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		local attach = Character["Right Arm"]:FindFirstChild("RightGripAttachment")

		local Lightning = ReplicatedStorage.Assets.Effects.Misc.LIGHTNING:Clone()
		Lightning.Parent = Root
		Debris:AddItem(Lightning,.1)

		local x,y,z = 5,5,5
		for i = 1,6 do
			local attach2 = Instance.new("Attachment")
			attach2.Parent = Character["Right Arm"]
			attach2.Position = Vector3.new(math.random(-x,x),math.random(-y,y),math.random(-z,z))
			local bolt = LightningModule.new(attach, attach2, 40)
			bolt.CanCollide = false
			bolt.PulseSpeed = 2
			bolt.PulseLength = 0.5
			bolt.FadeLength = 0.25
			if (i % 2 == 0) then
				bolt.Color = Color3.fromRGB(110, 153, 202)
			else
				bolt.Color = Color3.fromRGB(117, 237, 255)
			end
			Debris:AddItem(attach2,1)
		end

		for _ = 1,2 do
			local RightArm = ReplicatedStorage.Assets.Models.Misc.FakeArm:Clone()
			RightArm.CFrame = Character["Right Arm"].CFrame
			RightArm.Orientation = Character["Right Arm"].Orientation
			RightArm.CanCollide = false

			RightArm.Material = "Neon";
			RightArm.Anchored = false
			RightArm.Color = Color3.fromRGB(125, 227, 255)

			RightArm.Size = Character["Right Arm"].Size + Vector3.new(.035,.035,.035)
			RightArm.Transparency = .6
			RightArm.Parent = workspace.World.Visuals

			Debris:AddItem(RightArm,3)

			local LeftArm = ReplicatedStorage.Assets.Models.Misc.FakeArm:Clone()
			LeftArm.CFrame = Character["Left Arm"].CFrame
			LeftArm.Orientation = Character["Left Arm"].Orientation
			LeftArm.CanCollide = false

			LeftArm.Material = "Neon";
			LeftArm.Anchored = false
			LeftArm.Color = Color3.fromRGB(125, 227, 255)

			LeftArm.Size = Character["Left Arm"].Size + Vector3.new(.035,.035,.035)
			LeftArm.Transparency = .6
			LeftArm.Parent = workspace.World.Visuals

			Debris:AddItem(LeftArm,3)

			TaskScheduler:AddTask(.35,function()
				GlobalFunctions.TweenFunction({["Instance"] = RightArm, ["EasingStyle"] = Enum.EasingStyle.Quad, ["EasingDirection"] = Enum.EasingDirection.Out, ["Duration"] = .5,},{["Transparency"] = 1;})
				GlobalFunctions.TweenFunction({["Instance"] = LeftArm, ["EasingStyle"] = Enum.EasingStyle.Quad, ["EasingDirection"] = Enum.EasingDirection.Out, ["Duration"] = .5,},{["Transparency"] = 1;})
			end)

			local WeldConstraint = Instance.new("WeldConstraint")
			WeldConstraint.Part0 = Character["Right Arm"]
			WeldConstraint.Part1 = RightArm
			WeldConstraint.Parent = RightArm

			local WeldConstraint = Instance.new("WeldConstraint")
			WeldConstraint.Part0 = Character["Left Arm"]
			WeldConstraint.Part1 = LeftArm
			WeldConstraint.Parent = LeftArm

			-- SoundManager:AddSound("LightningSizzle", {Parent = Root, Volume = 5.5}, "Client")
			wait(.15)
		end
	end,

	["Snake Awakens"] = function(PathData)
		local Character = PathData.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		local Part = Instance.new("Part")
		Part.Transparency = 1
		Part.Name = "SnakeAwakenCFramePoint"
		Part.CFrame = Root.CFrame * CFrame.new(0,1,-5)
		Part.CanCollide = false
		Part.Massless = true
		Part.Parent = workspace.World.Visuals

		local WeldConstraint = Instance.new("WeldConstraint");
		WeldConstraint.Part0 = Root
		WeldConstraint.Part1 = Part;
		WeldConstraint.Parent = Part

		coroutine.resume(coroutine.create(function()
			for _ = 1,20 do
				wait(.13)
				local Clone = Effects.Cuts["CrescentCut3"]:Clone()
				Clone.Size = Vector3.new(7.95, .35, 7.95) -- 49 = Y, X and Z = .84
				Clone.CFrame = Part.CFrame * CFrame.Angles(math.random(-.65,14.59),math.random(-128.24,-117.79),math.random(-14.3,8.39))
				Clone.Parent = workspace.World.Visuals

				Debris:AddItem(Clone,.5)
				GlobalFunctions.TweenFunction({["Instance"] = Clone, ["EasingStyle"] = Enum.EasingStyle.Quad, ["EasingDirection"] = Enum.EasingDirection.Out, ["Duration"] = .15,},{["CFrame"] = Part.CFrame * CFrame.Angles(math.random(-.65,14.59),math.random(-128.24,-117.79),math.random(-14.3,8.39)); ["Transparency"] = 1;})

				GlobalFunctions.TweenFunction({["Instance"] = Clone, ["EasingStyle"] = Enum.EasingStyle.Quad, ["EasingDirection"] = Enum.EasingDirection.Out, ["Duration"] = .2,},{["Transparency"] = 1;})
			end
		end))

		for _ = 1,25 do
			wait(.1)
			local Clone = Effects.Cuts["CrescentCut3"]:Clone()
			Clone.Size = Vector3.new(7.95, 0.35, 7.95) -- 49 = Y, X and Z = .84
			Clone.CFrame = Part.CFrame * CFrame.Angles(math.random(-.65,14.59),math.random(-128.24,-117.79),math.random(-14.3,8.39))
			Clone.Parent = workspace.World.Visuals

			Debris:AddItem(Clone,.5)-- up 2, down 3

			-- SoundManager:AddSound("SteamHiss",{Parent = Root, Volume = .5, Looped = true}, "Client", {Duration = .75})
			GlobalFunctions.TweenFunction({["Instance"] = Clone, ["EasingStyle"] = Enum.EasingStyle.Quad, ["EasingDirection"] = Enum.EasingDirection.Out, ["Duration"] = .15,},{["CFrame"] = Part.CFrame * CFrame.Angles(math.random(-.65,14.59),math.random(-128.24,-117.79),math.random(-14.3,8.39)); ["Transparency"] = 1;})

			GlobalFunctions.TweenFunction({["Instance"] = Clone, ["EasingStyle"] = Enum.EasingStyle.Quad, ["EasingDirection"] = Enum.EasingDirection.Out, ["Duration"] = .2,},{["Transparency"] = 1;})
		end
		Part:Destroy()
	end,

	["Snake Awakens HitVFX"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		local Victim = Data.Victim
		local VRoot = Victim:FindFirstChild("HumanoidRootPart")

		VfxHandler.Orbies({Parent = VRoot, Size = Vector3.new(.4, .4, 5.79), Color = Color3.fromRGB(0,0,0), Speed = .35, Cframe = CFrame.new(0,0,0), Amount = 1, Sphere = true})
		VfxHandler.Orbies({Parent = VRoot, Size = Vector3.new(.35, .35, .35), Color = Color3.fromRGB(0,0,0), Speed = .35, Cframe = CFrame.new(0,0,3), Amount = 3, Circle = true})
	end
}

return KilluaVFX
