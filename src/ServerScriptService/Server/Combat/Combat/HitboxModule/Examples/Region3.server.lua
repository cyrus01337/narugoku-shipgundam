-- || Note ||--

-- StartPoint/EndPoint are based on how large you want you're hitbox to be

--[[

local HitResult,HitObject = HitboxModule.RegionModule(Player, {StartPoint = Vector3.new(2.75,2.75,2.75), EndPoint = Vector3.new(2.75,2.75,2.75)})
if HitResult == true then 
    local Victim = HitObject.Parent
    local VHumanoid = Victim:FindFirstChild("Humanoid")
	local VRoot = Victim:FindFirstChild("HumanoidRootPart")

    VHumanoid.Health - VHumanoid.Health - Damage
end

]]

-- Made by Fresh 2/27/2020
