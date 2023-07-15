--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

--|| Modules ||--
local HitboxService = require(ReplicatedStorage.Modules.Shared.RaycastManager)
local RayService = require(ReplicatedStorage.Modules.Shared.RaycastManager.RayService)

--|| Variables ||--


return function(Data)
	local Pos = Data.Pos or Vector3.new(0,0,0)
	local Quantity = Data.Quantity or 10
	local Radius = Data.Radius or 4
	local Duration = Data.Duration or 3
	local Size = Data.Size or Vector3.new(3,3,3)
	local Shrink = Data.Shrink or false
	
	local Points = HitboxService:GetRadialPoints(CFrame.new(Pos), Quantity, Radius)
	local RocksCache = {}
	for i = 1, #Points do
		local CF = Points[i]
		local Result = RayService:Cast(CF.Position + Vector3.new(0,5,0), CF.Position - Vector3.new(0,10,0), {workspace.World.Visuals, workspace.World.Visuals}, Enum.RaycastFilterType.Exclude)
		if Result then
			local Rock = script.Template:Clone()
			Rock.CastShadow = false
			Rock.Massless = true
			Rock.Anchored = true
			Rock.CanCollide = false
			Rock.Size = Size
			Rock.Color = Result.Instance.Color
			Rock.Material = Result.Material
			Rock.CFrame = CFrame.new(Result.Position - Vector3.new(0,Size.Y/2,0)) * CFrame.fromEulerAnglesXYZ(math.random(-360,360),math.random(-360,360),math.random(-360,360))
			Rock.Parent = workspace.World.Visuals or workspace
			RocksCache[#RocksCache + 1] = Rock
			
			local Animate = TweenService:Create(Rock, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = Result.Position})
			Animate:Play()
			Animate:Destroy()
		end
	end
	
	delay(Duration, function()
		for i = 1, #RocksCache do
			local Rock = RocksCache[i];
			local Goal = {
				Position = Rock.Position - Vector3.new(0,Rock.Size.Y,0),
				Orientation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
			}

			if Shrink then
				Goal.Size = Vector3.new(0,0,0);
			end

			local Animate = TweenService:Create(Rock, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), Goal)
			Animate:Play()
			Animate:Destroy()
			
			Debris:AddItem(Rock,Duration)
		end
	end)
end