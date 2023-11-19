--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--|| Imports ||--
local SoundManager = require(ReplicatedStorage.Modules.Shared.SoundManager)
local StateManager = require(ReplicatedStorage.Modules.Shared.StateManager)
local SpeedManager = require(ReplicatedStorage.Modules.Shared.StateManager.Speed)

local NetworkStream = require(ReplicatedStorage.Modules.Utility.NetworkStream)
local TaskScheduler = require(ReplicatedStorage.Modules.Utility.TaskScheduler)

--|| Variables ||--
local RNG = Random.new()
local TI2 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)

return function(Victim, Duration)
    local VHumanoid, VRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")

    local IceBar = script["Meshes/icef (1)"]:Clone()
    IceBar.CFrame = VRoot.CFrame
    IceBar.Parent = Victim

    local Weld = Instance.new("Weld")
    Weld.Part0 = Victim["Torso"]
    Weld.Part1 = IceBar
    Weld.Parent = IceBar

    coroutine.resume(coroutine.create(function()
        wait(2)
        local Tween = TweenService:Create(
            IceBar,
            TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            { ["Transparency"] = 1 }
        )
        Tween:Play()
        Tween:Destroy()
    end))

    SpeedManager.changeSpeed(Victim, 6, Duration, 4e4, false) --function(Character,Speed,Duration,Priority)

    TaskScheduler:AddTask(Duration, function()
        -- SoundManager:AddSound("icey",{Parent = VRoot, Volume = .8},"Client")
        IceBar:Destroy()
    end)
end
