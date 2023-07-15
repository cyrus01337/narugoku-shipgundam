--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)
local TaskScheduler = require(ReplicatedStorage.Modules.Utility.TaskScheduler)

--|| Variables ||--
local RNG = Random.new()
local TI2 = TweenInfo.new(.3,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0)

return function(Data)
	local Character = Data.Character
	
	for _,v in ipairs(Character:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part")  or v:IsA("Decal") and v.Name ~= "FakeHead" then
			if v.Transparency == 0 then
				v.Transparency = 1
				TaskScheduler:AddTask(Data.Duration,function()
					v.Transparency = 0
				end)
			end
		end
	end
end
