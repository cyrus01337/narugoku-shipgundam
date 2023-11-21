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
local Effects = ReplicatedStorage.Assets.Effects

local Metadata = Modules.Metadata
local Shared = Modules.Shared
local Utility = Modules.Utility

local HitPart2 = Models.Misc.HitPart2

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(Shared.SoundManager)
local RaycastService = require(Shared.RaycastManager)

local TaskScheduler = require(Utility.TaskScheduler)

local Explosions = require(Modules.Effects.Explosions)
local VfxHandler = require(Modules.Effects.VfxHandler)
local CameraShaker = require(Modules.Effects.CameraShaker)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--||Assets||--
local ShortFlashStep = Effects.Particles.skinnyflashstep
local FatFlashStep = Effects.Particles.fatflashstep

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

local Humanoid = Character:WaitForChild("Humanoid")

local function RemoveTrash(Trash)
    for i = 1, #Trash do
        local Item = Trash[i]
        if Item and Item.Parent then
            Item:Destroy()
        end
    end
end

local ShunsuiVFX = {
    ["Shunpo"] = function(PathData)
        local Character = PathData.Character

        local Steps = PathData.ShunpoDuration or 0.2
        local Images = PathData.Images or 9

        local Humanoid = Character:WaitForChild("Humanoid")

        VfxHandler.AfterImage({
            Character = Character,
            Duration = 1,
            StartTransparency = 0.2,
            Color = Color3.fromRGB(0, 0, 0),
        })

        --wait(.2)
        for Index = 1, Images do
            if Humanoid.WalkSpeed < 50 then
                VfxHandler.AfterImage({
                    Character = Character,
                    Duration = 1,
                    StartTransparency = 0.2,
                    Color = Color3.fromRGB(0, 0, 0),
                })
                break
            end

            --if Humanoid.WalkSpeed < 50 then break end

            local ShortClone = ShortFlashStep.Attachment.ParticleEmitter:Clone()
            local FatClone = FatFlashStep.Attachment.ParticleEmitter:Clone()

            FatClone.Enabled = true

            print("run")
            ShortClone.Parent = Character:FindFirstChild("HumanoidRootPart")
            FatClone.Parent = Character:FindFirstChild("HumanoidRootPart")

            Debris:AddItem(ShortClone, 0.3)
            Debris:AddItem(FatClone, 0.3)

            if Index == 8 then
                VfxHandler.AfterImage({
                    Character = Character,
                    Duration = 1,
                    StartTransparency = 0.2,
                    Color = Color3.fromRGB(0, 0, 0),
                })
            end
            wait(Steps / Images)
        end
    end,
}

return ShunsuiVFX
