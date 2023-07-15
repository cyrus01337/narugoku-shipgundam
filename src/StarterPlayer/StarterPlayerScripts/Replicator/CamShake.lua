local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")

local cameraShaker = require(RS.Modules.CameraShaker)
local camera = workspace.CurrentCamera

local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	camera.CFrame = camera.CFrame * shakeCFrame
end)

return function(Position, shakeStrength, maxMagnitude)
	local shakeMagnitude = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Position).Magnitude
	if shakeMagnitude < maxMagnitude then
		camShake:Start()
		if shakeMagnitude >= 0 and shakeMagnitude < maxMagnitude/4 then
			camShake:ShakeOnce(shakeStrength/1.5, shakeStrength * 2, 0, 0.7)
		elseif shakeMagnitude > maxMagnitude/4 and shakeMagnitude < maxMagnitude/3 then
			camShake:ShakeOnce(shakeStrength/5, shakeStrength * 1.5, 0, 1)
		elseif shakeMagnitude > maxMagnitude/3 and shakeMagnitude < maxMagnitude/2 then
			camShake:ShakeOnce(shakeStrength/7.5, shakeStrength * 1, 0, 1.2)
		elseif shakeMagnitude > maxMagnitude/3.5 and shakeMagnitude < maxMagnitude then
			camShake:ShakeOnce(shakeStrength/10, shakeStrength * 0.5, 0, 1.5)
		end
	end
end
