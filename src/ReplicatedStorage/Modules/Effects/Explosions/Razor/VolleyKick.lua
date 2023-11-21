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

function VelocityCalculation(End, Start, Gravity, Time)
    return (End - Start - 0.5 * Gravity * Time * Time) / Time
end

local RingTween = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

return function(Data)
    local Character = Data.Character
    local Result = Data.RaycastResult
    local Volleyball = Data.Volleyball

    local Player = Players:GetPlayerFromCharacter(Character)

    local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

    local Part = Instance.new("Part")
    Part.Anchored = true
    Part.Position = Result.Position
    Part.Transparency = 1
    Part.Orientation = Vector3.new(3.87, -4.36, -2.25)
    Part.Parent = workspace.World.Visuals

    Debris:AddItem(Part, 2)

    VfxHandler.RockExplosion({
        Pos = Result.Position,
        Quantity = 8,
        Radius = 15,
        Size = Vector3.new(2.5, 2.5, 2.5),
        Duration = 2,
    })

    local Calculation = Part.CFrame - Result.Position

    coroutine.resume(coroutine.create(function()
        for _ = 1, 2 do
            local Ring = ReplicatedStorage.Assets.Effects.Meshes.Ring2:Clone()
            Ring.Size = Vector3.new(50, 3, 50)
            Ring.Material = Enum.Material.Neon
            Ring.CanCollide = false
            Ring.CFrame = CFrame.new(Result.Position) * Calculation
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
    end))

    local Ring = Effects.RingInnit:Clone()
    Ring.Position = Result.Position + Vector3.new(0, -16, 0)
    Ring.Size = Vector3.new(15, 0.05, 15)
    Ring.Transparency = 0.25
    Ring.Material = "Neon"
    Ring.BrickColor = BrickColor.new("Institutional white")
    Ring.Parent = workspace.World.Visuals

    Debris:AddItem(Ring, 1)
    GlobalFunctions.TweenFunction({
        ["Instance"] = Ring,
        ["EasingStyle"] = Enum.EasingStyle.Quad,
        ["EasingDirection"] = Enum.EasingDirection.Out,
        ["Duration"] = 0.5,
    }, {
        ["Size"] = Vector3.new(25, 0.05, 25),
        ["Transparency"] = 1,
        ["CFrame"] = Ring.CFrame * CFrame.new(0, 12, 0),
    })

    local ShockWave = Effects.shockwave5:Clone()
    ShockWave.CFrame = Part.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(90), 0)
    ShockWave.Size = Vector3.new(50, 100, 50)
    ShockWave.Transparency = 0
    ShockWave.Material = "Neon"
    ShockWave.BrickColor = BrickColor.new("Institutional white")
    ShockWave.Parent = workspace.World.Visuals

    GlobalFunctions.TweenFunction({
        ["Instance"] = ShockWave,
        ["EasingStyle"] = Enum.EasingStyle.Quad,
        ["EasingDirection"] = Enum.EasingDirection.Out,
        ["Duration"] = 0.5,
    }, {
        ["Transparency"] = 1,
        ["Size"] = Vector3.new(0, 180, 0),
        ["CFrame"] = ShockWave.CFrame * CFrame.new(0, 50, 0) * CFrame.fromEulerAnglesXYZ(0, 5, 0),
    })

    Debris:AddItem(ShockWave, 0.5)

    for _ = 1, 6 do
        local Rock = Effects.Rock:Clone()
        Rock.Position = Result.Position
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

    local GroundEffect = Particles.GroundSlamThing:Clone()
    GroundEffect.CFrame = CFrame.new(Result.Position, Result.Position - Result.Normal)
        * CFrame.Angles(math.pi / 2, 0, 0)
    GroundEffect.ParticleEmitter.Color = ColorSequence.new(Result.Instance.Color)
    GroundEffect.Rocks.Color = ColorSequence.new(Result.Instance.Color)

    GroundEffect.Parent = workspace.World.Visuals

    GroundEffect.ParticleEmitter:Emit(18)
    GroundEffect.Rocks:Emit(20)

    if GlobalFunctions.CheckDistance(Player, Data.Distance) then
        CameraShake:Start()
        CameraShake:ShakeOnce(8, 15, 0, 1.5)
    end

    for _ = 1, math.random(6, 8) do
        local x, y, z =
            math.cos(math.rad(math.random(1, 6) * 60)),
            math.cos(math.rad(math.random(1, 6) * 60)),
            math.sin(math.rad(math.random(1, 6) * 60))
        local Start = Result.Position
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

    -- SoundManager:AddSound("SpearHit", {Parent = Root, Volume = 5}, "Client")

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = { Character, workspace.World.Visuals }
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local RootCalc = Root.Position

    local Position1, Position2 = RootCalc, (Volleyball.Position - RootCalc).Unit * 1000
    local Results = workspace:Raycast(Position1, Position2, raycastParams)
    if Results and Results.Instance then
        if Data.BodyVelocity then
            Data.BodyVelocity:Destroy()
        end
        Debris:AddItem(Volleyball.Parent, 2.5)

        local GoalPosition = Volleyball.Position + (Results.Normal.Unit * 20)
        local Velocity =
            VelocityCalculation(GoalPosition, Volleyball.Position, Vector3.new(0, -workspace.Gravity, 0), 1)

        Volleyball.Velocity = Velocity
        Volleyball.CanCollide = true

        coroutine.resume(coroutine.create(function()
            wait(1.5)
            if Volleyball then
                local EndTween = TweenService:Create(
                    Volleyball,
                    TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut, 0, false, 0),
                    { Size = Vector3.new(0, 0, 0) }
                )
                EndTween:Play()
                EndTween:Destroy()

                wait(0.275)

                local Sparks = Particles["PE1"]:Clone()
                Sparks:Emit(35)
                Sparks.Parent = Volleyball
            end
        end))
    end

    Debris:AddItem(GroundEffect, 3)

    for Index = 1, 3 do
        local RingTing = script.ring:Clone()
        RingTing.Color = Color3.fromRGB(255, 255, 255)
        RingTing.Material = "Neon"

        RingTing.Transparency = 0
        RingTing.Position = Result.Position + Vector3.new(0, 10, 0)
        RingTing.Rotation =
            Vector3.new(math.random(-360, 360) * Index, math.random(-360, 360) * Index, math.random(-360, 360) * Index)
        RingTing.Size = Vector3.new(20, 1, 20)

        RingTing.Parent = workspace.World.Visuals
        Debris:AddItem(RingTing, 0.5)

        local Tween = TweenService:Create(
            RingTing,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = Vector3.new(45, 1, 45), Transparency = 1 }
        )
        Tween:Play()
        Tween:Destroy()
        wait(0.1)
    end
end
