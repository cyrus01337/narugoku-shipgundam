local boltModule = require(game.ReplicatedStorage.Modules.LightningBolt)
local sparks = require(game.ReplicatedStorage.Modules.LightningBolt.LightningSparks)
local debris = require(game.ReplicatedStorage.Modules.Debris)

return function(a0, a1)
	local player = game.Players.LocalPlayer
	local char = player.Character
	
	a0.Position = a1.WorldPosition + Vector3.new(0, math.random(75, 80), 0)
	--a0.WorldCFrame = a0.WorldCFrame * CFrame.new(math.random(-15, 15), 0, math.random(-15, 15))
	
	coroutine.wrap(function()
		local Lightning = boltModule.new(a0, a1, 50)
		Lightning.MinRadius = 1
		Lightning.MaxRadius = 4
		Lightning.AnimationSpeed = 3
		Lightning.FadeLength = 0.5
		Lightning.PulseLength = 3
		Lightning.Thickness = 2
		Lightning.MinTransparency, Lightning.MaxTransparency = 0, 1
		Lightning.ContractFrom = 3
		Lightning.PulseSpeed = math.random(8, 15)
		Lightning.MinThicknessMultiplier, Lightning.MaxThicknessMultiplier = 0.3, .5
		Lightning.Color = ColorSequence.new(Color3.fromRGB(153, 225, 255), Color3.fromRGB(193, 255, 255))

		sparks.new(Lightning)
	end)()
	
	task.wait(0.1)
	
	local RayParam = RaycastParams.new()
	RayParam.FilterType = Enum.RaycastFilterType.Exclude
	RayParam.FilterDescendantsInstances = { char, workspace.Debris }

	local RaycastResult = workspace:Raycast(char.HumanoidRootPart.Position, Vector3.yAxis * -5, RayParam) or {}
	local hit, vec2Pos, surfaceNormal = RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal

	if hit then
		local hitCF = CFrame.new(vec2Pos, vec2Pos + surfaceNormal) * CFrame.Angles(-math.pi/2, 0, 0)
		coroutine.wrap(function()
			debris.lightningWaves(hitCF.Position, 15, ColorSequence.new(Color3.fromRGB(153, 225, 255), Color3.fromRGB(193, 255, 255)))
		end)()
		debris.Shockwave(hitCF.Position, 15, 25)
		debris.Ground(char.HumanoidRootPart.Position, 10, Vector3.new(2, 2.5, 2), nil, 30, false, 1.5)
		debris.sphereExp(hitCF.Position, 15, 20, Color3.fromRGB(170, 255, 255))
	end
	
	debris.BnWImpact()

	local sfx = script.LightningStrike:Clone()
	sfx.Parent = a1
	sfx:Play()
end
