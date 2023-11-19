--|| Services ||--
local Players = game:GetService("Players")

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Directories ||--
local Server = ServerScriptService.Server

local Managers = Server.Managers

local Modules = ReplicatedStorage.Modules
local Assets = ReplicatedStorage.Assets

local HitboxModule = require(script.Parent.Parent.Combat.Combat.HitboxModule)

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

local SoundManager = require(Shared.SoundManager)

local RaycastManager = require(Shared.RaycastManager)
local TaskScheduler = require(Utility.TaskScheduler)

local Ragdoll = require(ServerStorage.Modules.Ragdoll)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

local Whitebeard = {
    ["FirstAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        --[[ Fire Animation ]]
        --
        AnimationRemote:FireClient(Player, "GuraPunch", "Play")

        --[[ Fire Cero Client ]]
        --
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Distance = 100, Module = "WhitebeardVFX", Function = "QuakePunch" }
        )
        wait(0.35)
        CameraRemote:FireClient(Player, "CameraShake", { FirstText = 3, SecondText = 15 })

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
    end,

    ["SecondAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")

        local Target = ExtraData.Target

        if PlayerCombo.KeysLogged >= 3 then
            local HitResult, HitObject = HitboxModule.MagnitudeModule(
                Character,
                { SecondType = "Choke", Range = 5, KeysLogged = PlayerCombo.KeysLogged, Type = "Combat" },
                KeyData.SerializedKey,
                CharacterName
            )
            if HitResult then
                StateManager:ChangeState(Character, "Attacking", 3.5)
                local Victim = HitObject.Parent
                local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

                StateManager:ChangeState(Victim, "Stunned", 5)

                local Animator = VHum:FindFirstChildOfClass("Animator")
                AnimationRemote:FireClient(Player, "GuraGrab", "Play")

                local Weld = Instance.new("Weld")
                Weld.Part0 = Character["Left Arm"]
                Weld.Part1 = Victim["Head"]
                Weld.Parent = Victim["Head"]

                Debris:AddItem(Weld, 3.5)

                --[[ Lighting Screen Effects ]]
                --

                Hum.AutoRotate = false
                Root.Anchored = true
                coroutine.resume(coroutine.create(function()
                    wait(2.15)
                    for i = 1, 2 do
                        NetworkStream.FireClientDistance(
                            Character,
                            "ClientRemote",
                            5,
                            {
                                Character = Character,
                                Distance = 100,
                                Victim = Victim,
                                Module = "NatsuVFX",
                                Function = "NatsuScreen",
                            }
                        )
                        wait(0.75)
                    end
                    --wait(1.35)
                    Hum.AutoRotate = true
                    Root.Anchored = false
                end))

                if Animator then
                    local Animation = Animator:LoadAnimation(
                        ReplicatedStorage.Assets.Animations.Shared.Characters.Whitebeard.GuraGrabVictim
                    )
                    Animation:Play()
                end

                NetworkStream.FireClientDistance(
                    Character,
                    "ClientRemote",
                    200,
                    {
                        Character = Character,
                        Distance = 200,
                        Victim = Victim,
                        Module = "WhitebeardVFX",
                        Function = "HelmetSplitter",
                    }
                )

                CameraRemote:FireClient(
                    Player,
                    "ChangeUICooldown",
                    { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
                )
                DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            end
        end
    end,

    ["ThirdAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local HumanoidRootPart, Humanoid =
            Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

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

return Whitebeard
