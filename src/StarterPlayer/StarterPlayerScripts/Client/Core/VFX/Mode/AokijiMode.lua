--|| Services ||--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

--|| Variables ||--
local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()

local Mouse = Players.LocalPlayer:GetMouse()

local CurrentCamera = workspace.CurrentCamera

local Particles = ReplicatedStorage.Assets.Effects.Particles
local Effects = ReplicatedStorage.Assets.Effects.Meshes

--|| Modules ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(ReplicatedStorage.Modules.Shared.SoundManager)

local LightningModule = require(ReplicatedStorage.Modules.Effects.LightningBolt)
local VfxHandler = require(ReplicatedStorage.Modules.Effects.VfxHandler)
local CameraShaker = require(ReplicatedStorage.Modules.Effects.CameraShaker)
local Explosions = require(ReplicatedStorage.Modules.Effects.Explosions)

local TaskScheduler = require(ReplicatedStorage.Modules.Utility.TaskScheduler)

--|| Assets ||--
local PlayerHead = Effects["PlayerHead"]
local MB2Effect = ReplicatedStorage.Assets.Models.Misc["FakeBodyPart"]

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Visuals, workspace.World.Enviornment}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
end)

--|| Tweens ||--
local Ti = TweenInfo.new(.4,Enum.EasingStyle.Circular,Enum.EasingDirection.Out,0,false,0)

function CloneIce(Part,ToPart)
	local StartTime = os.clock()

	local IcePart = script[Part]:Clone()
	IcePart.CFrame = ToPart.CFrame
	IcePart.Parent = ToPart.Parent

	local Weld = Instance.new("Weld")
	Weld.Part0 = ToPart
	Weld.Part1 = IcePart
	Weld.Parent = IcePart

	coroutine.wrap(function()
		while os.clock() - StartTime <= 58 and _G.Data.Character == "Aokiji" do
			RunService.Heartbeat:Wait()
		end
		IcePart.smoke.Enabled = false
		IcePart.sparkz.Enabled = false

		if Character["Torso"]:FindFirstChild("aokiji sparkzz") then
			Character["Torso"]["aokiji sparkzz"].Enabled = false
			Debris:AddItem(Character["Torso"]["aokiji sparkzz"],2)
		end

		if Character["Torso"]:FindFirstChild("aokiji smokezzz") then
			Character["Torso"]["aokiji smokezzz"].Enabled = false
			Debris:AddItem(Character["Torso"]["aokiji smokezzz"],2)
		end

		Debris:AddItem(IcePart,2)
	end)()

	return IcePart
end

local Trash = {}

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

	local RaycastResult = workspace:Raycast(RayMag1.Origin, RayMag1.Direction * ((Z and Z) or 200))
	local Target, Position, Surface = RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal

	if Boolean then
		return Position,Target,Surface
	else
		return Position
	end
end

local racaystParams = RaycastParams.new()
racaystParams.FilterDescendantsInstances = {workspace.World.Map}
racaystParams.FilterType = Enum.RaycastFilterType.Include

local icebirdHit = false

local AokijiMode = {

	["Cutscene"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		CurrentCamera.CameraType = Enum.CameraType.Scriptable

		local InitialCFrame = CurrentCamera.CFrame

		local BodyPosition = Instance.new("BodyPosition")
		BodyPosition.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
		BodyPosition.Position = Root.Position
		BodyPosition.Parent = Root

		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
		BodyGyro.CFrame = Root.CFrame
		BodyGyro.Parent = Root

		local Cutscene = TweenService:Create(CurrentCamera,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{CFrame = Root.CFrame * CFrame.Angles(0,math.rad(180),0) * CFrame.new(0,-1,10)})
		Cutscene:Play()
		Cutscene:Destroy()

		wait(1)

		local FOV = workspace.CurrentCamera.FieldOfView

		local Zoom = TweenService:Create(CurrentCamera,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{FieldOfView = 100})
		Zoom:Play()
		Zoom:Destroy()
		Zoom.Completed:Wait()

		local EndZoom = TweenService:Create(CurrentCamera,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{FieldOfView = FOV})
		EndZoom:Play()
		EndZoom:Destroy()

		EndZoom.Completed:Wait()

		local EndTween = TweenService:Create(CurrentCamera,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{CFrame = InitialCFrame})
		EndTween:Play()
		EndTween:Destroy()

		EndTween.Completed:Wait()

		BodyPosition:Destroy()
		BodyGyro:Destroy()

		CurrentCamera.CameraType = Enum.CameraType.Custom
	end,

	["FreezeStop"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")

		local Victim = Data.Victim
		local VRoot,VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

		if GlobalFunctions.CheckDistance(Players.LocalPlayer, Data.Distance) then
			CameraShake:Start()
			CameraShake:ShakeOnce(8, 35, 0, 1.5)
		end

		-- SoundManager:AddSound("Explosiongrz",{Parent = Root, Volume = .8}, "Client")

		VfxHandler.Iceyzsz(VRoot)
		VfxHandler.Spherezsz({
			Cframe = VRoot.CFrame,
			TweenDuration1 = .2,
			TweenDuration2 = .35,
			Range = 5,
			MinThick = 12,
			MaxThick = 18,
			Part = nil,
			Color = Color3.fromRGB(110, 168, 255),
			Amount = 15
		})

		local IceParticle = script.IceBird.Bird.IceSmoke:Clone()
		IceParticle.Rate = 0
		IceParticle:Emit(10)

		IceParticle.Parent = VRoot
		Debris:AddItem(IceParticle, 1)

		local IceParticle2 = script.IceBird.Bird.Sparks:Clone()
		IceParticle2.Rate = 0
		IceParticle2:Emit(10)

		IceParticle2.Parent = VRoot
		Debris:AddItem(IceParticle2, 1)
	end,

	["FreezingGrab"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")

		local Victim = Data.Victim
		local VRoot,VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

		local StartTime = os.clock()

		coroutine.resume(coroutine.create(function()
			while wait() do
				-- SoundManager:AddSound("MoreIce",{Parent = Root, Volume = .275}, "Client")
				if os.clock() - StartTime >= 1.75 then break end
			end
		end))

		delay(1,function() VfxHandler.Iceyzsz(VRoot) end)

		VfxHandler.FakeBodyPart({Character = Victim,Object = "Left Leg", Material = "Neon",Color = Color3.fromRGB(79, 113, 136), TweenColor = Color3.fromRGB(136, 195, 234),Transparency = 1,Duration = 1.5,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Victim,Object = "Left Arm", Material = "Neon",Color = Color3.fromRGB(79, 113, 136), TweenColor = Color3.fromRGB(136, 195, 234),Transparency = 1,Duration = 1.5,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Victim,Object = "Torso", Material = "Neon",Color = Color3.fromRGB(79, 113, 136), TweenColor = Color3.fromRGB(136, 195, 234),Transparency = 1,Duration = 1.5,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Victim,Object = "Right Leg", Material = "Neon",Color = Color3.fromRGB(79, 113, 136), TweenColor = Color3.fromRGB(136, 195, 234),Transparency = 1,Duration = 1.5,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Victim,Object = "Right Arm", Material = "Neon",Color = Color3.fromRGB(79, 113, 136), TweenColor = Color3.fromRGB(136, 195, 234),Transparency = 1,Duration = 1.5,Delay = .1,})

		coroutine.resume(coroutine.create(function()
			for _ = 1,10 do
				for Index = 1,5 do
					local RootPosition = VRoot.CFrame
					local OriginalPosition = CFrame.new(RootPosition.Position + Vector3.new(math.random(-1,1) * 10,math.random(-1,1) * 10,math.random(-1,1 ) * 10), RootPosition.Position)

					local InstancedPart = ReplicatedStorage.Assets.Effects.Meshes.Block:Clone()
					InstancedPart.Shape = "Block"
					InstancedPart.Size = Vector3.new(1,1,10)
					InstancedPart.Material = Enum.Material.Neon
					InstancedPart.BrickColor = BrickColor.new("Medium blue")
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
	end,

	["Transformation"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		local StartTime = os.clock()

		delay(.65,function() VfxHandler.Iceyzsz(Root) end)

		VfxHandler.FakeBodyPart({Character = Character,Object = "Left Leg", Material = "Neon",Color = Color3.fromRGB(79, 113, 136), TweenColor = Color3.fromRGB(136, 195, 234),Transparency = 1,Duration = 1,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Character,Object = "Left Arm", Material = "Neon",Color = Color3.fromRGB(79, 113, 136), TweenColor = Color3.fromRGB(136, 195, 234),Transparency = 1,Duration = 1,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Character,Object = "Torso", Material = "Neon",Color = Color3.fromRGB(79, 113, 136), TweenColor = Color3.fromRGB(136, 195, 234),Transparency = 1,Duration = 1,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Character,Object = "Right Leg", Material = "Neon",Color = Color3.fromRGB(79, 113, 136), TweenColor = Color3.fromRGB(136, 195, 234),Transparency = 1,Duration = 1,Delay = .1,})
		VfxHandler.FakeBodyPart({Character = Character,Object = "Right Arm", Material = "Neon",Color = Color3.fromRGB(79, 113, 136), TweenColor = Color3.fromRGB(136, 195, 234),Transparency = 1,Duration = 1,Delay = .1,})

		-- SoundManager:AddSound("Gear2Transformation",{Parent = Root, TimePosition = 2, Volume = .85},"Client")
		-- SoundManager:AddSound("AokijiVoiceLine",{Parent = Root, Volume = 10.5}, "Client")

		coroutine.resume(coroutine.create(function()
			for _ = 1,10 do
				for Index = 1,5 do
					local RootPosition = Root.CFrame
					local OriginalPosition = CFrame.new(RootPosition.Position + Vector3.new(math.random(-1,1) * 10,math.random(-1,1) * 10,math.random(-1,1 ) * 10), RootPosition.Position)

					local InstancedPart = ReplicatedStorage.Assets.Effects.Meshes.Block:Clone()
					InstancedPart.Shape = "Block"
					InstancedPart.Size = Vector3.new(1,1,10)
					InstancedPart.Material = Enum.Material.Neon
					InstancedPart.BrickColor = BrickColor.new("Medium blue")
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

		--VfxHandler.FakeBodyPart({Character = Character, Object = "Right Leg", Material = "Neon",Color = Color3.fromRGB(97, 163, 177), TweenColor = Color3.fromRGB(97, 163, 177), Transparency = 1,Duration = 58, Delay = .1,})
		--VfxHandler.FakeBodyPart({Character = Character, Object = "Right Arm", Material = "Neon",Color = Color3.fromRGB(97, 163, 177), TweenColor = Color3.fromRGB(97, 163, 177), Transparency = 1,Duration = 58, Delay = .1,})
		--VfxHandler.FakeBodyPart({Character = Character, Object = "Torso", Material = "Neon",Color = Color3.fromRGB(97, 163, 177), TweenColor = Color3.fromRGB(97, 163, 177), Transparency = 1,Duration = 58, Delay = .1,})
		GlobalFunctions.FreshShake(100,45,1,.2,0)

		wait(1.15)
		CloneIce("HeadIce",Character:FindFirstChild("Head"))
		CloneIce("RightArmIce",Character:FindFirstChild("Right Arm"))
		CloneIce("RightLegIce", Character:FindFirstChild("Right Leg"))
		CloneIce("TorsoIce", Character:FindFirstChild("Torso"))

		local Sparkz = script.TorsoIce.sparkz:Clone()
		Sparkz.Name = "aokiji sparkzz"
		Sparkz.Rate = 150
		Sparkz.Parent = Character["Torso"]

		local Smoke = script.TorsoIce.smoke:Clone()
		Smoke.Name = "aokiji smokezzz"
		Smoke.Rate = 10
		Smoke.Parent = Character["Torso"]

		coroutine.resume(coroutine.create(function()
			for Index = 1,2 do
				local Ball = ReplicatedStorage.Assets.Effects.Meshes.regball:Clone()
				Ball.Material = Enum.Material.ForceField
				Ball.Transparency = 0
				Ball.CFrame = Root.CFrame
				Ball.Size = Vector3.new(5,5,5)
				Ball.Color = Color3.fromRGB(129, 201, 255)
				Ball.Parent = workspace.World.Visuals

				local Tween = TweenService:Create(Ball, TweenInfo.new(.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Size"] = Vector3.new(35,35,35), ["Transparency"] = 1})
				Tween:Play()
				Tween:Destroy()

				local Tween = TweenService:Create(Ball, TweenInfo.new(.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Transparency"] = 1})
				Tween:Play()
				Tween:Destroy()

				Debris:AddItem(Ball,.75)
				wait(.2)
			end
		end))

		VfxHandler.FloorFreeze(Root.CFrame, 100, 10, 15, nil, 10,Vector3.new(math.random(20,25), 0.989, math.random(20,25)),Character)
		VfxHandler.Iceyzsz(Root)

		VfxHandler.Spherezsz({
			Cframe = Root.CFrame,
			TweenDuration1 = .2,
			TweenDuration2 = .35,
			Range = 3,
			MinThick = 15,
			MaxThick = 25,
			Part = nil,
			Color = Color3.fromRGB(110, 168, 255),
			Amount = 20
		})

		-- SoundManager:AddSound("FlashFreeze",{Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = 7.5},"Client")
	end,

	["Ice Bird"] = function(PathData)
		local Character = PathData.Character
		local Humanoid,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

		local End = Root.CFrame

		local PositionCalculation,PositionCalculation2 = End.Position,End.upVector * -200

		local StartPoint = Root.CFrame * CFrame.new(0, 0, -5)

		local FakeEnd = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -10)
		local Dir = (FakeEnd.Position - Character.HumanoidRootPart.Position).Unit

		local Fireball = script.IceBird:Clone()
		Fireball.Bird.CFrame = CFrame.lookAt(StartPoint.Position, StartPoint.Position + Dir) * CFrame.Angles(0, math.rad(90), 0)
		Fireball.Name = Character.Name.." Hie Bird"
		Fireball.Parent = workspace.World.Visuals

		local Vel = PathData.Velocity
		local LifeT = PathData.Lifetime

		local Position,Part,Surface = GetMousePos(Mouse.X,Mouse.Y,500,true)

		VfxHandler.Iceyzsz(Root)
		-- SoundManager:AddSound("FlashFreeze",{Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = 7.5},"Client")
		-- SoundManager:AddSound("Eagle",{Parent = Fireball.Bird, Volume = 8}, "Client")

		GlobalFunctions.FreshShake(45,15,.5,.2,0)

		local BirdVelocity = Instance.new("BodyVelocity")
		BirdVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
		BirdVelocity.Velocity = Root.CFrame.lookVector  * 100
		BirdVelocity.Parent = Fireball.Bird

		local BirdAnimation = Fireball.AnimationController:LoadAnimation(script.flyanim)
		BirdAnimation:Play()

		VfxHandler.Spherezsz({
			Cframe = CFrame.new((Root.CFrame * CFrame.new(0, 5, 0)).Position),
			TweenDuration1 = .25,
			TweenDuration2 = .35,
			Range = 5,
			MinThick = 2,
			MaxThick = 5,
			Part = Root,
			Color = Color3.fromRGB(148, 250, 255),
			Amount = 12
		})

		local Connection; Connection = Fireball.Bird.Touched:Connect(function(Hit)
			if not Hit:IsDescendantOf(Character) and not Hit:IsDescendantOf(workspace.World.Visuals) and not Hit:IsDescendantOf(workspace.CurrentCamera) and not Hit:IsDescendantOf(workspace.World.Enviornment) then
				icebirdHit = true
				Explosions.Spear({Character = Character, RaycastResult = Fireball.Bird, Spear = Fireball.Bird, Distance = PathData.Distance})
				Connection:Disconnect(); Connection = nil
				delay(1,function()
					icebirdHit = false
				end)
				Debris:AddItem(Fireball,1)
				return
			end
		end)

		coroutine.wrap(function()
			while not icebirdHit do
				VfxHandler.FloorFreeze(Fireball.Bird.CFrame, 100, 10, 15, nil, 2.5, Vector3.new(8.5, 0.989, 8.5), Character, 0 , "Slidez")
				wait()
			end
		end)()
	end,

	["Ice Slide"] = function(PathData)
		local Character = PathData.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
		local LastRushEff = 0;

		-- local Sound = SoundManager:AddSound("Skateboard", {Parent = Root, Volume = 0, TimePosition = .1}, "Client")

		--HUD.RushEffect.ImageTransparency = 1 - (300 -20) / 250;

		while wait() do
			-- SoundManager:AddSound("IceExplosionGain",{Parent = Root, Volume = .35}, "Client")

			VfxHandler.FloorFreeze(Root.CFrame * CFrame.new(0,1,-4), 100, 10, 15, nil, 2, Vector3.new(9, 0.989, 9), Character, 0, "Slide")
			--VfxHandler.ImpactLines({Character = Character, Amount = 1, Color = BrickColor.new("White")})
		--[[if os.clock() - LastRushEff > .1 then
				LastRushEff = os.clock()
				HUD.RushEffect.Rotation = math.random() * 360
			end ]]
			if Root:FindFirstChild("IceSlide") == nil then break end
		end
		--	HUD.RushEffect.ImageTransparency = 1;
		-- Sound:Destroy()

		wait(1)
		RemoveTrash(Trash)
	end,

	["Ice Age"] = function(PathData)
		local Character = PathData.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		VfxHandler.FloorFreeze(Root.CFrame, 100, 10, 15, nil, 10,Vector3.new(math.random(20,25), 0.989, math.random(20,25)),Character)
		VfxHandler.Iceyzsz(Root)

		local NumberIndex = 3
		local CFrameIndex = Root.CFrame * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)

		local MultiplyNumber = 5 * (NumberIndex / 2)
		for _ = 1, 7 do
			-- SoundManager:AddSound("FlashFreeze",{Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = 8.75},"Client")
			GlobalFunctions.FreshShake(65,25,1,.2,0)

			for Index = 1, 13 do
				local IceCube = script.IceCube:Clone()
				IceCube.CFrame = CFrameIndex * CFrame.Angles(0, math.rad(27.692307692307693 * Index), 0)
				IceCube.CFrame = IceCube.CFrame * CFrame.new(0, -NumberIndex / 2, 0)

				local RayCalculation = IceCube.CFrame * CFrame.new(0, 2, -MultiplyNumber) * CFrame.Angles(math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)))

				Debris:AddItem(IceCube, 5)

				local RaycastResult = workspace:Raycast(RayCalculation.p + Vector3.new(0, 10, 0), CFrame.new(RayCalculation.p).UpVector * -402,racaystParams)
				local Position,Target = RaycastResult.Position, RaycastResult.Instance
				if not Target or Position.Y <= workspace.World.Enviornment.TestPart.Position.Y or Position.Y < workspace.World.Enviornment.TestPart2.Position.Y then
					if Position.Y <= workspace.World.Enviornment.TestPart.Position.Y and workspace.World.Enviornment.TestPart2.Position.Y < Position.Y then Position = Vector3.new(Position.X, workspace.World.Enviornment.TestPart.Position.Y, Position.Z) end
					IceCube.Color = BrickColor.new("Pastel light blue").Color
					IceCube.Transparency = 1
					IceCube.Material = Enum.Material.Glass

					local Tween = TweenService:Create(IceCube, TweenInfo.new(.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Transparency"] = 0})
					Tween:Play()
					Tween:Destroy()

					TaskScheduler:AddTask(.35,function()
						IceCube.Material = Enum.Material.Ice
					end)
					IceCube.Parent = workspace.World.Visuals

					local ToTweenCFrame = CFrame.new(Position) * CFrame.Angles(math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)))
					local ToSizeIndex = Vector3.new(NumberIndex, NumberIndex, NumberIndex) * (math.random(50, 100) / 100)

					local Tween = TweenService:Create(IceCube, TweenInfo.new(.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {["CFrame"] = ToTweenCFrame, ["Size"] = ToSizeIndex})
					Tween:Play()
					Tween:Destroy()

					IceCube.IceSmoke:Emit(5)
					IceCube.Sparks.Size = NumberSequence.new(ToSizeIndex.Magnitude / 2, ToSizeIndex.Magnitude)
					IceCube.Sparks:Emit(3)

					coroutine.wrap(function()
						wait(.25)
						local Weld = nil
						if Target and not Target:IsDescendantOf(workspace.World.Enviornment) and Target.Anchored  then
							Weld = Instance.new("Weld")
							Weld.C0 = Target.CFrame:inverse() * IceCube.CFrame
							Weld.Part0 = Target
							Weld.Part1 = IceCube
							Weld.Parent = IceCube

							IceCube.Anchored = false
						end
						coroutine.wrap(function()
							wait(2)
							-- SoundManager:AddSound("IceExplosionGain",{Parent = Root, Volume = .15}, "Client")
							IceCube.Material = Enum.Material.Glass

							local Tween = TweenService:Create(IceCube, TweenInfo.new(.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Size"] = Vector3.new(0, 0, 0)})
							Tween:Play()
							Tween:Destroy()

							local Tween = TweenService:Create(IceCube, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1, })
							Tween:Play()
							Tween:Destroy()

							if Weld == nil then
								local Tween = TweenService:Create(IceCube, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = CFrame.new(IceCube.CFrame.p) * CFrame.new(0, -IceCube.Size.X, 0)})
								Tween:Play()
								Tween:Destroy()
							end
							Debris:AddItem(IceCube, 1)
						end)()
					end)()
				else
					IceCube:Destroy()
				end
			end
			wait(.1)
			NumberIndex = NumberIndex * 1.5
			MultiplyNumber = MultiplyNumber * 1.4
		end
	end,
}

return AokijiMode
