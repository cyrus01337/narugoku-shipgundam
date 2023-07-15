local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Visual = workspace.World.Visuals

return function(Data)
	
	local j = Data.j or 2
	local i = Data.i or 6
	local StartPos = Data.StartPos
	local EndPos = Data.EndPos 
	local Range = Data.Range
	local Duration = Data.Duration or 0.15
	
	local Width, Length = Data.Width, Data.Length
	
	local Color1, Color2 = Data.Color1 or Color3.fromRGB(255, 255, 255), Data.Color2
	
	local Distance = Data.Distance
	
	local Material = Data.Material or Enum.Material.Neon
	
	for j = 1,j do
		for i = 1,i do
			local Block = script.Block:Clone()
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = "Sphere"
			mesh.Parent = Block
			Block.Size = Vector3.new(Width,Width,Length)
			Block.Material = Material
			if Color2 then
				if i % 2 == 0 then
					Block.Color = Color1
				else
					Block.Color = Color2
				end
			else
				Block.Color = Color1
			end
			Block.Parent = Visual

			Block.CFrame = CFrame.new(StartPos + Vector3.new(math.random(-1,1),math.random(-1,1),math.random(-1,1)), StartPos) 
			
			if (EndPos and Range) then
				Block.CFrame = CFrame.lookAt(StartPos, EndPos + Vector3.new(math.random(-Range,Range),math.random(-Range,Range),math.random(-Range,Range))) 
			end
			
			local tween = TweenService:Create(Block, TweenInfo.new(Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Size"] = Block.Size + Vector3.new(0,0, math.random(2,5)), ["CFrame"] = Block.CFrame * Distance})
			local tween2 = TweenService:Create(Block, TweenInfo.new(Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {["Size"] = Vector3.new(0,0,Length)})		
			tween:Play()
			tween:Destroy()
			tween2:Play()
			tween2:Destroy()
			Debris:AddItem(Block, Duration)						
		end
	end
end
