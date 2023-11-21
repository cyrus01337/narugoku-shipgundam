--||Services||--
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
local Utility = Modules.Utility

local Effects = Modules.Effects
local Shared = Modules.Shared

local EffectMeshes = ReplicatedStorage.Assets.Effects.Meshes
local EffectParticles = ReplicatedStorage.Assets.Effects.Particles
local EffectBeams = ReplicatedStorage.Assets.Effects.Beams

local HitPart2 = Models.Misc.HitPart2

--|| Imports ||--
local SoundManager = require(Shared.SoundManager)
local RaycastManager = require(Shared.RaycastManager)

local RayService = require(Shared.RaycastManager.RayService)

local Explosions = require(Effects.Explosions)
local VfxHandler = require(Effects.VfxHandler)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

--||Remotes||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--||Variables||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local PlayerMouse = Player:GetMouse()

local Humanoid = Character:WaitForChild("Humanoid")

local KiritusuguVFX = {
    ["DoubleAccel"] = function(PathData)
        local Character = PathData.Character or nil
        local ContactPoint = PathData.ContactPoint

        for i = 1, 2 do
            VfxHandler.AfterImage({
                Character = Character,
                Duration = 0.25,
                StartTransparency = 0.5,
                Color = Color3.fromRGB(180, 40, 70),
            })
            wait(0.05)
        end

        -- SoundManager:AddSound("Dodge", {Parent = Character.HumanoidRootPart}, "Client")
    end,
    ["Heavyshot"] = function(Data) end,
}

return KiritusuguVFX
