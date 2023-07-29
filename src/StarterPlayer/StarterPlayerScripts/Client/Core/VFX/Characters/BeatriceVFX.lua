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

local Metadata = Modules.Metadata
local Shared = Modules.Shared
local Utility = Modules.Utility

local HitPart2 = Models.Misc.HitPart2

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(Shared.SoundManager)
local RayService = require(Shared.RaycastManager.RayService)

local TaskScheduler = require(Utility.TaskScheduler)
local BezierModule = require(Utility.BezierModule)

local Explosions = require(Modules.Effects.Explosions)
local VfxHandler = require(Modules.Effects.VfxHandler)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Character = Player.Character or Player.CharacterAdded:Wait()

local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local Camera = workspace.CurrentCamera

local Humanoid = Character:WaitForChild("Humanoid")

local function RemoveTrash(Trash)
	for Index = 1,#Trash do
		local Item = Trash[Index]
		if Item and Item.Parent then
			Item:Destroy()
		end
	end
end

function GetMousePos(X,Y,Z,Boolean)
	local RayMag1 = workspace.CurrentCamera:ScreenPointToRay(X, Y) 

	local RayParam = RaycastParams.new()
	RayParam.FilterType = Enum.RaycastFilterType.Exclude
	RayParam.FilterDescendantsInstances = { Character, workspace.World.Visuals }

	local RaycastResult = workspace:Raycast(RayMag1.Origin, RayMag1.Direction * (Z or 200))
	local Target, Position, Surface = RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal

	if Boolean then
		return Position,Target,Surface
	else
		return Position
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {Character, workspace.World.Visuals}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function CreateRock(Result)
	local Size = 2 + 1 * math.random()

	local Rock = Instance.new("Part")
	Rock.Material = Result.Material
	Rock.Size = Vector3.new(1,1,1) * Size

	Rock.Anchored = true
	Rock.CanCollide = false
	Rock.Position = Result.Position - Vector3.new(0,Rock.Size.Y,0)

	Rock.Color = Result.Instance.Color
	Rock.Orientation = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100))

	Rock.Parent = workspace.World.Visuals
	Debris:AddItem(Rock, 3)

	local Tween = TweenService:Create(Rock, TweenInfo.new(.35, Enum.EasingStyle.Linear), {Position = Result.Position})
	Tween:Play()
	Tween:Destroy()

	TaskScheduler:AddTask(1, function()
		local Tween = TweenService:Create(Rock, TweenInfo.new(.5, Enum.EasingStyle.Linear), {Position = Result.Position - Vector3.new(0,Rock.Size.Y,0), Orientation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360)), Size = Vector3.new(0,0,0)})
		Tween:Play()
		Tween:Destroy()
	end)
end

local BeatriceVFX = {
	
	["bezierballs"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")
		
		local MousePosition,Part,Surface = GetMousePos(Mouse.X,Mouse.Y,500,true)
		
		local BallTing = script.beizerBalls[Data.WhichBall]:Clone()
		BallTing.Trail.Color = ColorSequence.new(BallTing.Color)
		BallTing.CFrame = Root.CFrame * CFrame.Angles(math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)))
		BallTing.Rocket.Target = Data.Victim:FindFirstChild("HumanoidRootPart")
		BallTing.Velocity = Vector3.new(math.random(-75, 75), math.random(25, 75), math.random(-75, 75))
		BallTing.Rocket.MaxSpeed = math.random(75, 125)
		BallTing.Parent = workspace.World.Visuals
		
		Debris:AddItem(BallTing,3)
		
		-- SoundManager:AddSound("Woosh", {Parent = BallTing, Volume = 2}, "Client")
		VfxHandler.FakeBodyPart({Character = Character,Object = "Right Arm", Material = "Neon",Color = script.beizerBalls[Data.WhichBall].Color, Transparency = 1, Duration = 1, Delay = .1,})

		local CFrameCalc = CFrame.new(Root.CFrame.p) * CFrame.new(0, -2, 0);
		VfxHandler.Beam(CFrameCalc, 15, 0, .25, ColorSequence.new(BrickColor.new("Pastel light blue").Color, Color3.fromRGB(script.beizerBalls[Data.WhichBall].Color)), 1, 15, 50, nil, NumberSequence.new(0.8, 1))		
		
		for _ = 1,3 do
			local slash = ReplicatedStorage.Assets.Effects.Meshes.ThreeDSlashEffect:Clone()
			local size = math.random(2,4) * 4
			local sizeadd = math.random(2,4) * 24
			local x,y,z = math.rad(math.random(8,12) * 30), math.rad(math.random(8,12) * 30), math.rad(math.random(8,12) * 30)
			local add = math.random(1,2)
			if add == 2 then
				add = -1
			end
			slash.Transparency = .4
			slash.Size = Vector3.new(2,size,size)
			slash.CFrame = Root.CFrame*CFrame.Angles(x,y,z)
			slash.Parent = workspace.World.Visuals
			
			local B5 = TweenInfo.new(.3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

			local Tween = TweenService:Create(slash,B5,{Transparency = 1,CFrame = slash.CFrame * CFrame.Angles(math.pi * add,0,0),Size = slash.Size+Vector3.new(0,sizeadd,sizeadd)})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(slash,.3)
		end		
		
		coroutine.resume(coroutine.create(function()
			wait(.2)
			local _ = BallTing:FindFirstChild("Rocket") and BallTing.Rocket:Fire()
			local Connection; Connection = BallTing.Rocket.ReachedTarget:Connect(function()
				
				BallTing.Transparency = 1

				Connection:Disconnect()
				Connection = nil

				Debris:AddItem(BallTing, 2)
				
				local Color = script.beizerBalls[Data.WhichBall].Color
				Explosions.bezierballs({Color = Color, Character = Character, Position = BallTing.Position, Ball = BallTing, Distance = Data.Distance})
			end)
		end))
	end,
	
	["boingzz"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		VfxHandler.FakeBodyPart({Character = Character,Object = "Left Leg", Material = "Neon",Color = Color3.fromRGB(177, 177, 177), TweenColor = Color3.fromRGB(136, 136, 136),Transparency = 1,Duration = 1,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Character,Object = "Left Arm", Material = "Neon",Color = Color3.fromRGB(177, 177, 177), TweenColor = Color3.fromRGB(136, 136, 136),Transparency = 1,Duration = 1,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Character,Object = "Torso", Material = "Neon",Color = Color3.fromRGB(177, 177, 177), TweenColor = Color3.fromRGB(136, 136, 136),Transparency = 1,Duration = 1,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Character,Object = "Right Leg", Material = "Neon",Color = Color3.fromRGB(177, 177, 177), TweenColor = Color3.fromRGB(136, 136, 136),Transparency = 1,Duration = 1,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Character,Object = "Right Arm", Material = "Neon",Color = Color3.fromRGB(177, 177, 177), TweenColor = Color3.fromRGB(136, 136, 136),Transparency = 1,Duration = 1,Delay = .1,})
				
		coroutine.resume(coroutine.create(function()
			local CFrameCalc = CFrame.new(Root.CFrame.p) * CFrame.new(0, -2, 0);
			VfxHandler.Beam(CFrameCalc, 15, 0, .25, ColorSequence.new(BrickColor.new("Pastel light blue").Color, Color3.fromRGB(255, 255, 255)), 1, 15, 50, nil, NumberSequence.new(0.8, 1))

			for Index = 1,4 do
				local shockWave = script.tekkaip.Attachment.Shockwave:Clone();
				shockWave.Parent = Root
				VfxHandler.Emit(shockWave,1)

				Debris:AddItem(shockWave, 5)
				wait(.1)	
			end
		end))

		for Index = 1,6 do
			local ReflectBoing = script.boinggz.Attachment.ParticleEmitter:Clone()
			ReflectBoing.Parent = workspace.World.Visuals:FindFirstChild(Character.Name.." beatrice barrier")
			ReflectBoing:Emit(1)

			Debris:AddItem(ReflectBoing,1)
			wait()	
		end

		-- SoundManager:AddSound("forcefieldhit"..math.random(1,4), {Parent = Root}, "Client", {Player = nil, Distance = nil})
	end,

	["removbal"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		local ShamacSmoke = script.fresh:Clone()
		ShamacSmoke.CFrame = Root.CFrame
		ShamacSmoke.Parent = workspace.World.Visuals

		VfxHandler.Emit(ShamacSmoke.Star,80) -- 80
		VfxHandler.Emit(ShamacSmoke.Void,10) -- 10

		Debris:AddItem(ShamacSmoke,2)

		local Ball = ReplicatedStorage.Assets.Effects.Meshes.regball:Clone()
		Ball.Material = Enum.Material.ForceField
		Ball.Transparency = 0
		Ball.CFrame = Root.CFrame
		Ball.Size = Vector3.new(5,5,5)
		Ball.Color = Color3.fromRGB(0, 0, 0)
		Ball.Parent = workspace.World.Visuals

		local Tween = TweenService:Create(Ball, TweenInfo.new(.35, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {["Size"] = Vector3.new(45,45,45), ["Transparency"] = 1})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(Ball,3)	

		VfxHandler.Orbies({Parent = Root, Speed = .5, Size = Vector3.new(1, 1, 12), Color = Color3.fromRGB(0,0,0), Cframe = CFrame.new(0,0,15), Amount = 10, Sphere = true})
		-- SoundManager:AddSound("StandPoof", {Parent = Root, Volume = .35}, "Client")
	end,

	["cast shield"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("Torso")

		-- SoundManager:AddSound("GigCast", {Parent = Root, Volume = 1.75}, "Client")
		
		TaskScheduler:AddTask(.25,function()
			local CelebrationParticle = Particles.ParticleAttatchments.LevelUpCelebration:Clone()
			CelebrationParticle.Parent = Root

			VfxHandler.Emit(CelebrationParticle.BigStars,1)
			VfxHandler.Emit(CelebrationParticle.Dots,5)
			VfxHandler.Emit(CelebrationParticle.Stars,10)

			Debris:AddItem(CelebrationParticle,3)

			local CelebrateParticle = Particles.CelebrateRoot:Clone()
			CelebrateParticle.Parent = workspace.World.Visuals

			VfxHandler.Emit(CelebrateParticle.Stars,12)
			Debris:AddItem(CelebrateParticle,3)
		end)

		for Index = 1,2 do
			local Ball = ReplicatedStorage.Assets.Effects.Meshes.regball:Clone()
			Ball.Material = Enum.Material.ForceField
			Ball.Transparency = 0
			Ball.CFrame = Root.CFrame
			Ball.Size = Vector3.new(5,5,5)
			Ball.Color = Color3.fromRGB(0, 0, 0)
			Ball.Parent = workspace.World.Visuals

			local Tween = TweenService:Create(Ball, TweenInfo.new(2.35, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {["Size"] = Vector3.new(15,15,15), ["Transparency"] = 1})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(Ball,3)	
			wait(.2)	
		end
			
		VfxHandler.FakeBodyPart({Character = Character,Object = "Left Leg", Material = "Neon",Color = Color3.fromRGB(177, 177, 177), TweenColor = Color3.fromRGB(136, 136, 136),Transparency = 1,Duration = 1,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Character,Object = "Left Arm", Material = "Neon",Color = Color3.fromRGB(177, 177, 177), TweenColor = Color3.fromRGB(136, 136, 136),Transparency = 1,Duration = 1,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Character,Object = "Torso", Material = "Neon",Color = Color3.fromRGB(177, 177, 177), TweenColor = Color3.fromRGB(136, 136, 136),Transparency = 1,Duration = 1,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Character,Object = "Right Leg", Material = "Neon",Color = Color3.fromRGB(177, 177, 177), TweenColor = Color3.fromRGB(136, 136, 136),Transparency = 1,Duration = 1,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Character,Object = "Right Arm", Material = "Neon",Color = Color3.fromRGB(177, 177, 177), TweenColor = Color3.fromRGB(136, 136, 136),Transparency = 1,Duration = 1,Delay = .1,})
		
		local Part = Instance.new("Part")
		Part.CFrame = Root.CFrame * CFrame.new(0,0,-2)
		Part.Transparency = 1
		Part.Name = Character.Name.." beatrice barrier"
		Part.CanCollide = false
		Part.Size = Vector3.new(6.059, 5.662, 0.05)
		Part.Parent = workspace.World.Visuals

		local WeldConstraint = Instance.new("WeldConstraint")
		WeldConstraint.Part0 = Part
		WeldConstraint.Part1 = Root
		WeldConstraint.Parent = Part

		Debris:AddItem(Part,4)

		local Star = script.fresh.Star:Clone()
		Star.Color = ColorSequence.new(Color3.fromRGB(0,0,0))
		Star.Parent = Root

		VfxHandler.Emit(Star,30)
		
		Debris:AddItem(Star,1.15)
		
		while Character:FindFirstChild("ForceField") do
			RunService.Heartbeat:Wait()
		end
		Part:Destroy()
	end,

	["brekapart"] = function(Data)
		local Character,Victim = Data.Character, Data.Victim

		local Root,VRoot = Character:FindFirstChild("HumanoidRootPart"),Victim:FindFirstChild("HumanoidRootPart") 

		local Smoke = script.smokking:Clone()
		Smoke.Parent = VRoot

		TaskScheduler:AddTask(.75,function()
			Smoke.Enabled = false
		end)

		Debris:AddItem(Smoke,1 + .2)

		VfxHandler.Emit(Smoke,12)

		-- SoundManager:AddSound("icey", {Parent = Root, Volume = 3}, "Client")

		for _,v in ipairs(Victim:GetChildren()) do
			if v.Name == "FakeBodyPart" then
				v:Destroy()
			end
		end

		for _ = 1,math.random(8,10) do
			local x,y,z = math.cos(math.rad(math.random(1,6) * 60)),math.cos(math.rad(math.random(1,6 ) * 60)),math.sin(math.rad(math.random(1,6) * 60))
			local Start = VRoot.Position
			local End = Start + Vector3.new(x,y,z)

			local Orbie = Effects.MeshOribe:Clone()
			Orbie.Color = Color3.fromRGB(0,0,0)
			Orbie.CFrame = CFrame.new(Start,End)
			Orbie.Size = Vector3.new(1,2,1)

			local OrbieTweenInfo = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

			local Tween = TweenService:Create(Orbie,OrbieTweenInfo,{CFrame = CFrame.new(Start,End) * CFrame.new(0,0,-(math.random(2,5) * 10)),Size = Vector3.new(0,0,24)})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(Orbie,.2)
			Orbie.Parent = workspace.World.Visuals
		end
	end,

	["shamac~hit"] = function(Data)
		local Character,Victim = Data.Character, Data.Victim

		local Root,VRoot = Character:FindFirstChild("HumanoidRootPart"),Victim:FindFirstChild("HumanoidRootPart") 

		local Smoke = script.smokking:Clone()
		Smoke.Parent = VRoot

		TaskScheduler:AddTask(.75,function()
			Smoke.Enabled = false
		end)

		Debris:AddItem(Smoke,1 + .2)

		VfxHandler.Emit(Smoke,12)	
		VfxHandler.FakeBodyPart({Character = Victim,Object = "Left Leg", Material = "Glass",Color = Color3.fromRGB(177, 66, 52), TweenColor = Color3.fromRGB(83, 78, 136),Transparency = 1,Duration = 4,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Victim,Object = "Right Arm", Material = "Glass",Color = Color3.fromRGB(165, 35, 35), TweenColor = Color3.fromRGB(100, 94, 165),Transparency = 1,Duration = 4,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Victim,Object = "Torso", Material = "Glass",Color = Color3.fromRGB(255, 29, 29), TweenColor = Color3.fromRGB(66, 47, 93),Transparency = 1,Duration = 4,Delay = .1,})
		
		local RaycastResult = workspace:Raycast(Root.Position, Root.CFrame.upVector * -15, raycastParams)
		if RaycastResult and RaycastResult.Instance then
			for Index = 1,2 do
				local RingTing = ReplicatedStorage.Assets.Effects.Meshes.RingInnit:Clone()
				RingTing.Material = RaycastResult.Material
				RingTing.Color = RaycastResult.Instance.Color
				RingTing.Anchored = true
				RingTing.CFrame = VRoot.CFrame * CFrame.new(0,-3,0)
				RingTing.Size = Vector3.new(15,.05,15)
				RingTing.Transparency = .25;
				RingTing.Parent = workspace.World.Visuals				

				GlobalFunctions.TweenFunction({
					["Instance"] = RingTing,
					["EasingStyle"] = Enum.EasingStyle.Quad,
					["EasingDirection"] = Enum.EasingDirection.Out,
					["Duration"] = .5,
				},{
					["Transparency"] = 1,
					["Size"] = Vector3.new(22,.05,22),
				})

				Debris:AddItem(RingTing,1.25)
				wait(.25)
			end
		end
	end,

	["Push"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		local StartTime = os.clock()
		local RockInBetween = .1
		local LastRock = os.clock() - RockInBetween

		local FakeRoot = script.FakeHumanoid:Clone()
		FakeRoot.PrimaryPart.CFrame = Root.CFrame * CFrame.new(0,0,-10)
		FakeRoot.Parent = workspace.World.Visuals

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
		BodyVelocity.Velocity = CFrame.new(Root.Position,Root.Position + (Root.CFrame.lookVector * 10) + (Root.CFrame.upVector * -10) ).lookVector * 100
		BodyVelocity.Parent = FakeRoot.PrimaryPart
		Debris:AddItem(BodyVelocity,.25)

		Debris:AddItem(FakeRoot,1)

		coroutine.resume(coroutine.create(function()
			while os.clock() - StartTime < .5 do
				if os.clock() - LastRock >= RockInBetween then
					LastRock = os.clock()

					local Left = FakeRoot.PrimaryPart.CFrame * CFrame.new(-4,0,5)
					local Right = FakeRoot.PrimaryPart.CFrame * CFrame.new(4,0,5)

					local LeftRay = RayService:Cast(Left, Left * CFrame.new(0,-4,0), {workspace.World.Visuals, workspace.World.Live}, Enum.RaycastFilterType.Exclude)
					local RightRay = RayService:Cast(Right, Right * CFrame.new(0,-4,0), {workspace.World.Visuals, workspace.World.Live}, Enum.RaycastFilterType.Exclude)

					if LeftRay then
						CreateRock(LeftRay)
					end

					if RightRay then
						CreateRock(RightRay)
					end
				end
				RunService.RenderStepped:Wait()
			end
		end))

		local Result = workspace:Raycast(Root.Position, Root.CFrame.upVector * -15, raycastParams)
		if Result and Result.Instance then
			local Clone = Particles.LightningBeamParticles:Clone()
			Clone.Transparency = 1
			Clone.CFrame = Root.CFrame * CFrame.new(0,2,1)

			Clone.Anchored = false
			Clone.CanCollide = true

			Clone.Attachment.Rocks:Emit(3)
			Clone.Smoke:Emit(10)
			Clone.Smoke.Color = ColorSequence.new(Result.Instance.Color) 
			Clone.Parent = workspace.World.Visuals

			Debris:AddItem(Clone,3)
		end

		VfxHandler.KnockbackLines({
			MAX = 2,
			ITERATION = 5,
			WIDTH = 0.35,
			LENGTH = 10,
			SPEED = .85,
			COLOR1 = Color3.fromRGB(255, 255, 255),
			COLOR2 = Color3.fromRGB(255, 255, 255),
			STARTPOS = Root.CFrame * CFrame.new(0,-5,0),
			ENDGOAL = CFrame.new(0,0,-50),
		})	

		local End = Root.CFrame

		local Position1,Position2 = End.p,End.upVector * -200
		local cframe = End * CFrame.new(0,0,-25)

		local Swirl = ReplicatedStorage.Assets.Effects.Meshes.Swirl:Clone()
		Swirl.CFrame = cframe * CFrame.Angles(math.pi/2,0,0)
		Swirl.Size = Vector3.new(3,0,3)
		Swirl.Color = Color3.fromRGB(219, 219, 219)
		Swirl.Material = Enum.Material.Neon
		Swirl.Name =  Character.Name.." beatrice push swirl"
		Swirl.Parent = workspace.World.Visuals

		local shockwave5 = Effects.shockwave5:Clone()
		shockwave5.CFrame = Root.CFrame * CFrame.new(0, 0,-5) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
		shockwave5.Size = Vector3.new(20,20,20)
		shockwave5.Transparency = 0
		shockwave5.Material = "Neon"
		shockwave5.BrickColor = BrickColor.new("Institutional white")
		shockwave5.Parent = workspace.World.Visuals

		Debris:AddItem(shockwave5,.3)

		GlobalFunctions.TweenFunction({
			["Instance"] = shockwave5,
			["EasingStyle"] = Enum.EasingStyle.Quad,
			["EasingDirection"] = Enum.EasingDirection.Out,
			["Duration"] = .25,
		},{
			["Transparency"] = 1,
			["Size"] = Vector3.new(0,90,0),
		})

		local shockwaveOG = Effects.shockwaveOG:Clone()
		shockwaveOG.CFrame = Root.CFrame * CFrame.new(0, 0,-5) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
		shockwaveOG.Size = Vector3.new(15,5,15)
		shockwaveOG.Transparency = 0
		shockwaveOG.Material = "Neon"
		shockwaveOG.BrickColor = BrickColor.new("Institutional white")
		shockwaveOG.Parent = workspace.World.Visuals	

		GlobalFunctions.TweenFunction({
			["Instance"] = shockwaveOG,
			["EasingStyle"] = Enum.EasingStyle.Quad,
			["EasingDirection"] = Enum.EasingDirection.Out,
			["Duration"] = .3,
		},{
			["Transparency"] = 1,
			["Size"] = Vector3.new(0,0,0),
		})

		Debris:AddItem(shockwaveOG,.3)	

		local Tweeninfo = TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)

		local Tween = TweenService:Create(Swirl,Tweeninfo,{Size = Vector3.new(20,24,20),CFrame = Swirl.CFrame * CFrame.new(0,24 / 2,0)})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(Swirl,.5)
		TaskScheduler:AddTask(.027,function()
			for Index = 1,2 do
				local End = cframe * CFrame.new(0,0,-10) * CFrame.Angles(math.pi / 2,0,0)
				local Start = cframe * CFrame.new(0,0,20) * CFrame.Angles(math.pi / 2,0,0)

				local Ring = script.Ring:Clone()
				Ring.CFrame = Start
				Ring.Material = Enum.Material.Neon
				Ring.Size = Vector3.new(40,3,40)
				Ring.Parent = workspace.World.Visuals

				local Tweeninfo2 = TweenInfo.new(.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)

				local Tween = TweenService:Create(Ring,Tweeninfo2,{CFrame = End,Size = Vector3.new(0,3,0)})
				Tween:Play()
				Tween:Destroy()

				Debris:AddItem(Ring,.4)
				wait(.15)
			end
		end)

		TaskScheduler:AddTask(.3,function()
			local Tween = TweenService:Create(Swirl,Tweeninfo,{Size = Vector3.new(0,24,0),Transparency = 1})
			Tween:Play()
			Tween:Destroy()
		end)

		coroutine.resume(coroutine.create(function()
			for Index = 1,6 do
				local X,Y,Z = math.random(-4,4) * 2,math.random(-4,4) * 2,-6
				coroutine.resume(coroutine.create(function()
					local Size = math.random(2,4) * 6
					for Index = 1,3 do
						local Ring = script.Ring2:Clone()
						Ring.CFrame = cframe * CFrame.new(X,Y,Z)
						Ring.Parent = workspace.World.Visuals

						local Tween = TweenService:Create(Ring,Tweeninfo,{Size = Vector3.new(Size,Size,0)})
						Tween:Play()
						Tween:Destroy()

						for _,v in ipairs(Ring:GetDescendants()) do
							if v:IsA("ImageLabel") then
								local Tween = TweenService:Create(v,Tweeninfo,{ImageTransparency = 1})
								Tween:Play()
								Tween:Destroy()
							end
						end
						Debris:AddItem(Ring,.4)
						wait(.1)
					end
				end))
				wait(.1)
			end
		end))		

		local RaycastResult = workspace:Raycast(Position1,Position2,raycastParams)
		if RaycastResult and RaycastResult.Instance and (RaycastResult.Position - Position1).Magnitude < 30 then
			for Index = 1,3 do
				local Slash = ReplicatedStorage.Assets.Effects.Meshes.ThreeDSlashEffect:Clone()
				local Size = math.random(2,4) * 3
				local SizeAdd = math.random(1,6) * 17
				local X,Y,Z = math.rad(math.random(8,12) * 30), math.rad(math.random(8,12) * 30), math.rad(math.random(8,12) * 30)
				local Add = math.random(1,2)
				if Add == 2 then
					Add = -1
				end
				Slash.Transparency = .7
				Slash.Size = Vector3.new(2,Size,Size)
				Slash.CFrame = Root.CFrame * CFrame.Angles(X,Y,Z)
				Slash.Parent = workspace.World.Visuals

				local Ti = TweenInfo.new(.15,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

				local Tween = TweenService:Create(Slash,Ti,{Transparency = 1,CFrame = Slash.CFrame*CFrame.Angles(math.pi * Add,0,0),Size = Slash.Size + Vector3.new(0,SizeAdd,SizeAdd)})
				Tween:Play()
				Tween:Destroy()

				Debris:AddItem(Slash,.3)

				coroutine.resume(coroutine.create(function()
					for Index = 1,3 do
						local Dust = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments["Dust"]:Clone()
						Dust.P1.Color = ColorSequence.new(RaycastResult.Instance.Color)
						Dust.Parent = Root

						VfxHandler.Emit(Dust.P1,3)
						Debris:AddItem(Dust,2)

						wait(.25)
					end
				end))
			end
			-- SoundManager:AddSound("Woosh", {Parent = Root, Volume = 1}, "Client")
		end	
		
		while Swirl do
			Swirl.CFrame = Swirl.CFrame * CFrame.Angles(0,.9,0)
			RunService.RenderStepped:Wait()
			if workspace.World.Visuals:FindFirstChild(Character.Name.." beatrice push swirl") == nil then break end
		end
	end,

	["Al~Shamac"] = function(Data)
		local Character = Data.Character

		local Root = Character:FindFirstChild("Torso")

		coroutine.resume(coroutine.create(function()
			local RaycastResult = workspace:Raycast(Root.Position, Root.CFrame.upVector * -15, raycastParams)
			if RaycastResult and RaycastResult.Instance then
				for Index = 1,12 do
					local Dust = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments["Dust"]:Clone()
					Dust.P1.Color = ColorSequence.new(RaycastResult.Instance.Color)
					Dust.Parent = Root

					VfxHandler.Emit(Dust.P1,3)
					Debris:AddItem(Dust,2)

					wait(.1)
				end
			end
		end))

		coroutine.resume(coroutine.create(function()
			for Index = 1,40 do
				for _ = 1,math.random(1,2) do
					local StartPosition = (Vector3.new(math.sin(360 * Index) * math.random(5,10), 0, math.cos(360 * Index) * math.random(5,10)) + Root.Position)
					local EndPosition = CFrame.new(StartPosition).UpVector * -10

					local RayData = RaycastParams.new()
					RayData.FilterDescendantsInstances = {Character, workspace.World.Live, workspace.World.Visuals} or workspace.World.Visuals
					RayData.FilterType = Enum.RaycastFilterType.Exclude
					RayData.IgnoreWater = true

					local RaycastResult = workspace:Raycast(StartPosition, EndPosition, RayData)
					if RaycastResult then
						local partHit, pos, normVector = RaycastResult.Instance or nil, RaycastResult.Position or nil, RaycastResult.Normal or nil
						if partHit then

							local Block = ReplicatedStorage.Assets.Effects.Meshes.Block:Clone()

							local X,Y,Z = math.random(20,50)/100,math.random(20,50)/100,math.random(20,50)/100
							Block.Size = Vector3.new(X,Y,Z)

							Block.Position = pos
							Block.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
							Block.Transparency = 0
							Block.Color = partHit.Color
							Block.Material = partHit.Material
							Block.Parent = workspace.World.Visuals

							local Tween = TweenService:Create(Block, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Orientation"] = Block.Orientation + Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360)), ["Position"] = Block.Position + Vector3.new(0,math.random(5,10),0)})
							Tween:Play()
							Tween:Destroy()

							Debris:AddItem(Block, .25)
						end
					end
				end
				wait()
			end
		end))

		coroutine.resume(coroutine.create(function()
			for _ = 1,10 do
				for Index = 1,5 do
					local RootPosition = Root.CFrame
					local OriginalPosition = CFrame.new(RootPosition.Position + Vector3.new(math.random(-1,1) * 10,math.random(-1,1) * 10,math.random(-1,1 ) * 10), RootPosition.Position)

					local InstancedPart = ReplicatedStorage.Assets.Effects.Meshes.Block:Clone()
					InstancedPart.Shape = "Block"
					InstancedPart.Size = Vector3.new(1,1,10)
					InstancedPart.Material = Enum.Material.Neon
					InstancedPart.BrickColor = BrickColor.new("Black")
					InstancedPart.Transparency = 0
					InstancedPart.CFrame = CFrame.new(OriginalPosition.Position + Vector3.new(math.random(-1,1),math.random(-1,1),math.random(-1,1)), RootPosition.Position) 
					InstancedPart.Parent = workspace.World.Visuals

					local ShereMesh = Instance.new("SpecialMesh")
					ShereMesh.MeshType = "Sphere"
					ShereMesh.Parent = InstancedPart

					local Tween = TweenService:Create(InstancedPart, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Size"] = InstancedPart.Size + Vector3.new(0,0, math.random(1,2)), ["Position"] = RootPosition.Position})
					Tween:Play()
					Tween:Destroy()

					local EndTween = TweenService:Create(InstancedPart, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {["Size"] = Vector3.new(0,0,10)})		
					EndTween:Play()
					EndTween:Destroy()

					Debris:AddItem(InstancedPart, .15)						
				end
				wait(.15)
			end
		end))

		local FakeCharacter = script["lose your mind"]:Clone()
		FakeCharacter.HumanoidRootPart.CFrame = Root.CFrame * CFrame.new(0,0,-.3)
		FakeCharacter.Parent = workspace.World.Visuals

		local WeldConstraint = Instance.new("WeldConstraint")
		WeldConstraint.Part0 = Root
		WeldConstraint.Part1 = FakeCharacter["HumanoidRootPart"]
		WeldConstraint.Parent = Root

		Debris:AddItem(WeldConstraint, 2) 
		Debris:AddItem(FakeCharacter, 2.1)

		for _,VictimParts in ipairs(Character:GetChildren()) do
			if VictimParts.ClassName == "MeshPart" or VictimParts.ClassName == "Part" and VictimParts.Name ~= "HumanoidRootPart" then
				for _,Particles in ipairs(script.Part:GetChildren()) do 
					local Aura = Particles:Clone()
					Aura.Name = "beatric shamac aura"
					Aura.Parent = VictimParts

					TaskScheduler:AddTask(1.85,function()
						Aura.Enabled = false
						Debris:AddItem(Aura,1)
					end)
				end
			end
		end
		
		wait(1.685)
		local ShamacSmoke = script.fresh:Clone()
		ShamacSmoke.CFrame = Root.CFrame
		ShamacSmoke.Parent = workspace.World.Visuals

		VfxHandler.Emit(ShamacSmoke.Star,100) -- 80
		VfxHandler.Emit(ShamacSmoke.Void,20) -- 10

		Debris:AddItem(ShamacSmoke,2)

		local Yami = Particles.Yami:Clone()
		Yami.Yami.Speed = NumberRange.new(30,40)
		Yami.Yami.Drag = 0
		Yami.Yami.Lifetime = NumberRange.new(.35)
		Yami.Yami.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 0)}
		Yami.Yami.LockedToPart = false
		Yami.Yami.SpreadAngle = Vector2.new(-360, 360)
		Yami.Position = Root.Position
		Yami.Parent = workspace.World.Visuals
		Yami.Yami:Emit(200)
		Debris:AddItem(Yami, 1)

		local Stars = Particles.ParticleAttatchments.Stars:Clone()
		Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
		Stars.Stars.LightEmission = 0
		Stars.Stars.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 0)}
		Stars.Stars.Drag = 0
		Stars.Stars.Rate = 100
		Stars.Stars.Acceleration = Vector3.new(0,0,0)
		Stars.Stars.Lifetime = NumberRange.new(0.45)
		Stars.Stars.Speed = NumberRange.new(30,45)
		Stars.Parent = Yami
		Stars.Stars:Emit(60)
		Debris:AddItem(Stars, 1)

		for Index = 1,2 do
			local Ball = ReplicatedStorage.Assets.Effects.Meshes.regball:Clone()
			Ball.Material = Enum.Material.ForceField
			Ball.Transparency = 0
			Ball.CFrame = Root.CFrame
			Ball.Size = Vector3.new(5,5,5)
			Ball.Color = Color3.fromRGB(0,0,0)
			Ball.Parent = workspace.World.Visuals

			local Tween = TweenService:Create(Ball, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Size"] = Vector3.new(80,80,80), ["Transparency"] = 1})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(Ball,2)	
			wait(.2)	
		end
	end,
}

return BeatriceVFX