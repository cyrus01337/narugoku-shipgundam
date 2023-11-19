local air = false 
local imp = false


script.Parent.Touched:connect(function(h)
if not h:IsDescendantOf(script.Parent.Parent) and air == true and imp == false and h and h.Transparency<1 then
	air = false
	imp = true
local sou = math.random(1,10)
local s = script["Impact"..sou]:clone()
s.Parent = script.Parent
s.Name = "Impact"
game.Debris:AddItem(s, 3)
s:Play()
end	
end)

while true do
	wait()
	local raycastParam = RaycastParams.new()
	raycastParam.FilterDescendantsInstances = { script.Parent.Parent }
	raycastParam.FilterType = Enum.RaycastFilterType.Exclude

	local raycastResult = workspace:Raycast(script.Parent.Position, Vector3.new(0, -3, 0), raycastParam)

	local h,p = raycastResult.Instance, raycastResult.Position
	if h then
	
	else
	air = true
	imp = false
	end
end