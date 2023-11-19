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

local Rengoku = {
    ["FirstAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Sword = Character:FindFirstChild("RengokuSword")
        if not Sword then
            return
        end

        -- SoundManager:AddSound("FlameBurst2",{Parent = Root, Volume = 1},"Client")

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)

        --UnkowningFire,1
        AnimationRemote:FireClient(Player, "UnkowningFire", "Play", { AdjustSpeed = 0.85 })

        SpeedManager.changeSpeed(Character, 8, 1, 1)
        StateManager:ChangeState(Character, "Guardbroken", 1)

        wait(0.25)
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "RengokuVFX", Function = "WaterStuff", Duration = 0.35 }
        )
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "RengokuVFX", Function = "Trail", Sword = Sword, Duration = 0.6 }
        )

        CameraRemote:FireClient(Player, "CameraShake", { FirstText = 8, SecondText = 10 })

        HitboxModule.GetTouchingParts(
            Player,
            {
                Delay = 0.225,
                ExistTime = 2,
                Type = "Sword",
                Size = Vector3.new(8.999, 4.517, 38.5),
                Transparency = 1,
                PositionCFrame = Root.CFrame * CFrame.new(0, 0, -15),
            },
            KeyData.SerializedKey,
            CharacterName
        )

        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Parent = Root
        BodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
        BodyVelocity.Velocity = Root.CFrame.lookVector * 95
        Debris:AddItem(BodyVelocity, 0.3)

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "RengokuVFX", Function = "WaterSurfaceSlash", Sword = Sword }
        )

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

        local Sword = Character:FindFirstChild("RengokuSword")
        if not Sword then
            return
        end

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            {
                Character = Character,
                Module = "RengokuVFX",
                Function = "Trail",
                Sword = Sword,
                Duration = 0.75,
                Bubbles = "fdsf",
                TrailFloor = "sdfsf",
            }
        )
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "RengokuVFX", Function = "WaterStuff", Duration = 0.5 }
        )

        SpeedManager.changeSpeed(Character, 8, 1, 1)
        StateManager:ChangeState(Character, "Guardbroken", 1)

        -- SoundManager:AddSound("FlameBurst2",{Parent = HumanoidRootPart, Volume = 1},"Client")
        -- SoundManager:AddSound("FlameMagic",{Parent = HumanoidRootPart, Volume = 1},"Client")

        AnimationRemote:FireClient(Player, "ScorchingFlame", "Play")

        wait(0.55)
        HitboxModule.MagnitudeModule(
            Character,
            { Delay = 0, Range = 10, KeysLogged = 1, Type = "Sword" },
            KeyData.SerializedKey,
            CharacterName
        )
        CameraRemote:FireClient(Player, "CameraShake", { FirstText = 6, SecondText = 8 })

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "RengokuVFX", Function = "secondform" }
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

        local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")

        local Hum, Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
        local Sword = Character:FindFirstChild("RengokuSword")

        if not Sword then
            return
        end

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)

        AnimationRemote:FireClient(Player, "BlazingUniverse", "Play", { AdjustSpeed = 1.25 })

        local TimeEvaluation = os.clock() - PlayerCombo.LastPressed <= 0.8 and true or false
        local NumberEvaluation = (PlayerCombo.Hits < 5 and TimeEvaluation and PlayerCombo.Hits + 1)
            or (PlayerCombo.Hits > 5 and 1)
            or (not PlayerCombo.TimeEvaluation and 1)

        SpeedManager.changeSpeed(Character, 8, 1, 1)
        StateManager:ChangeState(Character, "Guardbroken", 0.8)

        wait(0.25)
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "RengokuVFX", Function = "WaterStuff", Duration = 0.2 }
        )
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "RengokuVFX", Function = "Trail", Sword = Sword, Duration = 0.5 }
        )

        CameraRemote:FireClient(Player, "CameraShake", { FirstText = 8, SecondText = 10 })
        PlayerCombo.KeysLogged = NumberEvaluation

        HitboxModule.GetTouchingParts(
            Player,
            {
                ExistTime = 2,
                Type = "Sword",
                KeysLogged = NumberEvaluation,
                Size = Vector3.new(8.999, 4.517, 31.284),
                Transparency = 1,
                PositionCFrame = Root.CFrame * CFrame.new(0, 0, -15),
            },
            KeyData.SerializedKey,
            CharacterName
        )

        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Parent = Root
        BodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
        BodyVelocity.Velocity = Root.CFrame.lookVector * 75
        Debris:AddItem(BodyVelocity, 0.3)

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "RengokuVFX", Function = "WaterSurfaceSlash", Sword = Sword }
        )
    end,

    ["FourthAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character

        local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")

        local Hum, Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
        local Sword = Character:FindFirstChild("RengokuSword")

        if not Sword then
            return
        end

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)

        SpeedManager.changeSpeed(Character, 3, 2.75, 80) -- (Character,Speed,Duration,Priority)

        AnimationRemote:FireClient(Player, "Striking Tide", "Play", { AdjustSpeed = 0.65 })
        StateManager:ChangeState(Character, "Guardbroken", 2.35)

        local TimeEvaluation = os.clock() - PlayerCombo.LastPressed <= 0.8 and true or false
        local NumberEvaluation = (PlayerCombo.Hits < 5 and TimeEvaluation and PlayerCombo.Hits + 1)
            or (PlayerCombo.Hits > 5 and 1)
            or (not PlayerCombo.TimeEvaluation and 1)

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            {
                Character = Character,
                Module = "RengokuVFX",
                Function = "Trail",
                Rate = 150,
                Sword = Sword,
                TextureLength = 3,
                Duration = 1.5,
            }
        )

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "RengokuVFX", Function = "Striking Tide" }
        )

        PlayerCombo.KeysLogged = NumberEvaluation
        for _ = 1, 2 do
            -- SoundManager:AddSound("SwordSwing", {Parent = Root, Volume = 2}, "Client")
            CameraRemote:FireClient(Player, "CameraShake", { FirstText = 4, SecondText = 6 })

            coroutine.wrap(function()
                local HitResult, HitObject = HitboxModule.MagnitudeModule(
                    Character,
                    { Range = 7, KeysLogged = PlayerCombo.KeysLogged, Type = "Sword" },
                    KeyData.SerializedKey,
                    CharacterName
                )
                if HitResult then
                    wait(0.125)
                    local Victim = HitObject.Parent
                    local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

                    local BodyVelocity = Instance.new("BodyVelocity")
                    BodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
                    BodyVelocity.Velocity = (VRoot.CFrame.p - Root.CFrame.p).Unit * 12
                    BodyVelocity.Parent = VRoot
                    Debris:AddItem(BodyVelocity, 0.25)
                end
            end)()

            local BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
            BodyVelocity.Velocity = Root.CFrame.lookVector * 35
            BodyVelocity.Parent = Root
            Debris:AddItem(BodyVelocity, 0.25)
            wait(0.335)
        end
        --	coroutine.resume(coroutine.create(function()
        wait(0.225)
        CameraRemote:FireClient(Player, "CameraShake", { FirstText = 8, SecondText = 10 })
        -- SoundManager:AddSound("FlameBurst2", {Parent = Root}, "Client")

        CameraRemote:FireClient(Player, "CreateBlur", {
            Size = 15,
            Length = 0.25,
        })

        CameraRemote:FireClient(Player, "TweenObject", {
            LifeTime = 0.15,
            EasingStyle = Enum.EasingStyle.Linear,
            EasingDirection = Enum.EasingDirection.Out,
            Return = true,
            Properties = { FieldOfView = 85 },
        })

        local TanjiroData = AbilityData.ReturnData(Player, "FourthAbility", "Tanjiro")

        local HitObject = HitboxModule.RaycastModule(
            Player,
            { Visualize = false, Size = 18, KeysLogged = PlayerCombo.KeysLogged, Type = "Sword" },
            KeyData.SerializedKey,
            CharacterName
        )
        if HitObject.Hit then
            local Victim = HitObject.Object.Parent
            local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

            TanjiroData.GuardBreak = true

            local BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
            BodyVelocity.Velocity = (VRoot.CFrame.p - Root.CFrame.p).Unit * 12
            BodyVelocity.Parent = VRoot
            Debris:AddItem(BodyVelocity, 0.25)
            DamageManager.DeductDamage(
                Character,
                Victim,
                KeyData.SerializedKey,
                CharacterName,
                { Type = ExtraData.Type }
            )

            TanjiroData.GuardBreak = false
        end

        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
        BodyVelocity.Velocity = Root.CFrame.lookVector * 50
        BodyVelocity.Parent = Root
        Debris:AddItem(BodyVelocity, 0.25)
    end,
}

return Rengoku
