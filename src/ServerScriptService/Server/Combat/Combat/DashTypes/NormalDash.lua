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

    VfxHandler.RemoveBodyMover(Character)

    local SkillData = StateManager:ReturnData(Character, "LastSkill")

    MoveDirection = Vector3.new(0, 0, 0) and (Root.CFrame.lookVector * 1) or MoveDirection
    local AnimationDirection = DirectionKey == "W" and "FrontDash"
        or DirectionKey == "A" and "LeftDash"
        or DirectionKey == "D" and "RightDash"
        or "BackDash"

    if
        StateManager:Peek(Character, "Emoting") and not StateManager:Peek(Character, "Blocking")
        or StateManager:Peek(Character, "Running")
        or not (SkillData.Skill == "Swing")
    then
        AnimationRemote:FireClient(Player, AnimationDirection, "Play")
        task.delay(0.45, function()
            AnimationRemote:FireClient(Player, AnimationDirection, "Stop")
        end)
    end

    NetworkStream.FireClientDistance(
        Character,
        "ClientRemote",
        150,
        { Character = Character, Module = "PlayerClient", Function = "Dash" }
    )

    local MoveDirection = Humanoid.MoveDirection
    local DashingForce = 40 -- change this according to player's speed (if running, higher = more dramatic dash, etc...)
    if MoveDirection == Vector3.new(0, 0, 0) then
        MoveDirection = Root.CFrame.LookVector * 1
    end

    local BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
    BodyVelocity.Velocity = CFrame.new(Root.CFrame.Position, MoveDirection + Root.CFrame.Position).LookVector
        * DashingForce
    BodyVelocity.Parent = Root
    Debris:AddItem(BodyVelocity, 0.25)
end
