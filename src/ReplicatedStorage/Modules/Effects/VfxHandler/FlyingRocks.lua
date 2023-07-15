local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Visual = workspace.World.Visuals

return function(Data)
	
	local i = Data.i
	local j = Data.j
	
	local Offset = Data.Offset
	local Origin = Data.Origin
	
	local Filter = Data.Filter
	
	local Size = Data.Size -- Vector 2
	
	local AxisRange = Data.AxisRange
	local Height = Data.Height -- Vector2
	
	local Percent = Data.Percent or 0.65
	
	local Duration = Data.Duration 
	
	local IterationDelay = Data.IterationDelay
	
	for i = 1,i do
		for j = 1,j do
			local StartPosition = (Vector3.new(math.sin(360*i)*Offset, 0, math.cos(360*i)*Offset) + Origin)
			local EndPosition = CFrame.new(StartPosition).UpVector * -10

			local RayData = RaycastParams.new()
			RayData.FilterDescendantsInstances = Filter or Visual
			RayData.FilterType = Enum.RaycastFilterType.Exclude
			RayData.IgnoreWater = true

			local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
			if ray then

				local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
				if partHit then

					local Block = script.Block:Clone()

					local X,Y,Z = math.random(Size.X,Size.Y),math.random(Size.X,Size.Y),math.random(Size.X,Size.Y)
					Block.Size = Vector3.new(X,Y,Z)

					Block.Position = pos
					Block.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
					Block.Transparency = 0
					Block.Color = partHit.Color
					Block.Material = partHit.Material
					Block.Anchored = false
					Block.Parent = Visual

					local BodyVelocity = Instance.new("BodyVelocity")
					BodyVelocity.MaxForce = Vector3.new(1000000,1000000,1000000)
					BodyVelocity.Velocity = Vector3.new(math.random(-AxisRange,AxisRange),math.random(Height.X,Height.Y),math.random(-AxisRange,AxisRange)) * (j*Percent)
					BodyVelocity.P = 100000
					Block.Velocity = Vector3.new(math.random(-AxisRange,AxisRange),math.random(Height.X,Height.Y),math.random(-AxisRange,AxisRange)) * (j*Percent)
					BodyVelocity.Parent = Block

					Debris:AddItem(BodyVelocity, .05)
					Debris:AddItem(Block, Duration)
				end
			end
		end
		if IterationDelay then
			wait(IterationDelay)
		end
	end
end
