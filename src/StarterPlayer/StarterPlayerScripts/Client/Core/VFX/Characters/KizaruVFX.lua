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

local EffectMeshes = ReplicatedStorage.Assets.Effects.Meshes
local EffectParticles = ReplicatedStorage.Assets.Effects.Particles
local EffectBeams = ReplicatedStorage.Assets.Effects.Beams
local Particles = ReplicatedStorage.Assets.Effects.Particles
local EffectTrails = ReplicatedStorage.Assets.Effects.Trails

local Metadata = Modules.Metadata
local Effects = Modules.Effects
local Utility = Modules.Utility
local Shared = Modules.Shared

local HitPart2 = Models.Misc.HitPart2
local BezierModule = require(Modules.Utility.BezierModule)


--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)
local VfxHandler = require(Effects.VfxHandler)
local SoundManager = require(Shared.SoundManager)

local CameraShaker = require(Effects.CameraShaker)

local CurrentCamera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
end)	

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GetMouse = ReplicatedStorage.Remotes.GetMouse

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Humanoid = Character:WaitForChild("Humanoid")

local RingTween = TweenInfo.new(.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)
local TweenInf = TweenInfo.new(.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
local B5 = TweenInfo.new(.15,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Map}
raycastParams.FilterType = Enum.RaycastFilterType.Include

local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Visuals = workspace.World.Visuals

local KizaruVFX = {
	["secondform"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
				
		local End = Root.CFrame
		local Position1,Position2 = End.p,End.upVector * -200		
		
		local circleslash = script.circleslash:Clone()
		local one = circleslash.one
		local two = circleslash.two
		local StartSizeOne = Vector3.new(15,15,1)
		local StartSizeTwo = Vector3.new(15,15,2)
		local Multiple = math.random(2,2.5)

		one.Size = StartSizeOne
		two.Size = StartSizeTwo
		circleslash.Parent = Visuals

		one.CFrame = Root.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
		two.CFrame = Root.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)

		Debris:AddItem(circleslash, .5)
		--// PointLight
		local PointLight = Instance.new("PointLight")
		PointLight.Color = Color3.fromRGB(120, 201, 255)
		PointLight.Range = 25
		PointLight.Brightness = 1
		PointLight.Parent = one

		local LightTween = TweenService:Create(PointLight, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Range"] = 0, ["Brightness"] = 0})
		LightTween:Play()
		LightTween:Destroy()

		--// Tween one		
		local TweenOne = TweenService:Create(one, TweenInfo.new(.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = one.CFrame * CFrame.Angles(math.rad(3.36),math.rad(-80.51),math.rad(-12.76)),["Size"] = StartSizeOne * Multiple})
		TweenOne:Play()
		TweenOne:Destroy()

		--// Tween two
		local TweenTwo = TweenService:Create(two, TweenInfo.new(.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = two.CFrame * CFrame.Angles(math.rad(3.36),math.rad(-80.51),math.rad(-12.76)),["Size"] = StartSizeTwo * Multiple})
		TweenTwo:Play()
		TweenTwo:Destroy()

		wait(.05)

		--// Tween Decals
		for _, v in ipairs(one:GetChildren()) do
			if v:IsA("Decal") then
				local tween = TweenService:Create(v, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
				tween:Play()
				tween:Destroy()
			end	
		end

		for _, v in ipairs(two:GetChildren()) do
			local tween = TweenService:Create(v, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
			tween:Play()
			tween:Destroy()
		end
		
		VfxHandler.Spherezsz({
			Cframe = End, 
			TweenDuration1 = .3, 
			TweenDuration2 = .35, 
			Range = 8, 
			MinThick = 12, 
			MaxThick = 25, 
			Part = nil, 
			Color = Color3.fromRGB(255, 255, 127),
			Amount = 8
		})
		
		local RaycastResult = workspace:Raycast(Position1,Position2,raycastParams)
		if RaycastResult and RaycastResult.Instance and (RaycastResult.Position - Position1).Magnitude < 30 then
			for Index = 1,10 do
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

				local Dust = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments["Dust"]:Clone()
				Dust.P1.Color = ColorSequence.new(RaycastResult.Instance.Color)
				Dust.Parent = Root

				VfxHandler.Emit(Dust.P1,3)
				Debris:AddItem(Dust,2)
			end
		end
	end,	
	
	["WaterStuff"] = function(Data)
		local Character = Data.Character
		for Index = 1,Data.Amount or 5 do
			local Cframe,Size = Character:GetBoundingBox()
			local Options = {-5,5}

			local Slice = ReplicatedStorage.Assets.Effects.Meshes.Cut:Clone()
			local NormalSize = Slice.Size
			
			Slice.Water.Color = ColorSequence.new(Color3.fromRGB(255, 92, 52))

			Slice.Water.Enabled = true
			Slice.Transparency = 1
			Slice.CFrame = CFrame.new((Cframe * CFrame.new(Options[math.random(1,#Options)],5,Options[math.random(1,#Options)])).Position,Cframe.Position) * CFrame.Angles(math.rad(math.random(0,45)),math.rad(-90),0)
			Slice.Size = Vector3.new(NormalSize.X,0,0)
			Slice.Parent = workspace.World.Visuals		

			delay(.1,function() Slice.Water.Enabled = false end)
			Debris:AddItem(Slice,.6)

			GlobalFunctions.TweenFunction({["Instance"] = Slice,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .6,},{["Size"] = Vector3.new(6, 0.2, 10);['Transparency'] = 1;['CFrame'] = Slice.CFrame * CFrame.fromEulerAnglesYXZ(0,10,0);})
			wait(Data.Duration or .1)	
		end
	end,

	["Trail"] = function(PathData)
		local Sword = PathData.Sword
		local Character = PathData.Character

		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		for Index = 1,2 do
			local Offset = 5;
			local Rot = 288;
			local GoalSize = Vector3.new(35, 0.05, 7.5)
			if Index == 1 then
			else
				Offset = Offset * -1;
				Rot = 252
			end

			local SideWind = EffectMeshes.SideWind:Clone()
			SideWind.Size = Vector3.new(8, 0.05, 2)
			SideWind.Transparency = 0
			SideWind.Color = Color3.fromRGB(255, 127, 42)
			SideWind.CFrame = Root.CFrame * CFrame.new(Offset,-.5,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),math.rad(180),math.rad(Rot))
			SideWind.Parent = Visuals

			local Tween = TweenService:Create(SideWind, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = SideWind.CFrame * CFrame.new(-10,0,0), ["Size"] = GoalSize, ["Transparency"] = 1})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(SideWind, .25)

			local DeepRing = EffectMeshes.DeepRing:Clone()
			DeepRing.Size =  Vector3.new(5, 0.1, 5)
			DeepRing.Transparency = .15
			DeepRing.Color = Color3.fromRGB(255, 127, 42)
			DeepRing.CFrame = Root.CFrame * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)
			DeepRing.Parent = Visuals
			
			local Tween = TweenService:Create(DeepRing, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = DeepRing.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(math.random(45))* math.sign(Offset),math.rad(270),0), ["Size"] = Vector3.new(30, 0.1, 30), ["Transparency"] = 1})
			Tween:Play()
			Tween:Destroy()
			
			Debris:AddItem(DeepRing, .35)
		end

		coroutine.resume(coroutine.create(function()
			if PathData.TrailFloor ~= nil then return end
			
			local Trail = ReplicatedStorage.Assets.Effects.Trails.GroundTrail:Clone()
			Trail.Trail.Lifetime = 3
			Trail.Position = Root.Position
			Trail.Transparency = 1
			Trail.Parent = Visuals
			
			Debris:AddItem(Trail,5)
						
			local FireParticle = ReplicatedStorage.Assets.Effects.Particles.FireProc:Clone()
			FireParticle.Rate = 50
			FireParticle.Enabled = true
			FireParticle.LockedToPart = false
			FireParticle.Parent = Trail
			
			delay(.45,function() FireParticle.Enabled = false end)

			local Tween = TweenService:Create(Trail.Start, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Position"] = Vector3.new(0,0,.25)})
			Tween:Play()
			Tween:Destroy()			

			local Connection
			Connection = Tween.Completed:Connect(function()
				local EndTween = TweenService:Create(Trail.End, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Position"] = Vector3.new(0,0,-0.25)})
				EndTween:Play()
				EndTween:Destroy()

				Connection:Disconnect()
				Connection = nil
			end)

			for Index = 1,50 do
				--[[ Raycast ]]--
				local StartPosition = (Root.CFrame).Position
				local EndPosition = CFrame.new(StartPosition).UpVector * -10

				local RayData = RaycastParams.new()
				RayData.FilterDescendantsInstances = {Character, workspace.World.Live, Visuals} or Visuals
				RayData.FilterType = Enum.RaycastFilterType.Exclude
				RayData.IgnoreWater = true

				local RaycastResult = workspace:Raycast(StartPosition, EndPosition, RayData)
				if RaycastResult then
					local Part, Position, Normal = RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal
					if Part then
						Trail.Position = Position 
					end
				end
				RunService.Heartbeat:Wait()
			end
		end))	
		
		for _,v in ipairs(Sword.Blade:GetChildren()) do
			if v:IsA("Trail") then
				v.Enabled = true
			end
		end
		
		Sword.Blade.Lines.Enabled = true
		Sword.Blade.ParticleEmitter2.Enabled = true
		if PathData.Bubbles == nil then
			Sword.Blade.WaterSlashTrail.Enabled = true
		end
		
		--[[Sword.Blade.Clouds.Enabled = true
		Sword.Blade.WaterSlashTrail.Enabled = true
		Sword.Blade.WaterTrail.Enabled = true
		Sword.Blade.WaterTrail2.Enabled = true]]

		--	Sword.Blade.WaterSlashTrail.TextureLength = PathData.TextureLength or 6
		Sword.Blade.WaterSlashTrail.Rate = PathData.Rate or 35

		if PathData.Duration == .9 then
			Sword.Blade.WaterSlashTrail.LightEmission = .4
			Sword.Blade.WaterSlashTrail.Rate = 80
		elseif PathData.Duration == .5 then
			coroutine.wrap(function()
				wait(.25)
				local SlashEffect = ReplicatedStorage.Assets.Effects.Meshes.ThreeDSlashEffect:Clone(); SlashEffect.Anchored = true; SlashEffect.CanCollide = false; SlashEffect.Massless = true; SlashEffect.CFrame = Root.CFrame * CFrame.Angles(0,math.pi/1.75,math.pi/2); SlashEffect.Parent = workspace.World.Visuals;
				local RandomSize = math.random(3,4) * 3
				local SizeAddon = math.random(3,4) * 5

				local Tween = TweenService:Create(SlashEffect,B5,{Transparency = 1,CFrame = SlashEffect.CFrame * CFrame.Angles(3.36,0,0),Size = SlashEffect.Size + Vector3.new(0,SizeAddon,SizeAddon)})
				Tween:Play()
				Tween:Destroy()

				Debris:AddItem(SlashEffect, 2)		
				
				local circleslash = script.circleslash:Clone()
				local one = circleslash.one
				local two = circleslash.two
				local StartSizeOne = Vector3.new(15,15,1)
				local StartSizeTwo = Vector3.new(15,15,2)
				local Multiple = 2

				one.Size = StartSizeOne
				two.Size = StartSizeTwo
				circleslash.Parent = Visuals

				one.CFrame = Root.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
				two.CFrame = Root.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)

				for _,v in ipairs(circleslash:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end
				Debris:AddItem(circleslash, 2)
				
				local PointLight = Instance.new("PointLight")
				PointLight.Color = Color3.fromRGB(120, 201, 255)
				PointLight.Range = 25
				PointLight.Brightness = 1
				PointLight.Parent = one

				local LightTween = TweenService:Create(PointLight, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Range"] = 0, ["Brightness"] = 0})
				LightTween:Play()
				LightTween:Destroy()

				--// Tween one
				local TweenOne = TweenService:Create(one, TweenInfo.new(.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = one.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(270)),["Size"] = StartSizeOne * Multiple})
				TweenOne:Play()
				TweenOne:Destroy()

				--// Tween two
				local TweenTwo = TweenService:Create(two, TweenInfo.new(.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = two.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(270)),["Size"] = StartSizeTwo * Multiple})
				TweenTwo:Play()
				TweenTwo:Destroy()
				
				--local C; C = TweenOne.Completed:Connect(function()
				--end)

				wait(.1)

				--// Tween Decals
				for _, v in ipairs(one:GetChildren()) do
					if v:IsA("Decal") then
						local Tween = TweenService:Create(v, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
						Tween:Play()
						Tween:Destroy()
					end	
				end

				for _, v in ipairs(two:GetChildren()) do
					local Tween = TweenService:Create(v, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
					Tween:Play()
					Tween:Destroy()
				end
			end)()	
		end

		wait(PathData.Duration)
		
		for _,v in ipairs(Sword.Blade:GetChildren()) do
			if v:IsA("Trail") then
				v.Enabled = false
			end
		end

		Sword.Blade.WaterSlashTrail.Rate = 145
		Sword.Blade.WaterSlashTrail.Enabled = false
		Sword.Blade.Lines.Enabled = false
		Sword.Blade.ParticleEmitter2.Enabled = false

       --[[	Sword.Blade.Clouds.Enabled = false
		Sword.Blade.WaterTrail.Enabled = false
		Sword.Blade.WaterTrail2.Enabled = false	 ]]
	end,
	["WaterSurfaceSlash"] = function(PathData)
		local Character = PathData.Character 
		local Sword = PathData.Sword

		local End = Character.HumanoidRootPart.CFrame
		local p1,p2 = End.p,End.upVector * -200

		-- SoundManager:AddSound("WaterPlayerSlash", {Parent = Character.HumanoidRootPart, Looped = false}, "Client")

		local WaterEffect = ReplicatedStorage.Assets.Effects.Particles.Water:Clone()
		WaterEffect.Color = ColorSequence.new(Color3.fromRGB(255, 92, 52))
		WaterEffect.Parent = Sword.Blade
		WaterEffect.Enabled = true
		delay(1,function() WaterEffect.Enabled = false end)

		Debris:AddItem(WaterEffect,3)

		local results = workspace:Raycast(p1,p2,raycastParams)
		if results and results.Instance and (results.Position - p1).Magnitude < 30 then
			local Dust = ReplicatedStorage.Assets.Effects.Particles.Dust:Clone()
			Dust.CFrame = End * CFrame.Angles(0,.3,0 ) * CFrame.new(3,0,0)
			Dust.ParticleEmitter.Color = ColorSequence.new(results.Instance.Color)
			Dust.ParticleEmitter:Emit(10)
			Dust.Parent = workspace.World.Visuals
			Debris:AddItem(Dust,3)

			local Dust = ReplicatedStorage.Assets.Effects.Particles.Dust:Clone()
			Dust.CFrame = End * CFrame.Angles(0,-.3,0 ) * CFrame.new(-3,0,0)
			Dust.ParticleEmitter.Color = ColorSequence.new(results.Instance.Color)
			Dust.ParticleEmitter:Emit(10)
			Dust.Parent = workspace.World.Visuals

			local DirtStep = ReplicatedStorage.Assets.Effects.Particles.DirtStep:Clone()
			DirtStep.ParticleEmitter.Enabled = true
			DirtStep.CFrame = End * CFrame.new(0,-1.85,.225)
			DirtStep.ParticleEmitter.Color = ColorSequence.new(results.Instance.Color) 
			DirtStep.Parent = workspace.World.Visuals

			local WeldConstraint = Instance.new("WeldConstraint"); 
			WeldConstraint.Part0 = Character.HumanoidRootPart
			WeldConstraint.Part1 = DirtStep;
			WeldConstraint.Parent = DirtStep

			delay(.5,function() DirtStep.ParticleEmitter.Enabled = false end)

			Debris:AddItem(DirtStep,2)
			Debris:AddItem(Dust,3)
		end

		for Index = 1,12 do
			local Slash = ReplicatedStorage.Assets.Effects.Meshes.ThreeDSlashEffect:Clone()
			local size = math.random(2,4) * 3
			local sizeadd = math.random(1,6) * 17
			local x,y,z = math.rad(math.random(8,12) * 30), math.rad(math.random(8,12) * 30), math.rad(math.random(8,12) * 30)
			local add = math.random(1,2)
			if add == 2 then
				add = -1
			end
			Slash.Transparency = .7
			Slash.Size = Vector3.new(2,size,size)
			Slash.CFrame = End * CFrame.Angles(x,y,z)
			Slash.Parent = workspace.World.Visuals

			local Tween = TweenService:Create(Slash,TweenInf,{["Transparency"] = 1,["CFrame"] = Slash.CFrame * CFrame.Angles(math.pi * add,0,0),["Size"] = Slash.Size + Vector3.new(0,sizeadd,sizeadd)})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(Slash,.3)
		end
	end,
	["HieiScreen"] = function(Data)
	
	end;
	["Light"] = function(PathData)
		local Character = PathData.Character or nil
		local ContactPoint = PathData.ContactPoint
		local Enemy = PathData.Enemy or warn("I Suppose U Die")

		--[[ Play Sound ]]--
		-- SoundManager:AddSound("SGCast", {Parent = Character.HumanoidRootPart, Volume = 1}, "Client")

		--// Circle Slash
		local circleslash = script.circleslash:Clone()
		local one = circleslash.one
		local two = circleslash.two
		local StartSizeOne = Vector3.new(15,15,1)
		local StartSizeTwo = Vector3.new(15,15,2)
		local Multiple = 2

		one.Size = StartSizeOne
		two.Size = StartSizeTwo
		circleslash.Parent = Visuals

		one.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
		two.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)

		Debris:AddItem(circleslash, 0.5)
		--// PointLight
		local PointLight = Instance.new("PointLight")
		PointLight.Color = Color3.fromRGB(255, 255, 0)
		PointLight.Range = 25
		PointLight.Brightness = 1
		PointLight.Parent = one

		local LightTween = TweenService:Create(PointLight, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Range"] = 0, ["Brightness"] = 0})
		LightTween:Play()
		LightTween:Destroy()

		--// Tween one		
		local TweenOne = TweenService:Create(one, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = one.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(270)),["Size"] = StartSizeOne * Multiple})
		TweenOne:Play()
		TweenOne:Destroy()

		--// Tween two
		local TweenTwo = TweenService:Create(two, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = two.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(270)),["Size"] = StartSizeTwo * Multiple})
		TweenTwo:Play()
		TweenTwo:Destroy()

		wait(0.05)
		--// Tween Decals
		for i, v in ipairs(one:GetChildren()) do
			if v:IsA("Decal") then
				local tween = TweenService:Create(v, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
				tween:Play()
				tween:Destroy()
			end	
		end

		for i, v in ipairs(two:GetChildren()) do
			local tween = TweenService:Create(v, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
			tween:Play()
			tween:Destroy()
		end
		--
		wait(0.15)
		--// Set invisible 
		for _, v in ipairs(Character:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("MeshPart") then
				if v.Parent ~= "Katana" and v.Parent ~= "Sheath" and v.Name ~= "HumanoidRootPart" and v.Name ~= "FakeHead" then
					v.Transparency = 1	
				end
			end
		end
		--

		--// Fire Bezier Following.
		for i = 1,5 do
			local Pika = EffectParticles.Pika:Clone()

			local StartPosition = Character.HumanoidRootPart.Position
			local EndPosition = Enemy.HumanoidRootPart.Position

			--[[ Setpath Properties ]]--
			local Magnitude = (StartPosition - EndPosition).Magnitude
			local Midpoint = (StartPosition - EndPosition)/2

			local PointA = CFrame.new(CFrame.new(StartPosition) * (Midpoint/-1.5)).Position -- first 25% of the path
			local PointB = CFrame.new(CFrame.new(EndPosition) * (Midpoint/1.5)).Position -- last 25% of the path

			local Offset = Magnitude/2
			PointA = PointA + Vector3.new(math.random(-Offset,Offset),math.random(5, 15),math.random(-Offset,Offset))
			PointB = PointB + Vector3.new(math.random(-Offset,Offset),math.random(5, 15),math.random(-Offset,Offset))	

			--[[ Position the Hand ]]--
			Pika.Parent = workspace
			Pika.Position = StartPosition

			--[[ Lerp the Path ]]--
			coroutine.wrap(function()
				for i = 0, 1, .025 do
					local Coordinate = BezierModule:cubicBezier(i, StartPosition, PointA, PointB, EndPosition)
					Pika.CFrame = Pika.CFrame:Lerp(CFrame.new(Coordinate, EndPosition), i)
					game:GetService("RunService").Heartbeat:Wait()
				end
				Pika.Attachment.Star1.Enabled = false
				Pika.Attachment.Star2.Enabled = false
				Pika.Attachment.Sparks.Enabled = false
				Pika.Attachment["Sparks (30)"].Enabled = false
				Pika.Attachment["sparks  (20)"].Enabled = false
				Pika.Attachment["residue (20)"].Enabled = false
				Pika.Attachment["res"].Enabled = false
				Pika.Attachment["Wave"].Enabled = false
				Pika.Attachment["Waves"].Enabled = false
				Pika.Attachment["center spark 2 (1)"].Enabled = false
				Pika.Attachment["center ring (1)"].Enabled = false
				Pika.Attachment["Inner"].Enabled = false
				Pika.Attachment.Stars.Enabled = false
				Pika.Attachment.StarWave.Enabled = false
				Debris:AddItem(Pika, 1)
			end)()
		end

		--// wait for bezier to reach
		wait(0.5)
		--// Teleported to Enemy
		--[[ Play Sound ]]--
		-- SoundManager:AddSound("SGTeleport", {Parent = Character.HumanoidRootPart, Volume = 5}, "Client")

		--// Set visible 
		for i, v in pairs(Character:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("MeshPart") then
				if v.Parent ~= "Katana" and v.Parent ~= "Sheath" and v.Name ~= "HumanoidRootPart" and v.Name ~= "Handle" and v.Name ~= "FakeHead" then
					v.Transparency = 0
				end
			end
		end
		wait(0.25)
		local RedStar = EffectParticles.RedStar.Attachment:Clone()
		RedStar.RedStar.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 20), NumberSequenceKeypoint.new(1, 0)}
		RedStar.RedStar:Emit(1)
		RedStar.Parent = Enemy.HumanoidRootPart
		Debris:AddItem(RedStar, 1)

		--[[ Play Sound ]]--
		-- SoundManager:AddSound("SGFlesh", {Parent = Character.HumanoidRootPart, Volume = 5}, "Client")
		wait(0.25)
		--// Blood
		local HitAttachment = EffectParticles.HieiSwordHit.Attachment:Clone()
		for i, v in pairs(HitAttachment:GetChildren()) do
			--v.Color = ColorSequence.new(Color3.fromRGB(170, 0, 0))
			v.Enabled = true
			if v.Name ~= "Blood" then
				v:Emit(1.5)
			else
				v.Lifetime = NumberRange.new(0.25)
				v.Speed = NumberRange.new(50)
				v:Emit(100)
			end
			delay(.125,function()
				v.Enabled = false
			end)
		end
		HitAttachment.Parent = Enemy.HumanoidRootPart

		Debris:AddItem(HitAttachment, .75)	
		for i = 1,5 do
			local originalPos = Enemy.HumanoidRootPart.Position
			local beam = EffectMeshes.Block:Clone()
			beam.Shape = "Block"
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = "Sphere"
			mesh.Parent = beam
			beam.Size = Vector3.new(.5,.5,2)
			beam.Material = Enum.Material.SmoothPlastic
			beam.BrickColor = BrickColor.new("Cool yellow ")
			beam.Transparency = 0
			beam.Parent = Visuals

			beam.CFrame = CFrame.new(originalPos + Vector3.new(math.random(-1,1),math.random(-1,1),math.random(-1,1)), originalPos) 
			local tween = TweenService:Create(beam, TweenInfo.new(.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {["Size"] = beam.Size + Vector3.new(0,0, math.random(.5,1)), ["CFrame"] = beam.CFrame * CFrame.new(0,0,math.random(9,13))})
			local tween2 = TweenService:Create(beam, TweenInfo.new(.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {["Size"] = Vector3.new(0,0,2)})		
			tween:Play()
			tween:Destroy()
			tween2:Play()
			tween2:Destroy()
			Debris:AddItem(beam, .25)						
		end

		HitAttachment.Parent = Enemy.HumanoidRootPart

		--[[ Side Shockwaves ]]--
		for j = 1,2 do

			local Offset = 5;
			local Rot = 288;
			local GoalSize = Vector3.new(50, 0.5, 10);
			if j == 1 then
			else
				Offset = Offset * -1;
				Rot = 252
			end

			local SideWind = EffectMeshes.SideWind:Clone()
			SideWind.Size = Vector3.new(8, 0.05, 2)
			SideWind.Color = Color3.fromRGB(255, 255, 255)
			SideWind.Material = Enum.Material.SmoothPlastic
			SideWind.Transparency = -1
			SideWind.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(Offset,-0.5,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),math.rad(180),math.rad(Rot))
			SideWind.Parent = Visuals

			--[[ Tween the Side Shockwaves ]]--
			local tween = TweenService:Create(SideWind, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = SideWind.CFrame * CFrame.new(-10,0,0), ["Size"] = GoalSize, ["Transparency"] = 1})
			tween:Play()
			tween:Destroy()

			Debris:AddItem(SideWind, 0.2)
		end

		--// double bg slash
		for i = 1,2 do
			local originalPos = Enemy.HumanoidRootPart.Position
			local beam = EffectMeshes.Block:Clone()
			beam.Shape = "Block"
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = "Sphere"
			mesh.Parent = beam
			beam.Size = Vector3.new(2,2,30)
			beam.Material = Enum.Material.Neon
			beam.BrickColor = BrickColor.new("Institutional white")
			beam.Transparency = 0
			beam.Parent = Visuals

			beam.CFrame = CFrame.new(originalPos + Vector3.new(math.random(-1,1),math.random(-1,1),math.random(-1,1)), originalPos) 
			local tween = TweenService:Create(beam, TweenInfo.new(.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {["Size"] = beam.Size + Vector3.new(0,0, math.random(.5,1))})
			local tween2 = TweenService:Create(beam, TweenInfo.new(.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {["Size"] = Vector3.new(0,0,30)})		
			tween:Play()
			tween:Destroy()
			tween2:Play()
			tween2:Destroy()
			Debris:AddItem(beam, .1)						
		end
		--// Circle Slash
		local circleslash = script.circleslash:Clone()
		local one = circleslash.one
		local two = circleslash.two
		local StartSizeOne = Vector3.new(30,30,2)
		local StartSizeTwo = Vector3.new(30,30,2)
		local Multiple = 2

		one.Size = StartSizeOne
		two.Size = StartSizeTwo
		circleslash.Parent = Visuals

		local Offset = math.random(30,50)
		if math.random(1,2) == 1 then Offset *= 1 else Offset *= -1 end

		one.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(Offset),0,0)
		two.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(Offset),0,0)

		Debris:AddItem(circleslash, 0.5)

		--// Tween one		
		local TweenOne = TweenService:Create(one, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = one.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(270)),["Size"] = StartSizeOne * Multiple})
		TweenOne:Play()
		TweenOne:Destroy()

		--// Tween two
		local TweenTwo = TweenService:Create(two, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = two.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(270)),["Size"] = StartSizeTwo * Multiple})
		TweenTwo:Play()
		TweenTwo:Destroy()

		wait(0.05)
		--// Tween Decals
		for i, v in ipairs(one:GetChildren()) do
			if v:IsA("Decal") then
				local tween = TweenService:Create(v, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
				tween:Play()
				tween:Destroy()
			end	
		end

		for i, v in ipairs(two:GetChildren()) do
			local tween = TweenService:Create(v, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
			tween:Play()
			tween:Destroy()
		end

	end
}

return KizaruVFX