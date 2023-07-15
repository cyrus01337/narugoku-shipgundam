--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Tween1 = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Map}
raycastParams.FilterType = Enum.RaycastFilterType.Include

return function(Data)
	local Cframe = Data.Cframe
	local Part = Data.Part
	local Range = Data.Range
	local MinThick = Data.MinThick
	local MaxThick = Data.MaxThick
	local TweenDuration1 = Data.TweenDuration1
	local TweenDuration2 = Data.TweenDuration2
	local Color = Data.Color
	
	for Index = 1, Data.Amount do
		if Part then
			Cframe = Part.CFrame
		end
		
		local End = Cframe * CFrame.new(math.random(-Range, Range), math.random(-Range, Range), math.random(-Range, Range))
		local RandomCalculation = math.random(MinThick, MaxThick)
		local MagnitudeCalculation = (End.p - Cframe.p).magnitude
		
		local Sphere = script.Orbie:Clone()
		Sphere.CanCollide = false
		Sphere.Color = Color
		Sphere.CFrame = CFrame.new(Cframe.p, End.p) * CFrame.Angles(math.rad(90), 0, 0)
		Sphere.Parent = workspace.World.Visuals
		
		local Tween = TweenService:Create(Sphere, TweenInfo.new(TweenDuration1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = CFrame.new(End.p, Cframe.p) * CFrame.Angles(math.rad(-90), 0, 0), ["Size"] = Vector3.new(0, 1, 0)})
		Tween:Play()
		Tween:Destroy()
		
		local MeshTween = TweenService:Create(Sphere.Mesh, TweenInfo.new(TweenDuration1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Scale"] = Vector3.new(RandomCalculation, MagnitudeCalculation, RandomCalculation), ["Offset"] = Vector3.new(0, -MagnitudeCalculation / 2, 0)})
		MeshTween:Play()
		MeshTween:Destroy()
		
		coroutine.resume(coroutine.create(function()
			wait(TweenDuration1 / 2)
			if Sphere:findFirstChild("Mesh") then				
				local EndTween = TweenService:Create(Sphere.Mesh, TweenInfo.new(TweenDuration2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Scale"] = Vector3.new(0, 0, 0), ["Offset"] = Vector3.new(0, -MagnitudeCalculation, 0)})
				EndTween:Play()
				EndTween:Destroy()
			end
		end))
		Debris:AddItem(Sphere, TweenDuration2 * 2 + TweenDuration1)
	end
end
