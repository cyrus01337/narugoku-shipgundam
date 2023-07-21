--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PhysicsService = game:GetService("PhysicsService")

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--|| Imports ||--
local SoundManager = require(ReplicatedStorage.Modules.Shared.SoundManager)

local Debounce = false

local function IcedOut(Root)
	for _,v in ipairs(Root.Parent:GetChildren()) do
		if v:IsA("BasePart") then
			local ParticleHolder = Instance.new("Part")
			ParticleHolder.Anchored = true
			ParticleHolder.Transparency = 1
			ParticleHolder.CanCollide = false
			ParticleHolder.Size = v.Size
			ParticleHolder.CFrame = v.CFrame
			ParticleHolder.Parent = workspace.World.Visuals
			Debris:AddItem(ParticleHolder, 2)

			local IceParticle = script.IceSmoke:Clone()
			IceParticle.Parent = ParticleHolder
			IceParticle:Emit(3)

			local IceParticle2 = script.Sparks:Clone()
			IceParticle2.Parent = ParticleHolder
			IceParticle2:Emit(3)
		end
	end
end

local function GetAnimation(Humanoid, AnimationName)
	for _, PlayingTrack in ipairs(Humanoid:GetPlayingAnimationTracks()) do
		if PlayingTrack.Name == AnimationName then
			return true
		end
	end
	
	return false
end
local function PlaySkatingAnimation(Humanoid)
	for _, PlayingTrack in ipairs(Humanoid:GetPlayingAnimationTracks()) do
		if PlayingTrack.Name == "SwordRunning" or (Humanoid.WalkSpeed == 28 or Humanoid.WalkSpeed == 30) then
			
			--AnimationManager.PlayAnimation("Skating", {Looped = true, Weight = 10})
		end
	end
end

local function StopSkatingAnimation(Humanoid)
	for _, PlayingTrack in ipairs(Humanoid:GetPlayingAnimationTracks()) do
		if PlayingTrack.Name == "SwordRunning" or (Humanoid.WalkSpeed == 28 or Humanoid.WalkSpeed == 30) then
		--	AnimationManager.StopAnimation("Skating")
		end
	end
end
local function CreateFloorFunc(Random1, Random2, CFrame1, CFrame2, DesignatedCFrame, Duration, Size, Character, Transparency, Type)
	local IceFloor = script.FloorEffect:Clone()
	local RandomIndex = math.random(Random1, Random2)

	if Size then
		IceFloor.Size = Size
	else
		IceFloor.Size = Vector3.new(RandomIndex, math.random(350, 425) / 1000, RandomIndex)
	end
	IceFloor.Name = "iceFloor"

	if DesignatedCFrame then
		IceFloor.CFrame = DesignatedCFrame
	else
		IceFloor.CFrame = CFrame.new(CFrame1, CFrame1 + CFrame2) * CFrame.Angles(math.rad(-90), 0, 0)
	end
	
	IceFloor.Transparency = Transparency or .25
	if Type == "Slide" then
		IceFloor.Transparency = 1
		IceFloor.Material = Enum.Material.Glass

		local Tween = TweenService:Create(IceFloor, TweenInfo.new(.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Transparency"] = 0})
		Tween:Play()
		Tween:Destroy()

		delay(.35,function()
			IceFloor.Material = Enum.Material.Ice
		end)
	end

	IceFloor.CFrame = IceFloor.CFrame * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)
	IceFloor.Parent = workspace.World.Enviornment	
	-- SoundManager:AddSound("MoreIce",{Parent = IceFloor, Pitch = math.random(100, 120) / 100},"Client")	
	IceFloor.IceSmoke:Emit(Type == "Slide" and 75 or 15)
	
--[[IceFloor.Touched:Connect(function(Hit)
		if Hit:IsA("BasePart") and Hit:IsDescendantOf(Character) then
			local Humanoid = Hit.Parent:FindFirstChild("Humanoid") or Hit.Parent.Parent:FindFirstChild("Humanoid")
			
			if not Humanoid then return end
			if GetAnimation(Humanoid) then return end
			
			PlaySkatingAnimation(Humanoid)
		end
	end)
	
	IceFloor.TouchEnded:Connect(function(Hit)
		if Hit:IsA("BasePart") and Hit:IsDescendantOf(Character) then
			local Humanoid = Hit.Parent:FindFirstChild("Humanoid") or Hit.Parent.Parent:FindFirstChild("Humanoid")

			if not Humanoid then return end
			if GetAnimation(Humanoid) then 
				StopSkatingAnimation(Humanoid)
			end			
		end
	end) ]]
	
	task.spawn(function()
		wait(.25)
		IceFloor.Sparks.Enabled = false
	end)

	if Duration == nil then	Duration = 2 end

	coroutine.resume(coroutine.create(function()
		wait(Duration)
		
		if Type == "Slide" then
			IceFloor.Material = Enum.Material.Glass

			local Tween = TweenService:Create(IceFloor, TweenInfo.new(.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Transparency"] = 1})
			Tween:Play()
			Tween:Destroy()
			
			IcedOut(IceFloor)
		end
		
		local Tween = TweenService:Create(IceFloor, TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {["Size"] = Vector3.new(0, 0, 0)})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(IceFloor, .5)
	end))
	return IceFloor
end

return function(Area, RaycastBelow, Random1, Random2, Debounce, Duration, Size, Character,Transparency,Type)
	local PositionCalc = workspace.World.Enviornment.TestPart.Position.Y + 0.125
	local CFrameIndex = CFrame.new(Area.p)

	local RayParams = RaycastParams.new()
	RayParams.FilterType = Enum.RaycastFilterType.Include
	RayParams.FilterDescendantsInstances = { workspace.World.Map, workspace.World.Enviornment }

	local RaycastResult = workspace:Raycast(CFrameIndex.Position, CFrameIndex.UpVector * -RaycastBelow, RayParams)

	local Target, Position, Surface = RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal

	if Target and (Target.Name ~= "iceFloor" or Debounce) and (PositionCalc < Position.Y or Position.Y < workspace.World.Enviornment.TestPart2.Position.Y) then
		local Ice = nil
		Ice = CreateFloorFunc(Random1, Random2, Position, Surface, nil, Duration, Size, Character, Transparency,Type)
		if Target.CanCollide then Ice.CanCollide = false
			return
		else
			Ice.CanCollide = true
			return
		end
	end
	if Position.Y <= PositionCalc and workspace.World.Enviornment.TestPart2.Position.Y < Position.Y then
		local CFrameCalculation = CFrame.new(Position.X, PositionCalc + 5, Position.Z)
		RaycastBelow = 6

		local RayParams = RaycastParams.new()
		RayParams.FilterType = Enum.RaycastFilterType.Include
		RayParams.FilterDescendantsInstances = { workspace.World.Map, workspace.World.Enviornment }

		local RaycastResult = workspace:Raycast(CFrameCalculation.Position, CFrameCalculation.UpVector * -RaycastBelow, RayParams)

		local Target, Position, Surface = RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal

		if Target == nil then
			CreateFloorFunc(Random1, Random2, nil, nil, CFrame.new(Position.X, PositionCalc, Surface.Z), Duration, Size, Character, Transparency, Type)
		end
	end
end