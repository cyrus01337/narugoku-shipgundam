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
	local SizeIndex = Part.Size * math.random(90, 130) / 100
	local RandomCalculation = math.random(100, 1000) / 5000
	Part.Size = Vector3.new(RandomCalculation, RandomCalculation, Part.Size.Z)

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
	local Part = script.table1:Clone()
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
	end
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

local SanjiModeVFX = {

	["FLASHKICKHITTTTT"] = function(PathData)
		local Character = PathData.Character
		local Victim = PathData.Victim

		local VRoot = Victim:FindFirstChild("HumanoidRootPart")
		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

		local _ = Character.Name == Players.LocalPlayer.Name and GlobalFunctions.FreshShake(185,35,1,.15)

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4)
		BodyVelocity.Velocity = (VRoot.CFrame.Position - HumanoidRootPart.CFrame.Position).Unit * 10
		BodyVelocity.Parent = HumanoidRootPart
		Debris:AddItem(BodyVelocity,.2)

		local EnemyVelocity = Instance.new("BodyVelocity")
		EnemyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4)
		EnemyVelocity.Velocity = CFrame.new(HumanoidRootPart.Position,HumanoidRootPart.Position + (HumanoidRootPart.CFrame.lookVector * 2) + (HumanoidRootPart.CFrame.upVector * 8)).lookVector * 100
		EnemyVelocity.Parent = VRoot
		Debris:AddItem(EnemyVelocity,.1)

		--Victim.Humanoid:LoadAnimation(ReplicatedStorage.Assets.Animations.HitReactions["Hit4"]):Play()
		-- SoundManager:AddSound("Punched4",{Parent = Character:FindFirstChild("HumanoidRootPart"),Volume = 9},"Client")
	end,

	["DemonAxeExplode"] = function(PathData)
		local Character = PathData.Character
		local Humanoid,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

		local Victim = PathData.Victim
		local VHum,VRoot = Victim:FindFirstChild("Humanoid"),Victim:FindFirstChild("HumanoidRootPart")

		local ColorIndex = script.DemonAxeExplode.Part.Color
		local Color = Color3.fromRGB(255, 81, 0)

		if math.random(1, 2) == 1 then
			ColorIndex = Color
		end

		-- SoundManager:AddSound("VenomDragon_Explosion", {Parent = Root, Volume = 2}, "Client")

		local RaycastResult = Ray.new(VRoot.Position, Vector3.new(0,-1000,0))
		local Target,Position = workspace:FindPartOnRayWithIgnoreList(RaycastResult, {Character, workspace.World.Visuals}, false, false)
		if Target then
			local Dust = script.DemonAxeExplode.dust:Clone()
			Dust.CFrame = CFrame.new(Position) * CFrame.Angles(math.rad(-90), 0, 0)
			Dust.Parent = workspace.World.Visuals

			Dust.Attachment.Rocks.Color = ColorSequence.new(Target.Color)
			Dust.Attachment.dust1.Color = ColorSequence.new(Target.Color)
			Dust.Attachment.Rocks:Emit(60)
			Dust.Attachment.dust1:Emit(50)
			Dust.Attachment.BurningPart.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 5, 5), NumberSequenceKeypoint.new(0.5, 20, 5), NumberSequenceKeypoint.new(1, 0, 0) })
			Dust.Attachment.BurningPart:Emit(80)
			Dust.Attachment.BurningPart2:Emit(30)

			Debris:AddItem(Dust, 1)

			VfxHandler.Shockwave2(Dust.CFrame, Dust.CFrame, BrickColor.new("White"), Vector3.new(100, 4, 100), Vector3.new(30, 4, 30), 0.5, -1, Enum.EasingStyle.Quad, Color3.fromRGB(255, 255, 255), Enum.Material.Neon, "Rings")

			local PartTing2 = script.DemonAxeExplode.Part:Clone()
			PartTing2.CFrame = CFrame.new(Position)
			PartTing2.Material = Enum.Material.ForceField
			PartTing2.Transparency = -5
			PartTing2.Mesh.Scale = Vector3.new(75, 75, 75) / 4
			PartTing2.Parent = workspace.World.Visuals

			local Tween = TweenService:Create(PartTing2.Mesh, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Scale"] = Vector3.new(75, 75, 75)})
			Tween:Play()
			Tween:Destroy()

			local Tween = TweenService:Create(PartTing2, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(PartTing2, .25)

			local PartTing = script.DemonAxeExplode.Part:Clone()
			PartTing.CFrame = CFrame.new(Position)
			PartTing.Mesh.Scale = Vector3.new(25, 45, 25)
			PartTing.Parent = workspace.World.Visuals

			local Tween = TweenService:Create(PartTing.Mesh, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Scale"] = Vector3.new(0, PartTing.Mesh.Scale.Y + 15, 0), ["Offset"] = Vector3.new(0, 22.5, 0)})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(PartTing, .15)

			local EndCalculation = CFrame.new((VRoot.CFrame * CFrame.new(0, 5, 0)).Position)

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

			local End = CFrame.new(VRoot.Position, VRoot.Position + Position) * CFrame.Angles(math.rad(-90), 0, 0)

			for Index = 1, 8 do
				local PartTingz = script.DemonAxeExplode.Part:Clone()
				PartTingz.CFrame = CFrame.new(Position) * CFrame.Angles(0, math.rad(Index * 45), 0) * CFrame.new(0, -2, 22.5)
				PartTingz.CFrame = CFrame.new(Position, Position) * CFrame.Angles(0, math.rad(90), 0)
				PartTingz.Mesh.Scale = Vector3.new(35, 35, 35) / 2
				PartTingz.Parent = workspace.World.Visuals

				local Tween = TweenService:Create(PartTingz.Mesh, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Scale"] = Vector3.new(35, 35, 35)})
				Tween:Play()
				Tween:Destroy()

				local Tween = TweenService:Create(PartTingz, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Color"] = Color, ["Transparency"] =1 })
				Tween:Play()
				Tween:Destroy()

				Debris:AddItem(PartTingz, .25)
			end
		end
	end,

	["AscendKick"] = function(PathData)
		local Character = PathData.Character
		local Humanoid,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

		local SphereEffect = script.AscendKick.sphere:Clone()
		SphereEffect.CFrame = Root.CFrame * CFrame.new(0, 0, -40) * CFrame.Angles(math.rad(90), 0, math.rad(180))
		SphereEffect.Mesh.Scale = Vector3.new(12, 80, 12)
		SphereEffect.Parent = workspace.World.Visuals

		local Tween = TweenService:Create(SphereEffect.Mesh, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Offset"] = Vector3.new(0, 47.5, 0), ["Scale"] = Vector3.new(0, SphereEffect.Mesh.Scale.Y + 15, 0)})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(SphereEffect, 0.15)

		local CFrameCalculation = Root.CFrame * CFrame.new(0, 0, 3) * CFrame.Angles(math.rad(-90), 0, 0)

		VfxHandler.Spherezsz({
			Cframe = CFrameCalculation,
			TweenDuration1 = .2,
			TweenDuration2 = .2,
			Range = 0,
			MinThick = 20,
			MaxThick = 40,
			Part = nil,
			Color = script.AscendKick.sphere.Color,
			Amount = 25
		})

		VfxHandler.Shockwave2(CFrameCalculation * CFrame.new(0, 60, 0), CFrameCalculation, BrickColor.new("Pastel Blue"), Vector3.new(35, 2, 35), Vector3.new(5, 2, 5), 0.5, -1, Enum.EasingStyle.Quad, Color3.fromRGB(255, 255, 255), Enum.Material.Neon, "Rings")
		VfxHandler.Shockwave2(CFrameCalculation * CFrame.new(0, 20, 0), CFrameCalculation, BrickColor.new("Neon orange"), Vector3.new(60, 2, 60), Vector3.new(5, 2, 5), 0.4, -1, Enum.EasingStyle.Quad, Color3.fromRGB(255, 132, 60), Enum.Material.Neon, "Ring2")

		local Part = script.AscendKick.Part:Clone()
		Part.CFrame = CFrameCalculation
		Part.Mesh.Offset = Vector3.new(0, 12.5, 0)
		Part.Mesh.Scale = Vector3.new(20, 25, 20)
		Part.Parent = workspace.World.Visuals

		local Tween = TweenService:Create(Part.Mesh, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Offset"] = Vector3.new(0, 25, 0), ["Scale"] = Vector3.new(0, 0, 0)})
		Tween:Play()
		Tween:Destroy()

		local Tween = TweenService:Create(Part, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(Part, 0.25)

		local MeshPart = script.AscendKick.MeshPart:Clone()
		MeshPart.CFrame = CFrameCalculation * CFrame.Angles(0, math.rad(math.random(-360, 360)), math.rad(90))
		MeshPart.Parent = workspace.World.Visuals

		local Tween = TweenService:Create(MeshPart, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			["CFrame"] = MeshPart.CFrame * CFrame.new(50, 0, 0) * CFrame.Angles(math.rad(math.random(-360, 360)), 0, 0),
			["Size"] = MeshPart.Size * 4 + Vector3.new(10, 0, 0),
		})
		Tween:Play()
		Tween:Destroy()

		--	Tween.Completed:Wait()

		local Tween = TweenService:Create(MeshPart, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(MeshPart, 0.5)

		local Burst = script.AscendKick.Burst:Clone()
		Burst.Position = Root.Position
		Burst.Transparency = 1
		Burst.Parent = workspace.World.Visuals

		VfxHandler.Emit(Burst.Burst, 80)
		VfxHandler.Emit(Burst.ParticleEmitter2,30)

		Debris:AddItem(Burst,3)

		local PunchedParticle = script.AscendKick.PunchedParticle:Clone()
		PunchedParticle.CFrame = CFrameCalculation
		PunchedParticle.Parent = workspace.World.Visuals
		PunchedParticle.Attachment.new3:Emit(80)
		PunchedParticle.Attachment.back:Emit(80)
		PunchedParticle.Attachment.back2:Emit(50)
		PunchedParticle.Attachment.ring:Emit(1)
		PunchedParticle.Attachment.new3.Size = NumberSequence.new(18, 0)

		Debris:AddItem(PunchedParticle, 2)

		for _ = 1, 20 do
			local Sph = script.AscendKick.sph:Clone()
			Sph.CFrame = Root.CFrame * CFrame.Angles(math.rad(90), 0, 0) * CFrame.new(math.random(-15, 15), 0, math.random(-15, 15))
			Sph.Parent = workspace.World.Visuals
			local RandomIndex = math.random(3000, 6000) / 1000
			Sph.Mesh.Scale = Vector3.new(RandomIndex, math.random(500, 5000) / 100, RandomIndex)
			if math.random(1, 2) == 1 then
				Sph.Color = Color3.fromRGB(213, 115, 61)
			end
			local RandomIndex2 = math.random(200, 400) / 1000

			local Tween = TweenService:Create(Sph.Mesh, TweenInfo.new(RandomIndex2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				["Scale"] = Vector3.new(0, Sph.Mesh.Scale.Y, 0),
				["Offset"] = Vector3.new(0, -Sph.Mesh.Scale.Y * math.random(2, 5), 0)
			})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(Sph, RandomIndex2)
		end
	end,

	["TeleportKick"] = function(PathData)
		local Character = PathData.Character
		local Hum,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

		local Victim = PathData.Victim
		local VHum,VRoot = Victim:FindFirstChild("Humanoid"),Victim:FindFirstChild("HumanoidRootPart")

		-- SoundManager:AddSound("Teleport",{Parent = Root, Volume = 2.5}, "Client")

		local Tween = TweenService:Create(Root,TweenInfo.new(PathData.Duration or .15,Enum.EasingStyle.Quad),{CFrame = VRoot.CFrame * CFrame.new(0,0,3)})
		Tween:Play()
		Tween:Destroy()
	end,

	["AscendTrail"] = function(PathData)
		local Character = PathData.Character
		local Humanoid,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

		-- SoundManager:AddSound("OnDemonStep",{Parent = Root},"Client")

		local _ = Character.Name == Players.LocalPlayer.Name and GlobalFunctions.FreshShake(180,100,1,.15)

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
			local Target, Position = workspace:FindPartOnRayWithIgnoreList(Ray.new(LerpIndex.p, LerpIndex.upVector * -10), {workspace.World.Visuals, IndexCalculation})

			local Trail = script.AscendTrail.trail:Clone()
			Trail.CFrame = CFrame.new(Position)
			Trail.Parent = workspace.World.Visuals
			Trail.BurningPart:Emit(10)
			Trail.Attachment.BurningPart:Emit(6)

			local Tween = TweenService:Create(Trail.PointLight, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Color"] = BrickColor.new("Gold").Color, ["Range"] = 0})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(Trail, 1)
		end
	end,

	["SetDash"] = function(PathData)
		local Character = PathData.Character
		local Hum,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

		-- SoundManager:AddSound("FireProc",{Parent = Root, Volume = 8, Looped = true},"Client",{Duration = 2})

		wait(.45)

		for _,v in ipairs(script.DashPart:GetChildren()) do
			if v:IsA("ParticleEmitter") or v:IsA("PointLight") then
				local ParticleNdLight = v:Clone()
				ParticleNdLight.Parent = Root

				delay(1,function()
					if ParticleNdLight:IsA("ParticleEmitter") then
						ParticleNdLight.Enabled = false
					end
				end)

				Debris:AddItem(ParticleNdLight,2)
			end
		end
	end,

	["Anti_Manner_Kick_Course"] = function(PathData)
		local Character = PathData.Character
		local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		local Victim = PathData.Character
		local VRoot,VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

		local _ = Character.Name == Players.LocalPlayer.Name and GlobalFunctions.FreshShake(185,35,1,.15)
		-- SoundManager:AddSound("Ground Slam",{Parent = Root, Volume = 3.15}, "Client")

		local Twister = ReplicatedStorage.Assets.Effects.Meshes.Twister2:Clone()
		Twister.Material = Enum.Material.Neon
		Twister.CanCollide = false
		Twister.BrickColor = BrickColor.new("Neon orange")
		Twister.CFrame = CFrame.new(Root.Position) * CFrame.Angles(0, 0, math.rad(-180))
		Twister.Size = Vector3.new(35, 5, 35)
		Twister.Parent = workspace.World.Visuals

		local Burst = script.AscendKick.Burst:Clone()
		Burst.Position = Root.Position
		Burst.Transparency = 1
		Burst.Parent = workspace.World.Visuals

		VfxHandler.Emit(Burst.Burst, 80)
		VfxHandler.Emit(Burst.ParticleEmitter2,30)

		Debris:AddItem(Burst,3)

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

		local RaycastResult = Ray.new(Root.Position, Vector3.new(0,-1000,500))
		local Target,Position = workspace:FindPartOnRayWithIgnoreList(RaycastResult, {Character, workspace.World.Visuals, Victim}, false, false)
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

		local Rot = CFrame.new(Root.CFrame.Position)

		for Index = 1, 10 do
			local RandomCalculation = math.random(10, 35) / 100

			local Speedline = ReplicatedStorage.Assets.Effects.Meshes.speedline:Clone()
			Speedline.Color = WhiteColor
			Speedline.Size = Vector3.new(RandomCalculation, math.random(10, 300) / 10, RandomCalculation)
			Speedline.CFrame = Rot * CFrame.new(math.random(-5, 5), math.random(-25, 10), math.random(-5, 5))
			Speedline.Parent = workspace.World.Visuals

			local Tween = TweenService:Create(Speedline, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = Speedline.CFrame * CFrame.new(0, math.random(10, 80), 0), ["Transparency"] = 1})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(Speedline, .5)
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

		local Dust = ReplicatedStorage.Assets.Effects.Particles.BarrageDust:Clone()
		Dust.Parent = workspace.World.Visuals
		Debris:AddItem(Dust, 10)

		local Weld = Instance.new("Weld")
		Weld.Part0 = Root
		Weld.Part1 = Dust
		Weld.C0 = CFrame.new(0, -Humanoid.HipHeight - 1, 0)
		Weld.Parent = Root

		local Rot = Vector3.new(7, 3, 9) * 1.5
		local HipCalculation = Humanoid.HipHeight - 1

		while true do
			wait(.05)
			local End = Root.CFrame * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)

			local BrickColorIndex = BrickColor.new("Really black")
			local Color3Index = Color3.fromRGB(0, 0, 0)
			if math.random(1, 2) == 1 then
				Color3Index =  Color3.fromRGB(255, 128, 37)
				BrickColorIndex = BrickColor.new("Neon orange")
			end

			local RaycastResult = Ray.new(Root.Position, Vector3.new(0,-1000,500))
			local Target,Position = workspace:FindPartOnRayWithIgnoreList(RaycastResult, {Character, workspace.World.Visuals, workspace.World.Live}, false, false)
			if Target then
				Dust.Attachment.dust1.Enabled = true
				Dust.Attachment.dust1.Color = ColorSequence.new(Target.Color)
			else
				Dust.Attachment.dust1.Enabled = false
			end
			ToPart(End * CFrame.new(2, math.random(-10, 10) / 10 + 2, 0), End, BrickColorIndex, Vector3.new(Rot.X, 0, Rot.z), Rot / 4, math.random(15, 35) / 100, nil, Enum.EasingStyle.Back, Color3Index, Enum.Material.Neon)

			if os.clock() - StartTime >= 1.725 then break end
		end
		Dust.Attachment.dust1.Enabled = false
		Debris:AddItem(Dust,1)
	end,

	["Spectre"] = function(PathData)
		local Character = PathData.Character
		local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		Character["Right Leg"].Transparency = 1
		Character["Right Leg"].Flame.Transparency = 1
		for _,v in ipairs(Character["Right Leg"].Flame:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end

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

		if Character["Right Leg"]:FindFirstChild("Flame") then
			Character["Right Leg"].Flame.Transparency = 0
			for _,Particle in ipairs(Character["Right Leg"].Flame:GetDescendants()) do
				if Particle:IsA("ParticleEmitter") then
					Particle.Enabled = true
				end
			end
		end
	end,

}

return SanjiModeVFX
