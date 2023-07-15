--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

--|| Variables ||--
local RNG = Random.new()
local TI2 = TweenInfo.new(.3,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0)

return function(Data)
	local Character = Data.Character
	local Object = Data.Object
	local Properties = Data.Properties

	local Clone = ReplicatedStorage.Assets.Models.Misc.FakeBodyPart:Clone()
	Clone.CFrame = Character[Object].CFrame
	Clone.Massless = true
	Clone.Orientation = Character[Object].Orientation
	Clone.Material = Data.Material or "Neon"
	Clone.Color = Data.Color
	Clone.Name = Data.Name or "FakeBodyPart"
	Clone.Size = Character[Object].Size + Vector3.new(.035,.035,.035)
	Clone.Transparency = Data.Transparency
	Clone.Parent = Character

	local WeldConstraint = Instance.new("WeldConstraint")
	WeldConstraint.Part0 = Clone
	WeldConstraint.Part1 = Character[Object]
	WeldConstraint.Parent = Character[Object]

	if Data.Duration then
		Debris:AddItem(WeldConstraint, Data.Duration) 
		Debris:AddItem(Clone,Data.Duration)	
	end

	coroutine.resume(coroutine.create(function()
		if not Data.Duration then return end
		wait(Data.Delay or 0)
		GlobalFunctions.TweenFunction({
			["Instance"] = Clone,
			["EasingStyle"] = Enum.EasingStyle.Quad,
			["EasingDirection"] = Enum.EasingDirection.Out,
			["Duration"] = Data.Duration,
		},{
			["Transparency"] = .35,
			["Color"] = Data.TweenColor or Data.Color,
		})
	end))

	coroutine.resume(coroutine.create(function()
		if not Data.Duration then return end
		wait(Data.Duration - .35)
		GlobalFunctions.TweenFunction({
			["Instance"] = Clone,
			["EasingStyle"] = Enum.EasingStyle.Quad,
			["EasingDirection"] = Enum.EasingDirection.Out,
			["Duration"] = .5,
		},{
			["Transparency"] = 1,
		})
	end))


	if Data.Type then
		local Attachment1 = Character[Object]:FindFirstChild("LeftFootAttachment")

		local Attachment2 = Instance.new("Attachment")
		Attachment2.Position = Attachment2.Position - Vector3.new(0.086, -0.085, 0.548)
		Attachment2.Visible = false
		Attachment2.Parent = Character[Object]

		Debris:AddItem(Attachment2, 1)

		local TrailEffect = ReplicatedStorage.Assets.Effects.Trails.TrailTing:Clone()
		TrailEffect.Color = ColorSequence.new(Data.TweenColor)	
		TrailEffect.LightEmission = 1

		TrailEffect.LightInfluence = 1
		TrailEffect.Attachment0 = Attachment1

		TrailEffect.Attachment1 = Attachment2
		TrailEffect.Lifetime = .35
		TrailEffect.Enabled = true

		TrailEffect.Parent = Character[Object]
		Debris:AddItem(TrailEffect, .65)
	end

	return Clone
end
