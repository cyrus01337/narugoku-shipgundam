--|| Services ||--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Imports ||--
local StateManager = require(ReplicatedStorage.Modules.Shared.StateManager)

return function(Data)
    local Character = Data.Character
    local Victim = Data.Victim

    if RunService:IsServer() then
        if StateManager:Peek(Victim, "Blocking") then
            return
        end

        local VHum, VRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

        if Players:GetPlayerFromCharacter(Victim) == nil then
            local BodyGyro = Instance.new("BodyGyro")
            BodyGyro.MaxTorque = Vector3.new(12, 15555, 12)
            BodyGyro.P = 10000
            BodyGyro.CFrame = CFrame.lookAt(VRoot.CFrame.Position, HumanoidRootPart.Position + Vector3.new(0, 2, 0))
            BodyGyro.Parent = VRoot

            Debris:AddItem(BodyGyro, 0.35)
        end
    end
end
