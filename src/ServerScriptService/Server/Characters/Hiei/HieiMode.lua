--|| Services ||--
local Players = game:GetService("Players")

local TweenService = game:GetService("TweenService")

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Directories ||--
local Server = ServerScriptService.Server

local Managers = Server.Managers

local Modules = ReplicatedStorage.Modules
local State = Server.State

local Effects = Modules.Effects
local Shared = Modules.Shared
local Metadata = Modules.Metadata
local Utility = Modules.Utility

--|| Imports ||--
local ProfileService = require(Server.ProfileService)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local HitboxModule = require(Server.Combat.Combat.HitboxModule)

local AbilityData = require(Metadata.AbilityData.AbilityData)

local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)
local TaskScheduler = require(Utility.TaskScheduler)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)
local SoundManager = require(Shared.SoundManager)

local RaycastManager = require(Shared.RaycastManager)

local DamageManager = require(Managers.DamageManager)

local VfxHandler = require(Effects.VfxHandler)

local Ragdoll = require(ServerStorage.Modules.Ragdoll)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local MouseRemote = ReplicatedStorage.Remotes.GetMouse
local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote
local GUIRemote = ReplicatedStorage.Remotes.GUIRemote

--|| Functions ||--
local World = workspace.World

local Trash = {}

local function RemoveTrash(Trash)
    for Index = 1, #Trash do
        local Item = Trash[Index]
        if Item and Item.Parent then
            Item:Destroy()
        end
    end
end

local function GetNearPlayers(Character, Radius)
    local ChosenVictim
    local Live = workspace.World.Live

    local HumanoidRootPart = Character.PrimaryPart

    for _, Victim in ipairs(Live:GetChildren()) do
        if Victim:FindFirstChild("Humanoid") and Victim.Humanoid.Health > 0 then
            local EnemyRootPart = Victim:FindFirstChild("PrimaryPart") or Victim:FindFirstChild("HumanoidRootPart")

            if (EnemyRootPart.Position - HumanoidRootPart.Position).Magnitude <= Radius then
                if Victim ~= Character then
                    ChosenVictim = Victim
                end
            end
        end
    end
    return ChosenVictim
end

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

local function GetMouseTarget(Target, Character)
    local MouseHit = MouseRemote:InvokeClient(Players:GetPlayerFromCharacter(Character))

    local Root = Character:FindFirstChild("HumanoidRootPart")
    if (Root.Position - MouseHit.Position).Magnitude > 80 then
        return
    end

    if
        Target
        and Target:IsA("BasePart")
        and not Target:IsDescendantOf(Character)
        and GlobalFunctions.IsAlive(Target.Parent)
    then
        return Target.Parent or nil
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

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.World.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

local NatsuMode = {

    ["Transformation"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Data = ProfileService:GetPlayerProfile(Player)

        --AnimationRemote:FireClient(Player,"ZenitsuTransformation","Play")

        StateManager:ChangeState(Character, "IFrame", 1.35, { IFrameType = "" })
        SpeedManager.changeSpeed(Character, 0, 1.35, 4e4)

        -- TaskScheduler:AddTask(1,function() SoundManager:AddSound("ZenitVoiceLine",{Parent = Root, Volume = 2}, "Client") end)
        Root.Anchored = true

        --NetworkStream.FireClientDistance(Character, "ClientRemote", 350, {Character = Character , Module = Data.Character.."Mode", Function = "Transformation"})
        --NetworkStream.FireOneClient(Player,"ClientRemote",5,{Character = Character, Module = "AokijiMode", Function = "Cutscene"})

        local CreateFrameData = {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Color = Color3.fromRGB(202, 195, 89),
            Duration = 1,
        }

        TaskScheduler:AddTask(1.15, function()
            --NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "ZenitsuVFX", Function = "Rice Spirit"})
            -- SoundManager:AddSound("Thund",{Parent = Root, PlaybackSpeed = 1 - (((1 - 1) * 3) / 10)}, "Client")

            CameraRemote:FireClient(Player, "CreateFlashUI", CreateFrameData)
            Root.Anchored = false
        end)
    end,

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
        wait(0.25)
        Root.CFrame = Victim.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Distance = 100, Enemy = Victim, Module = "HieiMode", Function = "ShadowStep" }
        )
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
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
        local RANGE = 2
        local Victim = RaycastTarget(RANGE, Character) or GetNearestFromMouse(Character, 1)
        if not Victim then
            return
        end

        -- play anim
        AnimationRemote:FireClient(Player, "LightningDragonHammer", "Play", { AdjustSpeed = 1.5 })

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)

        GlobalFunctions.NewInstance("StringValue", { Parent = Character, Name = "Aiming", Value = Victim.Name }, 0.5)

        Humanoid.AutoRotate = false
        delay(2.05, function()
            Humanoid.AutoRotate = true
        end)

        --[[ Fire Client ]]
        --
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            {
                Character = Character,
                Distance = 100,
                SSJRock = true,
                Enemy = Victim,
                Module = "NatsuMode",
                Function = "LightningDragonCrimsonStart",
            }
        )
        wait(0.5)
        --[[ Fire Client ]]
        --
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            {
                Character = Character,
                Distance = 100,
                Enemy = Victim,
                Module = "NatsuMode",
                Function = "LightningDragonCrimsonMove",
            }
        )

        for _, v in ipairs(Root:GetChildren()) do
            if v:IsA("BodyPosition") then
                v:Destroy()
            end
        end
        --// BodyMover
        local DISTANCE = 75
        local BodyPosition = Instance.new("BodyPosition")
        BodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        BodyPosition.P = 200
        BodyPosition.D = 25
        BodyPosition.Parent = Character.HumanoidRootPart
        BodyPosition.Position = (Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -DISTANCE)).Position --Victim.Torso.Position
        Debris:AddItem(BodyPosition, 1)

        local Weld = Instance.new("Weld")
        Weld.Part0 = Root
        Weld.Part1 = Victim.HumanoidRootPart
        Weld.C0 = CFrame.new(0, 0, -3.05) * CFrame.Angles(0, math.rad(-180), 0)
        Weld.Parent = Victim.HumanoidRootPart

        Debris:AddItem(Weld, 3)

        local VictimPlayer = Players:GetPlayerFromCharacter(Victim)
        local Anim =
            Victim.Humanoid:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Characters.Mob.PhyscoSlamVictim)
        local _ = (VictimPlayer and AnimationRemote:FireClient(VictimPlayer, "PhyscoSlamVictim", "Play"))
            or (not VictimPlayer and Anim and Anim:Play())

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

            BodyPosition:Destroy()

            --[[ Fire Client ]]
            --
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                {
                    Character = Character,
                    Module = "NatsuMode",
                    Function = "LightningBurst",
                    Distance = 100,
                    ContactPointCFrame = Root.CFrame,
                }
            )
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                {
                    Character = Character,
                    Distance = 100,
                    Enemy = Victim,
                    Module = "NatsuMode",
                    Function = "LightningDragonHammer",
                }
            )
            Character.HumanoidRootPart.Anchored = true
            --// lock characters
            wait(0.85)
            Victim.HumanoidRootPart.Anchored = true
            Character.HumanoidRootPart.Anchored = false
            wait(0.3)
            Weld:Destroy()
            Victim.HumanoidRootPart.Anchored = false

            --[[ BodyMover ]]
            --
            BodyPosition:Destroy()
        end
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

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            30,
            { Character = Character, Distance = 100, Module = "AokijiMode", Function = "Cutscene" }
        )
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            30,
            { Character = Character, Distance = 100, Module = "NatsuMode", Function = "NatsuScreen" }
        )
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Distance = 100, Module = "NatsuMode", Function = "DragonTransformation" }
        )
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
        for _ = 1, 3 do
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
            wait(0.5)
        end
    end,
}

return NatsuMode
