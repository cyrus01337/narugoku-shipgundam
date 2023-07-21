local debrisFolder = workspace.Debris

local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local Player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Character = Player.Character

local Modules = RS.Modules
local bezierTween = require(Modules.BezierTweens)
local Waypoints = bezierTween.Waypoints
local partCacheMod = require(Modules.PartCache)

local trail = 0

local cacheFolder
if debrisFolder:FindFirstChild("Mochi") then
	cacheFolder = debrisFolder.Mochi
else
	cacheFolder = Instance.new("Folder")
	cacheFolder.Name = "Mochi"
	cacheFolder.Parent = debrisFolder
end

local partCache = partCacheMod.new(RS.FX.Mochi.MochiBall, 300, cacheFolder)

local function mochiImpactBall(OriginPosition, originalSize)
	local mochiBall = RS.FX.Mochi.MochiBall:Clone()
	mochiBall.Size = Vector3.new()

	local targetSize = originalSize * Random.new():NextNumber(1.5, 2.25)
	local targetCFrame = CFrame.new(OriginPosition) * CFrame.new(math.random(-8, 8), 0, math.random(-8, 8))
	local targetOrientation = Vector3.new(math.random(-179, 179), math.random(-179, 179), math.random(-179, 179))

	mochiBall.CFrame = targetCFrame
	mochiBall.Color = Color3.fromRGB(255, 204, 153)
	
	mochiBall.Parent = debrisFolder

	-- CREATING FLOOR --	
	local spawnTime = Random.new():NextNumber(0.4, 0.7)
	local tDur = Random.new():NextNumber(3, 5)

	local RayParam = RaycastParams.new()
	RayParam.FilterType = Enum.RaycastFilterType.Exclude
	RayParam.FilterDescendantsInstances = { debrisFolder }

	local RaycastResult = workspace:Raycast(targetCFrame.Position, Vector3.new(0, -targetSize.Y * 0.65, 0), RayParam)
	local hit, vec2Pos, surfaceNormal = RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal
	
	if hit then
		local mochiFloor = RS.FX.Mochi.MochiFloor:Clone()
		mochiFloor.CFrame = CFrame.new(vec2Pos, vec2Pos + surfaceNormal) * CFrame.Angles(-math.pi/2, 0, 0)
		mochiFloor.Size = Vector3.new()
		mochiFloor.Parent = debrisFolder

		TS:Create(mochiFloor, TweenInfo.new(spawnTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = Vector3.new(targetSize.X * 1.25, math.random(1, 3), targetSize.Z * 1.25)}):Play()
		TS:Create(mochiFloor, TweenInfo.new(tDur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Color3.fromRGB(255, 246, 208)}):Play()

		task.delay(spawnTime, function()
			TS:Create(mochiFloor, TweenInfo.new(tDur - 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(targetSize.X * 1.1, 1, targetSize.Z * 1.1)}):Play()
		end)

		task.delay(7, function()
			TS:Create(mochiFloor, TweenInfo.new(.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = Vector3.new()}):Play()
			game.Debris:AddItem(mochiFloor, .7)
		end)
	end
	--------------------
	TS:Create(mochiBall, TweenInfo.new(spawnTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize}):Play()
	TS:Create(mochiBall, TweenInfo.new(tDur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Orientation = Vector3.new(math.random(-30, 15), math.random(-179, 179), math.random(-50, 15)), Color = Color3.fromRGB(255, 246, 208)}):Play()

	task.delay(Random.new():NextNumber(4, 5), function()
		TS:Create(mochiBall, TweenInfo.new(Random.new():NextNumber(0.45, 0.7), Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = mochiBall.Position - Vector3.new(0,3,0), Size = Vector3.new(0,0,0)}):Play()
		game.Debris:AddItem(mochiBall, 0.8)
	end)
end

local function mochiExplosion(OriginPosition, OriginInstance)
	local amount = math.random(5, 8)

	local hitSFX = {
		RS.Sounds.Mochi.MochiFistHit1,
		RS.Sounds.Mochi.MochiFistHit2,
	}

	for sounds, sfx in pairs(hitSFX) do
		local clonedSFX = sfx:Clone()
		clonedSFX.Parent = OriginInstance
		clonedSFX:Play()
		game.Debris:AddItem(clonedSFX, 2)
	end

	for i = 1, amount do
		local mochiSize = Random.new():NextNumber(2, 4)
		local mochiPart = partCache:GetPart() --RS.FX.MochiDrip:Clone()
		mochiPart.Size = Vector3.new(mochiSize, mochiSize, mochiSize)
		mochiPart.CFrame = CFrame.new(OriginPosition)

		local rayCheck = CFrame.new(OriginPosition) * CFrame.new(Random.new():NextNumber(-30, 30), 15, Random.new():NextNumber(-30, 30))

		local RayParam = RaycastParams.new()
		RayParam.FilterType = Enum.RaycastFilterType.Exclude
		RayParam.FilterDescendantsInstances = { mochiPart, debrisFolder }

		local RaycastResult = workspace:Raycast(rayCheck.Position, Vector3.yAxis * 50, RayParam)

		local Rhit, Rvec2Pos, RsurfaceNormal = RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal

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

		local RaycastResult = workspace:Raycast(origin, direction, RayParam)

		local hit, vec2Pos, surfaceNormal = RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal

		if hit then
			local endCF = CFrame.new(vec2Pos, vec2Pos + surfaceNormal) * CFrame.Angles(-math.pi/2, 0, 0)		
			local p0 = mochiPart.Position
			local p2 = endCF.Position
			local p1 = CFrame.new((p0 + p2) / 2) * CFrame.new(0, Random.new():NextNumber(maxHeight * 0.25, maxHeight), 0).Position

			local distance = (p0 - p2).Magnitude
			local speed = 35

			local poolSize = Random.new():NextNumber(4, 8)

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
					--game.Debris:AddItem(mochiPart, .7)
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

return function(projectile, hasHit)	
	local Hit = script.hasHit
	Hit.Value = hasHit
	
	if Hit.Value == true then
		local oldSize = projectile.Size
		
		for i, v in pairs(projectile.HitFX:GetChildren()) do
			v:Emit(v:GetAttribute("EmitCount"))
		end
		
		mochiExplosion(projectile.Position, projectile)
		mochiImpactBall(projectile.Position, oldSize)
		mochiImpactBall(projectile.Position, oldSize)
		mochiImpactBall(projectile.Position, oldSize)
	else
		repeat
			local dripChance = Random.new():NextNumber(0, 100)

			if trail == 0 then
				trail = 1

				local cloneFX = partCache:GetPart()
				cloneFX.CastShadow = false

				cloneFX.CFrame = projectile.CFrame * CFrame.new(Random.new():NextNumber(-3.5, 3.5), Random.new():NextNumber(-3.5, 3.5), 0)
				cloneFX.Size = Vector3.new(14, 14, 14)
				
				cloneFX.Parent = debrisFolder
				
				TS:Create(cloneFX, TweenInfo.new(.1), {Size = cloneFX.Size * .9}):Play()
				task.delay(0.1, function()
					TS:Create(cloneFX, TweenInfo.new(Random.new():NextNumber(.8, 1), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(0,0,0), Color = Color3.fromRGB(255, 246, 208)}):Play()
					
					task.delay(1, function()
						partCache:ReturnPart(cloneFX)
					end)
				end)
			elseif trail == 1 then
				trail = 2
			elseif trail == 2 then
				trail = 0
			end
			
			projectile.Orientation = projectile.Orientation + Vector3.new(Random.new():NextNumber(0, 0.05), Random.new():NextNumber(0, 0.05), Random.new():NextNumber(0, 0.05))

			if dripChance < 5 then
				local ray = Ray.new(projectile.Position, Vector3.new(0, -1000, 0))
				local hit, vec2Pos, surfaceNormal = workspace:FindPartOnRayWithIgnoreList(ray, {Character, debrisFolder})

				if hit then
					local dripSize = Random.new():NextNumber(1, 2)

					local dripFX = partCache:GetPart()
					dripFX.Size = Vector3.new(dripSize, dripSize, dripSize)
					dripFX.Color = projectile.Color
					dripFX.CFrame = projectile.CFrame

					dripFX.Parent = debrisFolder

					local poolSize = Random.new():NextNumber(1, 5)

					local endCF = CFrame.new(vec2Pos, vec2Pos + surfaceNormal) * CFrame.Angles(-math.pi/2, 0, 0)-- * CFrame.new(0, dripFX.Size.Y/2, 0)

					local dist = (endCF.Position - dripFX.Position).Magnitude
					local speed = 75
					local tDuration = dist/speed

					TS:Create(dripFX, TweenInfo.new(tDuration, Enum.EasingStyle.Linear), {CFrame = endCF, Color = Color3.fromRGB(255, 246, 208)}):Play()
					task.delay(tDuration, function()
						TS:Create(dripFX, TweenInfo.new(.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = Vector3.new(poolSize * 2.5, 0.7, poolSize * 2.5)}):Play()
						task.delay(5, function()
							TS:Create(dripFX, TweenInfo.new(.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = Vector3.new(0,0,0)}):Play()
							
							task.delay(0.7, function()
								partCache:ReturnPart(dripFX)
							end)
						end)
					end)
				end
			end
			game:GetService("RunService").Heartbeat:Wait()
		until Hit.Value == true
	end
end
