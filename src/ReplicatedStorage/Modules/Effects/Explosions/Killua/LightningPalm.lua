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
local CameraShaker = require(Effects.CameraShaker)
local LightningExplosion = require(Effects.LightningBolt.LightningExplosion)
local VfxHandler = require(Effects.VfxHandler)

--|| Variables ||--
local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local RingTween = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

return function(Data)
    local Character = Data.Character
    local Root = Character:FindFirstChild("HumanoidRootPart")

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = { Character, workspace.World.Visuals }
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local Calculation = Root.CFrame - Root.Position

    local Result = workspace:Raycast(Root.Position, Root.CFrame.upVector * -15, raycastParams)
    if Result and Result.Instance then
        for _ = 1, 7 do
            local Rock = Effects.Rock:Clone()
            Rock.Position = Root.Position
            Rock.Material = Result.Material
            Rock.Color = Result.Instance.Color
            Rock.CanCollide = false
            Rock.Size = Vector3.new(2, 2, 2)
            Rock.Orientation = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
            Rock.Velocity = Vector3.new(math.random(-100, 100), math.random(100, 100), math.random(-100, 100))
            Rock.Parent = workspace.World.Visuals

            local BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.Velocity = Vector3.new(math.random(-40, 40), math.random(40, 75), math.random(-40, 40))
            BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
            BodyVelocity.Parent = Rock

            local BlockTrail = Particles.BlockSmoke:Clone()
            BlockTrail.Color = ColorSequence.new(Result.Instance.Color)
            BlockTrail.Enabled = true
            BlockTrail.Parent = Rock

            Debris:AddItem(Rock, 3)
            Debris:AddItem(BodyVelocity, 0.1)
        end
    end

    VfxHandler.RockExplosion({
        Pos = Result.Position,
        Quantity = 8,
        Radius = 15,
        Size = Vector3.new(2.5, 2.5, 2.5),
        Duration = 2,
    })

    LightningExplosion.new(
        Character.HumanoidRootPart.Position,
        0.5,
        14,
        ColorSequence.new(Color3.fromRGB(143, 212, 255)),
        ColorSequence.new(Color3.fromRGB(117, 237, 255)),
        nil
    )

    for _ = 1, 2 do
        local Ring = ReplicatedStorage.Assets.Effects.Meshes.Ring2:Clone()
        Ring.Size = Vector3.new(50, 3, 50)
        Ring.Material = Enum.Material.Neon
        Ring.CanCollide = false
        Ring.CFrame = CFrame.new(Root.Position) * Calculation
        Ring.Anchored = true
        Ring.Parent = workspace.World.Visuals

        Debris:AddItem(Ring, 0.4)

        local Tween = TweenService:Create(
            Ring,
            RingTween,
            { CFrame = Ring.CFrame * CFrame.new(0, 15, 0), Size = Vector3.new(0, 0, 0) }
        )
        Tween:Play()
        Tween:Destroy()

        wait(0.2)
    end
end
