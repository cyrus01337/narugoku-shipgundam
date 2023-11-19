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
	
	local Amount,Max = Data.Amount, Data.Max
	local FirstDuration, RocksLength = Data.FirstDuration, Data.RocksLength
	local Cframe,Iteration = Data.Cframe, Data.Iteration 
	
	local Angeled360 = 360 / Amount	
	
	local RockModel = Instance.new("Model", workspace.World.Visuals)
	Debris:AddItem(RockModel, RocksLength + .25)
	
	for Index = 1, Amount do
		--// Calculations
		local SizeCalc = math.sin(math.pi / Amount) * Iteration * 2 * 1.01
		local PositionCalc = Cframe * CFrame.Angles(0, math.rad(Index * Angeled360), 0) * CFrame.new(0, 0, Iteration) * CFrame.Angles(math.rad(45), 0, 0)
		local YAndZ = Max * math.random(50, 120) / 100
		local RandomizedForCalc = 5 + Max * 2
		local RaycastToSet = CFrame.new(PositionCalc.Position) * CFrame.new(0, RandomizedForCalc, 0)

		local RayParam = RaycastParams.new()
		RayParam.FilterType = Enum.RaycastFilterType.Include
		RayParam.FilterDescendantsInstances = { workspace.World.Map }

		local RaycastResult = workspace:Raycast(RaycastToSet.Position, RaycastToSet.UpVector * (-RandomizedForCalc * 2), RayParam) or {}

		local Target, Position, Surface = RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal
		
		local InstancedPart = script.Part:Clone()
		InstancedPart.CanCollide = false
		InstancedPart.Size = Vector3.new(SizeCalc, YAndZ, YAndZ)

		if Target then
			InstancedPart.Color = Target.Color
			InstancedPart.Material = Target.Material
			local Mult = 1
			if Position.Y < PositionCalc.Position.Y then
				Mult = -1
			end
			local MagZX = PositionCalc * CFrame.new(0, (PositionCalc.Position - Position).Magnitude * Mult, 0)
			local ToReturn = CFrame.new(Position, Position + Surface) * CFrame.Angles(math.rad(90), 0, 0)

			InstancedPart.CFrame = Cframe * CFrame.Angles(0, math.rad(Index * Angeled360), 0) * CFrame.new(0, 0, Iteration / 2)
			InstancedPart.Parent = RockModel
			local X, Y, Z = Cframe:components()
			
			local Ax, Ay, Az, A1, A2, A3, A4, A5, A6, A7, A8, A9 = ToReturn:components()
			
			local Tween = TweenService:Create(InstancedPart,TweenInfo.new(FirstDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out,0,false,0), {CFrame = CFrame.new(ToReturn.Position, CFrame.new(X, Y, Z, A1, A2, A3, A4, A5, A6, A7, A8, A9).Position) * CFrame.Angles(math.rad(math.random(20, 50)), 0, 0)})
			Tween:Play()
			Tween:Destroy()
			
			coroutine.resume(coroutine.create(function()
				wait(RocksLength)
				if InstancedPart then
					local Tween = TweenService:Create(InstancedPart.Mesh,TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out,0,false,0), {["Scale"] = Vector3.new(1, 0, 0)})
					Tween:Play()
					Tween:Destroy()
					
					local Tween = TweenService:Create(InstancedPart,TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out,0,false,0), {CFrame = InstancedPart.CFrame * CFrame.new(0, -Max * 1.25, 0)})
					Tween:Play()
					Tween:Destroy()
				end
			end))
		else
			InstancedPart:Destroy()
		end
	end
end
