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

local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local Humanoid = Character:WaitForChild("Humanoid")

local function RemoveTrash(Trash)
	for Index = 1,#Trash do
		local Item = Trash[Index]
		if Item and Item.Parent then
			Item:Destroy()
		end
	end
end

local function SearchBin(Table)
	for Index = 1,#Table do
		local Item = Table[Index]
		return Item
	end
end

function VelocityCalculation(End,Start,Gravity,Time)
	return (End - Start - .5 * Gravity * Time * Time) / Time
end

function GetMousePos(X,Y,Z,Boolean)
	local RayMag1 = Camera:ScreenPointToRay(X, Y) 
	local NewRay = Ray.new(RayMag1.Origin, RayMag1.Direction * ((Z and Z) or 200))
	local Target,Position,Surface = workspace:FindPartOnRayWithIgnoreList(NewRay, {Character,workspace.World.Visuals})
	if Boolean then
		return Position,Target,Surface
	else
		return Position
	end
end

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(ShakeCFrame)
	Camera.CFrame = Camera.CFrame * ShakeCFrame
end)

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {Character, workspace.World.Visuals}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local tii = TweenInfo.new(.15,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
local B5 = TweenInfo.new(.3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

local RazorVFX = {

	["Chop"] = function(Data)
		local Character,Victim = Data.Character, Data.Victim
		local Root,VRoot = Character:FindFirstChild("HumanoidRootPart")--, Victim:FindFirstChild("HumanoidRootPart")

		-- SoundManager:AddSound("Teleport", {Parent = Root, Volume = 1}, "Client")
		VfxHandler.AfterImage({Character = Character, Duration = 1, StartTransparency = .25,})
		
		local Part = Instance.new("Part")
		Part.Anchored = true
		Part.CFrame = Root.CFrame
		Part.Transparency = 1
		Part.Orientation = Vector3.new(3.87, -4.36, -2.25)
		Part.Parent = workspace.World.Visuals

		Debris:AddItem(Part,2)	
		
		local End = Root.CFrame
		local PositionCalc1,PositionCalc2 = End.Position, End.upVector * -200

		local RaycastResult = workspace:Raycast(PositionCalc1,PositionCalc2,raycastParams)
		if RaycastResult and RaycastResult.Instance and (RaycastResult.Position - PositionCalc1).Magnitude < 30 then	
			local Dust = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments["Dust"]:Clone()
			Dust.P1.Color = ColorSequence.new(RaycastResult.Instance.Color)
			Dust.Parent = Part

			VfxHandler.Emit(Dust.P1,35)

			TaskScheduler:AddTask(.225,function()
				Explosions.RazorChop({Character = Character, Victim = Victim, RaycastResult = RaycastResult, Distance = Data.Distance})
			end)
		end
	end,

	["RemoveBall"] = function(Data)
		local Volleyball = workspace.World.Visuals:FindFirstChild(Character.Name.." VOLLEYBALL RAZOR")

		if Volleyball == nil then return end

		for _,Instances in ipairs(Volleyball.PrimaryPart:GetChildren()) do
			if Instances:IsA("Weld") then
				Instances:Destroy()
			end
		end

		wait(1.5)
		if Volleyball then
			local EndTween = TweenService:Create(Volleyball.PrimaryPart,TweenInfo.new(1,Enum.EasingStyle.Elastic,Enum.EasingDirection.InOut,0,false,0),{Size = Vector3.new(0,0,0)})
			EndTween:Play()
			EndTween:Destroy()

			wait(.275)

			local Sparks = Particles["PE1"]:Clone()
			Sparks:Emit(35)
			Sparks.Parent = Volleyball.PrimaryPart

			Debris:AddItem(Volleyball,1)
		end
	end,

	["BallPrep"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		local PremadeVolleyball = workspace.World.Visuals:FindFirstChild(Character.Name.." VOLLEYBALL RAZOR")
		if PremadeVolleyball then PremadeVolleyball:Destroy() end

		local Volleyball

		Volleyball = Data.Type == nil and ReplicatedStorage.Assets.Models.Misc.Volleyballs.volleymodel or Data.Type == "Explode" and ReplicatedStorage.Assets.Models.Misc.Volleyballs.explodball

		local Volleyball = Volleyball:Clone()
		Volleyball.Name = Character.Name.." VOLLEYBALL RAZOR"
		Volleyball.PrimaryPart.Size = Vector3.new(0,0,0)

		local Tween = TweenService:Create(Volleyball.PrimaryPart,TweenInfo.new(.5,Enum.EasingStyle.Elastic,Enum.EasingDirection.InOut,0,false,0),{Size = Vector3.new(1.545, 1.545, 1.545)})
		Tween:Play()
		Tween:Destroy()		

		TaskScheduler:AddTask(.5,function() -- SoundManager:AddSound("GigCast", {Parent = Root, Volume = 2}, "Client")	end)

		local Weld = Instance.new("Weld")
		Weld.Part0 = Character["Right Arm"]
		Weld.Part1 = Volleyball.PrimaryPart
		Weld.C0 = CFrame.new(0,-1.4,0)
		Weld.Parent = Volleyball.PrimaryPart

		Volleyball.Parent = workspace.World.Visuals
		Debris:AddItem(Volleyball,14)
	end,

	["explodball"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		local Volleyball = workspace.World.Visuals:FindFirstChild(Character.Name.." VOLLEYBALL RAZOR")

		if Volleyball == nil then return end

		for _,Instances in ipairs(Volleyball.PrimaryPart:GetChildren()) do
			if Instances:IsA("Weld") then
				Instances:Destroy()
			end
		end

		for _ = 1, 10 do
			VfxHandler.UpwardOrbies({
				Quantity = math.random(5,7);
				Pos = Root.CFrame * CFrame.new(0,-5,0).Position, 
				Properties = {
					Material = Enum.Material.Neon;
					Transparency = 0.5;
					Color = math.random(1,2) == 1 and Color3.fromRGB(42, 42, 42) or Color3.fromRGB(22, 22, 22),
					Size = Vector3.new(.125,.125,math.random(4,5));
				};
				Offsets = {
					X = {-15/1.5, 15/1.5};
					Y = {0, 10};
					Z = {-15/1.5, 15/1.5};
					Offset = {-50,75};
				};
				TweenInfo = TweenInfo.new(2 + 2 * math.random(), Enum.EasingStyle.Back, Enum.EasingDirection.Out);
				Goal = {Transparency = 1};
			});
		end

		local Position = Root.CFrame * CFrame.new(0,0,-2).p
		local Velocity = VelocityCalculation(Position,Root.Position,Vector3.new(0,-workspace.Gravity,0),.9)
		Volleyball.PrimaryPart.Velocity = Velocity

		coroutine.resume(coroutine.create(function()
			wait(.25)
			VfxHandler.FakeBodyPart({
				Character = Character,
				Object = "Right Arm",
				Material = "Neon",
				Color = Color3.fromRGB(255, 85, 85), TweenColor = Color3.fromRGB(136, 26, 26),
				Transparency = 1,
				Duration = 1,
				Delay = .1,	
				Type = "Trail"
			})
		end))

		wait(.75)

		VfxHandler.ImpactLines({Character = Volleyball, Amount = 15, Delay = 0, Type = "volleyblallzz"})

		local BallPosition = Volleyball.PrimaryPart.Position

		-- SoundManager:AddSound("Woosh", {Parent = Volleyball.PrimaryPart, Volume = 3}, "Client")
		-- SoundManager:AddSound("VolleyballSmack", {Parent = Root, Volume = 10}, "Client")

		local Position,Part,Surface = GetMousePos(Mouse.X,Mouse.Y,500,true)

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
		BodyVelocity.Velocity = CFrame.new(Volleyball.PrimaryPart.Position,Position).lookVector * 200 * 1
		BodyVelocity.Parent = Volleyball.PrimaryPart	

		local Vel = Data.Velocity
		local LifeT = Data.Lifetime

		local Direction = (Position - Volleyball.PrimaryPart.Position).Unit
		local Points = RaycastService:GetSquarePoints(CFrame.new(Volleyball.PrimaryPart.Position), Volleyball.PrimaryPart.Size.X, Volleyball.PrimaryPart.Size.X)

		RaycastService:CastProjectileHitbox({
			Points = Points, 
			Direction = Direction, 
			Velocity = Vel, 
			Lifetime = LifeT, 
			Iterations = 50, 
			Visualize = false,
			Function = function(RaycastResult)
				Explosions.ExplodingThrow({Character = Character, RaycastResult = RaycastResult, Volleyball = Volleyball.PrimaryPart, BodyVelocity = BodyVelocity, Distance = Data.Distance})
			end,
			Ignore = {Character, workspace.World.Visuals} 
		})
	end,

	["VolleyKick"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		local Volleyball = workspace.World.Visuals:FindFirstChild(Character.Name.." VOLLEYBALL RAZOR")

		if Volleyball == nil then return end

		for _,Instances in ipairs(Volleyball.PrimaryPart:GetChildren()) do
			if Instances:IsA("Weld") then
				Instances:Destroy()
			end
		end

		for _ = 1, 10 do
			VfxHandler.UpwardOrbies({
				Quantity = math.random(5,7);
				Pos = Root.CFrame * CFrame.new(0,-5,0).p, 
				Properties = {
					Material = Enum.Material.Neon;
					Transparency = 0.5;
					Color = math.random(1,2) == 1 and Color3.fromRGB(42, 42, 42) or Color3.fromRGB(22, 22, 22),
					Size = Vector3.new(.125,.125,math.random(4,5));
				};
				Offsets = {
					X = {-15/1.5, 15/1.5};
					Y = {0, 10};
					Z = {-15/1.5, 15/1.5};
					Offset = {-50,75};
				};
				TweenInfo = TweenInfo.new(2 + 2 * math.random(), Enum.EasingStyle.Back, Enum.EasingDirection.Out);
				Goal = {Transparency = 1};
			});
		end

		local Position = Root.CFrame * CFrame.new(0,0,-2).p
		local Velocity = VelocityCalculation(Position,Root.Position,Vector3.new(0,-workspace.Gravity,0),.9)
		Volleyball.PrimaryPart.Velocity = Velocity

		coroutine.resume(coroutine.create(function()
			wait(.5)
			VfxHandler.FakeBodyPart({
				Character = Character,
				Object = "Left Leg",
				Material = "Neon",
				Color = Color3.fromRGB(255, 255, 255), TweenColor = Color3.fromRGB(136, 136, 136),
				Transparency = 1,
				Duration = 1,
				Delay = .1,	
				Type = "Trail"
			})
		end))

		wait(.795)

		VfxHandler.ImpactLines({Character = Volleyball, Amount = 15, Delay = 0, Type = "volleyblallzz"})

		local BallPosition = Volleyball.PrimaryPart.Position

		-- SoundManager:AddSound("Woosh", {Parent = Volleyball.PrimaryPart, Volume = 3}, "Client")
		-- SoundManager:AddSound("VolleyballSmack", {Parent = Root, Volume = 10}, "Client")

		local Position,Part,Surface = GetMousePos(Mouse.X,Mouse.Y,500,true)

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
		BodyVelocity.Velocity = CFrame.new(Volleyball.PrimaryPart.Position,Position).lookVector * 200 * 1
		BodyVelocity.Parent = Volleyball.PrimaryPart	

		local Vel = Data.Velocity
		local LifeT = Data.Lifetime

		local Direction = (Position - Volleyball.PrimaryPart.Position).Unit
		local Points = RaycastService:GetSquarePoints(CFrame.new(Volleyball.PrimaryPart.Position), Volleyball.PrimaryPart.Size.X, Volleyball.PrimaryPart.Size.X)

		RaycastService:CastProjectileHitbox({
			Points = Points, 
			Direction = Direction, 
			Velocity = Vel, 
			Lifetime = LifeT, 
			Iterations = 50, 
			Visualize = false,
			Function = function(RaycastResult)
				Explosions.VolleyKick({Character = Character, RaycastResult = RaycastResult, Volleyball = Volleyball.PrimaryPart, BodyVelocity = BodyVelocity, Distance = Data.Distance})
			end,
			Ignore = {Character, workspace.World.Visuals} 
		})
	end,

	["HardThrow"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		local Volleyball = workspace.World.Visuals:FindFirstChild(Character.Name.." VOLLEYBALL RAZOR")

		if Volleyball == nil then return end

		for _,Instances in ipairs(Volleyball.PrimaryPart:GetChildren()) do
			if Instances:IsA("Weld") then
				Instances:Destroy()
			end
		end

		-- SoundManager:AddSound("VolleyballSmack", {Parent = Root, Volume = 10}, "Client")

		local Index,Part = VfxHandler.ImpactLines({
			Character = Volleyball,
			Amount = 25,
			Delay = 0, 
			Type = "volleyblallz",
		})

		local cs = ReplicatedStorage.Assets.Effects.Meshes.Ring2:Clone()
		cs.Size = Vector3.new(5, 2, 5)
		local c1,c2 = Root.CFrame*CFrame.new(0,0,-40)*CFrame.Angles(math.pi/2,0,0) ,Root.CFrame*CFrame.new(0,0,10)*CFrame.Angles(math.pi/2,0,0) 
		cs.CFrame = c1
		cs.Material = Enum.Material.Neon
		cs.Parent = workspace.World.Visuals

		local Tween = TweenService:Create(cs,tii,{Size = Vector3.new(25,0,25),CFrame = c2})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(cs,.15)

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
			slash.CFrame = Root.CFrame * CFrame.Angles(x,y,z)
			slash.Parent = workspace.World.Visuals

			local Tween = TweenService:Create(slash,B5,{Transparency = 1,CFrame = slash.CFrame * CFrame.Angles(math.pi * add,0,0),Size = slash.Size + Vector3.new(0,sizeadd,sizeadd)})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(slash,.3)
		end

		local Position,Part,Surface = GetMousePos(Mouse.X,Mouse.Y,500,true)

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
		BodyVelocity.Velocity = CFrame.new(Volleyball.PrimaryPart.Position,Position).lookVector * 200 * 1
		BodyVelocity.Parent = Volleyball.PrimaryPart		

		local Vel = Data.Velocity
		local LifeT = Data.Lifetime

		local Direction = (Data.MouseHit.Position - Volleyball.PrimaryPart.Position).Unit
		local Points = RaycastService:GetSquarePoints(CFrame.new(Volleyball.PrimaryPart.Position), Volleyball.PrimaryPart.Size.X, Volleyball.PrimaryPart.Size.X)

		RaycastService:CastProjectileHitbox({
			Points = Points, 
			Direction = Direction, 
			Velocity = Vel, 
			Lifetime = LifeT, 
			Iterations = 50, 
			Visualize = false,
			Function = function(RaycastResult)
				Explosions.HardThrow({Character = Character, RaycastResult = RaycastResult, Volleyball = Volleyball.PrimaryPart, BodyVelocity = BodyVelocity, Distance = Data.Distance})
			end,
			Ignore = {Character, workspace.World.Visuals} 
		})
	end,

}

return RazorVFX