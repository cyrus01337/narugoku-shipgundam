--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models
local Effects = ReplicatedStorage.Assets.Effects.Meshes

local Metadata = Modules.Metadata
local Shared = Modules.Shared
local Utility = Modules.Utility

local HitPart2 = Models.Misc.HitPart2

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(Shared.SoundManager)
local RaycastService = require(Shared.RaycastManager)

local TaskScheduler = require(Utility.TaskScheduler)

local Explosions = require(Modules.Effects.Explosions)
local VfxHandler = require(Modules.Effects.VfxHandler)
local CameraShaker = require(Modules.Effects.CameraShaker)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

local Humanoid = Character:WaitForChild("Humanoid")

local function RemoveTrash(Trash)
	for Index = 1,#Trash do
		local Item = Trash[Index]
		if Item and Item.Parent then
			Item:Destroy()
		end
	end
end

local function AdjustableToSet(Part, Number)
	local SizeIndex = Part.Size * math.random(90, 130) / 100;
	local RandomCalculation = math.random(100, 1000) / 5000;
	Part.Size = Vector3.new(RandomCalculation, RandomCalculation, Part.Size.Z)

	local TransparencyIndex = 1

	if Part.Name == "Flame" then
		Part.Transparency = TransparencyIndex
	end

	local Tween = TweenService:Create(Part, TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["CFrame"] = Part.CFrame * CFrame.new(0, 0, -Number / 2), ["Size"] = SizeIndex, ["Transparency"] = 1})
	Tween:Play()
	Tween:Destroy()

	if Part.Name == "Center" then
		for _,Decals in ipairs(Part:GetChildren()) do
			if Decals:IsA("Decal") then
				local Tween = TweenService:Create(Decals, TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Transparency"] = 1})
				Tween:Play()
				Tween:Destroy()
			end
		end
	end
end

local function ToPart(Cframe, Part2CFrame, Color, ToTweenSize, Size, Duration, TransparencyData, TweenDetail, ToTweenColor, Material, SecondPart)
	local Part = script.Part:Clone()
	if SecondPart then
		Part = script[SecondPart]:Clone()
	end
	Part.CFrame = Cframe
	if Material then
		Part.Material = Material
	end
	if Part2CFrame then
		Part.CFrame = Part2CFrame
	end
	Part.BrickColor = Color
	if Size then
		Part.Size = Size
	end
	if TransparencyData == nil then
		TransparencyData = 0
	end
	Part.Transparency = TransparencyData
	Debris:AddItem(Part, Duration)
	local TweenInfoData = TweenInfo.new(Duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0)
	if TweenDetail then
		TweenInfoData = TweenInfo.new(Duration, TweenDetail, Enum.EasingDirection.Out, 0, false, 0)
	end;
	local TweenData = {
		Size = ToTweenSize,
		CFrame = Cframe,
		Transparency = 1
	}
	if ToTweenColor then
		TweenData.Color = ToTweenColor
	end
	Part.Parent = workspace.World.Visuals

	local Tween = TweenService:Create(Part,TweenInfoData,TweenData)
	Tween:Play()
	Tween:Destroy()
end

local function ToBurn(Part, Random1, Random2, CFrameParameter, LastRandom)
	if Part then
		local Attachment = Instance.new("Attachment", Part)
		local ShadowAttachment = Attachment:Clone()

		local Beam = script.Beam:Clone()
		Beam.Parent = Part
		Beam.Width0 = math.random(Random1, Random2)
		Beam.Attachment0 = Attachment
		Beam.Attachment1 = ShadowAttachment
		ShadowAttachment.Parent = Part

		local Tween = TweenService:Create(ShadowAttachment, TweenInfo.new(.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {["WorldPosition"] = (Part.CFrame * CFrame.new(0, 0, CFrameParameter)).p + Vector3.new(math.random(-LastRandom, LastRandom), math.random(-LastRandom, LastRandom), math.random(-LastRandom, LastRandom))})
		Tween:Play()
		Tween:Destroy()

		local Tween = TweenService:Create(Beam, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Width0"] = 0, ["Width1"] = 0})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(Beam, 0.25)
	end
end

function FastWait(Duration)
	Duration = Duration or 1/60
	local StartTime = os.clock()
	while os.clock() - StartTime < Duration do
		RunService.Stepped:Wait()
	end
end

local function returnCFrame(CFrameIndex, ToMultiply)
	local A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12 = CFrameIndex:components()
	return CFrame.new(A1 * ToMultiply, A2 * ToMultiply, A3 * ToMultiply, A4 * ToMultiply, A5 * ToMultiply, A6 * ToMultiply, A7 * ToMultiply, A8 * ToMultiply, A9 * ToMultiply, A10 * ToMultiply, A11 * ToMultiply, A12 * ToMultiply)
end

local SanjiVFX = {

	["AscendTrail"] = function(PathData)
		local Character = PathData.Character
		local Humanoid,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

		-- SoundManager:AddSound("OnDemonStep",{Parent = Root},"Client")

		if GlobalFunctions.CheckDistance(Player, 15) then
			GlobalFunctions.FreshShake(180,100,1,.15)
		end

		VfxHandler.RockExplosion({
			Pos = Root.Position,
			Quantity = 12,
			Radius = 5,
			Size = Vector3.new(1,1,1),
			Duration = 2,
		})

		coroutine.resume(coroutine.create(function()
			local Part = Instance.new("Part")
			Part.CFrame = Root.CFrame * CFrame.new(0,-3,0)
			Part.Anchored = true
			Part.Parent = workspace.World.Visuals

			for _ = 1, 30 do
				RunService.RenderStepped:Wait()
				ToBurn(Part, 30, 40, 50, 50)
			end
			Part:Destroy()
		end))

		local TrailPart = script.AscendTrail.trailp:Clone()
		local MagnitudeIndex = (Root.Position - Root.CFrame.p).Magnitude
		TrailPart.CFrame = CFrame.new(Root.Position, Root.CFrame.Position) * CFrame.new(0, 0, -MagnitudeIndex / 2) * CFrame.Angles(math.rad(90), 0, 0)
		TrailPart.Mesh.Scale = Vector3.new(4, MagnitudeIndex, 4)
		TrailPart.Parent = workspace.World.Visuals

		local Tween = TweenService:Create(TrailPart, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Color"] = Color3.fromRGB(255, 81, 0)})
		Tween:Play()
		Tween:Destroy()

		local Tween = TweenService:Create(TrailPart.Mesh, TweenInfo.new(.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {["Offset"] = Vector3.new(0, -MagnitudeIndex / 2, 0), ["Scale"] = Vector3.new(0, 0, 0)})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(TrailPart, 1)

		local TpBall = script.AscendTrail.tpball:Clone()
		TpBall.CFrame = Root.CFrame
		TpBall.Parent = workspace.World.Visuals

		local Tween = TweenService:Create(TpBall.PointLight, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Range"] = 13, ["Brightness"] = 0})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(TpBall, 3)

		TpBall.back:Emit(15)
		TpBall.back2:Emit(15)
		TpBall.BurningPart:Emit(25)
		TpBall.Attachment.BurningPart:Emit(25)

		local IndexCalculation = MagnitudeIndex / 5
		for Index = 1, IndexCalculation do
			local LerpIndex = Root:Lerp(Root.CFrame, Index / IndexCalculation)

			local RayParam = RaycastParams.new()
			RayParam.FilterType = Enum.RaycastFilterType.Exclude
			RayParam.FilterDescendantsInstances = { workspace.World.Visuals, IndexCalculation }

			local Origin = LerpIndex.Position
			local Direction = LerpIndex.UpVector * -10
			local RaycastResult = workspace:Raycast(Origin, Direction, RayParam) or {
				Position = Origin + Direction
			}

			local Target, Position = RaycastResult.Instance, RaycastResult.Position

			local Trail = script.AscendTrail.trail:Clone()
			Trail.CFrame = CFrame.new(Position)
			Trail.Parent = workspace.World.Visuals
			Trail.BurningPart:Emit(10)
			Trail.Attachment.BurningPart:Emit(6)

			local Tween = TweenService:Create(Trail.PointLight, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Color"] = BrickColor.new("Gold").Color, ["Range"] = 0})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(Trail, 1)
		end;
	end,

	["Anti_Manner_Kick_Course"] = function(PathData)
		local Character = PathData.Character
		local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		local Victim = PathData.Character
		local VRoot,VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

		if GlobalFunctions.CheckDistance(Player, 25) then
			GlobalFunctions.FreshShake(185,35,1,.15)
		end

		-- SoundManager:AddSound("Ground Slam",{Parent = Root, Volume = 3.15}, "Client")

		local Twister = ReplicatedStorage.Assets.Effects.Meshes.Twister2:Clone()
		Twister.Material = Enum.Material.Neon
		Twister.CanCollide = false
		Twister.BrickColor = BrickColor.new("Institutional white")
		Twister.CFrame = CFrame.new(Root.Position) * CFrame.Angles(0, 0, math.rad(-180))
		Twister.Size = Vector3.new(35, 5, 35)
		Twister.Parent = workspace.World.Visuals

		local Tween = TweenService:Create(Twister, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = Twister.CFrame * CFrame.Angles(0, math.rad(180), 0) * CFrame.new(0, -15, 0), ["Transparency"] = 1})
		Tween:Play()
		Tween:Destroy()

		local MeshTween = TweenService:Create(Twister, TweenInfo.new(.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Size"] = Vector3.new(15, 35, 15)})
		MeshTween:Play()
		MeshTween:Destroy()

		Debris:AddItem(Twister,5)

		local EndCalculation = CFrame.new((Root.CFrame * CFrame.new(0, 5, 0)).Position)
		local EndCalculation2 = CFrame.new(Root.Position) * CFrame.Angles(0, 0, math.rad(-180)) * CFrame.new(0, 5, 0)

		local ColorIndex = BrickColor.new("Steel blue").Color
		local WhiteColor = Color3.fromRGB(255, 255, 255)

		local Dust = ReplicatedStorage.Assets.Effects.Particles.DustAntiManner:Clone()
		Dust.Anchored = true
		Dust.CFrame = CFrame.new(Root.CFrame.p) * CFrame.new(0, -Humanoid.HipHeight - 1, 0)
		Dust.Parent = Victim

		local RayParam = RaycastParams.new()
		RayParam.FilterType = Enum.RaycastFilterType.Exclude
		RayParam.FilterDescendantsInstances = { Character, workspace.World.Visuals, Victim}

		local RaycastResult = workspace:Raycast(Root.Position, Vector3.new(0, -1000, 500), RayParam) or {}
		local Target, Position = RaycastResult.Instance, RaycastResult.Position

		if Target then
			Dust.Attachment.dust1.Color = ColorSequence.new(Target.Color)
			Dust.Attachment.dust2.Color = ColorSequence.new(Target.Color)
			Dust.Attachment.Rocks.Color = ColorSequence.new(Target.Color)
			Dust.Attachment.Rocks2.Color = ColorSequence.new(Target.Color)
			Dust.Attachment.dust1.Size = NumberSequence.new(5, 35)
			Dust.Attachment.dust1:Emit(25)
			Dust.Attachment.dust2:Emit(50)
			Dust.Attachment.Rocks:Emit(25)
			Dust.Attachment.Rocks2:Emit(25)
		end
		Debris:AddItem(Dust,3)

		local Rot = CFrame.new(Root.CFrame.Position);

		for Index = 1, 10 do
			local RandomCalculation = math.random(10, 35) / 100;

			local Speedline = ReplicatedStorage.Assets.Effects.Meshes.speedline:Clone();
			Speedline.Color = WhiteColor
			Speedline.Size = Vector3.new(RandomCalculation, math.random(10, 300) / 10, RandomCalculation);
			Speedline.CFrame = Rot * CFrame.new(math.random(-5, 5), math.random(-25, 10), math.random(-5, 5))
			Speedline.Parent = workspace.World.Visuals;

			local Tween = TweenService:Create(Speedline, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = Speedline.CFrame * CFrame.new(0, math.random(10, 80), 0), ["Transparency"] = 1})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(Speedline, .5);
		end

		VfxHandler.Spherezsz({
			Cframe = EndCalculation,
			TweenDuration1 = .25,
			TweenDuration2 = .35,
			Range = 25,
			MinThick = 2,
			MaxThick = 5,
			Part = Root,
			Color = Color3.fromRGB(255, 255, 255),
			Amount = 20
		})

		VfxHandler.Rockszsz({
			Cframe = Root.CFrame, -- Position
			Amount = 15, -- How manay rocks
			Iteration = 15, -- Expand
			Max = 2.5, -- Length upwards
			FirstDuration = .5, -- Rock tween outward start duration
			RocksLength = 3 -- How long the rocks stay for
		})
	end,

	["PartyTable"] = function(PathData)
		local Character = PathData.Character
		local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		local StartTime = os.clock()

		local Dust = ReplicatedStorage.Assets.Effects.Particles.BarrageDust:Clone();
		Dust.Parent = workspace.World.Visuals
		Debris:AddItem(Dust, 10)

		local Weld = Instance.new("Weld")
		Weld.Part0 = Root
		Weld.Part1 = Dust
		Weld.C0 = CFrame.new(0, -Humanoid.HipHeight - 1, 0)
		Weld.Parent = Root

		local Rot = Vector3.new(7, 4, 9) * 1.5;
		local HipCalculation = Humanoid.HipHeight - 1;

		while true do
			wait(.05)
			local End = Root.CFrame * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)

			local BrickColorIndex = BrickColor.new("Really black")
			local Color3Index = Color3.fromRGB(0, 0, 0)
			if math.random(1, 2) == 1 then
				Color3Index = Color3.fromRGB(255, 255, 255)
				BrickColorIndex = BrickColor.new("White")
			end

			local RayParam = RaycastParams.new()
			RayParam.FilterType = Enum.RaycastFilterType.Exclude
			RayParam.FilterDescendantsInstances = { Character, workspace.World.Visuals, workspace.World.Live }

			local RaycastResult = workspace:Raycast(Root.Position, Vector3.new(0, -1000, 500), RayParam) or {}
			local Target, Position = RaycastResult.Instance, RaycastResult.Position

			if Target then
				Dust.Attachment.dust1.Enabled = true;
				Dust.Attachment.dust1.Color = ColorSequence.new(Target.Color);
			else
				Dust.Attachment.dust1.Enabled = false;
			end;
			ToPart(End * CFrame.new(2, math.random(-10, 10) / 10 + 2, 0), End, BrickColorIndex, Vector3.new(Rot.X, 0, Rot.z), Rot / 4, math.random(15, 35) / 100, nil, Enum.EasingStyle.Back, Color3Index, Enum.Material.Neon);

			if os.clock() - StartTime >= 1.75 then break end
		end
		Dust.Attachment.dust1.Enabled = false
		Debris:AddItem(Dust,1)
	end,

	["Spectre"] = function(PathData)
		local Character = PathData.Character
		local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		Character["Right Leg"].Transparency = 1

		local StartTime = os.clock()

		while true do
			RunService.RenderStepped:Wait()

			local SpectreModel = script.Model:Clone()
			SpectreModel:SetPrimaryPartCFrame(Root.CFrame * CFrame.Angles(math.rad(math.random(-10, 10)), math.rad(math.random(-10, 10)), math.random(-360, 360)) * CFrame.new(math.random(-1000, 1000) / 1000, math.random(-1000, 1000) / 1000, -5))
			SpectreModel.Parent = workspace.World.Visuals

			AdjustableToSet(SpectreModel.PrimaryPart, 10)
			AdjustableToSet(SpectreModel.Flame, 10)

			Debris:AddItem(SpectreModel, 0.25)

			local RingEffect = script.ring:Clone()
			RingEffect.CFrame = SpectreModel.PrimaryPart.CFrame * CFrame.new(0, 0, -8) * CFrame.Angles(math.rad(90), math.random(-360, 360), 0)
			RingEffect.Parent = workspace.World.Visuals

			local RandomCalculation = math.random(400, 600) / 100

			local Tween = TweenService:Create(RingEffect, TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Size"] = Vector3.new(RandomCalculation, RingEffect.Size.Y, RandomCalculation), ["Transparency"] = 1})
			Tween:Play()
			Tween:Destroy()

			VfxHandler.Orbies({Parent = RingEffect, Speed = .2, Cframe = CFrame.new(0,0,math.random(3,5)), Amount = 1, Circle = true})
			Debris:AddItem(RingEffect, 0.25)

			if os.clock() - StartTime >= 1.5 then break end
		end

		Character["Right Leg"].Transparency = 0
	end,

	["Coiler"] = function(PathData)
		local Character = PathData.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		local Victim = PathData.Character
		local VRoot,VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

		if GlobalFunctions.CheckDistance(Player, 30) then
			GlobalFunctions.FreshShake(120,25,1,.15)
		end

		local Calculation = VRoot.CFrame - VRoot.Position

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {Character, workspace.World.Visuals, workspace.World.Live}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		-- SoundManager:AddSound("BOOM!",{Parent = Root, Volume = 3}, "Client")

		local windshockwave = ReplicatedStorage.Assets.Effects.Meshes.windshockwave:Clone()
		windshockwave.CFrame = VRoot.CFrame
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
			["Size"] = Vector3.new(30,30,30), -- 60,60,60
			["CFrame"] = windshockwave.CFrame * CFrame.fromEulerAnglesXYZ(0,5,0)
		})

		local windshockwave2 = ReplicatedStorage.Assets.Effects.Meshes.windshockwave2:Clone()
		windshockwave2.CFrame = VRoot.CFrame
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
			["Size"] = Vector3.new(30,30,30), --60,60,60
			["CFrame"] = windshockwave2.CFrame * CFrame.fromEulerAnglesXYZ(0,5,0)
		})

		Debris:AddItem(windshockwave,.35)
		Debris:AddItem(windshockwave2,.35)

		local Cframe = VRoot.CFrame * CFrame.new(0,0,-3)
		local r1 = Cframe.p + Vector3.new(0,30,0)
		local r2 = Cframe.upVector * -200

		local Result = workspace:Raycast(r1,r2,raycastParams)
		if Result and Result.Instance and (Cframe.p - Result.Position).Magnitude < 5 then

			VfxHandler.Rockszsz({
				Cframe = CFrame.new(Result.Position), -- Position
				Amount = 12, -- How Result rocks
				Iteration = 9, -- Expand
				Max = 2, -- Length upwards
				FirstDuration = .35, -- Rock tween outward start duration
				RocksLength = 3 -- How long the rocks stay for
			})

			for _ = 1, 6 do
				local Rock = ReplicatedStorage.Assets.Effects.Meshes.Rock:Clone()
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

				local BlockTrail = ReplicatedStorage.Assets.Effects.Particles.BlockSmoke:Clone()
				BlockTrail.Color = ColorSequence.new(Result.Instance.Color)
				BlockTrail.Enabled = true
				BlockTrail.Parent = Rock

				Debris:AddItem(Rock,3)
				Debris:AddItem(BodyVelocity,.1)
			end

			local CrashSmoke = ReplicatedStorage.Assets.Effects.Meshes.CrashSmoke:Clone()
			CrashSmoke.CanCollide = false
			CrashSmoke.Position = Result.Position
			CrashSmoke.Smoke.Color = ColorSequence.new(Result.Instance.Color)
			CrashSmoke.Smoke:Emit(12)
			CrashSmoke.Anchored = true
			CrashSmoke.Parent = workspace.World.Visuals

			local Rock = ReplicatedStorage.Assets.Effects.Particles.GroundSlamThing.Rocks:Clone()
			Rock:Emit(45)
			Rock.Color = ColorSequence.new(Result.Instance.Color)
			Rock.Parent = CrashSmoke
			delay(1,function()
				CrashSmoke.Smoke.Enabled = false
				Rock.Enabled = false
			end)
			Debris:AddItem(CrashSmoke,3)

			for _ = 1,12 do
				local x,y,z = math.cos(math.rad(math.random(1,6) * 60)),math.cos(math.rad(math.random(1,6 ) * 60)),math.sin(math.rad(math.random(1,6) * 60))
				local Start = VRoot.Position
				local End = Start + Vector3.new(x,y,z)

				local Orbie = ReplicatedStorage.Assets.Effects.Meshes.MeshOribe:Clone()
				Orbie.CFrame = CFrame.new(Start,End)
				Orbie.Size = Vector3.new(1,2,1)

				local OrbieTweenInfo = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

				local Tween = TweenService:Create(Orbie,OrbieTweenInfo,{CFrame = CFrame.new(Start,End)*CFrame.new(0,0,-(math.random(2,5) * 10)),Size = Vector3.new(0,0,24)})
				Tween:Play()
				Tween:Destroy()

				Debris:AddItem(Orbie,.2)
				Orbie.Parent = workspace.World.Visuals
			end
		end

		for Index = 1,2 do
			local Ring = ReplicatedStorage.Assets.Effects.Meshes.ring:Clone()
			Ring.Size = Vector3.new(12,.3,12)
			Ring.Position = VRoot.Position
			Ring.Parent = workspace.World.Visuals

			Debris:AddItem(Ring,3)

			local Tween = TweenService:Create(Ring, TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Size"] = Vector3.new(35,.3,35)})
			Tween:Play()
			Tween:Destroy()

			local ColorIndex = BrickColor.new("Institutional white")

			local Ring = ReplicatedStorage.Assets.Effects.Meshes.Ring2:Clone()
			Ring.BrickColor = ColorIndex
			Ring.Size = Vector3.new(50,3,50)
			Ring.Material = Enum.Material.Neon
			Ring.CanCollide = false
			Ring.CFrame = CFrame.new(VRoot.Position) * Calculation
			Ring.Anchored = true
			Ring.Parent = workspace.World.Visuals

			Debris:AddItem(Ring,.4)

			local RingTween = TweenInfo.new(.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)

			local Tween = TweenService:Create(Ring,RingTween,{CFrame = Ring.CFrame * CFrame.new(0,15,0) ,Size = Vector3.new(0,0,0)})
			Tween:Play()
			Tween:Destroy()

			wait(.2)
		end
	end,

	["Transformation"] = function(PathData)
		local Character = PathData.Character
		local Humanoid,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

		wait(.1)

		coroutine.wrap(function()
			wait(.15)
			local StartTime = os.clock()
			local Start = os.clock()

			while true do
				if os.clock() - StartTime >= .1 then
					local Slash = script.Slash:Clone()

					local Weld = Instance.new("Weld")
					Weld.Part0 = Root
					Weld.Part1 = Slash
					Weld.C0 = CFrame.new(0, 1, 0) * CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
					Weld.Parent = Slash

					local RandomIndex = math.random(15, 18)

					Slash.Mesh.Scale = Vector3.new(-RandomIndex, 1, -RandomIndex)
					Slash.Parent = workspace.World.Visuals

					local Tween = TweenService:Create(Slash.Decal, TweenInfo.new(.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Color3"] = Color3.fromRGB(0, 0, 0)})
					Tween:Play()
					Tween:Destroy()

					local Tween = TweenService:Create(Slash.Mesh, TweenInfo.new(.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Scale"] = Vector3.new(-30, -1, -30)})
					Tween:Play()
					Tween:Destroy()

					local CFrameDebounce = nil
					CFrameDebounce = returnCFrame(CFrame.Angles(0, -.25, 0), .02 * 60)

					Weld.C0 = Weld.C0 * CFrameDebounce

					--VfxHandler.Rotate.Start(Weld, CFrame.Angles(0, -.25, 0))
					Debris:AddItem(Slash, .25)

					StartTime = os.clock()
					if os.clock() - Start >= 1.3 then break end
				end
				RunService.Stepped:Wait()
			end
		end)()

		coroutine.wrap(function()
			-- local Sound = SoundManager:AddSound("OnDemonStep",{Parent = Root, Volume = 2, TimePosition = 0}, "Client")
			FastWait(.285)
			-- SoundManager:AddSound("Spiny",{Parent = Root, Volume = 2}, "Client")
		end)()

		local End = Root.CFrame * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)

		local Dust = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments.DustPUSSH:Clone()

		local RayParam = RaycastParams.new()
		RayParam.FilterType = Enum.RaycastFilterType.Exclude
		RayParam.FilterDescendantsInstances = { Character, workspace.World.Visuals, workspace.World.Live }

		local RaycastResult = workspace:Raycast(Root.Position, Vector3.new(0, -1000, 500), RayParam) or {}
		local Target, Position = RaycastResult.Instance, RaycastResult.Position

		if Target then
			coroutine.resume(coroutine.create(function()
				for _ = 1,3 do
					local Ring = ReplicatedStorage.Assets.Effects.Meshes.ring:Clone()
					Ring.Size = Vector3.new(12,.3,12)
					Ring.Position = Position
					Ring.Parent = workspace.World.Visuals

					Debris:AddItem(Ring,3)

					local Tween = TweenService:Create(Ring, TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Size"] = Vector3.new(35,.3,35)})
					Tween:Play()
					Tween:Destroy()
					wait(.2)
				end
			end))

			Dust.Parent = Root
			for _,v in ipairs(Dust:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v.Color = ColorSequence.new(Target.Color)
				end
			end
		end

		coroutine.wrap(function()
			wait(1.5)
			Dust.ParticleEmitter.Enabled = false

			for _ = 1,math.random(8,10) do
				local x,y,z = math.cos(math.rad(math.random(1,6) * 60)),math.cos(math.rad(math.random(1,6 ) * 60)),math.sin(math.rad(math.random(1,6) * 60))
				local Start = Root.Position
				local End = Start + Vector3.new(x,y,z)

				local Orbie = ReplicatedStorage.Assets.Effects.Meshes.MeshOribe:Clone()
				Orbie.CFrame = CFrame.new(Start,End)
				Orbie.Color = Color3.fromRGB(255, 127, 41)
				Orbie.Size = Vector3.new(1,2,1)

				local OrbieTweenInfo = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

				local Tween = TweenService:Create(Orbie,OrbieTweenInfo,{CFrame = CFrame.new(Start,End)*CFrame.new(0,0,-(math.random(2,5) * 10)),Size = Vector3.new(0,0,24)})
				Tween:Play()
				Tween:Destroy()

				Debris:AddItem(Orbie,.2)
				Orbie.Parent = workspace.World.Visuals
			end

			local Ball = ReplicatedStorage.Assets.Effects.Meshes.regball:Clone()
			Ball.Material = Enum.Material.ForceField
			Ball.Transparency = 0
			Ball.CFrame = Root.CFrame
			Ball.Size = Vector3.new(5,5,5)
			Ball.Color = Color3.fromRGB(255, 101, 24)
			Ball.Parent = workspace.World.Visuals

			local Tween = TweenService:Create(Ball, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Size"] = Vector3.new(35,35,35), ["Transparency"] = 1})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(Ball,2)
			Debris:AddItem(Dust,2)
		end)()

		local FlameLeg = script.Flame:Clone()
		FlameLeg.CFrame = Character["Right Leg"].CFrame * CFrame.Angles(math.rad(-90),0,0) * CFrame.new(0,0,-.35)
		FlameLeg.Parent = Character["Right Leg"]

		-- SoundManager:AddSound("BUNRINGAGA",{Parent = FlameLeg, Volume = .5}, "Client")

		local DemonStepAttachment = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments.demonstep:Clone()
		DemonStepAttachment.Parent = FlameLeg

		local WeldConstraint = Instance.new("WeldConstraint")
		WeldConstraint.Part0 = FlameLeg
		WeldConstraint.Part1 = Character["Right Leg"]
		WeldConstraint.Parent = FlameLeg

		local StartTime = os.clock()
		while os.clock() - StartTime <= 58 and _G.Data.Character == "Sanji" do
			RunService.Heartbeat:Wait()
		end

		for _,v in ipairs(Character:GetDescendants()) do
			if v.Name == "Flame" then
				v:Destroy()
			end
		end
	end,
}

return SanjiVFX
