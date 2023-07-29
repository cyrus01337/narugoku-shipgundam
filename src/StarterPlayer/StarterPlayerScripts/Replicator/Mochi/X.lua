local debrisFolder = workspace.Debris

local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character

local Modules = RS.Modules
local partCacheMod = require(Modules.PartCache)
local bezierTween = require(Modules.BezierTweens)
local Waypoints = bezierTween.Waypoints
local rocksMod = require(Modules.RocksModule)

local cacheFolder
if debrisFolder:FindFirstChild("Mochi") then
	cacheFolder = debrisFolder.Mochi
else
	cacheFolder = Instance.new("Folder")
	cacheFolder.Name = "Mochi"
	cacheFolder.Parent = debrisFolder
end

local partCache = partCacheMod.new(RS.FX.Mochi.MochiBall, 100, cacheFolder)

local function mochiExplosion(OriginPosition, OriginInstance)
	local amount = math.random(1, 3)

	local hitSFX = {
		RS.Sounds.Mochi.MochiBarrageHit1,
	}

	for sounds, sfx in pairs(hitSFX) do
		local clonedSFX = sfx:Clone()
		clonedSFX.Parent = OriginInstance
		clonedSFX:Play()
		game.Debris:AddItem(clonedSFX, 2)
	end

	for i = 1, amount do
		local mochiSize = Random.new():NextNumber(0.25, 0.75)
		local mochiPart = partCache:GetPart() --RS.FX.MochiDrip:Clone()
		mochiPart.Size = Vector3.new(mochiSize, mochiSize, mochiSize)
		mochiPart.CFrame = CFrame.new(OriginPosition)

		local rayCheck = CFrame.new(OriginPosition) * CFrame.new(Random.new():NextNumber(-20, 20), 15, Random.new():NextNumber(-20, 20))

		local roofCheckRay = Ray.new(rayCheck.Position, Vector3.new(0, 50, 0))
		local Rhit, Rvec2Pos, RsurfaceNormal = workspace:FindPartOnRayWithIgnoreList(roofCheckRay, {mochiPart, debrisFolder})


		local maxHeight

		local origin
		local direction = Vector3.yAxis * -1000

		if Rhit then
			maxHeight = (OriginPosition.Y - Rhit.Position.Y)
			origin = Vector3.new(rayCheck.Position.X, maxHeight - 1, rayCheck.Position.Z)
		else
			maxHeight = 50
			origin = rayCheck.Position
		end

		local RayParam = RaycastParams.new()
		RayParam.FilterType = Enum.RaycastFilterType.Exclude
		RayParam.FilterDescendantsInstances = { mochiPart, debrisFolder }

		local RaycastResult = workspace:Raycast(origin, direction, RayParam) or {}

		local hit, vec2Pos, surfaceNormal = RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal

		if hit then
			local endCF = CFrame.new(vec2Pos, vec2Pos + surfaceNormal) * CFrame.Angles(-math.pi/2, 0, 0)		
			local p0 = mochiPart.Position
			local p2 = endCF.Position
			local p1 = CFrame.new((p0 + p2) / 2) * CFrame.new(0, Random.new():NextNumber(maxHeight * 0.25, maxHeight), 0).Position

			local distance = (p0 - p2).Magnitude
			local speed = 35

			local poolSize = Random.new():NextNumber(0.75, 1.5)

			mochiPart.Parent = debrisFolder

			local Tween = bezierTween.Create(mochiPart, {
				Waypoints = Waypoints.new(p0, p1, p2),
				EasingStyle = Enum.EasingStyle.Linear,
				EasingDirection = Enum.EasingDirection.In,
				Time = distance/speed
			})

			Tween:Play()
			TS:Create(mochiPart, TweenInfo.new(distance/speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Color = Color3.fromRGB(255, 246, 208)}):Play()

			Tween.Completed:Connect(function()
				mochiPart.CFrame = CFrame.new(vec2Pos, vec2Pos + surfaceNormal) * CFrame.Angles(-math.pi/2, 0, 0)	
				TS:Create(mochiPart, TweenInfo.new(.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = Vector3.new(poolSize * 2, 0.5, poolSize * 2)}):Play()
				task.delay(5, function()
					TS:Create(mochiPart, TweenInfo.new(.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = Vector3.new(0,0,0)}):Play()
					task.delay(.7, function()
						partCache:ReturnPart(mochiPart)
					end)
				end)
			end)
		else
			partCache:ReturnPart(mochiPart)
		end
	end
end

local function groundCrack(rayPos)
	local ray = Ray.new(rayPos, Vector3.new(0, -30, 0))
	local hit, vec2Pos, surfaceNormal = workspace:FindPartOnRayWithIgnoreList(ray, {Character, debrisFolder})

	if hit then
		local crack = RS.FX.Mochi.MochiCrack:Clone()
		crack.CFrame = CFrame.new(vec2Pos, vec2Pos + surfaceNormal) * CFrame.Angles(-math.pi/2, math.random(360), 0) * CFrame.new(0, crack.Size.Y/2, 0)
		crack.Size = Vector3.new()
		
		crack.Parent = debrisFolder
		
		local crackFinalSize = Random.new(math.random(10, 20)):NextNumber(6, 8)
		
		TS:Create(crack, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = Vector3.new(crackFinalSize, 0.001, crackFinalSize)}):Play()
		
		task.delay(2, function()
			TS:Create(crack.Decal, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Transparency = 1}):Play()
			game.Debris:AddItem(crack, .4)
		end)
	end
end

return function(TargetPosition)	
	local mochiArm = RS.FX.Mochi.MochiArm:Clone()
	local mochiRoll = RS.FX.Mochi.MochiRoll:Clone()
	
	local random = Random.new(math.random(10, 20))
	
	local originPosition = (CFrame.new(TargetPosition) * CFrame.new(random:NextNumber(-4, 4), random:NextNumber(10, 15), random:NextNumber(-4, 4))).Position
	
	mochiRoll.CFrame = CFrame.lookAt(originPosition, TargetPosition)
	mochiRoll.Size = Vector3.new()
	
	local mochiRollDetail = RS.FX.Mochi.MochiRollArm:Clone()
	mochiRollDetail.CFrame = mochiRoll.CFrame * CFrame.new(0, 0, 0.2)
	mochiRollDetail.Size = Vector3.new()
	mochiRollDetail.Parent = debrisFolder
	
	mochiRoll.Parent = debrisFolder
	
	local mochiRollClone = mochiRoll:Clone()
	mochiRollClone.Parent = debrisFolder	
	
	TS:Create(mochiRoll, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = Vector3.new(23, 23, 13) * 0.33}):Play()
	TS:Create(mochiRollDetail, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = Vector3.new(13, 13, 0) * 0.33}):Play()
	TS:Create(mochiRollClone, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(15, 8, 6) * 2, Transparency = 1}):Play()
	
	
	--- Mochi Roll End Tween ---
	task.delay(0.7, function()
		TS:Create(mochiRoll, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = Vector3.new(0, 0, 13) * 0.33}):Play()
		TS:Create(mochiRollDetail, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = Vector3.new(0, 0, 25) * 0.33}):Play()
		game.Debris:AddItem(mochiRoll, .2)
		game.Debris:AddItem(mochiRollDetail, .25)
		game.Debris:AddItem(mochiRollClone, .1)
	end)
	---                      ---
	
	task.delay(0.1, function()
		mochiArm.CFrame = CFrame.lookAt(originPosition, TargetPosition) * CFrame.new(0, 0, -0.5) * CFrame.Angles(math.rad(180),0,0)
		mochiArm.Outline.CFrame = CFrame.lookAt(originPosition, TargetPosition) * CFrame.new(0, 0, -0.5) * CFrame.Angles(math.rad(180),0,0)
		mochiArm.Size = Vector3.new()
		mochiArm.Parent = debrisFolder
		
		TS:Create(mochiArm, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = Vector3.new(2, 2, (originPosition - TargetPosition).Magnitude * 2), CFrame = mochiArm.CFrame * CFrame.new(0, 0, ((originPosition - TargetPosition).Magnitude * 2)/2)}):Play()
		TS:Create(mochiArm.Outline, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = Vector3.new(2, 2, (originPosition - TargetPosition).Magnitude * 2) * 1.05, CFrame = mochiArm.CFrame * CFrame.new(0, 0, ((originPosition - TargetPosition).Magnitude * 2)/2)}):Play()
		TS:Create(mochiRollDetail, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = Vector3.new(11, 11, 25) * 0.33, CFrame = CFrame.lookAt(originPosition, TargetPosition) * CFrame.new(0,0,-2.5)}):Play()
		
		task.delay(0.25, function()
			mochiExplosion(TargetPosition, mochiArm)
			groundCrack(TargetPosition)
			rocksMod.Ground(TargetPosition, 6, Vector3.new(1, 2, 0.5), nil, 8, false, 2)
			
			for i, v in pairs(mochiArm.HitFX:GetChildren()) do
				v:Emit(v:GetAttribute("EmitCount"))
			end
			
			--- Mochi Arm End Tween ---
			task.delay(0.2, function()
				TS:Create(mochiArm, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = Vector3.new(0, 0, mochiArm.Size.Z)}):Play()
				TS:Create(mochiArm.Outline, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = Vector3.new(0, 0, mochiArm.Outline.Size.Z)}):Play()
				task.delay(0.15, function()
					mochiArm.Transparency = 1
					mochiArm.Outline:Destroy()
				end)
				game.Debris:AddItem(mochiArm, 4)
			end)
			---                      ---
		end)
	end)
end
