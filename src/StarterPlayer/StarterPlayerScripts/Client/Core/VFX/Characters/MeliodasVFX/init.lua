--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Lighting = game:GetService("Lighting")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Shared = Modules.Shared
local Utility = Modules.Utility

local EffectMeshes = ReplicatedStorage.Assets.Effects.Meshes
local EffectParticles = ReplicatedStorage.Assets.Effects.Particles
local EffectBeams = ReplicatedStorage.Assets.Effects.Beams

local World = workspace.World
local Visuals = World.Visuals

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(Shared.SoundManager)
local RaycastService = require(Shared.RaycastManager)

local Explosions = require(Modules.Effects.Explosions)
local VfxHandler = require(Modules.Effects.VfxHandler)
local CameraShaker = require(Modules.Effects.CameraShaker)

local BezierModule = require(Modules.Utility.BezierModule)
--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Mouse = Player:GetMouse()

local Camera = workspace.CurrentCamera

local CurrentCamera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
    CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
end)

local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local Humanoid = Character:WaitForChild("Humanoid")

local MeliodasVFX = {

    ["Hellblaze"] = function(Data)
        local Character = Data.Character
        local Root = Character:FindFirstChild("HumanoidRootPart")

        local hieifire = EffectParticles.hieifire:Clone()

        local StartPosition = Root.Position
        local EndPosition = Data.MouseHit.Position

        --[[ Setpath Properties ]]
        --
        local Magnitude = (StartPosition - EndPosition).Magnitude
        local Midpoint = (StartPosition - EndPosition) / 2

        local PointA = CFrame.new(CFrame.new(StartPosition) * (Midpoint / -1.5)).Position -- first 25% of the path
        local PointB = CFrame.new(CFrame.new(EndPosition) * (Midpoint / 1.5)).Position -- last 25% of the path

        local Offset = Magnitude / 2
        PointA = PointA + Vector3.new(math.random(-Offset, Offset), math.random(5, 15), math.random(-Offset, Offset))
        PointB = PointB + Vector3.new(math.random(-Offset, Offset), math.random(5, 15), math.random(-Offset, Offset))

        --[[ Position the Hand ]]
        --
        hieifire.Parent = Visuals
        hieifire.Attachment.ParticleEmitter.Rate = 500
        hieifire.Position = StartPosition
        hieifire.Attachment2.TrailTing.Lifetime = 0.25
        --[[ Lerp the Path ]]
        --
        local Speed = 4
        for i = 1, Magnitude, Speed do
            local Percent = i / Magnitude
            local Coordinate = BezierModule:cubicBezier(Percent, StartPosition, PointA, PointB, EndPosition)
            hieifire.CFrame = hieifire.CFrame:Lerp(CFrame.new(Coordinate, EndPosition), Percent)
            RunService.Heartbeat:Wait()
        end
        hieifire.Attachment.ParticleEmitter.Enabled = false
        hieifire.Attachment.ParticleEmitter.Size =
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(1, 4) })
        hieifire.Attachment.Stars.Enabled = false
        hieifire.Attachment.Waves.Enabled = false
        Debris:AddItem(hieifire, 1)
        require(script.Explosion)({
            RootCFrame = hieifire.CFrame,
            Filter = { Character, World.Live, Visuals },
        })
    end,
}

return MeliodasVFX
