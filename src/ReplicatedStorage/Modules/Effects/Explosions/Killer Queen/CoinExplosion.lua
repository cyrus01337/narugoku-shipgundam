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
local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.World.Visuals }
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local RingTween = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

return function(Data)
    local Character = Data.Character
    local Result = Data.ContactPointCFrame
    local Coin = Data.Coin

    local Player = Players:GetPlayerFromCharacter(Character)

    local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

    VfxHandler.RockExplosion({
        Pos = Result.Position,
        Quantity = 8,
        Radius = 15,
        Size = Vector3.new(2.5, 2.5, 2.5),
        Duration = 2,
    })

    local Part = Instance.new("Part")
    Part.Anchored = true
    Part.CFrame = Coin.CFrame
    Part.Transparency = 1
    Part.Orientation = Vector3.new(3.87, -4.36, -2.25)
    Part.Parent = workspace.World.Visuals

    Debris:AddItem(Part, 2)

    LightningExplosion.new(
        Result.Position,
        0.5,
        5,
        ColorSequence.new(Color3.fromRGB(255, 85, 0)),
        ColorSequence.new(Color3.fromRGB(255, 72, 0)),
        nil
    )

    local Calculation = Part.CFrame - Part.CFrame.Position

    local RayParam = RaycastParams.new()
    RayParam.FilterType = Enum.RaycastFilterType.Exclude
    RayParam.FilterDescendantsInstances = { Character, workspace.World.Visuals }

    local RaycastResult = workspace:Raycast(Part.PivotOffset.Position, Vector3.yAxis * -1000, raycastParams)
    local PartFount = RaycastResult.Part
    local Position = RaycastResult.Position

    if PartFount then
        local BurstParticle = Particles.Burst:Clone()
        BurstParticle.Position = Position or Part.Position
        BurstParticle.Transparency = 1
        BurstParticle.Rocks.Color = ColorSequence.new(PartFount.Color)
        BurstParticle.Smoke.Color = ColorSequence.new(PartFount.Color)
        BurstParticle.Parent = workspace.World.Visuals

        VfxHandler.Emit(BurstParticle.Burst, 80)
        VfxHandler.Emit(BurstParticle.Rocks, 30)
        VfxHandler.Emit(BurstParticle.Smoke, 30)
        VfxHandler.Emit(BurstParticle.BlackSmoke, 80)
        VfxHandler.Emit(BurstParticle.ParticleEmitter2, 30)

        coroutine.resume(coroutine.create(function()
            wait(1)
            local Tween = TweenService:Create(BurstParticle.Attachment.PointLight, RingTween, { Range = 0 })
            Tween:Play()
            Tween:Destroy()
        end))

        Debris:AddItem(BurstParticle, 3)

        for _ = 1, 6 do
            local Rock = Effects.Rock:Clone()
            Rock.Position = Position or Part.Position
            Rock.Material = PartFount.Material
            Rock.Color = PartFount.Color
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
            BlockTrail.Color = ColorSequence.new(PartFount.Color)
            BlockTrail.Enabled = true
            BlockTrail.Parent = Rock

            Debris:AddItem(Rock, 3)
            Debris:AddItem(BodyVelocity, 0.1)

            local GroundEffect = Particles.GroundSlamThing:Clone()
            GroundEffect.CFrame = CFrame.new(Part.Position) * CFrame.Angles(math.pi / 2, 0, 0)
            GroundEffect.ParticleEmitter.Color = ColorSequence.new(PartFount.Color)
            GroundEffect.Rocks.Color = ColorSequence.new(PartFount.Color)

            GroundEffect.Parent = workspace.World.Visuals

            GroundEffect.ParticleEmitter:Emit(18)
            GroundEffect.Rocks:Emit(20)

            Debris:AddItem(GroundEffect, 3)
        end
    end

    if GlobalFunctions.CheckDistance(Player, Data.Distance) then
        CameraShake:Start()
        CameraShake:ShakeOnce(8, 35, 0, 1.5)
    end

    for _ = 1, math.random(4, 10) do
        local x, y, z =
            math.cos(math.rad(math.random(1, 6) * 60)),
            math.cos(math.rad(math.random(1, 6) * 60)),
            math.sin(math.rad(math.random(1, 6) * 60))
        local Start = Part.Position
        local End = Start + Vector3.new(x, y, z)

        local Orbie = Effects.MeshOribe:Clone()
        Orbie.CFrame = CFrame.new(Start, End)
        Orbie.Size = Vector3.new(1, 2, 1)

        local OrbieTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

        local Tween = TweenService:Create(
            Orbie,
            OrbieTweenInfo,
            { CFrame = CFrame.new(Start, End) * CFrame.new(0, 0, -(math.random(2, 5) * 10)), Size = Vector3.new(
                0,
                0,
                24
            ) }
        )
        Tween:Play()
        Tween:Destroy()

        Debris:AddItem(Orbie, 0.2)
        Orbie.Parent = workspace.World.Visuals
    end

    for _ = 1, 2 do
        local Ring = ReplicatedStorage.Assets.Effects.Meshes.Ring2:Clone()
        Ring.Size = Vector3.new(50, 3, 50)
        Ring.Material = Enum.Material.Neon
        Ring.CanCollide = false
        Ring.CFrame = CFrame.new(Part.Position) * Calculation
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
