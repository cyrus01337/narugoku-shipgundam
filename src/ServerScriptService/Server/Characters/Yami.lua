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

local Effects = Modules.Effects
local Shared = Modules.Shared
local Metadata = Modules.Metadata
local Utility = Modules.Utility

--|| Imports ||--
local VfxHandler = require(Effects.VfxHandler)

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

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.World.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

local Yami = {
    ["FirstAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        StateManager:ChangeState(Character, "Attacking", 2)

        local Velocity = 300
        local Lifetime = 5

        --[[ Fire Animation ]]
        --
        AnimationRemote:FireClient(Player, "AvidyaSlash", "Play")

        --[[ Slash Charge Up ]]
        --
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Distance = 100, Module = "YamiVFX", Function = "AvidyaSlashCharge" }
        )
        local Aiming = GlobalFunctions.NewInstance("BoolValue", { Parent = Character, Name = "Aiming" }, 2.5)

        local StartTime = os.clock()

        coroutine.resume(coroutine.create(function()
            while true do
                local SkillData = StateManager:ReturnData(Character, "LastSkill")
                if os.clock() - StartTime >= 2.25 or SkillData.Skill == "Swing" then
                    StartTime = os.clock()
                    break
                end
                RunService.Heartbeat:Wait()
            end
            local MouseHit = MouseRemote:InvokeClient(Player)

            local Slash = Assets.Effects.Meshes.YamiSlash

            local StartPoint = Root.CFrame * CFrame.new(0, 0, 1)
            local Points = RaycastManager:GetSquarePoints(StartPoint, Slash.Size.X * 2, Slash.Size.X * 2)

            local Direction = (MouseHit.Position - StartPoint.Position).Unit

            local StartPosition = Root.CFrame
            local Direction = (StartPosition.Position - MouseHit.Position).Unit

            local Points = RaycastManager:GetSquarePoints(StartPosition, 10, 10)

            RaycastManager:CastProjectileHitbox({
                Points = Points,
                Direction = Direction,
                Velocity = Velocity,
                Lifetime = Lifetime,
                Iterations = 50,
                Visualize = false,
                Function = function(RaycastResult)
                    local ValidEntities = RaycastManager:GetEntitiesFromPoint(
                        RaycastResult.Position,
                        workspace:GetChildren(),
                        { [Character] = true },
                        15
                    )
                    for Index = 1, #ValidEntities do
                        local Entity = ValidEntities[Index]
                        DamageManager.DeductDamage(
                            Character,
                            Entity,
                            KeyData.SerializedKey,
                            CharacterName,
                            { Type = "Sword" }
                        )
                    end
                end,
                Ignore = { Character, workspace.World.Visuals },
            })

            --[[ Slash Charge Up ]]
            --
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                {
                    Character = Character,
                    Module = "YamiVFX",
                    Function = "YamiSlash",
                    StartPoint = StartPoint,
                    MouseHit = MouseHit,
                    Lifetime = Lifetime,
                    Velocity = Velocity,
                    Distance = 100,
                    Direction = Direction,
                    Ponts = Points,
                }
            )
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                { Character = Character, Distance = 10, Module = "YamiVFX", Function = "YamiScreen" }
            )

            --[[ Shake ]]
            --
            CameraRemote:FireClient(Player, "CameraShake", {
                FirstText = 6,
                SecondText = 12,
            })
        end))

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
    end,

    ["SecondAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local HumanoidRootPart, Humanoid =
            Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)

        local Aiming = GlobalFunctions.NewInstance("BoolValue", { Parent = Character, Name = "Aiming" }, 3)

        --[[ Fire Animation ]]
        --
        AnimationRemote:FireClient(Player, "DarkBinding", "Play")

        --[[ Fire Yami Charge Up ]]
        --
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Distance = 100, Module = "YamiVFX", Function = "AvidyaSlashCharge" }
        )

        --[[ Fire Client ]]
        --
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Distance = 100, Module = "YamiVFX", Function = "DarkBinding" }
        )
        --[[ Screen Shake ]]
        --
        CameraRemote:FireClient(Player, "CameraShake", {
            FirstText = 6,
            SecondText = 12,
        })
    end,

    ["ThirdAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local HumanoidRootPart, Humanoid =
            Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        StateManager:ChangeState(Character, "ForceField", 4)

        local Force = GlobalFunctions.NewInstance("BoolValue", { Parent = Character, Name = "ForceField" }, 4)
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "BeatriceVFX", Function = "cast shield" }
        )

        --[[ Fire Client ]]
        --
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Distance = 100, Module = "YamiVFX", Function = "BlackCocoonStart" }
        )
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Distance = 10, Module = "YamiVFX", Function = "YamiScreen" }
        )

        StateManager:ChangeState(Character, "Attacking", 4)
        SpeedManager.changeSpeed(Character, 2, 4, 3.5)

        local function RemoveBall()
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                { Character = Character, Module = "BeatriceVFX", Function = "removbal" }
            )
            --[[ Fire Client ]]
            --
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                { Character = Character, Distance = 100, Module = "YamiVFX", Function = "BlackCocoonEnd" }
            )
            --
            CameraRemote:FireClient(Player, "CameraShake", { FirstText = 2, SecondText = 10 })
            CameraRemote:FireClient(Player, "AddGradient", { Type = "Remove", Length = 0.75 })
            CameraRemote:FireClient(Player, "TweenObject", {
                LifeTime = 0.225,
                EasingStyle = Enum.EasingStyle.Linear,
                EasingDirection = Enum.EasingDirection.Out,
                Return = true,
                Properties = { FieldOfView = 120 },
            })
            StateManager:ChangeState(Character, "Attacking", 0.1)
            SpeedManager.changeSpeed(Character, 2, 0.01, 4.5)
            StateManager:ChangeState(Character, "IFrame", 0.35, { IFrameType = "" })
        end

        AnimationRemote:FireClient(Player, "betricbarrier", "Play")

        CameraRemote:FireClient(Player, "AddGradient", { Type = "Add", Length = 0.75 })

        coroutine.resume(coroutine.create(function()
            while Character:FindFirstChild("ForceField") and Player do
                local SkillData = StateManager:ReturnData(Character, "LastSkill")
                RunService.Heartbeat:Wait()
                if SkillData.Skill == "Swing" then
                    AnimationRemote:FireClient(Player, "betricbarrier", "Stop")
                    Force:Destroy()
                    break
                end
            end
            RemoveBall()
        end))

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
    end,

    ["FourthAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        StateManager:ChangeState(Character, "Attacking", 2)

        local Velocity = 300
        local Lifetime = 0.75

        --[[ Fire Animation ]]
        --
        AnimationRemote:FireClient(Player, "AvidyaSlash", "Play")

        --[[ Screen 2 for Yami ]]
        --
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Distance = 10, Module = "YamiVFX", Function = "YamiScreen2" }
        )

        --[[ Slash Charge Up ]]
        --
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Distance = 100, Module = "YamiVFX", Function = "DimensionCharge" }
        )
        for i = 1, 3 do
            --[[ Shake ]]
            --
            CameraRemote:FireClient(Player, "CameraShake", {
                FirstText = 3,
                SecondText = 6,
            })
            wait(0.67)
            if i == 2 then
                NetworkStream.FireClientDistance(
                    Character,
                    "ClientRemote",
                    200,
                    { Character = Character, Distance = 10, Module = "YamiVFX", Function = "YamiScreen" }
                )
            end
        end
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            {
                Character = Character,
                Distance = 100,
                Module = "YamiVFX",
                Velocity = Velocity,
                Lifetime = Lifetime,
                Function = "DimensionSlash",
            }
        )

        --[[ Shake ]]
        --
        CameraRemote:FireClient(Player, "CameraShake", {
            FirstText = 8,
            SecondText = 12,
        })

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
    end,
}

return Yami
