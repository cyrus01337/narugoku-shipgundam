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

local HitboxModule = require(script.Parent.Parent.Combat.Combat.HitboxModule)

local RaycastManager = require(Shared.RaycastManager)
local TaskScheduler = require(Utility.TaskScheduler)

local Ragdoll = require(ServerStorage.Modules.Ragdoll)

local World = workspace.World

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

local CreateFrameData = {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    Color = Color3.fromRGB(255, 221, 82),
    Duration = 0.5,
}

local function RaycastTarget(Radius, Character)
    local MouseHit = MouseRemote:InvokeClient(Players:GetPlayerFromCharacter(Character))

    local Root = Character:FindFirstChild("HumanoidRootPart")

    local RayParam = RaycastParams.new()
    RayParam.FilterDescendantsInstances = { Character, workspace.World.Visuals }
    RayParam.FilterType = Enum.RaycastFilterType.Exclude

    local RaycastResult = workspace:Raycast(Root.Position, (MouseHit.Position - Root.Position).Unit * Radius, RayParam)
        or {}
    local Target, Position = RaycastResult.Instance, RaycastResult.Position

    if Target and Target:FindFirstAncestorWhichIsA("Model"):FindFirstChild("Humanoid") then
        local Victim = Target:FindFirstAncestorWhichIsA("Model")
        if Victim ~= Character then
            return Victim, Position or nil
        end
    end
end

local function GetNearestFromMouse(Character, Range)
    local MouseHit = MouseRemote:InvokeClient(Players:GetPlayerFromCharacter(Character))

    for _, Entity in ipairs(workspace.World.Live:GetChildren()) do
        if Entity:IsA("Model") and GlobalFunctions.IsAlive(Entity) and Entity ~= Character then
            local EntityPrimary = Entity:FindFirstChild("HumanoidRootPart")
            local Distance = (MouseHit.Position - EntityPrimary.Position).Magnitude

            if Distance <= Range then
                return Entity or nil
            end
        end
    end
end

local Hiei = {
    ["FirstAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Victim = RaycastTarget(300, Character) or GetNearestFromMouse(Character, 25)
        if not Victim then
            return
        end
        StateManager:ChangeState(Character, "Guardbroken", 1.5)

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)

        StateManager:ChangeState(Character, "IFrame", 0.65, { IFrameType = "" })
        SpeedManager.changeSpeed(Character, 2, 1.5, 5) --function(Character,Speed,Duration,Priority)

        --Hum.AutoRotate = false

        Victim.Humanoid.WalkSpeed = 3
        TaskScheduler:AddTask(0.5, function()
            Victim.Humanoid.WalkSpeed = 14
        end)

        --[[ Fire Animation ]]
        --
        AnimationRemote:FireClient(Player, "ShadowGash", "Play")

        --Hum.AutoRotate = false

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Distance = 100, Enemy = Victim, Module = "HieiVFX", Function = "ShadowGash" }
        )
        wait(0.75)
        Root.CFrame = Victim.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)

        wait(0.45)
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            5,
            { Character = Character, Distance = 100, Module = "HieiVFX", Function = "HieiScreen" }
        )

        wait(0.1)
        --[[ Screen Shake ]]
        --
        CameraRemote:FireClient(Player, "CameraShake", {
            FirstText = 6,
            SecondText = 3,
        })
        DamageManager.DeductDamage(
            Character,
            Victim,
            KeyData.SerializedKey,
            CharacterName,
            { Type = "Sword", KeysLogged = ExtraData.KeysLogged }
        )

        wait(0.55)
        --Hum.AutoRotate = true
    end,

    ["SecondAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)

        StateManager:ChangeState(Character, "Guardbroken", 2)

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "HieiVFX", Function = "Charge" }
        )

        --local Aiming = GlobalFunctions.NewInstance("BoolValue",{Parent = Character, Name = "Aiming"},.45)
        AnimationRemote:FireClient(Player, "SwordOfDarkness", "Play")
        SpeedManager.changeSpeed(Character, 1, 2.35, 2.5)

        GlobalFunctions.NewInstance("BoolValue", { Parent = Character, Name = "Aiming" }, 0.75)

        wait(0.75)
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            5,
            { Character = Character, Distance = 100, Module = "HieiVFX", Function = "HieiScreen" }
        )

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            {
                Character = Character,
                Module = "HieiVFX",
                Function = "SwordOfDarkness",
                Distance = 100,
                ContactPoint = Root.CFrame,
            }
        )

        local HitResult, ValidEntities = HitboxModule.GetTouchingParts(
            Player,
            {
                Delay = 0.935,
                ExistTime = 2,
                Type = "Sword",
                KeysLogged = math.random(1, 3),
                Size = Vector3.new(12.417, 4.517, 58.929),
                Transparency = 1,
                PositionCFrame = Root.CFrame * CFrame.new(0, 0, -18.5),
            },
            KeyData.SerializedKey,
            CharacterName
        )
        if HitResult then
            for Index = 1, #ValidEntities do
                local Victim = ValidEntities[Index]
                local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

                TaskScheduler:AddTask(0.35, function()
                    NetworkStream.FireOneClient(
                        Player,
                        "ClientRemote",
                        5,
                        {
                            Character = Character,
                            Enemy = Victim,
                            Module = "HieiVFX",
                            Function = "ShadowHitEffect",
                            Distance = 100,
                        }
                    )

                    local _ = Players:GetPlayerFromCharacter(Victim)
                        and NetworkStream.FireOneClient(
                            Players:GetPlayerFromCharacter(Victim),
                            "ClientRemote",
                            5,
                            {
                                Character = Character,
                                Enemy = Victim,
                                Module = "HieiVFX",
                                Function = "ShadowHitEffect",
                                Distance = 100,
                            }
                        )
                    local _ = Players:GetPlayerFromCharacter(Victim)
                        and CameraRemote:FireClient(Players:GetPlayerFromCharacter(Victim), "SlashScreen")
                end)
            end
        end

        --CameraRemote:FireClient(Player, "CreateFlashUI", CreateFrameData)
        local MAX_DISTANCE = 50
        local BodyPosition = Instance.new("BodyPosition")
        BodyPosition.Position = (Root.CFrame * CFrame.new(0, 0, -MAX_DISTANCE)).Position
        BodyPosition.MaxForce = Vector3.new(1e4, 1e4, 1e4)
        BodyPosition.P = 200
        BodyPosition.D = 25
        BodyPosition.Parent = Root

        Debris:AddItem(BodyPosition, 1)

        wait(0.875)
        -- SoundManager:AddSound("UnSheath",{Parent = Root, Volume = 3},"Client")
    end,

    ["ThirdAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local HumanoidRootPart, Humanoid =
            Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Victim = RaycastTarget(300, Character) or GetNearestFromMouse(Character, 25)
        if not Victim then
            return
        end
        local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)

        SpeedManager.changeSpeed(Character, 2, 0.8, 5) --function(Character,Speed,Duration,Priority)
        StateManager:ChangeState(Character, "IFrame", 0.95, { IFrameType = "" })
        StateManager:ChangeState(Character, "Guardbroken", 2.15)

        --[[ Fire Animation ]]
        --
        AnimationRemote:FireClient(Player, "CounterStab", "Play")
        GlobalFunctions.NewInstance("StringValue", { Parent = Character, Name = "Aiming", Value = Victim.Name }, 0.5)

        VRoot.Anchored = true
        Humanoid.AutoRotate = false
        delay(2.05, function()
            VRoot.Anchored = false
            Humanoid.AutoRotate = true
        end)

        --// BodyMover
        local BodyPosition = Instance.new("BodyPosition")
        BodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        BodyPosition.P = 200
        BodyPosition.D = 25
        BodyPosition.Parent = Character.HumanoidRootPart
        BodyPosition.Position = Victim.Torso.Position
        Debris:AddItem(BodyPosition, 1)

        --[[ Fire Client ]]
        --
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Distance = 100, Enemy = Victim, Module = "HieiVFX", Function = "CounterStab" }
        )

        wait(0.9)

        local HitResult, HitObject = HitboxModule.MagnitudeModule(
            Character,
            { Range = 12, KeysLogged = 1, Type = "Combat" },
            KeyData.SerializedKey,
            CharacterName
        )
        if HitResult then
            local Victim = HitObject.Parent
            local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

            DamageManager.DeductDamage(
                Character,
                Victim,
                KeyData.SerializedKey,
                CharacterName,
                { Type = "Sword", KeysLogged = ExtraData.KeysLogged }
            )
            GlobalFunctions.NewInstance("BoolValue", { Parent = Character, Name = "HieiHit" }, 3.5)

            --// Raycast
            local MAX_HEIGHT = 25
            local StartPosition = Victim.HumanoidRootPart.Position
            local EndPosition = Victim.HumanoidRootPart.CFrame.UpVector * MAX_HEIGHT
            local GoalPosition

            local RayData = RaycastParams.new()
            RayData.FilterDescendantsInstances = { Victim, Character, World.Visuals } or World.Visuals
            RayData.FilterType = Enum.RaycastFilterType.Exclude
            RayData.IgnoreWater = true

            local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)

            if ray then
                local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
                if partHit then
                    MAX_HEIGHT = pos - Vector3.new(0, 5, 0)
                    partHit = nil
                    pos = nil
                    normVector = nil
                    ray = nil
                end
            end

            GoalPosition = Victim.HumanoidRootPart.Position + Vector3.new(0, MAX_HEIGHT, 0)

            BodyPosition = Instance.new("BodyPosition")
            BodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            BodyPosition.P = 200
            BodyPosition.D = 25
            BodyPosition.Position = GoalPosition
            BodyPosition.Parent = Victim.HumanoidRootPart
            Debris:AddItem(BodyPosition, 1.5)
            --// lock characters
            wait(0.6)
            Character.HumanoidRootPart.Anchored = true
            Character.HumanoidRootPart.CFrame = Victim.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)

            wait(0.25)
            Character.HumanoidRootPart.Anchored = true
            Victim.HumanoidRootPart.Anchored = true

            wait(0.3)
            DamageManager.DeductDamage(
                Character,
                Victim,
                KeyData.SerializedKey,
                CharacterName,
                { Type = "Sword", KeysLogged = ExtraData.KeysLogged }
            )

            Character.HumanoidRootPart.Anchored = false
            Victim.HumanoidRootPart.Anchored = false

            --[[ BodyMover ]]
            --
            BodyPosition:Destroy()

            -- FRESH ADD THE KNOCBACK THING HERE
            VfxHandler.SlamDown({ Character = Character, Victim = Victim })
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                {
                    Character = Victim,
                    Module = "HieiVFX",
                    Function = "Slam",
                    ContactPointCFrame = Victim.HumanoidRootPart.CFrame,
                }
            )
        end
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

        SpeedManager.changeSpeed(Character, 2, 1.35, 5) --function(Character,Speed,Duration,Priority)
        GlobalFunctions.NewInstance("BoolValue", { Parent = Character, Name = "Aiming" }, 1.35)

        --[[ Fire Animation ]]
        --
        AnimationRemote:FireClient(Player, "ShadowGash", "Play")
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Distance = 100, Module = "HieiVFX", Function = "Charge" }
        )

        -- SoundManager:AddSound("BlackDragonHellfire", {Parent = Root, TimePosition = .35, Volume = 2}, "Client")
        StateManager:ChangeState(Character, "Guardbroken", 1)

        wait(1.35)
        if StateManager:Peek(Character, "Stunned") then
            return
        end

        --[[ Fire Client ]]
        --
        local StartPosition = Character.HumanoidRootPart.Position
        local Range = 1000
        local MouseHit = MouseRemote:InvokeClient(Player)
        local GoalPosition = (MouseHit.Position - StartPosition).Unit * Range
        local EndPosition

        local RayData = RaycastParams.new()
        RayData.FilterDescendantsInstances = { Character, World.Live, World.Visuals } or World.Visuals
        RayData.FilterType = Enum.RaycastFilterType.Exclude
        RayData.IgnoreWater = true

        local ray = workspace:Raycast(StartPosition, GoalPosition, RayData)
        --[[ new Bezier ]]
        --
        if ray then
            --[[ Set Ray Variables ]]
            --
            local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
            if partHit then
                --[[ Fire Client ]]
                --
                NetworkStream.FireClientDistance(
                    Character,
                    "ClientRemote",
                    200,
                    {
                        Character = Character,
                        Distance = 100,
                        ContactPoint = pos,
                        Module = "HieiVFX",
                        Function = "BlackDragonHellfire",
                    }
                )
                --[[ Screen Shake ]]
                --
                CameraRemote:FireClient(Player, "CameraShake", {
                    FirstText = 6,
                    SecondText = 3,
                })
                wait(0.2)
                local ValidEntities = RaycastManager:GetEntitiesFromPoint(
                    pos,
                    workspace.World.Live:GetChildren(),
                    { [Character] = true },
                    25
                )
                for Index = 1, #ValidEntities do
                    local Entity = ValidEntities[Index]

                    DamageManager.DeductDamage(
                        Character,
                        Entity,
                        KeyData.SerializedKey,
                        CharacterName,
                        { Type = "Combat" }
                    )

                    local BodyVelocity = Instance.new("BodyVelocity")
                    BodyVelocity.Velocity = Vector3.new(0, 35, math.random(1, 2) == 1 and -15 or 15)
                    BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
                    BodyVelocity.Parent = Entity.PrimaryPart

                    Debris:AddItem(BodyVelocity, 0.3)
                    Ragdoll.DurationRagdoll(Entity, 1)
                end
            end
        end
    end,
}

return Hiei
