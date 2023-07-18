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
CameraShake:Start()

local BezierModule = require(Modules.Utility.BezierModule)

local VFXHandler = require(ReplicatedStorage.Modules.Effects.VfxHandler)


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
local Models = ReplicatedStorage.Assets.Models
local EffectParticles = ReplicatedStorage.Assets.Effects.Particles
local EffectBeams = ReplicatedStorage.Assets.Effects.Beams
local Particles = ReplicatedStorage.Assets.Effects.Particles
local EffectTrails = ReplicatedStorage.Assets.Effects.Trails

local TaskScheduler = require(ReplicatedStorage.Modules.Utility.TaskScheduler)



local DoughEndColour = Color3.fromRGB(148, 142, 123)

local function MochiGround(Character, Amount, EndPosition, Force)
	for _ = 1,Amount do
		local size = math.random(10,30) / 10
		local ball = script.ball:Clone()
		ball.Anchored = false
		ball.Size = Vector3.new(size,size,size)
		ball.CFrame = CFrame.new(EndPosition) * CFrame.new(0,2,0) * CFrame.Angles(math.rad(90),0,0) * CFrame.Angles(math.rad(math.random(-45,45)),math.rad(math.random(-45,45)),0)
		ball.Velocity = ball.CFrame.LookVector * (Force or 40)
		ball.CanTouch = true
		local conn;
		conn = ball.Touched:Connect(function(hit)
			if not hit:IsDescendantOf(Character) and not hit:IsDescendantOf(Visuals) and not hit:IsDescendantOf(World.Live) and not hit:IsDescendantOf(workspace.CurrentCamera) then
				conn:Disconnect()
				conn = nil
				ball.Anchored = true
				ball.CFrame = CFrame.new(ball.Position)
				size = math.random(5,9)
				local tween = TweenService:Create(ball,TweenInfo.new(.5),{Size = Vector3.new(size,.25,size)})
				tween:Play()
				tween:Destroy()
				coroutine.wrap(function()
					wait(.75)
					local tween = TweenService:Create(ball,TweenInfo.new(2),{Transparency = 1, Color = DoughEndColour})
					tween:Play()
					tween:Destroy()
					Debris:AddItem(ball,2)
				end)()
			end
		end)
		ball.Parent = Visuals
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

local IchigoVFX = {

	["RemoveMoichiRoll"] = function(PathData)
		local Character = PathData.Character
		local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		local Donut = World.Visuals:FindFirstChild(Character.Name.." Moichi Roll")
		if not Donut then return end

		Donut.Stick:Destroy()
		VfxHandler.RemoveBodyMover(Character)
	end,

	["Foresight"] = function(PathData)
		local Character = PathData.Character or nil
		local ContactPoint = PathData.ContactPoint

		for _ = 1,2 do
			VfxHandler.AfterImage({Character = Character, Duration = .25, StartTransparency = .5,Color = Color3.fromRGB(0,0,0)})
			wait(.05)
		end

		-- SoundManager:AddSound("Dodge", {Parent = Character.HumanoidRootPart}, "Client")
	end;

	["MoguraFlow"] = function(PathData)
		local Character = PathData.Character or nil
		local ContactPoint = PathData.ContactPoint

		local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		local StartTime = os.clock()

		local Dust = ReplicatedStorage.Assets.Effects.Particles.BarrageDust:Clone();
		Dust.Parent = Visuals
		Debris:AddItem(Dust, 10)

		local Weld = Instance.new("Weld")
		Weld.Part0 = Root
		Weld.Part1 = Dust
		Weld.C0 = CFrame.new(0, -Humanoid.HipHeight - 1, 0)
		Weld.Parent = Root

		local Rot = Vector3.new(7, 4, 9) * 1.5;
		local HipCalculation = Humanoid.HipHeight - 1;

		--// mochi on gorund
		coroutine.wrap(function()
			while os.clock() - StartTime <= .75 do
				MochiGround(Character, 1, Root.Position)
				wait(0.1)
			end
		end)()

		while true do
			wait()
			local End = Root.CFrame * CFrame.new(0,2,0) * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)

			local BrickColorIndex = BrickColor.new("Really black")
			local Color3Index = Color3.fromRGB(0, 0, 0)
			if math.random(1, 2) == 1 then
				Color3Index = Color3.fromRGB(255, 255, 255)
				BrickColorIndex = BrickColor.new("White")
			end

			local RaycastResult = Ray.new(Root.Position, Vector3.new(0,-1000,500))
			local Target,Position = workspace:FindPartOnRayWithIgnoreList(RaycastResult, {Character, workspace.World.Visuals, workspace.World.Live}, false, false)
			if Target then
				Dust.Attachment.dust1.Enabled = true;
				Dust.Attachment.dust1.Color = ColorSequence.new(Target.Color);
			else
				Dust.Attachment.dust1.Enabled = false;
			end
			ToPart(End * CFrame.new(2, math.random(-10, 10) / 10 + 2, 0), End, BrickColorIndex, Vector3.new(Rot.X, 0, Rot.z), Rot / 4, math.random(15, 35) / 100, nil, Enum.EasingStyle.Back, Color3Index, Enum.Material.Neon);

			if os.clock() - StartTime >= .75 then break end
		end
		Dust.Attachment.dust1.Enabled = false
		Debris:AddItem(Dust,1)
	end;

	["MochiRoll"] = function(PathData)
		local Character = PathData.Character or nil
		local ContactPoint = PathData.ContactPoint

		VfxHandler.ImpactLines({Character = Character, Amount = 20})
		-- SoundManager:AddSound("Dodge", {Parent = Character.HumanoidRootPart, Volume = 3}, "Client")

		wait(.35)

		local Speed = 50

		for _, v in ipairs(Character:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("MeshPart") then
				if v.Parent ~= "Katana" and v.Parent ~= "Sheath" and v.Name ~= "HumanoidRootPart" and v.Name ~= "FakeHead" then
					v.Transparency = 1
				end
			end
		end		--

		local GoalSize = Vector3.new(5, 15, 15)

		local Donut = Models.Misc.Donut:Clone()
		Donut.Size = Vector3.new(1,1,1)
		Donut.Name = Character.Name.." Moichi Roll"
		Donut.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,5,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
		Donut.Parent = Visuals

		Debris:AddItem(Donut, 6)
		local Tween = TweenService:Create(Donut, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Size"] = GoalSize})
		Tween:Play()
		Tween:Destroy()

		local Weld = Instance.new("Motor6D")
		Weld.Name = "Stick"
		Weld.Part0 = Character.HumanoidRootPart
		Weld.Part1 = Donut
		Weld.C0 = CFrame.new(0,3,0)
		Weld.Parent = Donut
		Debris:AddItem(Weld, 3)

		Donut.Anchored = false

		local Mouse = Player:GetMouse()
		Mouse.TargetFilter = workspace

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(1e5, 0, 1e5)
		BodyVelocity.Parent = Character.HumanoidRootPart

		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		BodyGyro.P = 10000
		BodyGyro.D = 100
		BodyGyro.Parent = Character.HumanoidRootPart

		local Trail = EffectTrails.GroundTrail:Clone()
		Trail.Trail.Lifetime = 3
		Trail.Position = Character.HumanoidRootPart.Position
		Trail.Transparency = 1
		Trail.Parent = Visuals

		--// tween the attachments
		local tween = TweenService:Create(Trail.Start, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Position"] = Vector3.new(0,0,.5)})
		tween:Play()
		tween:Destroy()

		local tween = TweenService:Create(Trail.End, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Position"] = Vector3.new(0,0,-0.5)})
		tween:Play()
		tween:Destroy()

		--// mochi on gorund
		coroutine.wrap(function()
			-- local Sound = SoundManager:AddSound("CartoonRun", {Parent = Character.HumanoidRootPart, Volume = 2}, "Client")

			while BodyVelocity.Parent do
				if not BodyVelocity.Parent then break end
				MochiGround(Character, 2, Character.HumanoidRootPart.Position)
				if GlobalFunctions.CheckDistance(Player, math.random(35,45)) then
					GlobalFunctions.FreshShake(20,20,.1,.1,0)
				end
				wait(.35)
			end

			-- Sound:Destroy()
		end)()

		local i = 0
		local Rate = 20
		while Weld.Parent do
			if not Weld.Parent then break end
			i += Rate
			Weld.C0 = CFrame.new(0,3,0) * CFrame.fromEulerAnglesXYZ(math.rad(-i),0,0)

			BodyVelocity.Velocity = Mouse.Hit.LookVector * Speed
			BodyGyro.CFrame = CFrame.new(Character.HumanoidRootPart.Position, Mouse.Hit.Position)

			--[[ Raycast ]]--
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
					Trail.Position = pos
					if not Trail.Trail.Enabled then
						Trail.Trail.Enabled = true
					end
					--for i = 1,2 do
					local Block = EffectMeshes.Block:Clone()

					local X,Y,Z = 2,2,2
					Block.Size = Vector3.new(X,Y,Z)

					Block.Position = pos
					Block.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
					Block.Transparency = 0
					Block.Color = partHit.Color
					Block.Material = partHit.Material
					Block.Parent = Visuals

					local BodyVelocity = Instance.new("BodyVelocity")
					BodyVelocity.MaxForce = Vector3.new(1000000,1000000,1000000)
					BodyVelocity.Velocity = Vector3.new(math.random(-40,40),math.random(30,40),math.random(-40,40)) * (.65)
					BodyVelocity.P = 100000
					BodyVelocity.Velocity = Vector3.new(math.random(-40,40),math.random(30,40),math.random(-40,40)) * (.65)
					BodyVelocity.Parent = Block

					Debris:AddItem(BodyVelocity, .05)
					Debris:AddItem(Block, 0.5)
					--end
				end
			else
				Trail.Trail.Enabled = false
			end

			wait()
		end
		Debris:AddItem(Trail, 3)
		BodyGyro:Destroy()
		BodyVelocity:Destroy()

		--// Set visible
		for i, v in pairs(Character:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("MeshPart") then
				if v.Parent ~= "Katana" and v.Parent ~= "Sheath" and v.Name ~= "HumanoidRootPart" and v.Name ~= "Handle" and v.Name ~= "FakeHead" then
					v.Transparency = 0
				end
			end
		end
	end;

	["FlowingMochi"] = function(PathData)
		local Character = PathData.Character or nil
		local ContactPoint = PathData.ContactPoint

		--// play dragon roar
		-- SoundManager:AddSound("OnDemonStep",{Parent = Character.HumanoidRootPart, Volume = 2}, "Client")

		local function DragonImpact(Dragon)

			--// play dragon roar
			-- SoundManager:AddSound("Boing",{Parent = Character.HumanoidRootPart, TimePosition = 0.5; Volume = 5}, "Client")

			--// PointLight
			local PointLight = Instance.new("PointLight")
			PointLight.Color = Color3.fromRGB(255, 255, 255)
			PointLight.Range = 300
			PointLight.Brightness = 5
			PointLight.Parent = Dragon

			local LightTween = TweenService:Create(PointLight, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Range"] = 0, ["Brightness"] = 0})
			LightTween:Play()
			LightTween:Destroy()

			--[[ Ball Effect ]]--
			local Ball = EffectMeshes.ball:Clone()
			Ball.Color = Color3.fromRGB(255, 255, 255)
			Ball.Material = Enum.Material.ForceField
			Ball.Transparency = 0
			Ball.Size = Vector3.new(20,20,20)
			Ball.Position = Dragon.Position
			Ball.Parent = Visuals

			local tween = TweenService:Create(Ball, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Size"] = Ball.Size * 4})
			tween:Play()
			tween:Destroy()
			Debris:AddItem(Ball, 0.25)

			local shock = EffectMeshes.upwardShock:Clone()
			shock.Position = Dragon.Position
			shock.Color = Color3.fromRGB(241, 231, 199)
			shock.Size = Vector3.new(0,0,0)
			local tween = TweenService:Create(shock,TweenInfo.new(.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size = Vector3.new(30,50,30), CFrame = shock.CFrame*CFrame.new(0,20,0)*CFrame.Angles(0,math.pi/2,0)})
			tween:Play()
			tween:Destroy()
			coroutine.wrap(function()
				wait(.1)
				local tween = TweenService:Create(shock,TweenInfo.new(.1,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size = Vector3.new(0,80,0), Color = DoughEndColour})
				tween:Play()
				tween:Destroy()
				Debris:AddItem(shock,.2)
			end)()
			shock.Parent = Visuals


			--[[ New Shockwave ]]--
			local Shockwave = EffectParticles.ParticleAttatchments.Shockwave:Clone()
			Shockwave.Shockwave.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 80)}
			Shockwave.Shockwave.Parent = Ball
			Ball.Shockwave:Emit(2)

			--[[ Flying Debris Rock ]]--
			local Offset = 20
			local RootPos = Dragon.Position + Vector3.new(0,5,0)
			for i = 1,2 do
				for j = 1,5 do

					MochiGround(Character, 1, Dragon.Position, 90)

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

			--// Lightning
			local StartPosition = (Dragon.Position )
			local EndPosition = CFrame.new(StartPosition).UpVector * -10

			local RayData = RaycastParams.new()
			RayData.FilterDescendantsInstances = {Character, World.Live, World.Visuals} or World.Visuals
			RayData.FilterType = Enum.RaycastFilterType.Exclude
			RayData.IgnoreWater = true

			local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
			if ray then

				local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
				if partHit then

					local Smoke = Particles.Smoke:Clone()
					Smoke.Smoke.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 0)}
					Smoke.Smoke.Color = ColorSequence.new(partHit.Color)
					Smoke.Smoke.Acceleration = Vector3.new(0,5,0)
					Smoke.Smoke.Drag = 5
					Smoke.Smoke.Lifetime = NumberRange.new(3)
					Smoke.Smoke.Rate = 500
					Smoke.Transparency = 1
					Smoke.Smoke.Speed = NumberRange.new(75)
					Smoke.Position = Dragon.Position
					Smoke.Size = Vector3.new(50,0,50)
					Smoke.Parent = Visuals
					coroutine.wrap(function()
						Smoke.Smoke.Enabled = true
						for _ = 1,2 do
							Smoke.Smoke:Emit(25)
							wait(0.05)
						end
						Smoke.Smoke.Enabled = false
					end)()
					Debris:AddItem(Smoke, 4)
				end


				VfxHandler.Rockszsz({
					Cframe = CFrame.new(Dragon.Position), -- Position
					Amount = 20, -- How manay rocks
					Iteration = 20, -- Expand
					Max = 3, -- Length upwards
					FirstDuration = .25, -- Rock tween outward start duration
					RocksLength = 2 -- How long the rocks stay for
				})
			end
		end

		--[[ Setpath Properties ]]--
		local StartPosition = Character.HumanoidRootPart.Position
		local EndPosition = ContactPoint

		local Magnitude = (StartPosition - EndPosition).Magnitude
		local Midpoint = (StartPosition - EndPosition)/2

		local PointA = CFrame.new(CFrame.new(StartPosition) * (Midpoint/-1.5)).Position -- first 25% of the path
		--local PointB = CFrame.new(CFrame.new(EndPosition) * (Midpoint/1.5)).Position -- last 25% of the path

		local Offset = Magnitude/2
		PointA = PointA + Vector3.new(0,Offset,0)

		local TrailPosition = nil;
		local EndTrail = false;

		--// mochi on gorund
		coroutine.wrap(function()
			while not EndTrail do
				if TrailPosition then
					MochiGround(Character, 1, TrailPosition)
				end
				wait()
			end
		end)()

		--[[ Lerp to Path ]]--
		local Trail;
		local Speed = 2;
		for Index = 1, Magnitude, Speed do
			local Percent = Index / Magnitude
			local Coordinate = BezierModule:quadBezier(Percent, StartPosition, PointA, EndPosition)

			local nextPoint = ((Index + 1) < Magnitude and BezierModule:quadBezier((Index + 1) / Magnitude,StartPosition,PointA,EndPosition) or BezierModule:quadBezier(1,StartPosition,PointA,EndPosition))

			-- trail test --
			local ChangeRate = 2
			local DirectionOffset = CFrame.new(math.random(-ChangeRate,ChangeRate),math.random(-ChangeRate,ChangeRate),math.random(-ChangeRate,ChangeRate))
			local trail = script.cylinder:Clone()
			trail.Material = Enum.Material.SmoothPlastic
			trail.Size = Vector3.new(15,(Coordinate-nextPoint).Magnitude * Speed / 2,15)
			trail.CFrame = CFrame.lookAt(Coordinate,nextPoint) * CFrame.Angles(math.rad(90),0,0) * DirectionOffset

			local CFrameIndex = trail.CFrame * CFrame.Angles(math.rad(180), 0, 0)
			VFXHandler.Shockwave2(CFrameIndex, CFrameIndex, BrickColor.new("Institutional white"), Vector3.new(20, .5, 20), Vector3.new(0, .5, 0), .2, 0, Enum.EasingStyle.Quad, Color3.fromRGB(255, 255, 255), Enum.Material.Neon, "Rings");

			local tween = TweenService:Create(trail,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size = Vector3.new(0,trail.Size.Y+8,0), Color = Color3.fromRGB(190, 182, 158)})
			tween:Play()
			tween:Destroy()
			Debris:AddItem(trail,1)
			trail.Parent = Visuals
			RunService.Heartbeat:Wait()

			TrailPosition = trail.Position
			Trail = trail
		end
		EndTrail = true
		DragonImpact(Trail)
	end;
}

return IchigoVFX
