--|| Services ||--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

--|| Variables ||--
local RNG = Random.new()
local TI2 = TweenInfo.new(.3,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0)

return function(CFrameIndex, CFrame2Index, ToColorNotTween, ToSizeTween, SizeIndex, Duration, TransIndex, Menbere, ColorIndex, Material, SecondPart)
	local Part = script.Part:Clone()
	if SecondPart then
		Part = script[SecondPart]:Clone()
	end
	Part.CFrame = CFrameIndex
	if Material then
		Part.Material = Material
	end
	if CFrame2Index then
		Part.CFrame = CFrame2Index
	end
	if not pcall(function()
			Part.BrickColor = ToColorNotTween
		end) then
		Part.Color = ToColorNotTween
	end
	if SizeIndex then
		Part.Size = SizeIndex
	end
	if TransIndex == nil then
		TransIndex = 0
	end
	Part.Transparency = TransIndex
	Debris:AddItem(Part, Duration)
	local Data = {
		Size = ToSizeTween, 
		CFrame = CFrameIndex, 
		Transparency = 1
	}
	if ColorIndex then
		Data.Color = ColorIndex
	end
	Part.Parent = workspace.World.Visuals

	local Tween = TweenService:Create(Part, TweenInfo.new(Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Data)
	Tween:Play()
	Tween:Destroy()
end