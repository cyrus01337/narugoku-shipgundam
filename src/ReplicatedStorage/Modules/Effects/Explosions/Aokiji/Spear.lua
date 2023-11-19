--|| Services ||--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Effects = Modules.Effects
local Shared = Modules.Shared

--|| Modules ||--
local SoundManager = require(Shared.SoundManager)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local CameraShaker = require(Effects.CameraShaker)
local LightningExplosion = require(Effects.LightningBolt.LightningExplosion)
local VfxHandler = require(Effects.VfxHandler)

local CurrentCamera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
    CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
end)

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.World.Visuals }
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local RingTween = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

return function(Data)
    local Character = Data.Character
    local Result = Data.RaycastResult
    local Spear = Data.Spear

    local CFrameIndex = CFrame.new(Result.Position)

    for Index = 1, 5 do
        local Rock = script.Rockk:Clone()
        Rock.Parent = workspace.World.Visuals
        Rock.CFrame = CFrameIndex * CFrame.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
        local RandomIndex = math.random(100, 300) / 500
        Rock.Size = Vector3.new(RandomIndex, RandomIndex, RandomIndex)
        Rock.Velocity = Vector3.new(math.random(-45, 45), math.random(50, 85), math.random(-45, 45))
        Rock.RotVelocity = Vector3.new(math.random(-7, 7), math.random(-7, 7), math.random(-7, 7))
        coroutine.wrap(function()
            wait(0.25)
            local Tween = TweenService:Create(
                Rock,
                TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
                { ["Size"] = Vector3.new(0, 0, 0) }
            )
            Tween:Play()
            Tween:Destroy()
        end)()
        Debris:AddItem(Rock, 0.75)
    end
    local PartEffect = script.Part:Clone()
    PartEffect.Parent = workspace.World.Visuals
    PartEffect.CFrame = CFrameIndex
    PartEffect.IceSmoke:Emit(15)
    PartEffect.Sparks:Emit(10)
    Debris:AddItem(PartEffect, 2)

    local Ball = ReplicatedStorage.Assets.Effects.Meshes.regball:Clone()
    Ball.Material = Enum.Material.ForceField
    Ball.Transparency = 0
    Ball.CFrame = CFrameIndex
    Ball.Size = Vector3.new(5, 5, 5)
    Ball.Color = Color3.fromRGB(129, 201, 255)
    Ball.Parent = workspace.World.Visuals

    local Tween = TweenService:Create(
        Ball,
        TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        { ["Size"] = Vector3.new(35, 35, 35), ["Transparency"] = 1 }
    )
    Tween:Play()
    Tween:Destroy()

    local Tween = TweenService:Create(
        Ball,
        TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        { ["Transparency"] = 1 }
    )
    Tween:Play()
    Tween:Destroy()

    Debris:AddItem(Ball, 3)

    local _ = not Spear.Name == "Bird"
        and VfxHandler.FloorFreeze(
            CFrame.new(Result.Position) * CFrame.new(0, 5, 0),
            100,
            10,
            15,
            nil,
            10,
            Vector3.new(math.random(20, 25), 0.989, math.random(20, 25)),
            Character
        )
    Spear.Transparency = Spear.Name == "Bird" and 1 or 0

    VfxHandler.Spherezsz({
        Cframe = CFrameIndex,
        TweenDuration1 = 0.2,
        TweenDuration2 = 0.35,
        Range = 20,
        MinThick = 15,
        MaxThick = 25,
        Part = nil,
        Color = Color3.fromRGB(110, 168, 255),
        Amount = 25,
    })

    -- SoundManager:AddSound("FlashFreeze",{Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = 5},"Client")
    if GlobalFunctions.CheckDistance(Player, 15) then
        GlobalFunctions.FreshShake(100, 45, 1, 0.2, 0)
    end
end
