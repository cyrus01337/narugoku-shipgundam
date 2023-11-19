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

function VelocityCalculation(End, Start, Gravity, Time)
    return (End - Start - 0.5 * Gravity * Time * Time) / Time
end

local RingTween = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

return function(Data)
    local Character = Data.Character
    local Result = Data.RaycastResult
    local Volleyball = Data.Volleyball
    local BodyVelocity = Data.BodyVelocity

    Debris:AddItem(Volleyball, 1)

    local Part = Instance.new("Part")
    Part.Anchored = true
    Part.Position = Result.Position
    Part.Transparency = 1
    Part.Orientation = Vector3.new(3.87, -4.36, -2.25)
    Part.Parent = workspace.World.Visuals

    Debris:AddItem(Part, 2)

    local Player = Players:GetPlayerFromCharacter(Character)

    local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

    coroutine.resume(coroutine.create(function()
        wait(0.35)
        for Index = 1, 2 do
            local ball = Effects.regball:Clone()
            ball.Transparency = 0.5
            ball.Size = Vector3.new(80, 80, 80) -- 100,100,100
            ball.BrickColor = BrickColor.new("Institutional white")
            ball.CFrame = Part.CFrame * CFrame.new(0, 5, 0)
            ball.Parent = workspace.World.Visuals

            GlobalFunctions.TweenFunction({
                ["Instance"] = ball,
                ["EasingStyle"] = Enum.EasingStyle.Quad,
                ["EasingDirection"] = Enum.EasingDirection.Out,
                ["Duration"] = 0.15,
            }, {
                ["Size"] = Vector3.new(0, 0, 0),
            })

            local windshockwave = Effects.windshockwave:Clone()
            windshockwave.CFrame = ball.CFrame
            windshockwave.Size = Vector3.new(5, 5, 5)
            windshockwave.Transparency = 0
            windshockwave.Material = "Neon"
            windshockwave.BrickColor = BrickColor.new("Institutional white")
            windshockwave.Parent = workspace.World.Visuals

            GlobalFunctions.TweenFunction({
                ["Instance"] = windshockwave,
                ["EasingStyle"] = Enum.EasingStyle.Quad,
                ["EasingDirection"] = Enum.EasingDirection.Out,
                ["Duration"] = 0.35,
            }, {
                ["Transparency"] = 1,
                ["Size"] = Vector3.new(80, 80, 80), -- 60,60,60
                ["CFrame"] = windshockwave.CFrame * CFrame.fromEulerAnglesXYZ(0, 5, 0),
            })

            local windshockwave2 = Effects.windshockwave2:Clone()
            windshockwave2.CFrame = ball.CFrame
            windshockwave2.Size = Vector3.new(5, 5, 5)
            windshockwave2.Transparency = 0
            windshockwave2.Material = "Neon"
            windshockwave2.BrickColor = BrickColor.new("Institutional white")
            windshockwave2.Parent = workspace.World.Visuals

            GlobalFunctions.TweenFunction({
                ["Instance"] = windshockwave2,
                ["EasingStyle"] = Enum.EasingStyle.Quad,
                ["EasingDirection"] = Enum.EasingDirection.Out,
                ["Duration"] = 0.35,
            }, {
                ["Transparency"] = 1,
                ["Size"] = Vector3.new(80, 80, 80), --60,60,60
                ["CFrame"] = windshockwave2.CFrame * CFrame.fromEulerAnglesXYZ(0, 5, 0),
            })

            if Index == 2 then
                ball.Color = Color3.fromRGB(255, 93, 39)
                windshockwave.Color = Color3.fromRGB(255, 93, 39)
                windshockwave2.Color = Color3.fromRGB(255, 93, 39)
            end

            Debris:AddItem(ball, 0.35)
            Debris:AddItem(windshockwave, 0.35)
            Debris:AddItem(windshockwave2, 0.35)
            wait(0.15)
        end
    end))

    local MeteorExplosion = Effects.MeteorExplosion:Clone()
    MeteorExplosion.Position = Part.Position

    MeteorExplosion.Parent = workspace.World.Visuals
    Debris:AddItem(MeteorExplosion, 3.5)

    local LargerParticles = MeteorExplosion["Larger Particles"]
    VfxHandler.Emit(LargerParticles, 100)

    -- SoundManager:AddSound("SpearHit", {Parent = Root, Volume = 8}, "Client")
    -- SoundManager:AddSound("Explosionbzz", {Volume = .7, Parent = Root}, "Client")

    if GlobalFunctions.CheckDistance(Player, Data.Distance) then
        CameraShake:Start()
        CameraShake:ShakeOnce(3, 5, 0, 1.5)
    end

    local Calculation = Part.CFrame - Result.Position + Vector3.new(0, 5, 0)

    VfxHandler.RockExplosion({
        Pos = Result.Position,
        Quantity = 15,
        Radius = 30,
        Size = Vector3.new(4, 4, 4),
        Duration = 2,
    })

    for _ = 1, 5 do
        local Shockwave = Effects.RingInnit:Clone()
        Shockwave.Position = Result.Position
        Shockwave.Parent = workspace.World.Visuals
        Debris:AddItem(Shockwave, 2)

        local RandomSize = 30 * (2 + 2 * math.random())

        local ColorChange = TweenService:Create(
            Shockwave,
            TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Color = Color3.fromRGB(255, 93, 39) }
        )
        ColorChange:Play()
        ColorChange:Destroy()

        local Expand = TweenService:Create(
            Shockwave,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = Vector3.new(RandomSize, 0.5, RandomSize) }
        )
        Expand:Play()
        Expand:Destroy()

        local Spin = TweenService:Create(
            Shockwave,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1),
            { Orientation = Shockwave.Orientation + Vector3.new(0, 360, 0) }
        )
        Spin:Play()
        Spin:Destroy()

        local Pillow = TweenService:Create(
            Shockwave,
            TweenInfo.new(0.35 + math.random(), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
            { Position = Shockwave.Position + Vector3.new(0, math.random(5, 50), 0), Transparency = 1 }
        )
        Pillow:Play()
        Pillow:Destroy()

        Debris:AddItem(Shockwave, 1.5)
    end

    for _ = 1, 6 do
        local Rock = Effects.Rock:Clone()
        Rock.Position = Result.Position
        Rock.Material = Result.Material
        Rock.Color = Result.Instance.Color
        Rock.CanCollide = false
        Rock.Size = Vector3.new(6, 6, 6)
        Rock.Orientation = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
        Rock.Velocity = Vector3.new(math.random(-100, 100), math.random(100, 100), math.random(-100, 100))
        Rock.Parent = workspace.World.Visuals

        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Velocity = Vector3.new(math.random(-80, 80), math.random(80, 120), math.random(-80, 80))
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
        CameraShake:ShakeOnce(3, 5, 0, 1.5)
    end

    for Index = 1, math.random(6, 8) do
        local x, y, z =
            math.cos(math.rad(math.random(1, 6) * 60)),
            math.cos(math.rad(math.random(1, 6) * 60)),
            math.sin(math.rad(math.random(1, 6) * 60))
        local Start = Result.Position
        local End = Start + Vector3.new(x, y, z)

        local Orbie = Effects.MeshOribe:Clone()
        Orbie.CFrame = CFrame.new(Start, End)
        Orbie.Size = Vector3.new(1, 2, 1)

        if Index == 2 or Index == 4 or Index == 1 then
            Orbie.Color = Color3.fromRGB(255, 93, 39)
        end

        local OrbieTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

        local Tween = TweenService:Create(
            Orbie,
            OrbieTweenInfo,
            { CFrame = CFrame.new(Start, End) * CFrame.new(0, 0, -(math.random(2, 5) * 35)), Size = Vector3.new(
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

    Debris:AddItem(GroundEffect, 3)

    for Index = 1, 2 do
        local Ring = ReplicatedStorage.Assets.Effects.Meshes.Ring2:Clone()
        Ring.Size = Vector3.new(95, 3, 95) --50,3,50
        Ring.Material = Enum.Material.Neon
        Ring.CanCollide = false
        Ring.CFrame = CFrame.new(Result.Position) * Calculation
        Ring.Anchored = true
        Ring.Parent = workspace.World.Visuals

        Debris:AddItem(Ring, 0.4)

        local Tween = TweenService:Create(
            Ring,
            RingTween,
            { CFrame = Ring.CFrame * CFrame.new(0, 45, 0), Size = Vector3.new(0, 0, 0) }
        )
        Tween:Play()
        Tween:Destroy()

        wait(0.2)
    end
end
