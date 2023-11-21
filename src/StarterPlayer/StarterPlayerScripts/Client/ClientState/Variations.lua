--|| Services ||--
local Players = game:GetService("Players")

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

--|| Modules ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local World = workspace.World
local Visuals = World.Visuals

local Mouse = Player:GetMouse()

local module = {}

function module.Aiming(StateData)
    if GlobalFunctions.IsAlive(Character) then
        -- dis mysts
        Mouse.TargetFilter = workspace.Visuals

        local Positioner = Character.HumanoidRootPart:FindFirstChild("Positioner") or Instance.new("BodyVelocity")
        Positioner.Name = "Positioner"
        Positioner.MaxForce = Vector3.new(1, 1, 1) * 50000
        Positioner.Velocity = Vector3.new(0, 0, 0)
        Positioner.Parent = Character.HumanoidRootPart

        local Rotater = Character.HumanoidRootPart:FindFirstChild("Rotater") or Instance.new("BodyGyro")
        Rotater.Name = "Rotater"
        Rotater.MaxTorque = Vector3.new(1, 1, 1) * 50000
        Rotater.D = 150
        Rotater.P = 5000
        Rotater.Parent = Character.HumanoidRootPart

        --while StateData.IsAim do
        RunService.Stepped:Wait()
        Rotater.CFrame = CFrame.lookAt(Character.HumanoidRootPart.Position, Mouse.Hit.Position)
        --	end

        Positioner:Destroy()
        Rotater:Destroy()
    end
end

return module
