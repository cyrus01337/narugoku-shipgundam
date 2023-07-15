-- || Note ||--

-- Size are based on how large you want you're hitbox to be

--[[

local HitboxData = {Size = 4}

local Hit = HitboxModule.RaycastModule(Player,HitboxData)
if Hit.Hit == true then
	local Victim = Hit.Object.Parent	
	local VHumanoid = Victim:FindFirstChild("Humanoid")
	local VRoot = Victim:FindFirstChild("HumanoidRootPart")

    VHumanoid.Health - VHumanoid.Health - Damage
 end
 
]]

-- Made by Fresh 2/27/2020
