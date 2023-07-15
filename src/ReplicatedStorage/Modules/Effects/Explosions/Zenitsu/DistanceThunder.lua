--|| Services ||--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Effects = Modules.Effects
local Shared = Modules.Shared

--|| Modules ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local CameraShaker = require(Effects.CameraShaker)
local LightningExplosion = require(Effects.LightningBolt.LightningExplosion)
local VfxHandler = require(Effects.VfxHandler)

local SoundManager = require(Shared.SoundManager)

local Camera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	Camera.CFrame = Camera.CFrame * shakeCFrame
end)

function CreateLightning(Start,End,numberofparts)
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
		local Color = Index % 2 == 0 and "Pastel blue-green" or "Pastel blue-green"

		local newcframe = CFrame.new(lastcf,End + Vector3.new(x,y,z)) * CFrame.new(0,0,-Distance)
		local newdisance = (lastcf - newcframe.p).Magnitude

		local Part = Instance.new("Part")
		Part.Material = Enum.Material.Neon
		Part.BrickColor = BrickColor.new(Color)
		Part.TopSurface = Enum.SurfaceType.SmoothNoOutlines
		Part.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
		Part.CanCollide = false
		Part.Anchored = true
		Part.CastShadow = false	
		Part.Size = Vector3.new(.25,.25,newdisance)
		Part.CFrame = CFrame.new(lastcf,newcframe.p) * CFrame.new(0,0,-newdisance / 2)
		Part.Parent = Lightning

		-- SoundManager:AddSound("LightningSizzle", {Parent = Part, Volume = 3}, "Client")

		local Ti2 = TweenInfo.new(.4,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0)
		local Ti3 = TweenInfo.new(.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,4,true,0)

		TweenService:Create(Part,Ti2,{Size = Vector3.new(0,0,newdisance)}):Play()
		TweenService:Create(Part,Ti3,{Transparency = 1}):Play()
		Debris:AddItem(Part,.4)
		lastcf = newcframe.p
	end
end

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

function createhugelightning2(Start,End,numberofparts,player)
	local lastcf = Start
	local Distance = (Start - End).Magnitude / numberofparts
	
	local Lightning = Instance.new("Folder")
	Lightning.Name = "lightasd"
	Lightning.Parent = workspace.World.Visuals
	Debris:AddItem(Lightning,2)
	
	for Index = 1,numberofparts do
		local X,Y,Z = math.random(-2,2) * math.clamp(numberofparts,5,99999),math.random(-2,2) * math.clamp(numberofparts,5,99999),math.random(-2,2) * math.clamp(numberofparts,5,99999)
		if Index == numberofparts then
			X = 0; Y = 0; Z = 0
		end
		local newcframe = CFrame.new(lastcf,End + Vector3.new(X,Y,Z)) * CFrame.new(0,0,-Distance)
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
		
		coroutine.resume(coroutine.create(function()
			wait(Index / 20)
			
			local Ti24 = TweenInfo.new(.14,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0)

			local Tween = TweenService:Create(Part,Ti24,{["Size"] = Vector3.new(0,0,newdisance),["Color"] = Color3.fromRGB(253, 234, 141)})
			Tween:Play()
			Tween:Destroy()
			
			Debris:AddItem(Part,.24)
		end))
		lastcf = newcframe.p
	end
end

--|| Variables ||--
local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local RingTween = TweenInfo.new(.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)

return function(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")
	
	local circleoutline = Effects.circleoutline:Clone()
	circleoutline.Size = Vector3.new(45,45,45)
	circleoutline.BrickColor = BrickColor.new("Medium blue")
	circleoutline.Material = "Neon"
	circleoutline.Transparency = 1
	circleoutline.CFrame = CFrame.new(Data.Position)
	circleoutline.Parent = workspace.World.Visuals
	Debris:AddItem(circleoutline, 1)
	
	local circle2 = Effects.windshockwave2:Clone()
	circle2.BrickColor = BrickColor.new("Dark stone grey")
	circle2.Material = "Neon"
	circle2.Transparency = .5
	circle2.Size = Vector3.new(45,45,45)
	circle2.CFrame = CFrame.new(Data.Position)
	circle2.Parent = workspace.World.Visuals
	Debris:AddItem(circle2, 1)
	
	local Tween = TweenService:Create(circle2,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Transparency = 1, Size = Vector3.new(50,50,50), CFrame = circle2.CFrame * CFrame.fromEulerAnglesXYZ(0,1,0)})
	Tween:Play()
	Tween:Destroy()
	
	task.spawn(function()
		for Index = 1, 3 do
			circleoutline.Transparency = 0
			circleoutline.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
			wait(.1)
			circleoutline.Transparency = 1
			circleoutline.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
			wait(.05)
		end
	end)
	
	VfxHandler.Spherezsz({
		Cframe = CFrame.new(Data.Position), 
		TweenDuration1 = .3, 
		TweenDuration2 = .5, 
		Range = 12, 
		MinThick = 35, 
		MaxThick = 80, 
		Part = nil, 
		Color = BrickColor.new("Cool yellow").Color,
		Amount = 5
	})

	VfxHandler.Spherezsz({
		Cframe = CFrame.new(Data.Position), 
		TweenDuration1 = .3, 
		TweenDuration2 = .5, 
		Range = 12, 
		MinThick = 35, 
		MaxThick = 80, 
		Part = nil, 
		Color = BrickColor.new("Pastel blue-green").Color,
		Amount = 8
	})
	
	local DistanceThudnerFolder = Instance.new("Folder")
	DistanceThudnerFolder.Name = "Distance Thunder"
	DistanceThudnerFolder.Parent = workspace.World.Visuals

	Debris:AddItem(DistanceThudnerFolder,2)

	local Ring = ReplicatedStorage.Assets.Effects.Meshes.myring:Clone()
	Ring.Color = Color3.fromRGB(255,255,255)
	Ring.Transparency = .3
	Ring.Position = Data.Position
	Ring.Size = Vector3.new(0,0,0)
	Ring.Parent = workspace.World.Visuals

	local Tween = TweenService:Create(Ring,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size = Vector3.new(55,2,55), Transparency = 1})
	Tween:Play()
	Tween:Destroy()

	Debris:AddItem(Ring,1.5)
	
	local SizeRange = 10.85

	VfxHandler.DexCrater({
		points = 20,
		radius = 21,
		position = Data.Position,
		size = 3,
		movement = true,
		speed = .15,
		yield = 1.5,
		domino = true,
		clearSpeed = .085,
		Exclude = {Character}
	})

	for _ = 1,4 do
		local SizeIndex = math.random(SizeRange,SizeRange * 3)
		local CFrameIndex = CFrame.new(Data.Position) * CFrame.new(math.random(-SizeRange,SizeRange),0,math.random(-SizeRange,SizeRange))

		local Smoke = script.smoke:Clone()
		Smoke.Size = Vector3.new(0,0,0)
		Smoke.Transparency = 1
		Smoke.Color = math.random(1,2) == 1 and Color3.fromRGB(255, 123, 90) or Color3.fromRGB(0,0,0)
		Smoke.Material = Enum.Material.Neon
		Smoke.CFrame = CFrameIndex
		Smoke.Parent = workspace.World.Visuals

		local Tween = TweenService:Create(Smoke,TweenInfo.new(.55,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Transparency = 0, Size = Vector3.new(SizeIndex,SizeIndex,SizeIndex), CFrame = Smoke.CFrame * CFrame.Angles(math.random(360),math.random(360),math.random(360))})
		Tween:Play()
		Tween:Destroy()

		coroutine.wrap(function()
			wait(.45)
			local Tween = TweenService:Create(Smoke,TweenInfo.new(.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size = Vector3.new(0,0,0),Transparency = 1})
			Tween:Play()
			Tween:Destroy()
		end)()

		Debris:AddItem(Smoke,.85)
	end

	for _ = 1,math.random(2,4) do
		local SlashEffect = ReplicatedStorage.Assets.Effects.Meshes.ThreeDSlashEffect:Clone()
		local SizeIndex = math.random(2,4) * 5
		local SizeAdd = math.random(2,4) * 4
		local X,Y,Z = math.rad(math.random(8,12) * 30), math.rad(math.random(8,12) * 30), math.rad(math.random(8,12) * 30)
		local AddVector = math.random(1,2)
		if AddVector == 2 then
			AddVector = -1
		end
		SlashEffect.Transparency = .4
		SlashEffect.Size = Vector3.new(2,SizeIndex,SizeIndex)
		SlashEffect.CFrame = Root.CFrame * CFrame.Angles(X,Y,Z)
		SlashEffect.Parent = DistanceThudnerFolder

		local B7 = TweenInfo.new(.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0)

		local Tween = TweenService:Create(SlashEffect,B7,{["Transparency"] = 1,["CFrame"] = SlashEffect.CFrame * CFrame.Angles(math.pi * AddVector,0,0),["Size"] = SlashEffect.Size + Vector3.new(0,SizeAdd,SizeAdd)})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(SlashEffect,.12)
	end
		
	local Part = script.Part:Clone()
	Part.CFrame = CFrame.new(Data.Position)
	Part.Anchored = true
	Part.Parent = workspace.World.Visuals
	
	VfxHandler.Emit(Part.Attachment.ParticleEmitter,15)
	Debris:AddItem(Part,5)
		
	local Ball = Effects.ball:Clone()
	Ball.Shape = "Cylinder"
	Ball.BrickColor = BrickColor.new("Medium blue")
	Ball.Material = "Neon"
	Ball.Size = Vector3.new(1000,15,15)
	Ball.Transparency = .5
	Ball.CFrame = CFrame.new(Data.Position) * CFrame.fromEulerAnglesXYZ(0,0,math.rad(90))	
	Ball.Parent = workspace.World.Visuals
	
	local Tween = TweenService:Create(Ball,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{["Transparency"] = 1})
	Tween:Play()
	Tween:Destroy()
	
	Debris:AddItem(Ball, 1)
	
	-- SoundManager:AddSound("Lightnining_Impact",{Parent = Root, Volume = 1},"Client")

	local Part = Instance.new("Part")
	Part.Name = "Part"
	Part.CanCollide = false
	Part.Anchored = true
	Part.Transparency = 1
	Part.CFrame = CFrame.new(Data.Position)
	---- SoundManager:AddSound("LightningExplosion2",{Parent = Root},"Client")

	-- SoundManager:AddSound("Ground Stomp",{Parent = Root, Volume = .85, Playing = true},"Client",{ExectueTween = 1})
	Debris:AddItem(Part,2)

	local Ball = Instance.new("Part")
	Ball.Size = Vector3.new()
	Ball.Anchored = true
	Ball.CastShadow = false
	Ball.CFrame = CFrame.new(Data.Position)
	Ball.Material = Enum.Material.Neon
	Ball.Color = math.random(1,2) == 1 and BrickColor.new("Pastel blue-green").Color or Color3.fromRGB(253, 234, 141)
	Ball.CanCollide = false
	Ball.Shape = Enum.PartType.Ball
	Ball.Parent = DistanceThudnerFolder

	Debris:AddItem(Ball,1)

	local A1 = TweenInfo.new(.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,true,0)

	local Tween = TweenService:Create(Ball,A1,{["Size"] = Vector3.new(30,30,30)})
	Tween:Play()
	Tween:Destroy() 

	local Distance = 1 - math.clamp((Camera.CFrame.Position - Data.Position).Magnitude,0,150) / 150
	local ColorCorrection = Instance.new("ColorCorrectionEffect")
	ColorCorrection.Parent = Camera

	local Tiasd = TweenInfo.new(.04,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,true,0)

	local Tween = TweenService:Create(ColorCorrection,Tiasd,{["Brightness"] = Distance / 5})
	Tween:Play()
	Tween:Destroy()

	Debris:AddItem(ColorCorrection,2)

	local Distance = 1 - math.clamp((Camera.CFrame.Position - Root.Position).Magnitude,0,150) / 150
	local ColorCorrection2 = Instance.new("ColorCorrectionEffect")
	ColorCorrection2.Parent = Camera

	local Tween = TweenService:Create(ColorCorrection2,Tiasd,{["Brightness"] = Distance / 7})
	Tween:Play()
	Tween:Destroy()

	Debris:AddItem(ColorCorrection2,2)
	
	createhugelightning(Root.Position,Data.Position,25,Players:GetPlayerFromCharacter(Character))
	createhugelightning(Root.Position,Data.Position,math.clamp(math.floor((Root.Position - Data.Position).Magnitude / 15), 3, 999),Players:GetPlayerFromCharacter(Character))
	
	for Index = 1,math.random(5,6) do
		local RandomIndex = math.random(1,2)
		if RandomIndex == 2 then
			local X,Y,Z = math.random(-2,2) * 20,math.random(-2,2) * 20,math.random(-2,2) * 20
			local Position = Data.Position + Vector3.new(X,Y,Z)
			createhugelightning2(Data.Position,Position,math.random(6,8) * 2.5)
		end
		local Part = Instance.new("Part")
		Part.Size = Vector3.new(4,0,4)
		Part.CanCollide = false
		Part.CastShadow = false
		Part.Anchored = true
		Part.Material = Enum.Material.Neon
		Part.Color = Color3.fromRGB(253, 234, 141)

		local X,Y,Z = math.rad(math.random(1,24) * 15),math.rad(math.random(1,24) * 15),math.rad(math.random(1,24) * 15)

		Part.CFrame = CFrame.new(Data.Position) * CFrame.Angles(X,Y,Z)
		Part.Parent = DistanceThudnerFolder

		local A3 = TweenInfo.new(.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0)

		local Tween = TweenService:Create(Part,A3,{["Size"] = Vector3.new(0,math.random(2,7) * 30,0)})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(Part,.2)
		wait(.01)
	end	
end