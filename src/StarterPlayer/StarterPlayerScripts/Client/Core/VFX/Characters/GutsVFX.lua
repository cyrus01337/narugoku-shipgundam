--|| Services ||--
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Effects = Modules.Effects
local Utility = Modules.Utility
local Shared = Modules.Shared

local HitPart2 = Models.Misc.HitPart2

local World = workspace.World
local Visuals = World.Visuals

--|| Import ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)
local VfxHandler = require(Effects.VfxHandler)
local SoundManager = require(Shared.SoundManager)

local LightningBolt = require(Modules.Effects.LightningBolt)

local CameraShaker = require(Effects.CameraShaker)

local CurrentCamera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
end)	

local BezierModule = require(Modules.Utility.BezierModule)

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

local EffectMeshes = ReplicatedStorage.Assets.Effects.Meshes
local EffectParticles = ReplicatedStorage.Assets.Effects.Particles
local EffectBeams = ReplicatedStorage.Assets.Effects.Beams
local Particles = ReplicatedStorage.Assets.Effects.Particles
local EffectTrails = ReplicatedStorage.Assets.Effects.Trails

local GutsVFX = {

	["DemonicPound"] = function(PathData)
		local Character = PathData.Character or nil
		local ContactPoint = PathData.ContactPoint				
		local RootStartPosition = Character.HumanoidRootPart.CFrame
		--[[ Play Sound ]]--
		-- SoundManager:AddSound("SODTeleport", {Parent = Character.HumanoidRootPart, Volume = 3}, "Client")
		
		wait(0.75)		
		-- LINES TEST
		local ReachedTarget = false
		local Block = EffectMeshes.Block:Clone()
		Block.Size = Vector3.new(1,1,1)
		Block.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,5,0)
		Block.Anchored = true
		Block.Transparency = 0
		Block.Parent = Visuals
		coroutine.wrap(function()
			
			local Trail = EffectTrails.GroundTrail:Clone()
			Trail.Trail.Lifetime = 3
			Trail.Position = Character.HumanoidRootPart.Position
			Trail.Transparency = 1
			Trail.Parent = Visuals

			--// tween the attachments
			local tween = TweenService:Create(Trail.Start, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Position"] = Vector3.new(0,0,0.5)})
			tween:Play()
			tween:Destroy()

			local tween = TweenService:Create(Trail.End, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Position"] = Vector3.new(0,0,-0.5)})
			tween:Play()
			tween:Destroy()

			local i = 0
			while not ReachedTarget do
				i += 1.5
				Block.CFrame = RootStartPosition * CFrame.new(0,0,-i)
				--[[ Raycast ]]--
				local StartPosition = Block.Position
				local EndPosition = CFrame.new(StartPosition).UpVector * -10

				local RayData = RaycastParams.new()
				RayData.FilterDescendantsInstances = {Character, World.Live, World.Visuals} or World.Visuals
				RayData.FilterType = Enum.RaycastFilterType.Exclude
				RayData.IgnoreWater = true

				local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
				if ray then
					local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
					if partHit then
						Trail.Position = pos 
					end
				end
				game:GetService("RunService").Heartbeat:Wait()
			end
			Block:Destroy()
			game.Debris:AddItem(Trail, 3)
		end)()

		--[[ Terrain Rocks on Ground ]]--
		for loops = 1,2 do
			coroutine.wrap(function()
				local OffsetX = 2
				--[[ Change Offset. Two Rocks on Both Sides. ]]--
				if loops == 2 then OffsetX = OffsetX * -1 end

				local GroundRocks = {}
				local i = 0
				while not ReachedTarget do
					i += 1 
					--[[ Raycast ]]--
					local StartPosition = (Block.CFrame * CFrame.new(OffsetX,0,-i/4)).Position
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

							local X,Y,Z = 1.5,1.5,1.5
							Block.Size = Vector3.new(X,Y,Z)

							Block.Position = pos
							Block.Anchored = true
							Block.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
							Block.Transparency = 0
							Block.Color = partHit.Color
							Block.Material = partHit.Material
							Block.Parent = Visuals
							GroundRocks[i] = Block;
							Debris:AddItem(Block, 3)
						end
					end
					game:GetService("RunService").Heartbeat:Wait()
				end	
			end)()
		end
		--- END TEST
		
		coroutine.wrap(function() wait(0.3) ReachedTarget = true end)()
		coroutine.wrap(function()
			for i = 1, 2 do
				--// Circle Slash
				local circleslash = EffectMeshes.circleslash:Clone()
				local one = circleslash.one
				local two = circleslash.two
				for _, v in ipairs(two:GetChildren()) do
					v.Color3 = Color3.fromRGB(255, 0, 0)
				end
				local StartSizeOne = Vector3.new(15,15,2)
				local StartSizeTwo = Vector3.new(15,15,2)
				local Multiple = 2 * i

				one.Size = StartSizeOne
				two.Size = StartSizeTwo
				circleslash.Parent = Visuals

				one.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)
				two.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)

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
				wait(0.6)
			end
		end)()

		wait(0.75)
		
		for i = 1,2 do
			local Offset = 8
			local Rot = 45
			if i == 2 then Rot = Rot * -1; Offset = Offset * -1 end
			--[[ Raycast ]]--
			local StartPosition = (Character.HumanoidRootPart.CFrame  * CFrame.new(Offset,0,0)).Position
			local EndPosition = CFrame.new(StartPosition).UpVector * -10

			local RayData = RaycastParams.new()
			RayData.FilterDescendantsInstances = {Character, World.Live, World.Visuals} or World.Visuals
			RayData.FilterType = Enum.RaycastFilterType.Exclude
			RayData.IgnoreWater = true

			local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
			if ray then
				local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
				if partHit then
					local Cleave = workspace.Cleave:Clone()
					Cleave.Material = partHit.Material
					Cleave.Color = partHit.Color
					Cleave.CFrame = CFrame.new(pos) * CFrame.new(0,8,2) * CFrame.fromEulerAnglesXYZ(0,math.rad(Rot),0)
					Cleave.Parent = Visuals
				end
			end
		end
		
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
	end;
}

return GutsVFX