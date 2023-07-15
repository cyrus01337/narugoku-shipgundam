local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
if RunService:IsServer() then
	PhysicsService:CreateCollisionGroup("MystSub") -- This is used for default collision group which should have nothing in it
end
local RayService = {}

local Type = typeof

--|| Private Functions
local function ConvertToVector(CF)
	return Type(CF) == "CFrame" and CF.Position or CF
end

--|| Functions
function RayService:Cast(Orgin, Goal, Data, FilterType, IgnoreWater, CollisionGroup)
	local StartPosition = ConvertToVector(Orgin)
	local EndPosition = ConvertToVector(Goal)
	local Difference = EndPosition - StartPosition
	local Direction = Difference.Unit
	local Distance = Difference.Magnitude
	
	local RayData = RaycastParams.new()
	RayData.FilterDescendantsInstances = Data or {}
	RayData.FilterType = FilterType or Enum.RaycastFilterType.Exclude
	RayData.IgnoreWater = IgnoreWater or true
	RayData.CollisionGroup = CollisionGroup or "MystSub"
	
	return workspace:Raycast(StartPosition, Direction * Distance, RayData)
end

function RayService:Visualize(Orgin, Goal, Color)
	local StartPosition = ConvertToVector(Orgin)
	local EndPosition = ConvertToVector(Goal)
	--print(StartPosition, EndPosition, Goal)
	local Distance = (EndPosition - StartPosition).Magnitude

	local Beam = Instance.new("Part")
	Beam.Anchored = true
	Beam.Color = Color or Color3.fromRGB(255,255,255)
	Beam.Locked = true
	Beam.CanCollide = false
	Beam.Size = Vector3.new(0.1,0.1,Distance)
	Beam.CFrame = CFrame.new(StartPosition, EndPosition) * CFrame.new(0,0,-Distance/2)
	Beam.Parent = workspace.World.Visuals
end

return RayService
