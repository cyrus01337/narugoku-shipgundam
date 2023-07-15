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
		local Color = Index % 2 == 0 and "Pastel blue-green" or "Pastel blue-green"

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

local function QuickTings(Root,Size)
	Size = Size
	local rocks = Instance.new("Folder")
	rocks.Name = "Rocks"
	rocks.Parent = workspace.World.Visuals
	Debris:AddItem(rocks,5)
	if Root then
		for Index = 1,12 do
			local RandomIndex = math.random(1,2)
			if RandomIndex == 1 then
				local radius = math.random(3,9)
				local Size2 = Size + (math.random(5,7) / 5)
				local Theta = math.rad(Index * 30)
				local x,z =  math.cos(Theta) * radius,math.sin(Theta) * radius
				x,z = Root.Position.X + x,Root.Position.Z + z
				local ax,ay,az = math.rad(math.random(1,12) * 30),math.rad(math.random(1,12) * 30),math.rad(math.random(1,12) * 30)
				local a2x,a2y,a2z = math.rad(math.random(1,12) * 30),math.rad(math.random(1,12) * 30),math.rad(math.random(1,12) * 30)
				local r1 = Vector3.new(x,Root.Position.Y,z)
				local r2 = Root.CFrame.upVector * -200
				local results = workspace:Raycast(r1,r2,raycastparams)
				if results and results.Instance and (results.Position - r1).Magnitude < 100 then
					local c1 = results.Position + Vector3.new(0,-(Size2 + .2),0)
					local c2 = results.Position
					local Part = Instance.new("Part")
					Part.Material = results.Instance.Material
					Part.Color = results.Instance.Color
					Part.Size = Vector3.new(Size2,Size2,Size2)
					Part.CanCollide = false
					Part.Anchored = true
					Part.Parent = rocks
					Part.CFrame = CFrame.new(c1) * CFrame.Angles(ax,ay,az)
					local Tween = TweenService:Create(Part,B6,{CFrame = CFrame.new(c2) * CFrame.Angles(a2x,a2y,a2z)})
					Tween:Play()
					Tween:Destroy()
					Debris:AddItem(Part,1)
					coroutine.resume(coroutine.create(function()
						wait(.8)
						local Tween = TweenService:Create(Part,B6,{CFrame = CFrame.new(c1) * CFrame.Angles(ax,ay,az)})
						Tween:Play()
						Tween:Destroy()
					end))
				end
			end
		end
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Map}
raycastParams.FilterType = Enum.RaycastFilterType.Include

local ZenitsuMode = {	
	["Transformation"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")
		
		local ZenitsuSword = Character:FindFirstChild("ZenitsuSword")		
		local StartTime = os.clock()
		
		coroutine.resume(coroutine.create(function()
			for Index = 1,3 do
				local X,Y,Z = math.random(-3,3) * 4,math.random(-3,3) * 4,math.random(-3,3) * 2
				local StartPosition = Root.Position
				local EndPosition = StartPosition + Vector3.new(X,Y,Z)
				CreateLightning(StartPosition,EndPosition,math.random(3,7))
				-- SoundManager:AddSound("LightningSizzle", {Parent = Root, Volume = 3}, "Client")
				wait(.35)
			end	
		end))
		
		coroutine.wrap(function()
			local WIDTH, LENGTH = 0.2, 4
			for j = 1,185 do
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
		
		for j = 1,25 do
			for i = 1,math.random(1,2) do
				--[[ Raycast ]]--
				local StartPosition = (Vector3.new(math.sin(360 * j) * math.random(5,10), 0, math.cos(360*j)*math.random(5,10)) + Character.HumanoidRootPart.Position)
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

						Debris:AddItem(Block, 0.25)
					end
				end
			end
			wait()
		end
		
		for _,v in ipairs(Character:GetChildren()) do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
				local particle = script.Part.particl:Clone()
				particle.Name = "ZenitMode"
				particle.Parent = v
				
				local particle2 = script.LongLineTing:Clone()
				particle2.Name = "ZenitMode"
				particle.Parent = v
				
				local particle3 = script.light:Clone()
				particle3.Name = "ZenitMode"
				particle3.Parent = v
			end
		end
		
		ZenitsuSword.Blade.Trail.Enabled = false
		ZenitsuSword.Blade.TrailMode.Enabled = true
				
		local OldFace = Character.FakeHead.face.Texture
		Character.FakeHead.face.Texture = "http://www.roblox.com/asset/?id=7028448688"
		
		local PointLight = Instance.new("PointLight")
		PointLight.Brightness = 2
		PointLight.Range = 15
		PointLight.Name = "ZenitMode"
		PointLight.Color = Color3.fromRGB(253, 234, 141)
		PointLight.Parent = Root
		
		while Character and Character.Humanoid.Health >= 1 and Character:FindFirstChild("ZenitsuSword") do
			coroutine.resume(coroutine.create(function()
				local Parents = {Character:FindFirstChild("HumanoidRootPart").Position, Character:FindFirstChild("Head").Position, Character:FindFirstChild("Left Arm").Position, Character:FindFirstChild("Right Leg").Position}

				local X,Y,Z = math.random(-3,3) * 4,math.random(-3,3) * 4,math.random(-3,3) * 2
				local StartPosition = Parents[math.random(1, #Parents)]
				local EndPosition = StartPosition + Vector3.new(X,Y,Z)
								
				for Index = 1,2 do					
					CreateLightning(StartPosition,EndPosition,math.random(3,7))
					-- SoundManager:AddSound("LightningSizzle", {Parent = Root, Volume = 2}, "Client")
					wait(.225)
				end
			end))

			if os.clock() - StartTime >= 58 then
				StartTime = os.clock()
				break
			end
			wait(1)
		end
		if Character:FindFirstChild("ZenitsuSword") then
			Character.FakeHead.face.Texture = OldFace
		end

		ZenitsuSword.Blade.Trail.Enabled = true
		ZenitsuSword.Blade.TrailMode.Enabled = false
		
		for _,v in ipairs(Character:GetDescendants()) do
			if string.find(v.Name,"ZenitMode") then
				v:Destroy()
			end
		end
	end,
	
	["SixFoldTeleport"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")
		
		local Configurations = Data.Configurations
		
		for Index = 1,4 do
			local x,y,z = math.random(-3,3) * 4,math.random(-3,3) * 4,math.random(-3,3) * 2
			local start = Configurations.End
			local End = start + Vector3.new(x,y,z)
			local Effect = script.D:Clone()
			Effect.CFrame = CFrame.new(start,End)

			local Ti5 = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

			local Tween = TweenService:Create(Effect,Ti5,{["CFrame"] = CFrame.new(start,End) * CFrame.new(0,0,-10),["Size"] = Vector3.new(0,0,7.649)})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(Effect,.2)
			Effect.Parent = workspace.World.Visuals
		end
		
		-- SoundManager:AddSound("Thunder_Teleport",{Parent = Root},"Client")
		createhugelightning(Configurations.Start, Configurations.End, Configurations.NumberOfParts)
	end,	
	
	["gitredy"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")
		
		for _ = 1,2 do
			local x,y,z = math.random(-2,2) * 10,math.random(-2,2) * 10,math.random(-2,2) * 10
			local End = Root.Position + Vector3.new(x,y,z)
			local Start = Root.CFrame * CFrame.new(math.random(-2,2),math.random(-2,2),math.random(-2,2)).p
			local c1,c2 = End + Vector3.new(0,3,0),Root.CFrame.upVector * -200
			local results = workspace:Raycast(c1,c2,raycastparams)
			if results and results.Instance and (results.Position - c1).Magnitude < 50 then			
				coroutine.resume(coroutine.create(function()
					for  _ = 1,4 do
						CreateLightning(Start,results.Position,math.random(4,7),"Cool yellow")
						wait(.15)
					end
				end))
				-- SoundManager:AddSound("LightningSizzle", {Parent = Root, Volume = 3}, "Client")
			end
			wait(.05)
		end
		
		coroutine.resume(coroutine.create(function()
			for _ = 1,4 do
				for Index = 1,5 do
					local RootPosition = Root.CFrame
					local OriginalPosition = CFrame.new(RootPosition.Position + Vector3.new(math.random(-1,1) * 10,math.random(-1,1) * 10,math.random(-1,1 ) * 10), RootPosition.Position)

					local InstancedPart = ReplicatedStorage.Assets.Effects.Meshes.Block:Clone()
					InstancedPart.Shape = "Block"
					InstancedPart.Size = Vector3.new(1,1,10)
					InstancedPart.Material = Enum.Material.Neon
					InstancedPart.BrickColor = math.random(1,2) == 1 and BrickColor.new("Pastel blue-green") or BrickColor.new("Cool yellow")
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
	
	["TransformationOld"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")
				
		local sixfoldupgrade = Instance.new("Folder")
		sixfoldupgrade.Name = "Rocks"
		sixfoldupgrade.Parent = workspace.World.Visuals
		Debris:AddItem(sixfoldupgrade,5)
		
		GlobalFunctions.FreshShake(100,30,1,.2,0)

		local Center = Root.CFrame
		
		local Type = 2
			
		coroutine.resume(coroutine.create(function()
			for Index = 1,6 do
				-- SoundManager:AddSound("Thunder_Teleport",{Parent = Root},"Client")
				local radiusx,radiusy,radiusz = (math.random(1,5) * 10) + 10,(math.random(1,5) * 10) + 10,(math.random(1,5) * 10) + 10
				local x,y,z = math.random(1,2),math.random(1,2),math.random(1,2)
				if x == 2 then
					x = -1
				end
				if y == 2 then
					y = 1
				end
				if z == 2 then
					z = -1
				end
				local pos = Center * CFrame.new(x * radiusx,y * radiusy,z * radiusz)
				local position = pos.p

				if Index == 6 then
					position = Center.p
				end
				local End = position
				createhugelightning(Root.Position,End, math.clamp((Root.Position - End).Magnitude / 15,3,20), Players:GetPlayerFromCharacter(Character))
				wait(.08)
			end
		end))
				
		if Character and Root and Type then
			for _ = 1,math.random(3,6) * 3 do
				local Rock = ReplicatedStorage.Assets.Effects.Meshes.Rock:Clone()
				local x,y,z = math.random(-6,6),0,math.random(-6,6)
				Rock.CFrame = Root.CFrame * CFrame.new(x,y,z) * CFrame.new(0,-Character:GetModelSize().Y / 2,0) * CFrame.Angles(math.rad(math.random(1,24) * 15),math.rad(math.random(1,24) * 15),math.rad(math.random(1,24)* 15) )
				Rock.CanCollide = false
				Rock.Material = Enum.Material.Slate
				Rock.Color = RockColors[math.random(1,#RockColors)]
				Rock.Parent = sixfoldupgrade
				local Size = math.random(1,2) / 2
				Rock.Size = Vector3.new(Size,Size,Size)
				
				local B1 = TweenInfo.new(2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)

				local Tween = TweenService:Create(Rock,B1,{Position = Rock.Position+Vector3.new(0,((math.random(1,7))),0)})
				Tween:Play()
				Tween:Destroy()
				coroutine.resume(coroutine.create(function()
					wait(1)
					local B3 = TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

					local Tween = TweenService:Create(Rock,B3,{Transparency = 1})
					Tween:Play()
					Tween:Destroy()
				end))
				Debris:AddItem(Rock,2)
			end
			VfxHandler.RockExplosion({
				Pos = Root.Position, 
				Quantity = 14, 
				Radius = 5,
				Size = Vector3.new(1.85,1.85,1.85), 
				Duration = .5, 
			})	
			--QuickTings(Root,Type)
			local Wave = script.Shock:Clone()
			Wave.Size = Vector3.new(15,0,15)
			Wave.Material = Enum.Material.Neon
			Wave.CFrame = Root.CFrame * CFrame.new(0,-Root.Parent:GetModelSize().Y / 2,0)
			Wave.Parent = sixfoldupgrade
			
			local PointLight = Instance.new("PointLight")
			PointLight.Brightness = 0
			PointLight.Range = 0
			PointLight.Color = Color3.fromRGB(253, 234, 141)
			PointLight.Parent = Root
			Debris:AddItem(PointLight,1)
			local Ti = TweenInfo.new(.12,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true,0)
			TweenService:Create(PointLight,Ti,{Brightness = 10,Range = 20}):Play()
			
			local B2 = TweenInfo.new(.1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
			local B4 = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

			TweenService:Create(Wave,B2,{Size = Vector3.new(15,30,15),CFrame = Wave.CFrame * CFrame.new(0,30 / 2,0)}):Play()
			TweenService:Create(Wave,B4,{Transparency = 1}):Play()
			coroutine.resume(coroutine.create(function()
				wait(.1)
				local B2 = TweenInfo.new(.1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

				TweenService:Create(Wave,B2,{Size = Vector3.new(5,0,5),CFrame = Wave.CFrame * CFrame.new(0,-30 / 2,0) * CFrame.Angles(0,math.rad(math.random(10,24) * 15),0)}):Play()
			end))
			Debris:AddItem(Wave,.2)
			
			--coroutine.resume(coroutine.create(function()
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
			--end))
			local DistanceIndex = 1 - math.clamp((workspace.CurrentCamera.CFrame.Position - Root.Position).Magnitude,0,70) / 70
			
			--local ColorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			--ColorCorrectionEffect.TintColor = Color3.fromRGB(255, 230, 101)
			--ColorCorrectionEffect.Parent = workspace.CurrentCamera
			--TweenService:Create(ColorCorrectionEffect,Ti,{Brightness = DistanceIndex / 2}):Play()
			--Debris:AddItem(ColorCorrectionEffect,2)
			
			-- SoundManager:AddSound("BOOM!",{Parent = Root, Volume = 2.5}, "Client")
		end
		
		local Start = nil
		local End = nil
		if Type == 1 then
			local x,z = math.random(-2,2) * 3,math.random(-2,2) * 3
			Start = Root.CFrame * CFrame.new(x,0,z)
			local r1,r2 = Start.Position + Vector3.new(0,3,0),Start.upVector * -200
			local results = workspace:Raycast(r1,r2,raycastparams)
			if results and results.Instance and (results.Position-r1).Magnitude < 12 then
				Start = results.Position
			end
			if typeof(Start) == "CFrame" then
				Start = Start.p
			end
			End = Start + Vector3.new(0,(20 * Type) + (math.random(3,5) * 3) ,0)
		else
			local x,z = math.random(-2,2) * 3,math.random(-2,2) * 3
			Start = Root.CFrame * CFrame.new(x,0,z)
			local r1,r2 = Start.Position + Vector3.new(0,3,0),Start.upVector * -200
			local results = workspace:Raycast(r1,r2,raycastparams)
			if results and results.Instance and (results.Position - r1).Magnitude <12 then
				Start = results.Position
			end
			if typeof(Start) == "CFrame" then
				Start = Start.p
			end
			End = Start + Vector3.new(0,(20 * Type) + (math.random(3,5) * 3) ,0)
		end
		coroutine.resume(coroutine.create(function()
			for _ = 1,8 do
				if Start and End then
					local numberofparts = math.random(4,6)
					local lastcf = Start
					local Distance = (Start - End).Magnitude / numberofparts
					for Index = 1,numberofparts do
						local x,y,z = math.random(-2,2) * 5 * Type,math.random(-2,2) * 5 * Type,math.random(-2,2) * 5 * Type
						if Index == numberofparts then
							x = 0
							y = 0
							z = 0
						end
						local newcframe = CFrame.new(lastcf,End + Vector3.new(x,y,z)) * CFrame.new(0,0,-Distance)
						local newdisance = (lastcf-newcframe.p).Magnitude
						local Part = Instance.new("Part")
						Part.Material = Enum.Material.Neon
						Part.Color = Color3.fromRGB(128, 187, 219)
						Part.TopSurface = Enum.SurfaceType.SmoothNoOutlines
						Part.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
						Part.CanCollide = false
						Part.Name = Index
						Part.Parent = workspace.World.Visuals
						Part.Anchored = true
						Part.CastShadow = false
						Part.Size = Vector3.new(Type,Type,newdisance)
						Part.CFrame = CFrame.new(lastcf,newcframe.p) * CFrame.new(0,0,-newdisance / 2)
						local v = Instance.new("Vector3Value")
						v.Name = "Start"
						v.Value = Start
						v.Parent = Part
						local Ti2 = TweenInfo.new(.4,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

						TweenService:Create(Part,Ti2,{Size = Vector3.new(0,0,newdisance)}):Play()
						Debris:AddItem(Part,.4)
						lastcf = newcframe.p
						local Ti4 = TweenInfo.new(.02,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,2,true,0)

						TweenService:Create(Part,Ti4,{Transparency = 1}):Play()
					end
				end
				wait(.25)	
			end
		end))
		if Root then
			for _ = 1,math.random(1,2) do
				local x,y,z = math.random(-2,2) * 10,math.random(-2,2) * 10,math.random(-2,2) * 10
				local End = Root.Position + Vector3.new(x,y,z)
				local Start = Root.CFrame * CFrame.new(math.random(-2,2),math.random(-2,2),math.random(-2,2)).p
				local c1,c2 = End + Vector3.new(0,3,0),Root.CFrame.upVector * -200
				local results = workspace:Raycast(c1,c2,raycastparams)
				if results and results.Instance and (results.Position - c1).Magnitude < 50 then			
					coroutine.resume(coroutine.create(function()
						for  _ = 1,4 do
							CreateLightning(Start,results.Position,math.random(4,7))
							wait(.15)
						end
					end))
					-- SoundManager:AddSound("LightningSizzle", {Parent = Root, Volume = 3}, "Client")
				end
				wait(.05)
			end
		end
	end,

	["WhirlWindHit"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
		
		local Root = Data.Part
		local contactPointCFrame = Data.ContactPointCFrame.CFrame

		local _ = Character.Name == Players.LocalPlayer.Name and GlobalFunctions.FreshShake(85,25,1,.2,0)

		VfxHandler.Orbies({
			Parent = contactPointCFrame,
			Size = Vector3.new(0,0,math.random(1.8,3.5)), 
			Color = Color3.fromRGB(0,0,0), 
			Speed = .35,
			Cframe = CFrame.new(0,0,50),
			Amount = 15, 
			Circle = true
		})
		-- SoundManager:AddSound("Thunder_explosion",{Parent = Root, Volume = 5},"Client")

		local Dust = Effects.Dust:Clone()
		Dust.CFrame = contactPointCFrame * CFrame.new(0,-1,0)
		Dust.Orientation = Vector3.new(0,0,0)
		Dust.Parent = workspace.World.Visuals
		Dust.Particle.SpreadAngle = Vector2.new(-360, 360)
		Dust.Size = Vector3.new(0,0,0)
		Dust.Particle.EmissionDirection = "Back"
		Dust.Particle.Speed = NumberRange.new(60)
		Dust.Particle.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 3)}
		Dust.Particle.Lifetime = NumberRange.new(1.5)
		Dust.Particle.Drag = 2
		Dust.Particle.Enabled = true
		Dust.Particle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))	
		Dust.Particle:Clear()

		VfxHandler.Emit(Dust.Particle,100)
		Debris:AddItem(Dust, 3)	

		local Dust2 = Effects.Dust:Clone()
		Dust2.CFrame = contactPointCFrame * CFrame.new(0,-1,0)
		Dust2.Parent = workspace.World.Visuals
		Dust2.Particle.SpreadAngle = Vector2.new(0, 180)
		Dust2.Size = Vector3.new(0,0,0)
		Dust2.Particle.EmissionDirection = "Back"
		Dust2.Particle.Speed = NumberRange.new(50)
		Dust2.Particle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))	
		Dust2.Particle.Lifetime = NumberRange.new(1)
		Dust2.Particle.Enabled = true
		Dust2.Particle:Clear()
		Dust2.Particle:Emit(100)		
		Debris:AddItem(Dust2, 2)		

		local GroundDebris = Effects.grounddebris:Clone()
		GroundDebris.CFrame = contactPointCFrame
		GroundDebris.Parent = workspace.World.Visuals
		GlobalFunctions.TweenFunction({
			["Instance"] = GroundDebris,
			["EasingStyle"] = Enum.EasingStyle.Quad,
			["EasingDirection"] = Enum.EasingDirection.Out,
			["Duration"] = .35,
		},{
			["Transparency"] = 1,
			["Size"] = GroundDebris.Size + Vector3.new(60,0,60),
		})

		Debris:AddItem(GroundDebris, .35)

		--
		local windshockwave = Effects.windshockwave:Clone()
		windshockwave.CFrame = contactPointCFrame
		windshockwave.Size = Vector3.new(10, 10, 10)
		windshockwave.Transparency = 0
		windshockwave.Material = "Neon"
		windshockwave.BrickColor = BrickColor.new("Pastel blue-green")
		windshockwave.Parent = workspace.World.Visuals

		local windshockwave2 = Effects.windshockwave2:Clone()
		windshockwave2.CFrame = contactPointCFrame
		windshockwave2.Size = Vector3.new(10, 10, 10)
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
			["Size"] = Vector3.new(80,80,80),
			["CFrame"] = windshockwave2.CFrame * CFrame.fromEulerAnglesXYZ(0,10,0)
		})

		GlobalFunctions.TweenFunction({
			["Instance"] = windshockwave,
			["EasingStyle"] = Enum.EasingStyle.Quad,
			["EasingDirection"] = Enum.EasingDirection.Out,
			["Duration"] = .35,
		},{
			["Transparency"] = 1,
			["Size"] = Vector3.new(80,80,80),
			["CFrame"] = windshockwave.CFrame * CFrame.fromEulerAnglesXYZ(0,10,0)
		})

		Debris:AddItem(windshockwave2, .35)
		Debris:AddItem(windshockwave, .35)


		local Result = workspace:Raycast(Root.Position, Root.CFrame.upVector * -15, raycastParams)
		if Result and Result.Instance then
			Dust.Particle.Color = ColorSequence.new(Result.Instance.Color)	
			Dust2.Particle.Color = ColorSequence.new(Result.Instance.Color)	

			Dust.Position = Result.Position
			Dust2.Position = Result.Position

			for _ = 1, 10 do
				local Rock = Effects.Rock:Clone()
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

				local BlockTrail = Particles.BlockSmoke:Clone()
				BlockTrail.Color = ColorSequence.new(Result.Instance.Color)
				BlockTrail.Enabled = true
				BlockTrail.Parent = Rock

				Debris:AddItem(Rock,3)
				Debris:AddItem(BodyVelocity,.1)
			end
		end
	end,	

	["WhirlWindRelease"] = function(Data)
		local Character = Data.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
		
		local Root = Data.Part
		
		for Index = 1, 9 do
			-- SoundManager:AddSound("Lightning_Release",{Parent = Root, Volume = 4},"Client")

			-- SoundManager:AddSound("LightningExplosion2",{Parent = Root,Volume = 2},"Client")

			local _ = Character.Name == Players.LocalPlayer.Name and GlobalFunctions.FreshShake(100,30,1,.2,0)
			local ColorIndex = Index >= 4 and BrickColor.new("Pastel blue-green") or BrickColor.new("Cool yellow")

			coroutine.resume(coroutine.create(function()
				for _ = 1, 3 do
					local OriginalPosition = Root.Position

					local Orbie = Effects.block:Clone()
					Orbie.Size = Vector3.new(2, 2, 20)
					Orbie.Material = "Neon"
					Orbie.BrickColor = ColorIndex
					Orbie.Transparency = 0
					Orbie.CFrame = CFrame.new(OriginalPosition + Vector3.new(math.random(-1,1),math.random(-1,1),math.random(-1,1)), OriginalPosition) 

					local SpecialMesh = Instance.new("SpecialMesh")
					SpecialMesh.MeshType = "Sphere"
					SpecialMesh.Parent = Orbie					

					Orbie.Parent = workspace.World.Visuals

					GlobalFunctions.TweenFunction({
						["Instance"] = Orbie,
						["EasingStyle"] = Enum.EasingStyle.Quad,
						["EasingDirection"] = Enum.EasingDirection.Out,
						["Duration"] = .35,
					},{
						["Size"] = Orbie.Size + Vector3.new(0,0,math.random(1.8,3.5)),
						["CFrame"] = Orbie.CFrame * CFrame.new(0,0,40)
					})

					GlobalFunctions.TweenFunction({
						["Instance"] = Orbie,
						["EasingStyle"] = Enum.EasingStyle.Quad,
						["EasingDirection"] = Enum.EasingDirection.Out,
						["Duration"] = .35,
					},{
						["Transparency"] = .8,
						["Size"] = Vector3.new(0,0,.8)
					})

					Debris:AddItem(Orbie,.35)				
				end
			end))
			local Slash = Effects.slash:Clone()
			Slash.Material = "Neon"
			Slash.BrickColor = math.random(1,2) == 1 and BrickColor.new("Pastel blue-green") or BrickColor.new("Cool yellow")
			Slash.Size = Vector3.new(5,5,5)
			Slash.CFrame = Root.CFrame * CFrame.fromEulerAnglesXYZ(math.random(-360,360),math.random(-360,360),math.random(-360,360))
			Slash.Transparency = 0
			Slash.Parent = workspace.World.Visuals

			GlobalFunctions.TweenFunction({
				["Instance"] = Slash,
				["EasingStyle"] = Enum.EasingStyle.Quad,
				["EasingDirection"] = Enum.EasingDirection.Out,
				["Duration"] = .25,
			},{
				["Transparency"] = 1,
				["Size"] = Vector3.new(30,30,30)
			})

			Debris:AddItem(Slash, .25)		

			local SwingShockwave = Effects.SwingShockwave:Clone()
			SwingShockwave.BrickColor = ColorIndex
			SwingShockwave.Material = "Neon"
			SwingShockwave.CFrame = Root.CFrame
			SwingShockwave.Rotation = Vector3.new(math.random(-60,60) * Index,math.random(-60,60) * Index, math.random(-60,60) * Index)
			SwingShockwave.Parent = workspace.World.Visuals

			GlobalFunctions.TweenFunction({
				["Instance"] = SwingShockwave,
				["EasingStyle"] = Enum.EasingStyle.Quad,
				["EasingDirection"] = Enum.EasingDirection.Out,
				["Duration"] = .25,
			},{
				["Transparency"] = 1,
				["Size"] = Vector3.new(50, 0.05, 50),
				["CFrame"] = SwingShockwave.CFrame * CFrame.fromEulerAnglesXYZ(0,10,0)
			})

			Debris:AddItem(SwingShockwave,.25)

			local Ring = Effects.ring:Clone()
			Ring.BrickColor = math.random(1,2) == 1 and BrickColor.new("Pastel blue-green") or BrickColor.new("Cool yellow")
			Ring.Material = "Neon"
			Ring.Transparency = 0
			Ring.CFrame = Root.CFrame
			Ring.Size = Vector3.new(5,1,5)
			Ring.Parent = workspace.World.Visuals

			local OutRing = Ring:Clone()
			OutRing.Material = "Neon"
			OutRing.BrickColor = ColorIndex
			OutRing.Size = Vector3.new(10,1,10)
			OutRing.CFrame = Root.CFrame * CFrame.new(0,5,0) * CFrame.fromEulerAnglesXYZ(math.random(-360,360),math.random(-360,360),math.random(-360,360))
			OutRing.Parent = Ring

			Debris:AddItem(Ring, 1)

			GlobalFunctions.TweenFunction({["Instance"] = Ring,["EasingStyle"] = Enum.EasingStyle.Quart,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .5,},{["Size"] = Vector3.new(15,1,15), ["CFrame"] = Ring.CFrame * CFrame.fromEulerAnglesXYZ(0,100,0)})
			GlobalFunctions.TweenFunction({["Instance"] = OutRing,["EasingStyle"] = Enum.EasingStyle.Quart,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .5,},{["Size"] = Vector3.new(30,1,30),["CFrame"] = OutRing.CFrame * CFrame.fromEulerAnglesXYZ(0,100,0)})

			GlobalFunctions.TweenFunction({["Instance"] = Ring,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .25,},{["Transparency"] = 1, ["CFrame"] = Ring.CFrame * CFrame.fromEulerAnglesXYZ(0,100,0)})
			GlobalFunctions.TweenFunction({["Instance"] = OutRing,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .25,},{["Transparency"] = 1, ["CFrame"] = OutRing.CFrame * CFrame.fromEulerAnglesXYZ(0,100,0)})
			wait(.15)
		end
	end,
}

return ZenitsuMode