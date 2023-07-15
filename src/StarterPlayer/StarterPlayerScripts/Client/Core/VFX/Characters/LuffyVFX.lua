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

local World = workspace.World
local Visuals = World.Visuals

local EffectMeshes = ReplicatedStorage.Assets.Effects.Meshes
local EffectParticles = ReplicatedStorage.Assets.Effects.Particles
local EffectBeams = ReplicatedStorage.Assets.Effects.Beams
local Particles = ReplicatedStorage.Assets.Effects.Particles

local function RemoveTrash(Trash)
	for Index = 1,#Trash do
		local Item = Trash[Index]
		if Item and Item.Parent then
			Item:Destroy()
		end
	end
end

local LuffyVFX = {

	["GatlingHitVFX"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		local Victim = Data.Victim
		local VRoot = Victim:FindFirstChild("HumanoidRootPart")

		VfxHandler.Orbies({Parent = VRoot, Size = Vector3.new(.4, .4, 5.79), Color = Color3.fromRGB(255, 255, 255), Speed = .2, Cframe = CFrame.new(0,0,0), Amount = 1, Sphere = true})		
		VfxHandler.Orbies({Parent = VRoot, Size = Vector3.new(.565, .565, .565), Color = Color3.fromRGB(255, 255, 255), Speed = .2, Cframe = CFrame.new(0,0,3), Amount = 15, Circle = true})
	end;

	["Gatling"] = function(PathData)
		local Character = PathData.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		local Sound = -- SoundManager:AddSound("JetGatling",{Parent = Root, Looped = true},"Client",{Duration = 2})

		--[[ Set Arms Invisible ]]--
		local RightArm = Character["Right Arm"]
		local LeftArm = Character["Left Arm"]

		RightArm.Transparency = 1
		LeftArm.Transparency = 1

		--[[ Side Shockwaves ]]--
		for j = 1,2 do

			local Offset = 5;
			local Rot = 288;
			local GoalSize = Vector3.new(35, 0.05, 7.5);
			if j == 1 then
			else
				Offset = Offset * -1;
				Rot = 252
			end

			local SideWind = EffectMeshes.SideWind:Clone()
			SideWind.Size = Vector3.new(8, 0.05, 2)
			SideWind.Transparency = 0
			SideWind.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(Offset,-0.5,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),math.rad(180),math.rad(Rot))
			SideWind.Parent = Visuals

			--[[ Tween the Side Shockwaves ]]--
			local tween = TweenService:Create(SideWind, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = SideWind.CFrame * CFrame.new(-10,0,0), ["Size"] = GoalSize, ["Transparency"] = 1})
			tween:Play()
			tween:Destroy()

			Debris:AddItem(SideWind, 0.15)
		end

		coroutine.wrap(function()
			for i = 1, 10 do
				local shockwaveOG = EffectMeshes.shockwaveOG:Clone()
				shockwaveOG.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)* CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
				shockwaveOG.Size = Vector3.new(5, 2, 5)
				shockwaveOG.Transparency = 0
				shockwaveOG.Material = "Neon"
				if (i % 2 == 0) then
					shockwaveOG.Color = Color3.fromRGB(255, 255, 255)
				else
					shockwaveOG.Color = Color3.fromRGB(0, 0, 0)
				end
				shockwaveOG.Parent = Visuals
				local tween = TweenService:Create(shockwaveOG, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Size"] = Vector3.new(25, 5, 25), ["CFrame"] = shockwaveOG.CFrame * CFrame.fromEulerAnglesXYZ(0,5,0)})
				tween:Play()
				tween:Destroy()
				Debris:AddItem(shockwaveOG, 0.2)


				--[[ Ring Behind Player ]]--
				local cs = ReplicatedStorage.Assets.Effects.Meshes.Ring2:Clone()
				cs.Size = Vector3.new(5, 2, 5)
				local c1,c2 = Root.CFrame*CFrame.new(0,0,-40)*CFrame.Angles(math.pi/2,0,0) ,Root.CFrame*CFrame.new(0,0,10)*CFrame.Angles(math.pi/2,0,0) 
				cs.CFrame = c1
				cs.Material = Enum.Material.Neon
				cs.Parent = workspace.World.Visuals

				local Tween = TweenService:Create(cs,TweenInfo.new(.15,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),{Size = Vector3.new(25,0,25),CFrame = c2})
				Tween:Play()
				Tween:Destroy()

				Debris:AddItem(cs,.15)

				--[[ Wind Debris Effect ]]--
				local slash = ReplicatedStorage.Assets.Effects.Meshes.ThreeDSlashEffect:Clone()
				local size = math.random(2,4) * 4
				local sizeadd = math.random(2,4) * 20
				local x,y,z = math.rad(math.random(8,12) * 30), math.rad(math.random(8,12) * 30), math.rad(math.random(8,12) * 30)
				local add = math.random(1,2)
				if add == 2 then
					add = -1
				end
				slash.Transparency = .4
				slash.Size = Vector3.new(2,size,size)
				slash.CFrame = Root.CFrame*CFrame.Angles(x,y,z)
				slash.Parent = workspace.World.Visuals

				local Tween = TweenService:Create(slash,TweenInfo.new(.3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),{Transparency = 1,CFrame = slash.CFrame*CFrame.Angles(math.pi * add,0,0),Size = slash.Size+Vector3.new(0,sizeadd,sizeadd)})
				Tween:Play()
				Tween:Destroy()

				Debris:AddItem(slash,.3)

				--[[ Delay Iteration ]]--
				wait(.15)
			end
		end)()

		--[[ Ring ]]--
		coroutine.wrap(function()
			for _ = 1,6 do
				local Ring = EffectMeshes.Ring:Clone()
				Ring.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-5) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
				Ring.Size = Vector3.new(2.5,0,2.5)
				Ring.Transparency = 0
				Ring.Parent = Visuals

				local tween = TweenService:Create(Ring, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Size"] = Vector3.new(20,0,20)})
				tween:Play()
				tween:Destroy()
				Debris:AddItem(Ring, 0.15)
				wait(.15)
			end
		end)()
		
		coroutine.wrap(function()
			local WIDTH, LENGTH = 0.25, 10
			for j = 1,55 do
				for i = 1,3 do
					local Block = EffectMeshes.Sphere:Clone()
					Block.Transparency = 0
					Block.Mesh.Scale = Vector3.new(WIDTH,WIDTH,LENGTH)
					Block.Material = Enum.Material.Neon
					if j % 2 == 0 then
						Block.Color = Color3.fromRGB(255, 255, 255)
					else
						Block.Color = Color3.fromRGB(0, 0, 0)
					end
					Block.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-2.5,2.5) * i,math.random(-2,2) * i, 0)
					Block.Parent = Visuals

					local tween = TweenService:Create(Block, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1, ["CFrame"] = Block.CFrame * CFrame.new(0,0,-25)})
					tween:Play()
					tween:Destroy()
					Debris:AddItem(Block, 0.15)
				end
				wait()
			end
		end)()

		--
		for _ = 1,115 do 
			local ToCFrame = Root.CFrame * CFrame.new(0,0,-30)

			local CFrameConfig = CFrame.new((Root.CFrame * CFrame.new(math.random(-3,3),math.random(-2,2),math.random(-4,-3))).p,ToCFrame.p) * CFrame.Angles(math.rad(90),0,0)

			local Arm = script.LuffyGattlingArm:Clone()
			Arm.Color = Color3.fromRGB(232, 186, 200)
			Arm.Anchored = true
			Arm.Massless = true
			Arm.CFrame = CFrameConfig
			Arm.Parent = workspace.World.Visuals

			local Shockwave = script["Meshes/SHOCKWAVE"]:Clone()
			Shockwave.Transparency = .5
			Shockwave.Size = Vector3.new(2.078, 0.23, 2.077)
			Shockwave.CFrame = Arm.CFrame
			Shockwave.Anchored = true
			Shockwave.CanCollide = false
			Shockwave.Parent = workspace.World.Visuals

			Debris:AddItem(Shockwave,.05)

			RunService.Heartbeat:Wait()

			local Tween = TweenService:Create(Arm,TweenInfo.new(.5,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{CFrame = Arm.CFrame * CFrame.new(0,-math.random(3,5),0)})
			Tween:Play()
			Tween:Destroy()

			local Tween = TweenService:Create(Shockwave,TweenInfo.new(.05,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Size = Vector3.new(3.654, 0.405, 3.653), CFrame = Shockwave.CFrame * CFrame.new(0,-math.random(1,2),0)})
			Tween:Play()
			Tween:Destroy()

			RunService.Heartbeat:Wait()

			local Tween = TweenService:Create(Arm,TweenInfo.new(.2,Enum.EasingStyle.Quad),{Transparency = 1})
			Tween:Play()
			Tween:Destroy()

			local ShockwaveTween = TweenService:Create(Shockwave,TweenInfo.new(.05,Enum.EasingStyle.Quad),{Transparency = 1})
			ShockwaveTween:Play()
			ShockwaveTween:Destroy()

			for _,v in ipairs(Arm:GetDescendants()) do
				if v:IsA("Decal") or v:IsA("UnionOperation") then
					local Animate = TweenService:Create(v,TweenInfo.new(.35,Enum.EasingStyle.Quad),{Transparency = 1})
					Animate:Play()
					Animate:Destroy()
				end
			end
			Debris:AddItem(Arm,.75)
		end

		RightArm.Transparency = 0
		LeftArm.Transparency = 0
	end;

	["Pistole"] = function(PathData)
		local Character = PathData.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		local Character = PathData.Character or nil
		local ContactPoint = PathData.ContactPoint

		--[[ Play Sound ]]--
		-- SoundManager:AddSound("GomuSFX", {Parent = Root, TimePosition = .5, Volume = 3}, "Client")

		wait(.75)

		local Arm = Character["Right Arm"]
		local GomuArm = Arm:Clone()
		GomuArm.CanCollide = false
		GomuArm.Anchored = false
		GomuArm.Massless = true

		--[[ Weld GomuArm to CharacterArm ]]--
		local Motor6D = Instance.new("Motor6D")
		Motor6D.Part0 = Arm
		Motor6D.Part1 = GomuArm
		Motor6D.Parent = Arm
		GomuArm.Parent = Visuals

		--[[ Arm Tweening Out ]]--
		local LENGTH = 50
		local StartSize = GomuArm.Size
		local GoalSize = Vector3.new(GomuArm.Size.X, LENGTH, GomuArm.Size.Z)

		local StartCFrame = Motor6D.Part0.CFrame:inverse() * (Arm.CFrame * CFrame.new(0,0,0))
		local GoalCFrame = Motor6D.Part0.CFrame:inverse() * (Arm.CFrame * CFrame.new(0,-LENGTH/1.925,0))

		--[[ Tween the size Outwards of the Arm ]]--
		local tween = TweenService:Create(GomuArm, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = GoalCFrame, ["Size"] = GoalSize})
		tween:Play()
		tween:Destroy()

		--[[ Tween the CFrame of the Arm according to Arm Size ]]--
		local tween = TweenService:Create(Motor6D, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["C0"] = GoalCFrame})
		tween:Play()
		tween:Destroy()

		--[[ Effects ]]--

		--[[ Shockwave 5 ]]--		
		local shockwave5 = EffectMeshes.shockwave5:Clone()
		shockwave5.Transparency = 0
		shockwave5.Material = "Neon"
		shockwave5.Color = Color3.fromRGB(255, 255, 255)
		shockwave5.Size = Vector3.new(5, 6, 5)
		shockwave5.CFrame = GomuArm.CFrame * CFrame.new(0,-5,0)
		shockwave5.Parent = Visuals
		local tween = TweenService:Create(shockwave5, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = shockwave5.CFrame * CFrame.new(0,-20,0) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0), ["Size"] = Vector3.new(7,50,7), ["Transparency"] = 1})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(shockwave5, 0.2)

		--[[ HollowCylinder ]]--
		local HollowCylinder = EffectMeshes.HollowCylinder:Clone()
		HollowCylinder.Size = Vector3.new(5, 5, 5)
		HollowCylinder.CFrame = GomuArm.CFrame * CFrame.new(0,-5,0)
		HollowCylinder.Parent = Visuals
		local tween = TweenService:Create(HollowCylinder, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = HollowCylinder.CFrame * CFrame.new(0,-15,0) * CFrame.fromEulerAnglesXYZ(0,math.rad(270),0), ["Size"] = Vector3.new(8,50,8), ["Transparency"] = 1})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(HollowCylinder, 0.2)

		--[[ WindMesh ]]--
		local WindMesh = EffectMeshes.WindMesh:Clone()
		WindMesh.Size = Vector3.new(2, 15, 15)
		WindMesh.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-15) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)
		WindMesh.Parent = Visuals
		local tween = TweenService:Create(WindMesh, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = WindMesh.CFrame * CFrame.new(-15,0,0) * CFrame.fromEulerAnglesXYZ(math.rad(270),0,0), ["Size"] = Vector3.new(0, 15, 15), ["Transparency"] = 1})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(WindMesh, 0.25)

		--[[ Ring ]]--
		local Ring = EffectMeshes.RingInnit:Clone()
		Ring.Size = Vector3.new(5, 0.05, 5)
		Ring.CFrame = Arm.CFrame * CFrame.new(0,-10,0)
		Ring.Parent = Visuals
		local tween = TweenService:Create(Ring, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = Ring.CFrame * CFrame.new(0,10,0), ["Size"] = Vector3.new(5, 0, 5), ["Transparency"] = 1})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(Ring, 0.25)

		wait(0.2)
		-- SoundManager:AddSound("Slap",{Parent = Root, TimePosition = 0.1, Volume = .5}, "Client")
		--[[ Return Arm size Back to Normal ]]--
		local tween = TweenService:Create(GomuArm, TweenInfo.new(.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {["CFrame"] = Arm.CFrame, ["Size"] = StartSize})
		tween:Play()
		tween:Destroy()

		--[[ Tween the CFrame Arm Back ]]--
		local tween = TweenService:Create(Motor6D, TweenInfo.new(.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {["C0"] = StartCFrame})
		tween:Play()
		tween:Destroy()

		wait(0.2)

		--[[ WindMesh ]]--
		local WindMesh = EffectMeshes.WindMesh:Clone()
		WindMesh.Size =  Vector3.new(0.1,3,3)
		WindMesh.Transparency = 0.5
		WindMesh.CFrame = Arm.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(90))
		WindMesh.Parent = Visuals

		local tween = TweenService:Create(WindMesh, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = WindMesh.CFrame * CFrame.new(2,0,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0), ["Size"] = Vector3.new(0.1, 3, 3), ["Transparency"] = 1})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(WindMesh, 0.5)

		wait(0.2)
		GomuArm:Destroy()
	end;

	["Axe"] = function(PathData)
		local Character = PathData.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		local Character = PathData.Character or nil
		local ContactPoint = PathData.ContactPoint

		--[[ Play Sound ]]--
		-- SoundManager:AddSound("GomuSFX", {Parent = Character.HumanoidRootPart, TimePosition = 0.55, Volume = 3}, "Client")

		wait(0.25)


		--[[ Effect When Ball Hit Ground ]]--
		local function GroundTouched(RootPos, PartHit)

			--[[ Rocks xD ]]--
			local Rocks = EffectParticles.ParticleAttatchments.Rocks:Clone()
			Rocks.Rocks.Color = ColorSequence.new(PartHit.Color)
			Rocks.Rocks.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0)}
			Rocks.Rocks.Drag = 5
			Rocks.Rocks.Rate = 100
			Rocks.Rocks.Acceleration = Vector3.new(0,-100,0)
			Rocks.Rocks.Lifetime = NumberRange.new(3)
			Rocks.Rocks.Speed = NumberRange.new(100,200)
			Rocks.Parent = Character.HumanoidRootPart
			Rocks.Rocks:Emit(100)
			Debris:AddItem(Rocks, 4)

			local Smoke = Particles.Smoke:Clone()
			Smoke.Smoke.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 5), NumberSequenceKeypoint.new(1, 0)}
			Smoke.Smoke.Color = ColorSequence.new(PartHit.Color)
			Smoke.Smoke.Acceleration = Vector3.new(0,-15,0)
			Smoke.Smoke.Drag = 5
			Smoke.Smoke.Lifetime = NumberRange.new(2)
			Smoke.Smoke:Emit(100)
			Smoke.Smoke.Speed = NumberRange.new(100)
			Smoke.Position = RootPos
			Smoke.Parent = Visuals
			Debris:AddItem(Smoke, 3)


			RootPos = (Character.HumanoidRootPart.Position)
			local Offset = 20
			--[[ Flying Debris Rock ]]--
			for i = 1,2 do
				local StartPosition = (Vector3.new(math.sin(360*i)*Offset, 0, math.cos(360*i)*Offset) + RootPos)
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

						local X,Y,Z = math.random(1,2),math.random(1,2),math.random(1,2)
						Block.Size = Vector3.new(X,Y,Z)

						Block.Position = pos
						Block.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
						Block.Transparency = 0
						Block.Color = partHit.Color
						Block.Material = partHit.Material
						Block.Anchored = false
						Block.CanCollide = true
						Block.Parent = Visuals

						local BodyVelocity = Instance.new("BodyVelocity")
						BodyVelocity.MaxForce = Vector3.new(1000000,1000000,1000000)
						BodyVelocity.Velocity = Vector3.new(math.random(-80,80),math.random(50,60),math.random(-80,80)) * (i*.65)
						BodyVelocity.P = 100000
						Block.Velocity = Vector3.new(math.random(-80,80),math.random(50,60),math.random(-80,80)) * (i*.65)
						BodyVelocity.Parent = Block

						Debris:AddItem(BodyVelocity, .05)
						Debris:AddItem(Block, 2)
					end
				end
				wait()
			end

			--[[ Smoke Effect on Ground ]]--
			local Smoke = Particles.Smoke:Clone()
			Smoke.Smoke.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 5)}
			Smoke.Smoke.Drag = 5
			Smoke.Smoke.Lifetime = NumberRange.new(.75,1)
			Smoke.Smoke.Rate = 250
			Smoke.Smoke:Emit(5)
			Smoke.Smoke.Speed = NumberRange.new(75)
			Smoke.Smoke.SpreadAngle = Vector2.new(1,180)
			Smoke.Smoke.Enabled = true
			Smoke.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,-2.5,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
			Smoke.Parent = Visuals
			--[[ Set Smoke Properties ]]--
			Smoke.Smoke.Color = ColorSequence.new(PartHit.Color)
			if PartHit == nil then Smoke:Destroy() end
			coroutine.wrap(function()
				for i = 1,2 do
					Smoke.Smoke:Emit(50)
					wait(0.1)
				end
				Smoke.Smoke.Enabled = false					
			end)()
			Debris:AddItem(Smoke, 2.5)

			--[[ Terrain Rocks on Ground ]]--
			local GroundRocks = {}
			for i = 1,15 do
				--[[ Raycast ]]--
				local StartPosition = (Vector3.new(math.sin(360*i)*Offset, 0, math.cos(360*i)*Offset) + RootPos)
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

						local X,Y,Z = 2,2,2
						Block.Size = Vector3.new(X,Y,Z)

						Block.Position = pos
						Block.Anchored = true
						Block.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
						Block.Transparency = 0
						Block.Color = partHit.Color
						Block.Material = partHit.Material
						Block.Parent = Visuals
						GroundRocks[i] = Block;
						Debris:AddItem(Block, 2)

					end
				end
			end	

			--[[ Delete Rocks ]]--
			wait(1.5)
			if #GroundRocks > 0 then
				for i,v in ipairs(GroundRocks) do
					v.Anchored = false
				end
			end
		end

		local Arm = Character["Right Leg"]
		local GomuArm = Arm:Clone()
		GomuArm.CanCollide = false
		GomuArm.Anchored = false
		GomuArm.Massless = true

		--[[ Weld GomuArm to CharacterArm ]]--
		local Motor6D = Instance.new("Motor6D")
		Motor6D.Part0 = Arm
		Motor6D.Part1 = GomuArm
		Motor6D.Parent = Arm
		GomuArm.Parent = Visuals

		--[[ Arm Tweening Out ]]--
		local LENGTH = 50
		local StartSize = GomuArm.Size
		local GoalSize = Vector3.new(GomuArm.Size.X, LENGTH, GomuArm.Size.Z)

		local StartCFrame = Motor6D.Part0.CFrame:inverse() * (Arm.CFrame * CFrame.new(0,0,0))
		local GoalCFrame = Motor6D.Part0.CFrame:inverse() * (Arm.CFrame * CFrame.new(0,-LENGTH/1.925,0))

		--[[ Tween the size Outwards of the Arm ]]--
		local tween = TweenService:Create(GomuArm, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = GoalCFrame, ["Size"] = GoalSize})
		tween:Play()
		tween:Destroy()

		--[[ Tween the CFrame of the Arm according to Arm Size ]]--
		local tween = TweenService:Create(Motor6D, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["C0"] = GoalCFrame})
		tween:Play()
		tween:Destroy()

		--[[ Effects ]]--
		wait(0.05)

		--[[ Shockwave 5 ]]--	
		local shockwave5 = EffectMeshes.shockwave5:Clone()
		shockwave5.Transparency = 0
		shockwave5.Material = "Neon"
		shockwave5.Color = Color3.fromRGB(255, 255, 255)
		shockwave5.Size = Vector3.new(5, 6, 5)
		shockwave5.CFrame = GomuArm.CFrame * CFrame.new(0,-5,0)
		shockwave5.Parent = Visuals
		local tween = TweenService:Create(shockwave5, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = shockwave5.CFrame * CFrame.new(0,-20,0) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0), ["Size"] = Vector3.new(7,50,7), ["Transparency"] = 1})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(shockwave5, 0.2)

		--[[ HollowCylinder ]]--
		local HollowCylinder = EffectMeshes.HollowCylinder:Clone()
		HollowCylinder.Size = Vector3.new(5, 5, 5)
		HollowCylinder.CFrame = GomuArm.CFrame * CFrame.new(0,-5,0)
		HollowCylinder.Parent = Visuals
		local tween = TweenService:Create(HollowCylinder, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = HollowCylinder.CFrame * CFrame.new(0,-15,0) * CFrame.fromEulerAnglesXYZ(0,math.rad(270),0), ["Size"] = Vector3.new(8,50,8), ["Transparency"] = 1})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(HollowCylinder, 0.2)

		--[[ WindMesh ]]--
		local WindMesh = EffectMeshes.WindMesh:Clone()
		WindMesh.Size = Vector3.new(2, 15, 15)
		WindMesh.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,10,0) * CFrame.fromEulerAnglesXYZ(0,0,math.rad(90))
		WindMesh.Parent = Visuals
		local tween = TweenService:Create(WindMesh, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = WindMesh.CFrame * CFrame.new(-5,0,0) * CFrame.fromEulerAnglesXYZ(math.rad(270),0,0), ["Size"] = Vector3.new(0, 15, 15), ["Transparency"] = 1})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(WindMesh, 0.25)

		--[[ Ring ]]--
		local Ring = EffectMeshes.RingInnit:Clone()
		Ring.Size = Vector3.new(5, 2, 5)
		Ring.CFrame = Arm.CFrame * CFrame.new(0,-10,0)
		Ring.Parent = Visuals
		local tween = TweenService:Create(Ring, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = Ring.CFrame * CFrame.new(0,10,0), ["Size"] = Vector3.new(5, 0, 5), ["Transparency"] = 1})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(Ring, 0.25)

		wait(.2)
		--[[ Return Arm size Back to Normal ]]--
		local tween = TweenService:Create(GomuArm, TweenInfo.new(.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {["CFrame"] = Arm.CFrame, ["Size"] = StartSize})
		tween:Play()
		tween:Destroy()

		--[[ Tween the CFrame Arm Back ]]--
		local tween = TweenService:Create(Motor6D, TweenInfo.new(.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {["C0"] = StartCFrame})
		tween:Play()
		tween:Destroy()

		--[[ Lines in Front/Gravity Force ]]--
		coroutine.wrap(function()
			local WIDTH, LENGTH = 0.5, 20
			for j = 1,10 do
				for i = 1,5 do
					local Block = EffectMeshes.Sphere:Clone()
					Block.Transparency = 0
					Block.Mesh.Scale = Vector3.new(WIDTH,LENGTH,WIDTH)
					Block.Material = Enum.Material.Neon
					if j % 2 == 0 then
						Block.Color = Color3.fromRGB(255, 255, 255)
					else
						Block.Color = Color3.fromRGB(0, 0, 0)
					end
					Block.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-5,5)*i,50,math.random(-2,2)*i)
					Block.Parent = Visuals

					local tween = TweenService:Create(Block, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Position"] = Block.Position - Vector3.new(0,100,0)})
					tween:Play()
					tween:Destroy()
					Debris:AddItem(Block, 0.15)
				end
				wait()
			end
		end)()

		wait(0.2)

		--[[ WindMesh ]]--
		local WindMesh = EffectMeshes.WindMesh:Clone()
		WindMesh.Size =  Vector3.new(0.1,3,3)
		WindMesh.Transparency = 0.5
		WindMesh.CFrame = Arm.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(90))
		WindMesh.Parent = Visuals

		local tween = TweenService:Create(WindMesh, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = WindMesh.CFrame * CFrame.new(2,0,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0), ["Size"] = Vector3.new(0.1, 3, 3), ["Transparency"] = 1})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(WindMesh, 0.5)

		--[[ Ring2 ]]--
		local Ring2 = EffectMeshes.Ring2OG:Clone()
		Ring2.Transparency = 0.5
		Ring2.CFrame = Character.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
		Ring2.Size = Vector3.new(10, 10, 1)
		Ring2.Parent = Visuals
		Debris:AddItem(Ring2, .15)

		local tween = TweenService:Create(Ring2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Size"] = Vector3.new(50, 50, 1), ["Transparency"] = 1})
		tween:Play()
		tween:Destroy()	

		--[[ Foot Lands Earth ]]--


		--[[ Expand Lines Out ]]--
		for j = 1,10 do
			for i = 1,2 do
				local originalPos = (Character.HumanoidRootPart.Position)
				local beam = EffectMeshes.Block:Clone()
				beam.Shape = "Block"
				local mesh = Instance.new("SpecialMesh")
				mesh.MeshType = "Sphere"
				mesh.Parent = beam
				beam.Size = Vector3.new(2,2,5)
				beam.Material = Enum.Material.Neon
				beam.Color = Color3.fromRGB(255, 255, 255)
				beam.Transparency = 0
				beam.Parent = Visuals

				beam.CFrame = CFrame.new(originalPos + Vector3.new(math.random(-1,1),math.random(-1,1),math.random(-1,1)), originalPos) 
				local tween = TweenService:Create(beam, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Size"] = beam.Size + Vector3.new(0,0, math.random(1,2)), ["CFrame"] = beam.CFrame * CFrame.new(0,0,35)})
				local tween2 = TweenService:Create(beam, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {["Size"] = Vector3.new(0,0,math.random(0,5))})		
				tween:Play()
				tween:Destroy()
				tween2:Play()
				tween2:Destroy()
				Debris:AddItem(beam, .15)
			end
		end
		--[[ Block becomes Cylinder ]]--
		local Block = EffectMeshes.Block:Clone()
		Block.BrickColor = BrickColor.new("Institutional white")
		Block.Shape = "Cylinder"
		Block.Transparency = 0
		Block.Material = "Neon"
		Block.Size = Vector3.new(50,5,5)
		Block.Position = Character.HumanoidRootPart.Position + Vector3.new(0,50,0)
		Block.CFrame = Block.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(90))		
		Block.Parent = Visuals

		local tween = TweenService:Create(Block, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Size"] = Vector3.new(100, 0, 0)})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(Block, 0.2)

		--[[ shockwave5 ]]--
		local shockwave5 = EffectMeshes.shockwave5:Clone()
		shockwave5.CFrame = Character.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(90), 0)
		shockwave5.Size = Vector3.new(25, 50, 25)
		shockwave5.Transparency = 0
		shockwave5.Material = "Neon"
		shockwave5.BrickColor = BrickColor.new("Institutional white")
		shockwave5.Parent = Visuals

		local tween = TweenService:Create(shockwave5, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = shockwave5.CFrame * CFrame.new(0,25,0) * CFrame.fromEulerAnglesXYZ(0,5,0), ["Size"] = Vector3.new(0, 75, 0)})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(shockwave5, 0.2)

		--[[ Move Towards Goal ]]--
		local BodyPosition = Instance.new("BodyPosition")
		BodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		BodyPosition.P = 200;
		BodyPosition.D = 20;
		BodyPosition.Parent = Character.HumanoidRootPart
		BodyPosition.Position = Character.HumanoidRootPart.Position + Vector3.new(0,5,0)
		Debris:AddItem(BodyPosition, 0.1)

		--[[ Raycast Directly Below by x Studs Away ]]--
		local StartPosition = (Character.HumanoidRootPart.Position)
		local EndPosition = CFrame.new(StartPosition).UpVector * -10

		local RayData = RaycastParams.new()
		RayData.FilterDescendantsInstances = {Character, World.Live, World.Visuals} or World.Visuals
		RayData.FilterType = Enum.RaycastFilterType.Exclude
		RayData.IgnoreWater = true

		local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
		if ray then
			local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
			if partHit then
				--[[ Rocks Fall Down ]]--
				coroutine.wrap(function() GroundTouched(pos, partHit) end)()
			end
		end	
		wait(.2)
		GomuArm:Destroy()
	end;

	["Bazooka"] = function(PathData)
		local Character = PathData.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		local Character = PathData.Character or nil
		local ContactPoint = PathData.ContactPoint

		--[[ Play Sound ]]--
		-- SoundManager:AddSound("GomuSFX", {Parent = Character.HumanoidRootPart, TimePosition = .6, Volume = 3}, "Client")

		wait(.25)

		for i = 1,2 do
			local Arm;
			if i == 1 then 
				Arm = Character["Right Arm"]
			else
				Arm = Character["Left Arm"]
			end
			coroutine.wrap(function()
				local GomuArm = Arm:Clone()
				GomuArm.CanCollide = false
				GomuArm.Anchored = false
				GomuArm.Massless = true

				--[[ Weld GomuArm to CharacterArm ]]--
				local Motor6D = Instance.new("Motor6D")
				Motor6D.Part0 = Arm
				Motor6D.Part1 = GomuArm
				Motor6D.Parent = Arm
				GomuArm.Parent = Visuals

				--[[ Arm Tweening Out ]]--
				local LENGTH = 50
				local StartSize = GomuArm.Size
				local GoalSize = Vector3.new(GomuArm.Size.X, LENGTH, GomuArm.Size.Z)

				local StartCFrame = Motor6D.Part0.CFrame:inverse() * (Arm.CFrame * CFrame.new(0,0,0))
				local GoalCFrame = Motor6D.Part0.CFrame:inverse() * (Arm.CFrame * CFrame.new(0,-LENGTH/1.925,0))

				--[[ Tween the size Outwards of the Arm ]]--
				local tween = TweenService:Create(GomuArm, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = GoalCFrame, ["Size"] = GoalSize})
				tween:Play()
				tween:Destroy()

				--[[ Tween the CFrame of the Arm according to Arm Size ]]--
				local tween = TweenService:Create(Motor6D, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["C0"] = GoalCFrame})
				tween:Play()
				tween:Destroy()

				wait(0.2)
				--[[ Return Arm size Back to Normal ]]--
				local tween = TweenService:Create(GomuArm, TweenInfo.new(.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {["CFrame"] = Arm.CFrame, ["Size"] = StartSize})
				tween:Play()
				tween:Destroy()

				--[[ Tween the CFrame Arm Back ]]--
				local tween = TweenService:Create(Motor6D, TweenInfo.new(.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {["C0"] = StartCFrame})
				tween:Play()
				tween:Destroy()

				wait(0.2)

				--[[ WindMesh ]]--
				local WindMesh = EffectMeshes.WindMesh:Clone()
				WindMesh.Size =  Vector3.new(0.1,3,3)
				WindMesh.Transparency = 0.5
				WindMesh.CFrame = Arm.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(90))
				WindMesh.Parent = Visuals

				local tween = TweenService:Create(WindMesh, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = WindMesh.CFrame * CFrame.new(2,0,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0), ["Size"] = Vector3.new(0.1, 3, 3), ["Transparency"] = 1})
				tween:Play()
				tween:Destroy()
				Debris:AddItem(WindMesh, 0.5)

				wait(0.2)
				GomuArm:Destroy()
			end)()
		end
		wait(0.6)

		--[[ Now ReLEASE !!! ]]--
		for i = 1,2 do
			local Arm;
			if i == 1 then 
				Arm = Character["Right Arm"]
			else
				Arm = Character["Left Arm"]
			end
			coroutine.wrap(function()
				local GomuArm = Arm:Clone()
				GomuArm.CanCollide = false
				GomuArm.Anchored = false
				GomuArm.Massless = true

				--[[ Weld GomuArm to CharacterArm ]]--
				local Motor6D = Instance.new("Motor6D")
				Motor6D.Part0 = Arm
				Motor6D.Part1 = GomuArm
				Motor6D.Parent = Arm
				GomuArm.Parent = Visuals

				--[[ Arm Tweening Out ]]--
				local LENGTH = 50
				local StartSize = GomuArm.Size
				local GoalSize = Vector3.new(GomuArm.Size.X, LENGTH, GomuArm.Size.Z)

				local StartCFrame = Motor6D.Part0.CFrame:inverse() * (Arm.CFrame * CFrame.new(0,0,0))
				local GoalCFrame = Motor6D.Part0.CFrame:inverse() * (Arm.CFrame * CFrame.new(0,-LENGTH/1.925,0))

				--[[ Tween the size Outwards of the Arm ]]--
				local tween = TweenService:Create(GomuArm, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = GoalCFrame, ["Size"] = GoalSize})
				tween:Play()
				tween:Destroy()

				--[[ Tween the CFrame of the Arm according to Arm Size ]]--
				local tween = TweenService:Create(Motor6D, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["C0"] = GoalCFrame})
				tween:Play()
				tween:Destroy()

				--[[ Side Shockwaves ]]--
				for j = 1,2 do

					local Offset = 5;
					local Rot = 288;
					local GoalSize = Vector3.new(35, 0.05, 7.5);
					if j == 1 then
					else
						Offset = Offset * -1;
						Rot = 252
					end

					local SideWind = EffectMeshes.SideWind:Clone()
					SideWind.Size = Vector3.new(8, 0.05, 2)
					SideWind.Transparency = 0.75
					SideWind.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(Offset,-0.5,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),math.rad(180),math.rad(Rot))
					SideWind.Parent = Visuals

					--[[ Tween the Side Shockwaves ]]--
					local tween = TweenService:Create(SideWind, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = SideWind.CFrame * CFrame.new(-10,0,0), ["Size"] = GoalSize, ["Transparency"] = 1})
					tween:Play()
					tween:Destroy()

					Debris:AddItem(SideWind, 0.25)
				end

				--[[ Effects ]]--

				--[[ Shockwave 5 ]]--		
				local shockwave5 = EffectMeshes.shockwave5:Clone()
				shockwave5.Transparency = 0
				shockwave5.Material = "Neon"
				shockwave5.Color = Color3.fromRGB(255, 255, 255)
				shockwave5.Size = Vector3.new(5, 6, 5)
				shockwave5.CFrame = GomuArm.CFrame * CFrame.new(0,-5,0)
				shockwave5.Parent = Visuals
				local tween = TweenService:Create(shockwave5, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = shockwave5.CFrame * CFrame.new(0,-20,0) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0), ["Size"] = Vector3.new(7,50,7), ["Transparency"] = 1})
				tween:Play()
				tween:Destroy()
				Debris:AddItem(shockwave5, 0.2)

				--[[ HollowCylinder ]]--
				local HollowCylinder = EffectMeshes.HollowCylinder:Clone()
				HollowCylinder.Size = Vector3.new(5, 5, 5)
				HollowCylinder.CFrame = GomuArm.CFrame * CFrame.new(0,-5,0)
				HollowCylinder.Parent = Visuals
				local tween = TweenService:Create(HollowCylinder, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = HollowCylinder.CFrame * CFrame.new(0,-15,0) * CFrame.fromEulerAnglesXYZ(0,math.rad(270),0), ["Size"] = Vector3.new(8,50,8), ["Transparency"] = 1})
				tween:Play()
				tween:Destroy()
				Debris:AddItem(HollowCylinder, 0.2)

				--[[ WindMesh ]]--
				local WindMesh = EffectMeshes.WindMesh:Clone()
				WindMesh.Size =  Vector3.new(2, 15, 15)
				WindMesh.Transparency = 0.5
				WindMesh.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-15) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)
				WindMesh.Parent = Visuals
				local tween = TweenService:Create(WindMesh, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = WindMesh.CFrame * CFrame.new(-15,0,0) * CFrame.fromEulerAnglesXYZ(math.rad(270),0,0), ["Size"] = Vector3.new(0, 15, 15), ["Transparency"] = 1})
				tween:Play()
				tween:Destroy()
				Debris:AddItem(WindMesh, 0.25)

				--[[ Ring ]]--
				local Ring = EffectMeshes.RingInnit:Clone()
				Ring.Size = Vector3.new(5, 0.05, 5)
				Ring.CFrame = Arm.CFrame * CFrame.new(0,-10,0)
				Ring.Parent = Visuals
				local tween = TweenService:Create(Ring, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = Ring.CFrame * CFrame.new(0,10,0), ["Size"] = Vector3.new(5, 0, 5), ["Transparency"] = 1})
				tween:Play()
				tween:Destroy()
				Debris:AddItem(Ring, 0.25)

				wait(0.2)
				-- SoundManager:AddSound("Slap",{Parent = Root, TimePosition = 0.1, Volume = .5}, "Client")

				--[[ Return Arm size Back to Normal ]]--
				local tween = TweenService:Create(GomuArm, TweenInfo.new(.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {["CFrame"] = Arm.CFrame, ["Size"] = StartSize})
				tween:Play()
				tween:Destroy()

				--[[ Tween the CFrame Arm Back ]]--
				local tween = TweenService:Create(Motor6D, TweenInfo.new(.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {["C0"] = StartCFrame})
				tween:Play()
				tween:Destroy()

				wait(0.2)

				--[[ WindMesh ]]--
				local WindMesh = EffectMeshes.WindMesh:Clone()
				WindMesh.Size =  Vector3.new(0.1,3,3)
				WindMesh.Transparency = 0.5
				WindMesh.CFrame = Arm.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(90))
				WindMesh.Parent = Visuals

				local tween = TweenService:Create(WindMesh, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = WindMesh.CFrame * CFrame.new(2,0,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0), ["Size"] = Vector3.new(0.1, 3, 3), ["Transparency"] = 1})
				tween:Play()
				tween:Destroy()
				Debris:AddItem(WindMesh, 0.5)

				wait(0.2)
				GomuArm:Destroy()
			end)()
		end
		--[[ Block becomes Cylinder ]]--
		local Block = EffectMeshes.Block:Clone()
		Block.BrickColor = BrickColor.new("Institutional white")
		Block.Shape = "Cylinder"
		Block.Transparency = 0
		Block.Material = "Neon"
		Block.Size = Vector3.new(50,5,5)
		Block.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-15) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),math.rad(180))		
		Block.Parent = Visuals

		local tween = TweenService:Create(Block, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Size"] = Vector3.new(50, 0, 0)})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(Block, 0.2)

		--[[ shockwave5 ]]--
		local shockwave5 = EffectMeshes.shockwave5:Clone()
		shockwave5.CFrame = Character.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
		shockwave5.Size = Vector3.new(25, 50, 25)
		shockwave5.Transparency = 0
		shockwave5.Material = "Neon"
		shockwave5.BrickColor = BrickColor.new("Institutional white")
		shockwave5.Parent = Visuals

		local tween = TweenService:Create(shockwave5, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = shockwave5.CFrame * CFrame.new(0,10,0) * CFrame.fromEulerAnglesXYZ(0,5,0), ["Size"] = Vector3.new(0, 75, 0)})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(shockwave5, 0.2)

		--[[ Terrain Rocks on Ground ]]--
		local RootPos = Character.HumanoidRootPart.CFrame	
		for loops = 1,2 do
			coroutine.wrap(function()
				local OffsetX = 10
				--[[ Change Offset. Two Rocks on Both Sides. ]]--
				if loops == 2 then OffsetX = -10 end

				local GroundRocks = {}
				for i = 1,10 do
					--[[ Raycast ]]--
					local StartPosition = (RootPos * CFrame.new(OffsetX/(i),0,-i*5)).Position
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

							local RATE = 10
							local X,Y,Z = 0.25 + (i / RATE),0.25 + (i / RATE),0.25 + (i / RATE)
							Block.Size = Vector3.new(X,Y,Z)

							Block.Position = pos
							Block.Anchored = true
							Block.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
							Block.Transparency = 0
							Block.Color = partHit.Color
							Block.Material = partHit.Material
							Block.Parent = Visuals
							GroundRocks[i] = Block;
							Debris:AddItem(Block, 0.25)							
						end
					end
					game:GetService("RunService").Heartbeat:Wait()
				end	
			end)()
		end

		wait(.4)
		--[[ Move Towards Goal ]]--
		local BodyPosition = Instance.new("BodyPosition")
		BodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		BodyPosition.P = 200;
		BodyPosition.D = 20;
		BodyPosition.Parent = Character.HumanoidRootPart
		BodyPosition.Position = (Character.HumanoidRootPart.CFrame * CFrame.new(0,0,10)).Position
		Debris:AddItem(BodyPosition, 0.1)
	end;	
}

return LuffyVFX