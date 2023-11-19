--|| Services ||--
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Effects = Modules.Effects
local Utility = Modules.Utility
local Shared = Modules.Shared

local World = workspace.World
local Visuals = World.Visuals

--|| Import ||--
local VfxHandler = require(Effects.VfxHandler)

local BezierModule = require(Modules.Utility.BezierModule)

local EffectMeshes = ReplicatedStorage.Assets.Effects.Meshes
local EffectParticles = ReplicatedStorage.Assets.Effects.Particles
local EffectBeams = ReplicatedStorage.Assets.Effects.Beams
local Particles = ReplicatedStorage.Assets.Effects.Particles
local EffectTrails = ReplicatedStorage.Assets.Effects.Trails

return function(Data)
    local RootCFrame = Data.RootCFrame
    local Filter = Data.Filter

    local shock = EffectMeshes.upwardShock:Clone()
    shock.Size = Vector3.new(0, 0, 0)
    shock.CFrame = RootCFrame
    shock.Parent = Visuals

    Debris:AddItem(shock, 2)

    VfxHandler.Rockszsz({
        Cframe = RootCFrame, -- Position
        Amount = 25, -- How manay rocks
        Iteration = 15, -- Expand
        Max = 2, -- Length upwards
        FirstDuration = 0.25, -- Rock tween outward start duration
        RocksLength = 2, -- How long the rocks stay for
    })

    --[[ New Shockwave ]]
    --
    local Shockwave = EffectParticles.ParticleAttatchments.Shockwave:Clone()
    Shockwave.Shockwave.Size =
        NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 50) })
    Shockwave.Shockwave.Parent = shock
    shock.Shockwave:Emit(1)

    --[[ Ball Effect ]]
    --
    local Ball = EffectMeshes.ball:Clone()
    Ball.Color = Color3.fromRGB(170, 85, 255)
    Ball.Material = Enum.Material.ForceField
    Ball.Transparency = 0
    Ball.Size = Vector3.new(5, 5, 5)
    Ball.CFrame = RootCFrame
    Ball.Parent = Visuals

    local tween = TweenService:Create(
        Ball,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { ["Transparency"] = 1, ["Size"] = Ball.Size * 7 }
    )
    tween:Play()
    tween:Destroy()
    Debris:AddItem(Ball, 0.25)

    --[[ Stars xD ]]
    --
    local Stars = EffectParticles.ParticleAttatchments.Stars:Clone()
    Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(170, 85, 255))
    Stars.Stars.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0) })
    Stars.Stars.Drag = 5
    Stars.Stars.Rate = 100
    Stars.Stars.Acceleration = Vector3.new(0, -10, 0)
    Stars.Stars.Lifetime = NumberRange.new(1, 1.5)
    Stars.Stars.Speed = NumberRange.new(75, 200)

    Stars.Stars:Emit(50)

    Stars.Parent = shock
    Debris:AddItem(Stars, 1.5)

    --// PointLight
    local PointLight = Instance.new("PointLight")
    PointLight.Color = Color3.fromRGB(85, 0, 127)
    PointLight.Range = 100
    PointLight.Brightness = 5
    PointLight.Parent = shock

    local LightTween = TweenService:Create(
        PointLight,
        TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { ["Range"] = 0, ["Brightness"] = 0 }
    )
    LightTween:Play()

    LightTween:Destroy()

    local Fire = EffectParticles.Hiei:Clone()
    local Attachment = Instance.new("Attachment")
    Attachment.Parent = shock
    Fire.Cremation.Parent = Attachment
    Attachment.Cremation.Name = "Fire"
    Fire:Destroy()

    Attachment.Fire.Speed = NumberRange.new(60, 90)
    Attachment.Fire.Drag = 5

    Attachment.Fire.Lifetime = NumberRange.new(0.75, 1)
    Attachment.Fire.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 15), NumberSequenceKeypoint.new(1, 0) })
    Attachment.Fire.Acceleration = Vector3.new(0, 0, 0)
    Attachment.Fire.Rate = 200
    Attachment.Fire.Enabled = true
    Attachment.Fire:Emit(50)
    delay(0.1, function()
        Attachment.Fire.Enabled = false
        Attachment.Fire:Emit(50)
    end)
    Debris:AddItem(Attachment, 1)

    --[[ Flying Debris Rock ]]
    --
    VfxHandler.FlyingRocks({
        i = 2, -- first loop
        j = 5, -- nested loop
        Offset = 10, -- radius from starting pos
        Origin = RootCFrame.Position, -- where to start
        Filter = Filter, -- filter raycast
        Size = Vector2.new(1, 3), -- size range random from 1,3
        AxisRange = 80, -- velocity X and Z ranges from (-AxisRange,AxisRange)
        Height = Vector2.new(50, 60), -- velocity Y ranges from X,Y
        Percent = 0.65, -- velocity * percent of nested loop
        Duration = 2, -- duration of the debris rock
        IterationDelay = 0, -- delay between each i loop
    })

    --[[ Wunbo Orbies ]]
    --
    VfxHandler.WunboOrbies({
        j = 3, -- j (first loop)
        i = 3, -- i (second loop)
        StartPos = RootCFrame.Position, -- where the orbies originate
        Duration = 0.15, -- how long orbies last
        Width = 1, -- width (x,y) sizes
        Length = math.random(5, 10), -- length (z) size
        Color1 = Color3.fromRGB(170, 85, 255), -- color of half of the orbies, color2 is the other half
        Color2 = Color3.fromRGB(255, 255, 255), -- color of half of the orbies, color2 is the other half
        Distance = CFrame.new(0, 0, 50), -- how far the orbies travel
    })

    --[[ Rocks xD ]]
    --
    local Rocks = EffectParticles.ParticleAttatchments.Rocks:Clone()
    Rocks.Rocks.Size =
        NumberSequence.new({ NumberSequenceKeypoint.new(0, math.random(5, 10) / 10), NumberSequenceKeypoint.new(1, 0) })
    Rocks.Rocks.Drag = 5
    Rocks.Rocks.Rate = 100
    Rocks.Rocks.Acceleration = Vector3.new(0, -100, 0)
    Rocks.Rocks.Lifetime = NumberRange.new(1, 1.5)
    Rocks.Rocks.Speed = NumberRange.new(75, 100)
    Rocks.Parent = shock
    Rocks.Rocks:Emit(50)
    Debris:AddItem(Rocks, 2)
end
