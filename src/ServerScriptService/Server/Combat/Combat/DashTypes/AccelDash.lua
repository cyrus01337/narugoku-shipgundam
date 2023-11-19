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

--|| Remotes ||--
local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote

--|| Modules ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(Shared.SoundManager)
local StateManager = require(Shared.StateManager)

local NetworkStream = require(Utility.NetworkStream)

local VfxHandler = require(Effects.VfxHandler)

--|| Variables ||--
local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.World.Visuals }
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

return function(Character, ExtraData, MoveData, DashCopy)
    local Player = Players:GetPlayerFromCharacter(Character)

    local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
    local MoveDirection = Humanoid.MoveDirection

    local DirectionKey = ExtraData.DirectionKey

    local DashingForce = DashCopy.DashingForce

    if not DashCopy.CanDash then
        return
    end
end
