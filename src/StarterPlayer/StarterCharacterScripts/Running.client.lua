local Players = game:GetService("Players")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local ContextActionService = game:GetService("ContextActionService")

local hum = char:WaitForChild("Humanoid")
local RunAnim = hum:LoadAnimation(game.ReplicatedStorage.Assets.Animations.Shared.Misc.Running)
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage.Modules
local Shared = Modules.Shared
local StateManager = require(Shared.StateManager)

local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local DefaultFOV = 70
local lastTime = tick()
local walkingSpeed = 14
local runningSpeed = 30

local T

UIS.InputBegan:Connect(function(input, gameprocessed)
    if input.KeyCode == Enum.KeyCode.W then
        local now = tick()
        local difference = (now - lastTime)
        if difference <= 0.5 then
            RunAnim:Play()

            hum.WalkSpeed = runningSpeed

            ReplicatedStorage.Remotes.Run:FireServer()

            --StateManager:ChangeState(Character,"Running", true)
        else
            lastTime = tick()
        end
    end
end)

UIS.InputEnded:Connect(function(input, gameprocessed)
    if input.KeyCode == Enum.KeyCode.W then
        RunAnim:Stop()

        hum.WalkSpeed = walkingSpeed

        local properties = { FieldOfView = DefaultFOV }
        local Info = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0.1)
        T = game:GetService("TweenService"):Create(game.Workspace.CurrentCamera, Info, properties)
        T:Play()

        --StateManager:ChangeState(Character,"Running", false)
    end
end)
