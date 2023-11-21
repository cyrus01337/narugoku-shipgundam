--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Directories ||--
local Server = ServerScriptService.Server

local Managers = Server.Managers

local Modules = ReplicatedStorage.Modules
local State = Server.State
local Managers = Server.Managers

local Effects = Modules.Effects
local Shared = Modules.Shared
local Metadata = Modules.Metadata
local Utility = Modules.Utility

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local VfxHandler = require(Effects.VfxHandler)

local AbilityData = require(Metadata.AbilityData.AbilityData)

local DebounceManager = require(State.DebounceManager)

local DamageManager = require(Managers.DamageManager)

local NetworkStream = require(Utility.NetworkStream)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)

local RotatedRegion3 = require(Shared.RotatedRegion3)
local SoundManager = require(Shared.SoundManager)

local HitboxModule = require(script.Parent.Parent.Combat.Combat.HitboxModule)

local RaycastManager = require(Shared.RaycastManager)

--|| Remote ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote
local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

--|| Functions ||--
local function GetMouseTarget(Target, Character)
    if Target:IsA("BasePart") and not Target:IsDescendantOf(Character) and GlobalFunctions.IsAlive(Target.Parent) then
        return true, Target.Parent
    end
end

local Tanjiro = {
    ["FirstAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character

        local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")

        local Hum, Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
        local Sword = Character:FindFirstChild("TanjiroSword")

        if not Sword then
            return
        end

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)

        AnimationRemote:FireClient(Player, "WaterSurfaceSlash", "Play", { AdjustSpeed = 1.25 })

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
            { Character = Character, Module = "TanjiroVFX", Function = "WaterStuff", Duration = 0.2 }
        )
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "TanjiroVFX", Function = "Trail", Sword = Sword, Duration = 0.5 }
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
            { Character = Character, Module = "TanjiroVFX", Function = "WaterSurfaceSlash", Sword = Sword }
        )
    end,

    ["ThirdAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character

        local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")

        local Hum, Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
        local Sword = Character:FindFirstChild("TanjiroSword")

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)

        local NotificationMainText = " in air"

        local TimeEvaluation = os.clock() - PlayerCombo.LastPressed <= 0.8 and true or false
        local NumberEvaluation = (PlayerCombo.Hits < 5 and TimeEvaluation and PlayerCombo.Hits + 1)
            or (PlayerCombo.Hits > 5 and 1)
            or (not PlayerCombo.TimeEvaluation and 1)

        AnimationRemote:FireClient(Player, "Whirlpool", "Play", { AdjustSpeed = 0.75 })
        delay(0.125, function()
            AnimationRemote:FireClient(Player, "WhirlPool", "Play", { AdjustSpeed = 2 })
        end)

        SpeedManager.changeSpeed(Character, 3, 1, 4) -- (Character,Speed,Duration,Priority)
        StateManager:ChangeState(Character, "Guardbroken", 0.75)

        wait(0.375)
        if StateManager:Peek(Character, "Stunned") then
            return
        end

        NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {
            Character = Character,
            Module = "TanjiroVFX",
            Function = "Whirlpool",
            Distance = 80,
            ContactPointCFrame = Root.CFrame,
        })

        CameraRemote:FireClient(Player, "TweenObject", {
            LifeTime = 0.225,
            EasingStyle = Enum.EasingStyle.Linear,
            EasingDirection = Enum.EasingDirection.Out,
            Return = true,
            Properties = { FieldOfView = 100 },
        })

        task.spawn(function()
            wait(0.2)
            CameraRemote:FireClient(Player, "CameraShake", {
                FirstText = 6,
                SecondText = 8,
            })
        end)

        local PlaceToGo = ReplicatedStorage.Assets.Models.Misc.BP:Clone()
        PlaceToGo.CFrame = Root.CFrame * CFrame.new(0, 15, 0)
        PlaceToGo.Parent = workspace.World.Visuals

        local BodyPosition = Instance.new("BodyPosition")
        BodyPosition.Position = PlaceToGo.Position
        BodyPosition.MaxForce = Vector3.new(500, 500, 500) * 12500
        BodyPosition.Parent = Root

        Debris:AddItem(PlaceToGo, 0.05)
        Debris:AddItem(BodyPosition, 1.5)

        local HitResult, ValidEntities = HitboxModule.GetTouchingParts(
            Player,
            {
                ExistTime = 2,
                Type = "Sword",
                KeysLogged = NumberEvaluation,
                Size = Vector3.new(30, 60, 30),
                Transparency = 1,
                PositionCFrame = Root.CFrame,
            },
            KeyData.SerializedKey,
            CharacterName
        )
        if HitResult then
            for Index = 1, #ValidEntities do
                local Victim = ValidEntities[Index]

                StateManager:ChangeState(Victim, "Stunned", 1.35)
                StateManager:ChangeState(Character, "IFrame", 1)

                local VHumanoid = Victim:FindFirstChild("Humanoid")
                local VRoot = Victim:FindFirstChild("HumanoidRootPart")

                local PlaceToGo = ReplicatedStorage.Assets.Models.Misc.BP:Clone()
                PlaceToGo.CFrame = Root.CFrame * CFrame.new(0, 15, 0)
                PlaceToGo.Parent = workspace.World.Visuals

                local BodyPosition = Instance.new("BodyPosition")
                BodyPosition.Position = PlaceToGo.Position
                BodyPosition.MaxForce = Vector3.new(500, 500, 500) * 12500
                BodyPosition.Parent = Root

                Debris:AddItem(PlaceToGo, 0.05)
                Debris:AddItem(BodyPosition, 1.5)

                local PlaceToGo = ReplicatedStorage.Assets.Models.Misc.BP:Clone()
                PlaceToGo.CFrame = VRoot.CFrame * CFrame.new(0, 15, 3)
                PlaceToGo.Parent = workspace.World.Visuals

                local BodyPosition = Instance.new("BodyPosition")
                BodyPosition.Position = PlaceToGo.Position
                BodyPosition.MaxForce = Vector3.new(500, 500, 500) * 12500
                BodyPosition.Parent = VRoot

                Debris:AddItem(PlaceToGo, 0.05)
                Debris:AddItem(BodyPosition, 1.5)

                VfxHandler.FaceVictim({ Character = Character, Victim = Victim })
                local PlaceToGo = ReplicatedStorage.Assets.Models.Misc.BP:Clone()
                PlaceToGo.CFrame = Root.CFrame * CFrame.new(0, 15, 0)
                PlaceToGo.Parent = workspace.World.Visuals

                local BodyPosition = Instance.new("BodyPosition")
                BodyPosition.Position = PlaceToGo.Position
                BodyPosition.MaxForce = Vector3.new(500, 500, 500) * 12500
                BodyPosition.Parent = Root

                Debris:AddItem(PlaceToGo, 0.05)
                Debris:AddItem(BodyPosition, 1.5)

                local PlaceToGo = ReplicatedStorage.Assets.Models.Misc.BP:Clone()
                PlaceToGo.CFrame = VRoot.CFrame * CFrame.new(0, 15, 3)
                PlaceToGo.Parent = workspace.World.Visuals

                local BodyPosition = Instance.new("BodyPosition")
                BodyPosition.Position = PlaceToGo.Position
                BodyPosition.MaxForce = Vector3.new(500, 500, 500) * 12500
                BodyPosition.Parent = VRoot

                Debris:AddItem(PlaceToGo, 0.05)
                Debris:AddItem(BodyPosition, 1.5)

                VfxHandler.FaceVictim({ Character = Character, Victim = Victim })

                wait(0.3)
                for _ = 1, 3 do
                    DamageManager.DeductDamage(
                        Character,
                        Victim,
                        KeyData.SerializedKey,
                        CharacterName,
                        { Type = ExtraData.Type, KeysLogged = NumberEvaluation }
                    )
                    wait(0.135)
                end
            end
        end

        --[[if StateManager:Peek(Character,"InAir") then warn("must be in air to use this skill!")
			GUIRemote:FireClient(Player,"Notification",{
				Function = "Initiate",
				Player = Player,
				Color = Color3.new(1,0,0),
				Text = ("You must be <font color= 'rgb(%s, %s, %s)'>&lt; "..NotificationMainText.."&gt;</font> to use whirpool")
			})
			return 
		end	 ]]
    end,

    ["FourthAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character

        local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")

        local Hum, Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
        local Sword = Character:FindFirstChild("TanjiroSword")

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
                Module = "TanjiroVFX",
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
            { Character = Character, Module = "TanjiroVFX", Function = "Striking Tide" }
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
        -- SoundManager:AddSound("WaterPlayerSlash", {Parent = Root}, "Client")

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

    ["SecondAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character

        local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")

        local Hum, Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
        local Sword = Character:FindFirstChild("TanjiroSword")

        if not Sword then
            return
        end

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)

        AnimationRemote:FireClient(Player, "WaterWheel", "Play", { AdjustSpeed = 2 })
        SpeedManager.changeSpeed(Character, 3, 1, 1)
        StateManager:ChangeState(Character, "Guardbroken", 0.8)

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "TanjiroVFX", Function = "Trail", Sword = Sword, Duration = 0.9 }
        )

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "TanjiroVFX", Function = "WaterStuff", Amount = 17 }
        )

        local TimeEvaluation = os.clock() - PlayerCombo.LastPressed <= 0.8 and true or false
        local NumberEvaluation = (PlayerCombo.Hits < 5 and TimeEvaluation and PlayerCombo.Hits + 1)
            or (PlayerCombo.Hits > 5 and 1)
            or (not PlayerCombo.TimeEvaluation and 1)

        wait(0.2)
        PlayerCombo.KeysLogged = NumberEvaluation
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "TanjiroVFX", Function = "WaterWheel", Sword = Sword, Duration = 0.5 }
        )

        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(4e4, 0, 4e4)
        BodyVelocity.Name = "fdfsfdsfsdfszxzzdxfzf"
        BodyVelocity.Parent = Root
        Debris:AddItem(BodyVelocity, 0.6)

        coroutine.wrap(function()
            wait(0.125)
            CameraRemote:FireClient(Player, "CameraShake", { FirstText = 6, SecondText = 8 })

            wait(0.125)
            local HitResult, ValidEntities = HitboxModule.GetTouchingParts(
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
            if HitResult then
                for Index = 1, #ValidEntities do
                    local Victim = ValidEntities[Index]
                    local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

                    NetworkStream.FireClientDistance(
                        Character,
                        "ClientRemote",
                        200,
                        {
                            Character = Character,
                            Module = "TanjiroVFX",
                            Function = "WaterWheelHit",
                            Victim = Victim,
                            Distance = 30,
                        }
                    )

                    if not StateManager:Peek(Character, "InAir") then
                        VfxHandler.RemoveBodyMover(Victim)
                        VRoot.CFrame = VRoot.CFrame * CFrame.new(0, -12, 12)
                    end

                    VfxHandler.RemoveBodyMover(Character)
                    -- SoundManager:AddSound("WaterImpact",{Volume = 2, Parent = Root}, "Client")
                end
            end
        end)()

        -- SoundManager:AddSound("WaterPlayerSlash", {Parent = Root}, "Client")

        while BodyVelocity and RunService.Stepped:Wait() do
            BodyVelocity.Velocity = Root.CFrame.LookVector * 80
            if Root:FindFirstChild("fdfsfdsfsdfszxzzdxfzf") == nil then
                break
            end
        end
    end,
}

return Tanjiro
