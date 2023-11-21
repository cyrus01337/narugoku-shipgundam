--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Shared = Modules.Shared
local Utility = Modules.Utility

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(Shared.SoundManager)

local TaskScheduler = require(Utility.TaskScheduler)

local Explosions = require(Modules.Effects.Explosions)
local VfxHandler = require(Modules.Effects.VfxHandler)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local Humanoid = Character:WaitForChild("Humanoid")

local EffectMeshes = ReplicatedStorage.Assets.Effects.Meshes
local EffectParticles = ReplicatedStorage.Assets.Effects.Particles
local EffectBeams = ReplicatedStorage.Assets.Effects.Beams
local World = workspace.World
local Visuals = World.Visuals
local Live = World.Live

local HieiMode = {
    ["Transformation"] = function(Data)
        local Character = Data.Character
        local Root = Character:FindFirstChild("HumanoidRootPart")
    end,

    ["DragonTransformation"] = function(Data)
        local Character = Data.Character
        local Root = Character:FindFirstChild("HumanoidRootPart")
    end,

    ["ShadowStep"] = function(Data)
        local Character = Data.Character
        local Root = Character:FindFirstChild("HumanoidRootPart")

        --[[ Flying Debris Rock ]]
        --
        VfxHandler.FlyingRocks({
            i = 2, -- first loop
            j = 5, -- nested loop
            Offset = 5, -- radius from starting pos
            Origin = Root.Position, -- where to start
            Filter = { Character, Live, Visuals }, -- filter raycast
            Size = Vector2.new(1, 3), -- size range random from 1,3
            AxisRange = 80, -- velocity X and Z ranges from (-AxisRange,AxisRange)
            Height = Vector2.new(25, 40), -- velocity Y ranges from X,Y
            Percent = 0.5, -- velocity * percent of nested loop
            Duration = 2, -- duration of the debris rock
            IterationDelay = 0, -- delay between each i loop
        })

        --[[ Crater on Ground ]]
        --
        VfxHandler.Rockszsz({
            Cframe = CFrame.new(Root.Position), -- Position
            Amount = 10, -- How manay rocks
            Iteration = 10, -- Expand
            Max = 2, -- Length upwards
            FirstDuration = 0.25, -- Rock tween outward start duration
            RocksLength = 2, -- How long the rocks stay for
        })
        --//
        local Block = EffectMeshes.Block:Clone()
        Block.Anchored = true
        Block.Size = Vector3.new(0, 0, 0)
        Block.CanCollide = false
        Block.Anchored = true
        Block.CFrame = Root.CFrame
        Block.Parent = Visuals
        Debris:AddItem(Block, 1.5)

        --[[ Wunbo Orbies ]]
        --
        VfxHandler.WunboOrbies({
            j = 4, -- j (first loop)
            i = 6, -- i (second loop)
            StartPos = Root.Position, -- where the orbies originate
            Duration = 0.15, -- how long orbies last
            Width = 1, -- width (x,y) sizes
            Length = 5, -- length (z) size
            Color1 = Color3.fromRGB(255, 255, 255), -- color of half of the orbies, color2 is the other half
            Color2 = Color3.fromRGB(0, 0, 0), -- color of half of the orbies, color2 is the other half
            Distance = CFrame.new(0, 0, 25), -- how far the orbies travel
        })

        local CrashSmoke = EffectParticles.CrashSmoke:Clone()
        CrashSmoke.Parent = Visuals
        CrashSmoke.CanCollide = false
        CrashSmoke.Position = Root.Position
        CrashSmoke.Smoke.Size =
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 5), NumberSequenceKeypoint.new(1, 5) })
        CrashSmoke.Size = Vector3.new(15, 0, 15)
        CrashSmoke.Smoke:Emit(80)
        CrashSmoke.Anchored = true

        Debris:AddItem(CrashSmoke, 3)
        --//
        local Fire = EffectParticles.Hiei:Clone()
        local Attachment = Instance.new("Attachment")
        Attachment.Parent = Root
        Fire.Cremation.Parent = Attachment
        Attachment.Cremation.Name = "Fire"
        Fire:Destroy()

        Attachment.Fire.Speed = NumberRange.new(55, 75)
        Attachment.Fire.Drag = 5

        Attachment.Fire.Lifetime = NumberRange.new(0.25, 0.4)
        Attachment.Fire.Size =
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 5), NumberSequenceKeypoint.new(1, 0) })
        Attachment.Fire.Acceleration = Vector3.new(0, 0, 0)
        Attachment.Fire.Rate = 200
        Attachment.Fire.Enabled = true
        Attachment.Fire:Emit(50)
        wait(0.1)
        Attachment.Fire.Enabled = false
        Attachment.Fire:Emit(50)
        Debris:AddItem(Attachment, 1)
        wait(0.9)
        CrashSmoke.Smoke.Enabled = false
    end,
}

return HieiMode
