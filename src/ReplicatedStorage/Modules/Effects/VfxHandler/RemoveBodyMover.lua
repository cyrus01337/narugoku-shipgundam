--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Imports ||--
local StateManager = require(ReplicatedStorage.Modules.Shared.StateManager)

return function(Object)
	for _,v in ipairs(Object:GetDescendants()) do
		if v:IsA("BodyVelocity") or v:IsA("BodyPosition") or v:IsA("BodyGyro") then
			v:Destroy()
		end
	end
end
