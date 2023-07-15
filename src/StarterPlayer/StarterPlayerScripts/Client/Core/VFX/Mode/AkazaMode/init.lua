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

local TaskScheduler = require(Utility.TaskScheduler)

local Explosions = require(Modules.Effects.Explosions)
local VfxHandler = require(Modules.Effects.VfxHandler)

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

local AkazaLightning = require(script.AkazaLightning)
local DistanceThunder = require(script.DistanceThunder)
local LightningBolt = require(Modules.Effects.LightningBolt)

local EffectMeshes = ReplicatedStorage.Assets.Effects.Meshes
local EffectParticles = ReplicatedStorage.Assets.Effects.Particles
local EffectBeams = ReplicatedStorage.Assets.Effects.Beams
local World = workspace.World
local Visuals = World.Visuals
local raycastparams = RaycastParams.new()
raycastparams.FilterDescendantsInstances = {workspace.World.Map}
raycastparams.FilterType = Enum.RaycastFilterType.Include

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

local RockColors = {
	Color3.fromRGB(163, 162, 165),
	Color3.fromRGB(124, 120, 111),
	Color3.fromRGB(234, 227, 202),
	Color3.fromRGB(163, 162, 165),
}

local B6 = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

local function createhugelightning(Start,End,numberofparts)
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
		Part.Color = Color3.fromRGB(255, 85, 0)
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

function CreateLightning(Start,End,numberofparts,ColorTing)
	local Lightning = Instance.new("Folder",workspace.World.Visuals)
	Lightning.Name = "Lightning"
	Debris:AddItem(Lightning,2)
	local lastcf = Start
	local Distance = (Start - End).Magnitude / numberofparts

	for Index = 1,numberofparts do
		local x,y,z = math.random(-2,2) * 5,math.random(-2,2) * 5,math.random(-2,2) * 5
		if Index == numberofparts then
			x = 0
			y = 0
			z = 0
		end
		local Color = Index % 2 == 0 and "Daisy orange" or "Daisy orange"

		local newcframe = CFrame.new(lastcf,End + Vector3.new(x,y,z)) * CFrame.new(0,0,-Distance)
		local newdisance = (lastcf - newcframe.p).Magnitude

		local Part = Instance.new("Part")
		Part.Material = Enum.Material.Neon
		Part.BrickColor = BrickColor.new(ColorTing or Color)
		Part.TopSurface = Enum.SurfaceType.SmoothNoOutlines
		Part.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
		Part.CanCollide = false
		Part.Anchored = true
		Part.CastShadow = false	
		Part.Size = Vector3.new(.25,.25,newdisance)
		Part.CFrame = CFrame.new(lastcf,newcframe.p) * CFrame.new(0,0,-newdisance / 2)
		Part.Parent = Lightning

		local Ti2 = TweenInfo.new(.4,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0)
		local Ti3 = TweenInfo.new(.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,4,true,0)

		TweenService:Create(Part,Ti2,{Size = Vector3.new(0,0,newdisance)}):Play()
		TweenService:Create(Part,Ti3,{Transparency = 1}):Play()
		Debris:AddItem(Part,.4)
		lastcf = newcframe.p
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Map}
raycastParams.FilterType = Enum.RaycastFilterType.Include

local AkazaMode = {	
	["Transformation"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")
	end;
	
	["DragonTransformation"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")
		
		local Waves = Particles.ParticleAttatchments.Waves:Clone()
		Waves.Waves.Lifetime = NumberRange.new(0.35)
		Waves.Parent = Root
		local WaitTime = 0.15
		for _ = 1,10 do
			Waves.Waves:Emit(1)
			wait(WaitTime)
		end
	end;	
	
	["AkazaScreen"] = function(Data)
		local ColorCorrection = Instance.new("ColorCorrectionEffect")
		ColorCorrection.Parent = game:GetService("Lighting") 
		
		
		local tween2 = TweenService:Create(ColorCorrection, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["TintColor"] = Color3.fromRGB(204, 204, 204), ["Contrast"] = 0, ["Saturation"] = -1})
		tween2:Play()
		tween2:Destroy()
		
		wait(1.5)
		
		local tween2 = TweenService:Create(ColorCorrection, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["TintColor"] = Color3.fromRGB(0, 0, 0), ["Contrast"] = 0, ["Saturation"] = -1})
		tween2:Play()
		tween2:Destroy()
		
		wait(0.35)
		
		local tween2 = TweenService:Create(ColorCorrection, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["TintColor"] = Color3.fromRGB(255, 0, 0), ["Brightness"] = 0, ["Contrast"] = 0, ["Saturation"] = 0})
		tween2:Play()
		tween2:Destroy()
		
		wait(1)
		
		local tween2 = TweenService:Create(ColorCorrection, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["TintColor"] = Color3.fromRGB(255, 255, 255), ["Brightness"] = 0, ["Contrast"] = 0, ["Saturation"] = 0})
		tween2:Play()
		tween2:Destroy()

		Debris:AddItem(ColorCorrection, 1)
	end;
	
	["FiredUp"] = function(Data)
		local Character = Data.Character		
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		local Enemy = Data.Enemy
		
		local Offset = -2.75
		for i = 1,2 do
			if i == 2 then Offset *= -1 end
			
			local RootCFrame = Root.CFrame * CFrame.new(Offset,0,-3)
			
			local shock = EffectMeshes.upwardShock:Clone()
			shock.CFrame = RootCFrame * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)
			shock.Color = Color3.fromRGB(255, 255, 255)
			shock.Size = Vector3.new(0,0,0)

			local tween = TweenService:Create(shock,TweenInfo.new(.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size = Vector3.new(12, 12, 12), CFrame = shock.CFrame*CFrame.new(0,2,0)*CFrame.Angles(0,math.pi/2,0)})
			tween:Play()
			tween:Destroy()
			delay(0.15, function()
				local tween = TweenService:Create(shock,TweenInfo.new(.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size = Vector3.new(0,10,0), Color = Color3.fromRGB(255, 85, 0)})
				tween:Play()
				tween:Destroy()
				Debris:AddItem(shock,2)
				wait(0.15)
				shock.Transparency = 1
			end)
			shock.Parent = Visuals
			
			VfxHandler.Rockszsz({
				Cframe = RootCFrame, -- Position
				Amount = 10, -- How manay rocks
				Iteration = 5, -- Expand
				Max = 1, -- Length upwards
				FirstDuration = .25, -- Rock tween outward start duration
				RocksLength = 2 -- How long the rocks stay for
			})
			
			--[[ New Shockwave ]]--
			local Shockwave = EffectParticles.ParticleAttatchments.Shockwave:Clone()
			Shockwave.Shockwave.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 50)}
			Shockwave.Shockwave.Parent = shock
			shock.Shockwave:Emit(1)
			
			--[[ Ball Effect ]]--
			local Ball = EffectMeshes.ball:Clone()
			Ball.Color = Color3.fromRGB(255, 0, 0)
			Ball.Material = Enum.Material.ForceField
			Ball.Transparency = 0
			Ball.Size = Vector3.new(4,4,4)
			Ball.CFrame = RootCFrame
			Ball.Parent = Visuals

			local tween = TweenService:Create(Ball, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Size"] = Ball.Size * 5})
			tween:Play()
			tween:Destroy()
			Debris:AddItem(Ball, 0.25)

			--[[ Stars xD ]]--
			local Stars = EffectParticles.ParticleAttatchments.Stars:Clone()
			Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
			Stars.Stars.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}
			Stars.Stars.Drag = 5
			Stars.Stars.Rate = 100
			Stars.Stars.Acceleration = Vector3.new(0,-15,0)
			Stars.Stars.Lifetime = NumberRange.new(0.5,0.75)
			Stars.Stars.Speed = NumberRange.new(75,90)

			Stars.Stars:Emit(25)
			
			Stars.Parent = shock
			Debris:AddItem(Stars, 2)

			--// PointLight
			local PointLight = Instance.new("PointLight")
			PointLight.Color = Color3.fromRGB(255, 255, 127)
			PointLight.Range = 15
			PointLight.Brightness = 5
			PointLight.Parent = shock

			local LightTween = TweenService:Create(PointLight, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Range"] = 0, ["Brightness"] = 0})
			LightTween:Play()
			
			LightTween:Destroy()
			
			local Fire = EffectParticles.FireMagicParticle:Clone()
			local Attachment = Fire.Attachment
			Attachment.Parent = shock
			Fire:Destroy()

			Attachment.Fire.Speed = NumberRange.new(50, 65)
			Attachment.Fire.Drag = 5

			Attachment.Fire.Lifetime = NumberRange.new(0.35, 0.45)
			Attachment.Fire.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 5), NumberSequenceKeypoint.new(1, 0)}
			Attachment.Fire.Acceleration = Vector3.new(0,0,0)
			Attachment.Fire.Rate = 200
			Attachment.Fire.Enabled = true
			Attachment.Fire:Emit(15)
			delay(0.1, function()
				Attachment.Fire.Enabled = false
				Attachment.Fire:Emit(15)
			end)
			Debris:AddItem(Attachment, 1)
			
			--[[ Flying Debris Rock ]]--
			VfxHandler.FlyingRocks({
				i = 3; -- first loop
				j = 4; -- nested loop
				Offset = 3; -- radius from starting pos
				Origin = RootCFrame.Position; -- where to start
				Filter = {Character, World.Live, Visuals}; -- filter raycast
				Size = Vector2.new(1,3); -- size range random from 1,3 
				AxisRange = 80; -- velocity X and Z ranges from (-AxisRange,AxisRange)
				Height = Vector2.new(15,25); -- velocity Y ranges from X,Y
				Percent = 0.25; -- velocity * percent of nested loop
				Duration = 2; -- duration of the debris rock
				IterationDelay = 0; -- delay between each i loop
			})
			
			--[[ Wunbo Orbies ]]--
			VfxHandler.WunboOrbies({
				j = 2; -- j (first loop)
				i = 3; -- i (second loop)
				StartPos = Root.Position; -- where the orbies originate
				Duration = 0.15; -- how long orbies last
				Width = 1; -- width (x,y) sizes
				Length = 5; -- length (z) size
				Color1 = Color3.fromRGB(255, 71, 71); -- color of half of the orbies, color2 is the other half
				Color2 = Color3.fromRGB(255, 255, 255); -- color of half of the orbies, color2 is the other half
				Distance = CFrame.new(0,0,20); -- how far the orbies travel
			})
			
			--[[ Rocks xD ]]--
			local Rocks = EffectParticles.ParticleAttatchments.Rocks:Clone()
			Rocks.Rocks.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, math.random(5,10)/20), NumberSequenceKeypoint.new(1, 0)}
			Rocks.Rocks.Drag = 5
			Rocks.Rocks.Rate = 100
			Rocks.Rocks.Acceleration = Vector3.new(0,-50,0)
			Rocks.Rocks.Lifetime = NumberRange.new(1,1.5)
			Rocks.Rocks.Speed = NumberRange.new(25,50)
			Rocks.Parent = shock
			Rocks.Rocks:Emit(5)
			Debris:AddItem(Rocks, 2)
			
			for _ = 1,5 do createhugelightning(RootCFrame.Position,RootCFrame.Position + Vector3.new(math.random(-15,15),math.random(5,15), math.random(-15,15)),3) end
			wait(0.75)
		end
	end;
	
	["LightningBurst"] = function(Data)
		local Character = Data.Character		
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		local StartTime = os.clock()
		local RockInBetween = 0
		local LastRock = os.clock() - RockInBetween

		-- SoundManager:AddSound("Lightning_Release",{Parent = Root, Volume = 0.5},"Client")
		-- SoundManager:AddSound("Lightning_Release_2",{Parent = Root, Volume = 0.5},"Client")
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

			local Tween = TweenService:Create(DashMesh, TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Color"] = Color3.fromRGB(248, 217, 109)})
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
		Light.Color = Color3.fromRGB(170, 170, 255)
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
			AkazaLightning({Character = Character, Distance = Data.Distance})
		end)

		wait(.425)
		for Index = 1,10 do
			local Max = Max - 10
			local startPos = Data.ContactPointCFrame.p
			local endPos = Character.HumanoidRootPart.CFrame.p
			local amount = 3
			local width = 2.35
			local offsetRange = 5

			local Color = Index % 2 == 0 and "Daisy orange" or "Yellow"

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
	
	["LightningDragonHammer"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")
		
		--[[ Smash Ground ]]--
		for i, v in pairs(Character:GetDescendants()) do
			if v.Name == "AkazaFireEffect" then
				v.Fire.Enabled = false
				v.Fire:Emit(5)
				Debris:AddItem(v, .5)
			end
		end
		--
		VfxHandler.Rockszsz({
			Cframe = Root.CFrame, -- Position
			Amount = 20, -- How manay rocks
			Iteration = 30, -- Expand
			Max = 2, -- Length upwards
			FirstDuration = .25, -- Rock tween outward start duration
			RocksLength = 3 -- How long the rocks stay for
		})
		--
		
		--[[ Ball Effect ]]--
		local Ball = EffectMeshes.ball:Clone()
		Ball.Color = Color3.fromRGB(170, 85, 255)
		Ball.Material = Enum.Material.ForceField
		Ball.Transparency = 0
		Ball.Size = Vector3.new(20, 20, 20)
		Ball.Position = Character.HumanoidRootPart.Position
		Ball.Parent = Visuals

		local tween = TweenService:Create(Ball, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Size"] = Ball.Size * 4})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(Ball, 0.45)

		--[[ Sphere Effect ]]--
		local Sphere = EffectMeshes.Sphere:Clone()
		Sphere.Color = Color3.fromRGB(170, 85, 255)
		Sphere.Material = Enum.Material.Neon
		Sphere.Transparency = 0
		Sphere.Mesh.Scale = Vector3.new(25, 100, 25)
		Sphere.Position = Character.HumanoidRootPart.Position
		Sphere.Parent = Visuals

		local tween = TweenService:Create(Sphere.Mesh, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Scale"] = Vector3.new(0,Sphere.Mesh.Scale.Y,0)})
		tween:Play()
		tween:Destroy()

		Debris:AddItem(Sphere, 0.1)

		--[[ Stars xD ]]--
		local Stars = EffectParticles.ParticleAttatchments.Stars:Clone()
		Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(170, 85, 255))
		Stars.Stars.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0)}
		Stars.Stars.Drag = 5
		Stars.Stars.Rate = 100
		Stars.Stars.Acceleration = Vector3.new(0,-100,0)
		Stars.Stars.Lifetime = NumberRange.new(1, 1.5)
		Stars.Stars.Speed = NumberRange.new(150,200)
		Stars.Parent = Character.HumanoidRootPart

		Stars.Stars.Enabled = true
		Stars.Stars:Emit(100)
		Debris:AddItem(Stars, 2)

		--[[ Fire P00rticle XD ]]--
		local Fire = EffectParticles.FireMagicParticle:Clone()
		local Attachment = Fire.Attachment
		Fire.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,-3,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)

		Attachment.Fire.Speed = NumberRange.new(200, 250)
		Attachment.Fire.Drag = 5

		Attachment.Fire.Lifetime = NumberRange.new(1)
		Attachment.Fire.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 20), NumberSequenceKeypoint.new(1, 0)}
		Attachment.Fire.Acceleration = Vector3.new(0,100,0)
		Attachment.Fire.Rate = 200

		Attachment.Fire.SpreadAngle = Vector2.new(1, 180)
		coroutine.wrap(function()
			Attachment.Fire.Enabled = true
			for i = 1,2 do
				Attachment.Fire:Emit(25)
				wait(0.05)
			end
			Attachment.Fire.Enabled = false
			Stars.Stars.Enabled = false
		end)()
		Fire.Parent = Visuals
		Debris:AddItem(Fire, 1)

		--[[ Flying Debris Rock ]]--
		for i = 1,2 do
			for j = 1,5 do		
				--[[ Raycast ]]--
				local StartPosition = (Vector3.new(math.sin(360*i)*15, 0, math.cos(360*i)*15) + Character.HumanoidRootPart.Position)
				local EndPosition = CFrame.new(StartPosition).UpVector * -10

				local RayData = RaycastParams.new()
				RayData.FilterDescendantsInstances = {Character, World.Live, World.Visuals} or World.Visuals
				RayData.FilterType = Enum.RaycastFilterType.Exclude
				RayData.IgnoreWater = true

				local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
				if ray then

					local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
					if partHit then

						local Block = EffectMeshes.Block:Clone()

						local X,Y,Z = math.random(2,5),math.random(2,5),math.random(2,5)
						Block.Size = Vector3.new(X,Y,Z)

						Block.Position = pos
						Block.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
						Block.Transparency = 0
						Block.Color = partHit.Color
						Block.Material = partHit.Material
						Block.Anchored = false
						Block.Parent = Visuals

						local BodyVelocity = Instance.new("BodyVelocity")
						BodyVelocity.MaxForce = Vector3.new(1000000,1000000,1000000)
						BodyVelocity.Velocity = Vector3.new(math.random(-80,80),math.random(50,60),math.random(-80,80)) * (j*.65)
						BodyVelocity.P = 100000
						Block.Velocity = Vector3.new(math.random(-80,80),math.random(50,60),math.random(-80,80)) * (j*.65)
						BodyVelocity.Parent = Block

						Debris:AddItem(BodyVelocity, .05)
						Debris:AddItem(Block, 2)
					end
				end
			end
			wait()
		end
		
		
	end;
	
	["LightningDragonCrimsonStart"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")
		
		if not Data.SSJRock then
			-- SoundManager:AddSound("LightningFlameRoar",{Parent = Root, Volume = 2},"Client")
		else
			-- SoundManager:AddSound("Fire1",{Parent = Root, Volume = 2},"Client")
		end	
		
		for i, v in ipairs(Character:GetChildren()) do
			if v:IsA("MeshPart") or v:IsA("BasePart") then
				local Fire = EffectParticles.FireMagicParticle:Clone()
				local Attachment = Fire.Attachment
				Attachment.Parent = v
				Fire:Destroy()
				Attachment.Fire.Speed = NumberRange.new(20, 40)
				
				Attachment.Fire.Lifetime = NumberRange.new(0.15, 0.3)
				Attachment.Fire.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(1, 5)}
				Attachment.Fire.Acceleration = Vector3.new(0,1000,0)
				Attachment.Fire.Rate = 50
				Attachment.Fire.ZOffset = -2
				Attachment.Fire.Enabled = true
				Attachment.Fire.LockedToPart = true
				Attachment.Name = "AkazaFireEffect"
			end
		end
		
		local PointLight = Instance.new("PointLight")
		PointLight.Brightness = 2
		PointLight.Range = 100
		PointLight.Color = Color3.fromRGB(255, 170, 0)
		PointLight.Parent = Root
		
		local Tween = TweenService:Create(PointLight, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["Range"] = 0})
		Tween:Play()
		Tween:Destroy()
		Debris:AddItem(PointLight, 0.5)
		
		coroutine.wrap(function()
			for j = 1,2 do
				--
				VfxHandler.Rockszsz({
					Cframe = Root.CFrame, -- Position
					Amount = 8 * j, -- How manay rocks
					Iteration = 6 * j, -- Expand
					Max = 0.5 * j, -- Length upwards
					FirstDuration = .25, -- Rock tween outward start duration
					RocksLength = 2 -- How long the rocks stay for
				})
				--
				--// Lightning 
				local Offset = 20*j
				local StartPosition = (Vector3.new(math.sin(360)*Offset, 0, math.cos(360)*Offset) + (Root.Position - Vector3.new(0,5,0)))

				for i = 1,5 do
					--// lightning contact ripple \\--
					local newStartPosition = Root.Position
					local newEndPosition = (Vector3.new(math.sin(360*i)*Offset, 0, math.cos(360*i)*Offset) + Root.Position)

					local baseBall = EffectMeshes.Block:Clone()
					baseBall.Transparency = 1
					baseBall.Size = Vector3.new(0,0,0)
					baseBall.Anchored = true
					baseBall.CanCollide = false	
					baseBall.Position = newStartPosition
					baseBall.Parent = Visuals

					local ball = EffectMeshes.Block:Clone()
					ball.Transparency = 1
					ball.Size = Vector3.new(0,0,0)
					ball.Anchored = true
					ball.CanCollide = false	
					ball.Position = newEndPosition
					ball.Parent = Visuals		

					local Attachment = Instance.new("Attachment")
					Attachment.Parent = baseBall

					local Attachment2 = Instance.new("Attachment")
					Attachment2.Parent = ball	

					local a1, a2 = Attachment, Attachment2
					for i = 1,2 do
						local ranCF = CFrame.fromAxisAngle((newEndPosition - newStartPosition).Unit, 2*math.random()*math.pi)

						local A1, A2 = {}, {}
						A1.WorldPosition, A1.WorldAxis = a1.WorldPosition, ranCF*a1.WorldAxis
						A2.WorldPosition, A2.WorldAxis = a2.WorldPosition, ranCF*a2.WorldAxis
						local NewBolt = LightningBolt.new(A1, A2, 10)
						NewBolt.CurveSize0, NewBolt.CurveSize1 = 0, 0
						NewBolt.MinRadius, NewBolt.MaxRadius = 0, 5
						NewBolt.Frequency = 1 
						NewBolt.AnimationSpeed = 7 
						NewBolt.Thickness = 0.5
						NewBolt.MinThicknessMultiplier, NewBolt.MaxThicknessMultiplier = 0.2, 1 

						NewBolt.MinTransparency, NewBolt.MaxTransparency = 0, 1
						NewBolt.PulseSpeed = 5
						NewBolt.PulseLength = 1
						NewBolt.FadeLength = 0.2
						NewBolt.ContractFrom = .5

						--Bolt Color Properties--
						if i == 1 then
							NewBolt.Color = Color3.fromRGB(255, 255, 127)
						else
							NewBolt.Color = Color3.fromRGB(255, 255, 127)
						end	
						NewBolt.ColorOffsetSpeed = 5 		
					end
					Debris:AddItem(Attachment, 0.5)	
					Debris:AddItem(ball,  0.5)
					Debris:AddItem(baseBall,  0.5)
				end	
				--
				
				wait(0.25)
			end
		end)()
		if Data.SSJRock then
			for j = 1,25 do
				for i = 1,math.random(1,2) do
					--[[ Raycast ]]--
					local StartPosition = (Vector3.new(math.sin(360 * j) * math.random(10,14), 0, math.cos(360 * j) * math.random(10,14)) + Character.HumanoidRootPart.Position)
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

							local X,Y,Z = math.random(20,50) / 20,math.random(20,50) / 20,math.random(20,50) / 20
							Block.Size = Vector3.new(X,Y,Z)

							Block.Position = pos
							Block.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
							Block.Transparency = 0
							Block.Color = partHit.Color
							Block.Material = partHit.Material
							Block.Parent = workspace.World.Visuals

							local Tween = TweenService:Create(Block, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Orientation"] = Block.Orientation + Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360)), ["Position"] = Block.Position + Vector3.new(0,math.random(10,14),0)})
							Tween:Play()
							Tween:Destroy()

							Debris:AddItem(Block, 0.25)
						end
					end
				end
				wait()
			end
		end
		
	end;
	
	["LightningDragonCrimsonMove"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")
		
		--[[ Fire P00rticle XD ]]--
		coroutine.wrap(function()
			for i = 1,2 do
				local Offset = 1
				if i == 1 then
					Offset = Offset * 5
				else
					Offset = Offset * -5
				end
				local Fire = EffectParticles.FireMagicParticle:Clone()
				local Attachment = Fire.Attachment
				Attachment.Parent = Character.Torso
				Attachment.Position = Attachment.Position + Vector3.new(0,0,Offset)
				Fire:Destroy()

				Attachment.Fire.Speed = NumberRange.new(20,40)
				--Attachment.Fire.Drag = -5

				Attachment.Fire.Lifetime = NumberRange.new(.5)
				Attachment.Fire.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 4), NumberSequenceKeypoint.new(1, 0)}
				Attachment.Fire.Acceleration = Root.CFrame.LookVector * -2000
				Attachment.Fire.Rate = 200

				Attachment.Fire.SpreadAngle = Vector2.new(-360, 360)
				coroutine.wrap(function()
					Attachment.Fire.Enabled = true
					for i = 1,2 do
						Attachment.Fire:Emit(50)
						wait(0.25)
					end
					Attachment.Fire.Enabled = false
				end)()
				Debris:AddItem(Attachment, 0.75)
			end

			wait(0.5)

			--[[ Fire P00rticle XD ]]--
			coroutine.wrap(function()

				local Fire = EffectParticles.FireMagicParticle:Clone()
				local Attachment = Fire.Attachment
				Attachment.Parent = Character.HumanoidRootPart
				Fire:Destroy()

				Attachment.Fire.Speed = NumberRange.new(150, 200)
				Attachment.Fire.Drag = 5

				Attachment.Fire.Lifetime = NumberRange.new(0.5, 0.75)
				Attachment.Fire.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 6), NumberSequenceKeypoint.new(1, 10)}
				Attachment.Fire.Acceleration = Vector3.new(0,0,0)
				Attachment.Fire.Rate = 200

				Attachment.Fire.SpreadAngle = Vector2.new(-180, 180)
				coroutine.wrap(function()
					Attachment.Fire.Enabled = true
					for i = 1,2 do
						Attachment.Fire:Emit(50)
						wait(0.1)
					end
					Attachment.Fire.Enabled = false
				end)()
				Debris:AddItem(Attachment, 1)

				--[[ Stars xD ]]--
				local Stars = EffectParticles.ParticleAttatchments.Stars:Clone()
				Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
				Stars.Stars.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0)}
				Stars.Stars.Drag = 5
				Stars.Stars.Rate = 100
				Stars.Stars.Acceleration = Vector3.new(0,-100,0)
				Stars.Stars.Lifetime = NumberRange.new(0.5, 0.75)
				Stars.Stars.Speed = NumberRange.new(100,200)
				Stars.Parent = Character.HumanoidRootPart

				Stars.Stars.Enabled = true
				Stars.Stars:Emit(100)
				Debris:AddItem(Stars, 1)
				wait(0.2)
				Stars.Stars.Enabled = false
			end)()

		end)()

	end;
	
	["LightningDragonCrimsonEnd"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")
		
		Root.CFrame = Root.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(30),0,0)
		local RootCFrame = Root.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(30),0,0)
		--[[ Small Burst of Fire and Star Particles ]]--
		local Fire = EffectParticles.FireMagicParticle:Clone()
		local Attachment = Fire.Attachment
		Attachment.Parent = Character.HumanoidRootPart
		Fire:Destroy()

		Attachment.Fire.Speed = NumberRange.new(100)
		Attachment.Fire.Drag = 5

		Attachment.Fire.Lifetime = NumberRange.new(0.35, 0.55)
		Attachment.Fire.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 0)}
		Attachment.Fire.Acceleration = Vector3.new(0,-100,0)
		Attachment.Fire.Rate = 200

		Attachment.Fire.SpreadAngle = Vector2.new(-180, 180)
		Attachment.Fire:Emit(50)
		Debris:AddItem(Attachment, 2)

		--[[ Stars xD ]]--
		local Stars = EffectParticles.ParticleAttatchments.Stars:Clone()
		Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
		Stars.Stars.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0)}
		Stars.Stars.Drag = 5
		Stars.Stars.Rate = 100
		Stars.Stars.Acceleration = Vector3.new(0,0,0)
		Stars.Stars.Lifetime = NumberRange.new(0.35, 0.45)
		Stars.Stars.Speed = NumberRange.new(120,150)
		Stars.Parent = Character.HumanoidRootPart

		Stars.Stars:Emit(50)
		Debris:AddItem(Stars, 2)

		--[[ Fancy Wave ]]--
		local FancyWave = EffectParticles.ParticleAttatchments.FancyWave:Clone()
		FancyWave.FancyWave.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
		FancyWave.FancyWave.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 0)}
		FancyWave.FancyWave.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}
		FancyWave.FancyWave.Rate = 100
		FancyWave.FancyWave.Lifetime = NumberRange.new(0.2)
		FancyWave.FancyWave.Parent = Attachment

		FancyWave:Destroy()

		wait(0.25)
		--[[ Ring ]]--
		coroutine.wrap(function()
			local WaitTime = 0.15
			for j = 1,5 do

				local RingInnit = EffectMeshes.RingInnit:Clone()
				RingInnit.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,1,-1)* CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
				RingInnit.Size = Vector3.new(15,0.5,15)
				RingInnit.Transparency = 0
				RingInnit.Parent = Visuals
				local tween = TweenService:Create(RingInnit, TweenInfo.new(WaitTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Size"] = Vector3.new(0,.5,0)})
				tween:Play()
				tween:Destroy()
				Debris:AddItem(RingInnit, WaitTime)

				wait(WaitTime)
				--WaitTime = WaitTime - (j/10)
			end
		end)()

		--[[ Orbies come IN ]]--
		for j = 1,5 do
			for i = 1,5 do
				local RootPosition = Character.Torso.CFrame

				local originalPos = CFrame.new(RootPosition.Position + Vector3.new(math.random(-3,3)*5,math.random(-3,3)*5,math.random(-3,3)*5), RootPosition.Position)
				local beam = EffectMeshes.Block:Clone()
				beam.Shape = "Block"
				local mesh = Instance.new("SpecialMesh")
				mesh.MeshType = "Sphere"
				mesh.Parent = beam
				beam.Size = Vector3.new(1,1,5)
				beam.Material = Enum.Material.Neon
				beam.Color = Color3.fromRGB(255, 85, 0)
				beam.Transparency = 0
				beam.Parent = Visuals
				beam.CFrame = CFrame.new(originalPos.Position + Vector3.new(math.random(-1,1),math.random(-1,1),math.random(-1,1)), RootPosition.Position) 
				local tween = TweenService:Create(beam, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Size"] = beam.Size + Vector3.new(0,0, math.random(1,2)), ["Position"] = RootPosition.Position})
				local tween2 = TweenService:Create(beam, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {["Size"] = Vector3.new(0,0,5)})		
				tween:Play()
				tween:Destroy()
				tween2:Play()
				tween2:Destroy()
				Debris:AddItem(beam, .15)						
			end
			Attachment.FancyWave:Emit(5)
			wait(0.1)
			if j == 3 then
				--// play dragon roar
				-- SoundManager:AddSound("DragonRoar", {Parent = Character.HumanoidRootPart, Volume = 1}, "Client")
			end	
		end
		
		--[[ Expand Lines Out ]]--
		coroutine.wrap(function()
			for i = 1,15 do
				local originalPos = Character.HumanoidRootPart.Position
				local beam = EffectMeshes.Block:Clone()
				beam.Shape = "Block"
				local mesh = Instance.new("SpecialMesh")
				mesh.MeshType = "Sphere"
				mesh.Parent = beam
				beam.Size = Vector3.new(5,5,5)
				beam.Material = Enum.Material.Neon
				beam.Color = Color3.fromRGB(255, 98, 101)
				beam.Transparency = 0
				beam.Parent = Visuals

				beam.CFrame = CFrame.new(originalPos + Vector3.new(math.random(-1,1),1,math.random(-1,1)), originalPos) 
				local tween = TweenService:Create(beam, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Size"] = beam.Size + Vector3.new(0,0, math.random(2,5)), ["CFrame"] = beam.CFrame * CFrame.new(0,0,math.random(20,40))})
				local tween2 = TweenService:Create(beam, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {["Size"] = Vector3.new(0,0,10)})		
				tween:Play()
				tween:Destroy()
				tween2:Play()
				tween2:Destroy()
				Debris:AddItem(beam, .2)						
			end
		end)()

		--[[ FRONT OF GOING CIRCLE Fire P00rticle XD ]]--
		local FrontFire = EffectParticles.FireMagicParticle:Clone()
		local FrontAttachment = FrontFire.Attachment
		FrontFire.CFrame = Character.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(90))

		FrontAttachment.Fire.Speed = NumberRange.new(150, 180)
		FrontAttachment.Fire.Drag = 5

		FrontAttachment.Fire.Lifetime = NumberRange.new(.5)
		FrontAttachment.Fire.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 0)}
		FrontAttachment.Fire.Acceleration = Vector3.new(0,100,0)
		FrontAttachment.Fire.Rate = 200

		FrontAttachment.Fire.SpreadAngle = Vector2.new(1, 180)
		coroutine.wrap(function()
			FrontAttachment.Fire.Enabled = true
			for i = 1,2 do
				FrontAttachment.Fire:Emit(25)
				wait(0.05)
			end
			FrontAttachment.Fire.Enabled = false
		end)()
		FrontFire.Parent = Visuals
		Debris:AddItem(FrontFire, 1)

		--[[ Fire P00rticle XD ]]--
		local RoarFire = EffectParticles.FireMagicParticle:Clone()
		RoarFire.Shape = "Block"
		RoarFire.Attachment.Fire.Parent = RoarFire

		RoarFire.Size = Vector3.new(10,10,100)
		RoarFire.Transparency = 1
		RoarFire.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-45)
		RoarFire.Parent = Visuals

		RoarFire.Fire.Speed = NumberRange.new(100)
		RoarFire.Fire.Drag = 5

		RoarFire.Fire.Lifetime = NumberRange.new(0.5, 0.75)
		RoarFire.Fire.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 15), NumberSequenceKeypoint.new(1, 0)}
		RoarFire.Fire.Acceleration = Character.HumanoidRootPart.CFrame.LookVector*250
		RoarFire.Fire.Rate = 500

		RoarFire.Fire.SpreadAngle = Vector2.new(-360, 360)

		--[[ Stars xD ]]--
		local Stars = EffectParticles.ParticleAttatchments.Stars:Clone()
		Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
		Stars.Stars.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}
		Stars.Stars.Drag = 5
		Stars.Stars.Rate = 100
		Stars.Stars.Enabled = true
		Stars.Stars.Acceleration = Character.HumanoidRootPart.CFrame.LookVector*50
		Stars.Stars.Lifetime = NumberRange.new(1, 1.5)
		Stars.Stars.Speed = NumberRange.new(50,75)
		Stars.Stars.Parent = RoarFire
		Stars:Destroy()

		coroutine.wrap(function()
			RoarFire.Fire.Enabled = true
			for i = 1,2 do
				RoarFire.Fire:Emit(50)
				RoarFire.Stars:Emit(10)
				DistanceThunder({Character = Character, Position = (RootCFrame * CFrame.fromEulerAnglesXYZ(-math.rad(22),0,0) * CFrame.new(0,0,-100)).Position})
				wait(0.1)
			end
			RoarFire.Fire.Enabled = false
			RoarFire.Stars.Enabled = false
		end)()
		Debris:AddItem(RoarFire, 2)
		--[[ Ring ]]--
		coroutine.wrap(function()
			for i = 0,7 do
				local RingInnit = EffectMeshes.RingInnit:Clone()
				RingInnit.CFrame = RootCFrame * CFrame.fromEulerAnglesXYZ(-math.rad(22),0,0) * CFrame.new(0,-10,-(i*10)) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
				RingInnit.Size = Vector3.new(5,0,5)
				RingInnit.Transparency = 0
				RingInnit.Parent = Visuals

				local tween = TweenService:Create(RingInnit, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Size"] = Vector3.new(50,0,50)})
				tween:Play()
				tween:Destroy()
				Debris:AddItem(RingInnit, 0.15)
				wait(0.025)
			end
		end)()
		wait(0.2)
		for i, v in pairs(Character:GetDescendants()) do
			if v.Name == "AkazaFireEffect" then
				v.Fire.Enabled = false
				v.Fire:Emit(5)
				Debris:AddItem(v, .5)
			end
		end
	end;
}

return AkazaMode