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

local Explosions = require(Modules.Effects.Explosions)
local VfxHandler = require(Modules.Effects.VfxHandler)

local LightningModule = require(Modules.Effects.LightningBolt)
local LightningExplosion = require(Modules.Effects.LightningBolt.LightningExplosion)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local Humanoid = Character:WaitForChild("Humanoid")

local function RemoveTrash(Trash)
	for i = 1,#Trash do
		local Item = Trash[i]
		if Item and Item.Parent then
			Item:Destroy()
		end
	end
end

local function Lerp(Start, End, Alpha)
	return Start + (End - Start) * Alpha
end

local function BezierCurve(Start, Offset, End, Alpha)
	local FirstLerp = Lerp(Start, Offset, Alpha)
	local SecondLerp = Lerp(Offset, End, Alpha)

	local BezierLerp = Lerp(FirstLerp, SecondLerp, Alpha)

	return BezierLerp
end

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Map}
raycastParams.FilterType = Enum.RaycastFilterType.Include

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

	local Tween = TweenService:Create(Rock, TweenInfo.new(.15, Enum.EasingStyle.Linear), {Position = Result.Position})
	Tween:Play()
	Tween:Destroy()

	TaskScheduler:AddTask(1, function()
		local Tween = TweenService:Create(Rock, TweenInfo.new(.5, Enum.EasingStyle.Linear), {Position = Result.Position - Vector3.new(0,Rock.Size.Y,0), Orientation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360)), Size = Vector3.new(0,0,0)})
		Tween:Play()
		Tween:Destroy()
	end)
end

function GetMousePos(X,Y,Z,Boolean)
	local RayMag1 = workspace.CurrentCamera:ScreenPointToRay(X, Y)
	local NewRay = Ray.new(RayMag1.Origin, RayMag1.Direction * ((Z and Z) or 200))
	local Target,Position,Surface = workspace:FindPartOnRayWithIgnoreList(NewRay, {Character,workspace.World.Visuals})
	if Boolean then
		return Position,Target,Surface
	else
		return Position
	end
end

local Mouse = Player:GetMouse()

local function createhugelightning(Start,End,numberofparts,player)
	local lastcf = Start
	local Distance = (Start-End).Magnitude/numberofparts
	local Lightning = Instance.new("Folder")
	Lightning.Name = "lightasd"
	Lightning.Parent = workspace.World.Visuals
	Debris:AddItem(Lightning,1.4)

	for Index = 1,numberofparts do
		local x,y,z = math.random(-2,2) * math.clamp(numberofparts,5,99999) ,math.random(-2,2) * math.clamp(numberofparts,5,99999),math.random(-2,2) * math.clamp(numberofparts,5,99999)
		if Index == numberofparts then
			x = 0; y = 0; z = 0
		end
		local newcframe = CFrame.new(lastcf,End + Vector3.new(x,y,z)) * CFrame.new(0,0,-Distance)
		local newdisance = (lastcf - newcframe.p).Magnitude
		local Part = Instance.new("Part")
		Part.Material = Enum.Material.Neon
		Part.Color = Color3.fromRGB(128, 187, 219)
		Part.TopSurface = Enum.SurfaceType.SmoothNoOutlines
		Part.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
		Part.CanCollide = false
		Part.Anchored = true
		Part.CastShadow = false
		Part.Size = Vector3.new(.7,.7,newdisance)
		Part.CFrame = CFrame.new(lastcf,newcframe.p) * CFrame.new(0,0,-newdisance / 2)
		Part.Parent = Lightning

		local Ti2 = TweenInfo.new(.4,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0)

		coroutine.resume(coroutine.create(function()
			wait(Index / 20)
			TweenService:Create(Part,Ti2,{Size = Vector3.new(0,0,newdisance),Color = Color3.fromRGB(253, 234, 141)}):Play()
			Debris:AddItem(Part,.4)
		end))
		lastcf = newcframe.p
	end
end

local ZenitsuVFX = {

	["Zap"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		for _ = 1,5 do
			-- SoundManager:AddSound("Lightning_Release",{Parent = Root},"Client")
			createhugelightning(Root.Position,Data.Position,math.clamp(math.floor((Root.Position - Data.Position).Magnitude / 15), 3, 999),Players:GetPlayerFromCharacter(Character))
			wait()
		end
	end,

	["Rice Spirit"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		-- SoundManager:AddSound("Thund",{Parent = Root, Volume = 6, PlaybackSpeed = 1 - (((1 - 1) * 3) / 10)}, "Client")
		Explosions["Rice Spirit"]({Character = Character})
	end,

	["Distance Thunder"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		local MousePosition,Part,Surface = GetMousePos(Mouse.X,Mouse.Y,300,true)

		local Calculation1 = Root.Position
		local Calculation2 = (MousePosition - Root.Position).Unit * 300

		local RaycastResult = workspace:Raycast(Calculation1,Calculation2,raycastParams)
		if RaycastResult and RaycastResult.Instance then
			MousePosition = RaycastResult.Position
			Part = RaycastResult.Instance
			Surface = RaycastResult.Normal
		end

		Explosions.DistanceThunder({Character = Character, Position = MousePosition, Part = Part, Surface = Surface})
	end,

	["SleepChangeCameraTorso"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		workspace.CurrentCamera.CameraSubject = Character["Torso"]
	end,

	["SleepRevertCamera"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		workspace.CurrentCamera.CameraSubject = Humanoid
	end,

	["Sleeping"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		local SleepingParticle = script.Sleeping.ParticleEmitter:Clone()
		SleepingParticle.Enabled = true
		SleepingParticle.Parent = Character["Head"]

		local Bubbles = script.Bubbles:Clone()
		Bubbles.CFrame =  Character["Head"].CFrame * CFrame.new(0,0,-1.35)
		Bubbles.Parent = Character

		local WeldConstraint = Instance.new("WeldConstraint")
		WeldConstraint.Part0 = Bubbles
		WeldConstraint.Part1 = Character["Head"]
		WeldConstraint.Parent = Bubbles

		-- local Sound = SoundManager:AddSound("Snorting",{["Volume"] = 6, ["Parent"] = Root, ["Looped"] = true}, "Client",{["Duration"] = 4e4})

		while Character:FindFirstChild("StopSleeping") == nil do
			RunService.RenderStepped:Wait()
		end

		-- Sound:Destroy()

		Bubbles.ParticleEmitter.Enabled = false
		Debris:AddItem(Bubbles,.375)

		SleepingParticle.Enabled = false
		Debris:AddItem(SleepingParticle,1)
	end,

	["Menbere"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		local ContactPointCFrame = Data.ContactPointCFrame

		local StartPoint = ContactPointCFrame * CFrame.new(0, -3, -18)

		local FakeEnd = ContactPointCFrame * CFrame.new(0, 0, -10)
		local Dir = (FakeEnd.Position - Root.Position).Unit

		wait(.35)

		local DahNoob = script["Meshes/slashground_Plane.003 (1)"]:Clone()
		DahNoob.CFrame = CFrame.lookAt(StartPoint.Position, StartPoint.Position + Dir) * CFrame.Angles(0, math.rad(90), 0)
		DahNoob.Parent = workspace.World.Visuals

		local StartTween = TweenService:Create(DahNoob,TweenInfo.new(.85, Enum.EasingStyle.Sine, Enum.EasingDirection.Out,0,false,.135), {["Color"] = Color3.fromRGB(0, 0, 0)})
		StartTween:Play()
		StartTween:Destroy()

		StartTween.Completed:Wait()

		local EndTween = TweenService:Create(DahNoob,TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),{["Transparency"] = 1})
		EndTween:Play()
		EndTween:Destroy()

		Debris:AddItem(DahNoob,1)
	end,

	["Dash"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		local StartTime = os.clock()
		local RockInBetween = 0
		local LastRock = os.clock() - RockInBetween

		--VfxHandler.ImpactLines({Character = Character, Amount = 12, Color = BrickColor.new("Pastel yellow")})\

	    --[[coroutine.resume(coroutine.create(function()
			while os.clock() - StartTime < .075 do
				if os.clock() - LastRock >= RockInBetween then
					LastRock = os.clock()

					local Left = Character.PrimaryPart.CFrame * CFrame.new(-4,0,3)
					local Right = Character.PrimaryPart.CFrame * CFrame.new(4,0,3)

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
		end)) ]]

		-- SoundManager:AddSound("Lightning_Release",{Parent = Root, Volume = 2},"Client")
		-- SoundManager:AddSound("Lightning_Release_2",{Parent = Root, Volume = 2},"Client")
		-- SoundManager:AddSound("Lightning",{Parent = Root},"Client")

		local End = Root.CFrame

		local Ti2 = TweenInfo.new(.4,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
		local Ti3 = TweenInfo.new(.02,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,4,true,0)
		local Ti4 = TweenInfo.new(.02,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,2,true,0)

		local NewLine = Effects.Line:Clone()
		NewLine.CFrame = End * CFrame.new(0,1.5,20)
		local Tween = TweenService:Create(NewLine,TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{CFrame = End * CFrame.new(0,1.5,10),Size = Vector3.new(0,0,NewLine.Size.Z)})
		Tween:Play()
		Tween:Destroy()

		NewLine.Parent = workspace.World.Visuals
		Debris:AddItem(NewLine,.4)

		for _ = 1,5 do
			local Line = Effects.Lightning:Clone()
			Line.CFrame = End * CFrame.new(-7, -1, 5)
			TweenService:Create(Line,Ti2,{CFrame = End * CFrame.new(-7,-1,10)}):Play()
			TweenService:Create(Line,Ti3,{Transparency = 0}):Play()

			Line.Parent = workspace.World.Visuals
			Debris:AddItem(Line,.4)

			local Line2 = Effects.Lightning2:Clone()
			Line2.CFrame = End * CFrame.new(7, -1, 3)
			TweenService:Create(Line2,Ti2,{CFrame = End * CFrame.new(7,-1,5)}):Play()
			TweenService:Create(Line2,Ti3,{Transparency = 0}):Play()

			Line2.Parent = workspace.World.Visuals
			Debris:AddItem(Line2,.4)

			local Line3 = Effects.Lightning3:Clone()
			Line3.CFrame = End * CFrame.Angles(math.pi/2,0,0) * CFrame.new(0, -1, 5)
			TweenService:Create(Line3,Ti2,{CFrame = End * CFrame.Angles(math.pi/2,0,0) * CFrame.new(0,-1,10)}):Play()
			TweenService:Create(Line3,Ti4,{Transparency = 0}):Play()

			Line3.Parent = workspace.World.Visuals
			Debris:AddItem(Line3,.2)
		end

		for Index = 1,2 do
			local Cframe = End * CFrame.new(-2.5,0,3)
			if Index == 2 then
				Cframe = End * CFrame.new(2.5,0,3)
			end
			local DashMesh = Effects.DashMesh:Clone()
			DashMesh.Transparency = .6
			DashMesh.CFrame = Cframe * CFrame.new(0,-DashMesh.Size.Y / 2,0)
			DashMesh.Size = Vector3.new(0.54, 6, 29)
			DashMesh.Parent = workspace.World.Visuals

			local tiasdasd = TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

			local Tween = TweenService:Create(DashMesh,tiasdasd,{Transparency = 1,CFrame = Cframe * CFrame.new(0,-DashMesh.Size.Y / 2,3)})
			Tween:Play()
			Tween:Destroy()

			local Tween = TweenService:Create(DashMesh, TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Color"] = BrickColor.new("Pastel blue-green").Color})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(DashMesh,.5)
		end

		local p1,p2 = End.p,End.upVector * -200
		local RaycastResult = workspace:Raycast(p1,p2,raycastParams)
		if RaycastResult and RaycastResult.Instance and (RaycastResult.Position - p1).Magnitude < 30 then
			local FirstDust = script.zenitdust:Clone()
			FirstDust.CFrame = End * CFrame.Angles(0,.3,0) * CFrame.new(3,0,0)
			FirstDust.ParticleEmitter.Color = ColorSequence.new(RaycastResult.Instance.Color)
			FirstDust.ParticleEmitter:Emit(20)

			FirstDust.Parent = workspace.World.Visuals
			Debris:AddItem(FirstDust,3)

			local SecondDust = script.zenitdust:Clone()
			SecondDust.CFrame = End * CFrame.Angles(0,-.3,0) * CFrame.new(-3,0,0)
			SecondDust.ParticleEmitter.Color = ColorSequence.new(RaycastResult.Instance.Color)
			SecondDust.ParticleEmitter:Emit(20)

			SecondDust.Parent = workspace.World.Visuals
			Debris:AddItem(SecondDust,3)
		end

		local Light = Instance.new("PointLight")
		Light.Color = Color3.fromRGB(255, 221, 82)
		Light.Brightness = 10
		Light.Range = 15
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

			delay(.5,function() DirtStep.ParticleEmitter.Enabled = false end)
			Debris:AddItem(DirtStep,2)
		end

		local Max = 200
		TaskScheduler:AddTask(.2,function()
			for Index = 1,10 do
				local Max = Max - 10
				local startPos = Data.ContactPointCFrame.p
				local endPos = Character.HumanoidRootPart.CFrame.p
				local amount = 10
				local width = .35
				local offsetRange = 2

				local Model = VfxHandler.Lightning({
					StartPosition = startPos,
					EndPosition = endPos,
					Amount = amount,
					Width = width,
					OffsetRange = offsetRange,
					Color = "Cool yellow"--BrickColor.new("Cool yellow")
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
		end)

		TaskScheduler:AddTask(.1,function()
			Explosions.ZenitsuTP({Character = Character, Distance = Data.Distance})
		end)

		wait(.425)
		for Index = 1,10 do
			local Max = Max - 10
			local startPos = Data.ContactPointCFrame.p
			local endPos = Character.HumanoidRootPart.CFrame.p
			local amount = 3
			local width = 2.35
			local offsetRange = 5

			local Color = Index % 2 == 0 and "Pastel blue-green" or "Yellow"

			local Model = VfxHandler.Lightning({
				StartPosition = startPos,
				EndPosition = endPos,
				Amount = amount,
				Width = width,
				OffsetRange = offsetRange,
				Color = Color
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

	["ThunderClapandFlash"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		-- SoundManager:AddSound("Ground Stomp",{Parent = Root},"Client")

		if Character.Name == Players.LocalPlayer.Name then
			GlobalFunctions.FreshShake(20,25,.5,.2,0)
		end

		coroutine.resume(coroutine.create(function()
			for _ = 1,12 do
				local slash = ReplicatedStorage.Assets.Effects.Meshes.ThreeDSlashEffect:Clone()
				local size = math.random(2,4) * 4
				local sizeadd = math.random(2,4) * 12
				local x,y,z = math.rad(math.random(8,12) * 30), math.rad(math.random(8,12) * 30), math.rad(math.random(8,12) * 30)
				local add = math.random(1,2)
				if add == 2 then
					add = -1
				end
				slash.Transparency = .4
				slash.Size = Vector3.new(2,size,size)
				slash.CFrame = Root.CFrame * CFrame.Angles(x,y,z)
				slash.Parent = workspace.World.Visuals

				local B5 = TweenInfo.new(.3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

				local Tween = TweenService:Create(slash,B5,{Transparency = 1,CFrame = slash.CFrame * CFrame.Angles(math.pi * add,0,0),Size = slash.Size + Vector3.new(0,sizeadd,sizeadd)})
				Tween:Play()
				Tween:Destroy()

				Debris:AddItem(slash,.3)
			end
		end))

		coroutine.resume(coroutine.create(function()
			for Index = 1,4 do
				local X,Y,Z = math.random(-3,3) * 4,math.random(-3,3) * 4,math.random(-3,3) * 2
				local Start = Root.CFrame.Position
				local End = Start + Vector3.new(X,Y,Z)

				local Effect = script.D:Clone()
				Effect.CFrame = CFrame.new(Start,End)
				Effect.Parent = workspace.World.Visuals

				local Ti5 = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

				local Tween = TweenService:Create(Effect,Ti5,{CFrame = CFrame.new(Start,End) * CFrame.new(0,0,-10),Size = Vector3.new(0,0,7.649)})
				Tween:Play()
				Tween:Destroy()

				Debris:AddItem(Effect,.2)
			end
		end))

		coroutine.wrap(function()
			local WIDTH, LENGTH = 0.2, 4
			for j = 1,25 do
				for i = 1,1 do
					local Sphere = Effects.Sphere:Clone()
					Sphere.Transparency = 0
					Sphere.Mesh.Scale = Vector3.new(WIDTH,LENGTH,WIDTH)
					Sphere.Material = Enum.Material.Neon
					if j % 2 == 0 then
						Sphere.Color = Color3.fromRGB(0, 0, 0)
					else
						Sphere.Color = Color3.fromRGB(255, 255, 140)
					end
					Sphere.CFrame = Root.CFrame * CFrame.new(math.random(-4,4) * i,-5,math.random(-2,2) * i)
					Sphere.Parent = workspace.World.Visuals

					local Tween = TweenService:Create(Sphere, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Size"] = Vector3.new(0,Sphere.Size.Y,Sphere.Size.Z), ["Transparency"] = 1, ["Position"] = Sphere.Position + Vector3.new(0,math.random(7.5,10),0)})
					Tween:Play()
					Tween:Destroy()

					Debris:AddItem(Sphere, .35)
				end
				RunService.Stepped:Wait()
			end
		end)()

		local attach = Character["Right Arm"]:FindFirstChild("RightGripAttachment")

		coroutine.resume(coroutine.create(function()
			for Index = 1,2 do
				local Lightning = ReplicatedStorage.Assets.Effects.Misc.LIGHTNING:Clone()
				Lightning.Color = Color3.fromRGB(255, 221, 82)
				Lightning.Range = 15
				Lightning.Brightness = 15
				Lightning.Parent = Root
				Debris:AddItem(Lightning,.1)
				wait(.2)
			end
		end))

		local attach = Character["Torso"]:FindFirstChild("BodyFrontAttachment")

		coroutine.wrap(function()
			local b,g,t = 5,5,5
			for Index = 1,4 do
				local attach2 = Instance.new("Attachment")
				attach2.Parent = Character["Torso"]
				attach2.Position = Vector3.new(math.random(-b,b),math.random(-g,g),math.random(t,t))
				local bolt = LightningModule.new(attach, attach2, 40)
				bolt.PulseSpeed = 3
				bolt.PulseLength = .75
				bolt.FadeLength = .55
				if (Index % 2 == 0) then
					bolt.Color = Color3.fromRGB(128, 187, 219)
				else
					bolt.Color = Color3.fromRGB(128, 187, 219)
				end
				Debris:AddItem(attach2,.65)
				wait(.035)
			end
		end)()

		local x,y,z = 5,5,5
		for Index = 1,8 do
			local attach2 = Instance.new("Attachment")
			attach2.Parent = Character["Torso"]
			attach2.Position = Vector3.new(math.random(-x,x),math.random(-y,y),math.random(-z,z))
			local bolt = LightningModule.new(attach, attach2, 40)
			bolt.PulseSpeed = 2
			bolt.PulseLength = .75
			bolt.FadeLength = .55
			if (Index % 2 == 0) then
				bolt.Color = Color3.fromRGB(255, 255, 140)
			else
				bolt.Color = Color3.fromRGB(255, 255, 140)
			end
			Debris:AddItem(attach2,1)
		end

		coroutine.resume(coroutine.create(function()
			for _ = 1,2 do
				-- SoundManager:AddSound("LightningSizzle", {Parent = Root, Volume = 2.5}, "Client")
				wait(.15)
			end
		end))

		for j = 1,25 do
			for i = 1,math.random(1,2) do
				--[[ Raycast ]]--
				local StartPosition = (Vector3.new(math.sin(360 * j) * math.random(5,10), 0, math.cos(360 * j) * math.random(5,10)) + Character.HumanoidRootPart.Position)
				local EndPosition = CFrame.new(StartPosition).UpVector * -10

				local RayData = RaycastParams.new()
				RayData.FilterDescendantsInstances = {Character, workspace.World.Live, workspace.World.Visuals} or workspace.World.Visuals
				RayData.FilterType = Enum.RaycastFilterType.Exclude
				RayData.IgnoreWater = true

				local ray = workspace:Raycast(StartPosition, EndPosition, RayData)
				if ray then

					local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
					if partHit then

						local Block = Effects.Block:Clone()

						local X,Y,Z = math.random(20,50) / 100,math.random(20,50) / 100,math.random(20,50) / 100
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

						Debris:AddItem(Block, 0.25)
					end
				end
			end
			wait()
		end
	end,
}

return ZenitsuVFX
