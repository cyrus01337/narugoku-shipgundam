--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

--|| Modules ||--
local HitboxService = require(ReplicatedStorage.Modules.Shared.RaycastManager)
local RayService = require(ReplicatedStorage.Modules.Shared.RaycastManager.RayService)

return function(Data)
	
	local Pos = Data.Pos or Vector3.new(0,0,0)
	local Quantity = Data.Quantity or 20
	local Properties = Data.Properties or {}
	local Offsets = Data.Offsets or {
		X = {-10,10},
		Y = {0, 10},
		Z = {-10,10},
		Offset = {10,20},
	}
	local TweenInfo = Data.TweenInfo or TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local Goal = Data.Goal or {}

	for _ = 1, Quantity do
		local Orb = script.Orb:Clone()
		for Property, Value in next, Properties do
			Orb[Property] = Value;
		end
		local Pos = Pos + Vector3.new(math.random(Offsets.X[1], Offsets.X[2]), math.random(Offsets.Y[1], Offsets.Y[2]), math.random(Offsets.Z[1], Offsets.Z[2]))
		Orb.CFrame = CFrame.lookAt(Pos, Pos - Vector3.new(0,5,0))
		Orb.Parent = workspace.World.Visuals
		Goal.CFrame = Orb.CFrame * CFrame.new(0,0,math.random(Offsets.Offset[1], Offsets.Offset[2]))
		
		local Tween = TweenService:Create(Orb, TweenInfo, Goal)
		Tween:Play()
		Tween:Destroy()
		
		Debris:AddItem(Orb,1)
	end
end