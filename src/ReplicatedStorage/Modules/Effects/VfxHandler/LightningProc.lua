--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Imports ||--
local SoundManager = require(ReplicatedStorage.Modules.Shared.SoundManager)
local StateManager = require(ReplicatedStorage.Modules.Shared.StateManager)

local NetworkStream = require(ReplicatedStorage.Modules.Utility.NetworkStream)

--|| Variables ||--
local RNG = Random.new()
local TI2 = TweenInfo.new(.3,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0)

return function(Data)
	local Victim,Character = Data.Victim,Data.Character

	local VHumanoid,VRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")

	local Duration,StunTime = Data.Duration, Data.StunTime

	if StateManager:Peek(Victim,"Blocking") then return end
	if not StateManager:Peek(Victim,"IFrame") then return end
	
	coroutine.resume(coroutine.create(function()
		for Index = 1,Duration do
			StateManager:ChangeState(Victim, "Attacking", StunTime)
			
			NetworkStream.FireClientDistance(Character,"ClientRemote",50,{
				Character = Character, 
				Victim = Victim, 
				Module = "PlayerClient", 
				Function = "LightningStun"
			})	
			wait(Data.Speed)
		end	
	end))
end
