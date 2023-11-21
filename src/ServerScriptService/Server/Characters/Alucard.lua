--||Services||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--||Directories||--
local Server = ServerScriptService.Server

local Managers = Server.Managers

local Modules = ReplicatedStorage.Modules
local Assets = ReplicatedStorage.Assets

local State = Server.State

local Shared = Modules.Shared
local Metadata = Modules.Metadata
local Utility = Modules.Utility

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local AbilityData = require(Metadata.AbilityData.AbilityData)

local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)

local DamageManager = require(Managers.DamageManager)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)

local RotatedRegion3 = require(Shared.RotatedRegion3)
local SoundManager = require(Shared.SoundManager)

local HitboxModule = require(script.Parent.Parent.Combat.Combat.HitboxModule)

local RaycastManager = require(Shared.RaycastManager)

--||Remotes||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

local Alucard = {
    ["FirstAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        AnimationRemote:FireClient(Player, "Multishot", "Play", { Looped = false })

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "AlucardVFX", Function = "Multishot" }
        )

        local Velocity = 200
        local Lifetime = 5

        local Mesh = Assets.Models.Misc.Bullet
        local Size = Mesh.Size

        local LastArm = "Right Arm"

        local Mouse = MouseRemote:InvokeClient(Player)

        for _ = 1, 8 do
            CameraRemote:FireClient(Player, "CameraShake", { FirstText = 4, SecondText = 3.5 })

            local ArmEvaluation = LastArm == "Right Arm" and "Left Arm" or (LastArm == "Left Arm" and "Right Arm")

            local CFrameEvaluation = ArmEvaluation == "Right Arm" and CFrame.new(2, 0, -3) or CFrame.new(-2, 0, -3)
            local StartPoint = Character.HumanoidRootPart.CFrame * CFrameEvaluation
            local EndPoint = StartPoint * CFrame.new(0, 0, -10)

            local Points = RaycastManager:GetSquarePoints(StartPoint, Size.X * 2, Size.X * 2)

            RaycastManager:CastProjectileHitbox({
                Points = Points,
                Direction = (EndPoint.Position - StartPoint.Position).Unit,
                Velocity = Velocity,
                Lifetime = Lifetime,
                Iterations = 50,
                Visualize = false,
                Function = function(RaycastResult)
                    local Target = RaycastResult.Instance
                    if
                        Target
                        and Target:IsA("BasePart")
                        and not Target:IsDescendantOf(Character)
                        and GlobalFunctions.IsAlive(Target.Parent)
                    then
                        DamageManager.DeductDamage(Character, Target.Parent, KeyData.SerializedKey, CharacterName)
                    end
                end,
                Ignore = { Character, workspace.World.Visuals },
            })
            LastArm = LastArm == "Right Arm" and "Left Arm" or "Right Arm"
            wait(0.1)
        end

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
    end,

    ["SecondAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        AnimationRemote:FireClient(Player, "Heavyshot", "Play")
        CameraRemote:FireClient(Player, "CameraShake", { FirstText = 3, SecondText = 2.5 })

        local Velocity = 200
        local Lifetime = 5

        local Mesh = Assets.Models.Misc.Bullet
        local Size = Mesh.Size

        local LastArm = "Right Arm"

        local Mouse = MouseRemote:InvokeClient(Player)

        local StartPoint = Character.HumanoidRootPart.CFrame * CFrame.new(2, 0, -3)
        local EndPoint = StartPoint * CFrame.new(0, 0, -10)

        local Points = RaycastManager:GetSquarePoints(StartPoint, Size.X * 2, Size.X * 2)

        wait(0.5)

        RaycastManager:CastProjectileHitbox({
            Points = Points,
            Direction = (EndPoint.Position - StartPoint.Position).Unit,
            Velocity = Velocity,
            Lifetime = Lifetime,
            Iterations = 50,
            Visualize = false,
            Function = function(RaycastResult)
                local Target = RaycastResult.Instance
                if
                    Target
                    and Target:IsA("BasePart")
                    and not Target:IsDescendantOf(Character)
                    and GlobalFunctions.IsAlive(Target.Parent)
                then
                    DamageManager.DeductDamage(Character, Target.Parent, KeyData.SerializedKey, CharacterName)
                end
            end,
            Ignore = { Character, workspace.World.Visuals },
        })

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "AlucardVFX", Function = "Heavyshot" }
        )
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            10,
            { Character = Character, Distance = 10, Module = "NatsuVFX", Function = "NatsuScreen" }
        )

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
    end,

    ["ThirdAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
    end,

    ["FourthAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
    end,
}

return Alucard
