--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Imports ||--
local SoundManager = require(ReplicatedStorage.Modules.Shared.SoundManager)
local StateManager = require(ReplicatedStorage.Modules.Shared.StateManager)

local NetworkStream = require(ReplicatedStorage.Modules.Utility.NetworkStream)
local TaskScheduler = require(ReplicatedStorage.Modules.Utility.TaskScheduler)

--|| Variables ||--
local RNG = Random.new()
local TI2 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)

return function(Data)
    local Victim, Character = Data.Victim, Data.Character

    local VHumanoid, VRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")

    local Duration, Damage = Data.Duration, Data.Damage

    if StateManager:Peek(Victim, "Blocking") then
        return
    end
    if VRoot:FindFirstChild("FireProc") then
        return
    end
    if not StateManager:Peek(Victim, "IFrame") then
        return
    end

    -- local Sound = SoundManager:AddSound("FireProc", {Parent = VRoot, Volume = 8, Looped = true}, "Client", {Duration = 134134718341})

    local FireParticle = ReplicatedStorage.Assets.Effects.Particles.FireProc:Clone()
    FireParticle.Enabled = true
    FireParticle.Parent = VRoot

    coroutine.resume(coroutine.create(function()
        for Index = 1, Duration do
            TaskScheduler:AddTask(0.5, function()
                VHumanoid:TakeDamage(Damage)
                NetworkStream.FireClientDistance(
                    Character,
                    "ClientRemote",
                    50,
                    {
                        Damage = Damage,
                        Victim = Victim,
                        Module = "PlayerClient",
                        Function = "DamageIndication",
                        StunTime = 0,
                    }
                )
            end)
            wait(1)
            if VHumanoid.Health <= 3 then
                break
            end
        end
        FireParticle.Enabled = false

        Debris:AddItem(FireParticle, 1)
        Debris:AddItem(Sound, 1)
    end))
end
