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
		local Color = Index % 2 == 0 and "Neon orange" or "Cool yellow"

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
			wait(Index / 40)
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
		Part.Color = Color3.fromRGB(255, 85, 0)
		Part.TopSurface = Enum.SurfaceType.SmoothNoOutlines
		Part.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
		Part.CanCollide = false
		Part.Anchored = true
		Part.CastShadow = false	
		Part.Size = Vector3.new(.7,.7,newdisance)
		Part.CFrame = CFrame.new(lastcf,newcframe.p) * CFrame.new(0,0,-newdisance / 2)
		Part.Parent = Lightning
		
		coroutine.resume(coroutine.create(function()
			wait(Index / 40)
			
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
return function(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")
	
	coroutine.resume(coroutine.create(function()
		for Index = 1,math.random(5,6) do
			local RandomIndex = math.random(1,2)
			if RandomIndex == 2 then
				local X,Y,Z = math.random(-2,2) * 20,math.random(-2,2) * 20,math.random(-2,2) * 20
				local Position = Data.Position + Vector3.new(X,Y,Z)
				--createhugelightning2(Data.Position,Position,math.random(6,8) * 2.5)
			end
			wait(.01)
		end
	end))
	
	-- SoundManager:AddSound("Lightnining_Impact",{Parent = Root, Volume = 1},"Client")
	
	local X,Y,Z = math.random(-2,2) * 2,math.random(-2,2) * 2,math.random(-2,2) * 2
	local pos = Data.Position + Vector3.new(X,Y,Z)
	
	createhugelightning(Root.Position,pos,25,Players:GetPlayerFromCharacter(Character))
	createhugelightning(Root.Position,pos,math.clamp(math.floor((Root.Position - pos).Magnitude / 15), 3, 999),Players:GetPlayerFromCharacter(Character))
end