--|| Services ||--
local Players = game:GetService("Players")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

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
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local AbilityData = require(Metadata.AbilityData.AbilityData)

local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)

local RaycastManager = require(Shared.RaycastManager)

local HitboxModule = require(script.Parent.Parent.Combat.Combat.HitboxModule)

local DamageManager = require(Managers.DamageManager)

local VfxHandler = require(Effects.VfxHandler)

local Ragdoll = require(ServerStorage.Modules.Ragdoll)

local TaskScheduler = require(Utility.TaskScheduler)

local ProfileService = require(ServerScriptService.Server.ProfileService)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local MouseRemote = ReplicatedStorage.Remotes.GetMouse
local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote
local GUIRemote = ReplicatedStorage.Remotes.GUIRemote

--|| Functions ||--
local function GetMouseTarget(Target, Character)
    if Target:IsA("BasePart") and not Target:IsDescendantOf(Character) and GlobalFunctions.IsAlive(Target.Parent) then
        return true, Target.Parent
    else
        return false
    end
end

local Mob = {

    ["FirstAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
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
                local Victim = HitObject.Parent
                local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

                local UnitVector = (Root.Position - VRoot.Position).Unit
                local VictimLook = VRoot.CFrame.LookVector
                local DotVector = UnitVector:Dot(VictimLook)

                if not StateManager:Peek(Victim, "IFrame") then
                    CameraRemote:FireClient(
                        Player,
                        "ChangeUICooldown",
                        { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
                    )
                    DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
                    return
                end

                if StateManager:Peek(Victim, "Blocking") and DotVector >= -0.5 then
                    CameraRemote:FireClient(
                        Player,
                        "ChangeUICooldown",
                        { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
                    )
                    DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
                    return
                end

                local Data = ProfileService:GetPlayerProfile(Player)
                if Data.Character == "Mob" then
                    DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
                    CameraRemote:FireClient(
                        Player,
                        "ChangeUICooldown",
                        { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
                    )
                end

                StateManager:ChangeState(Character, "Guardbroken", 3.5)
                StateManager:ChangeState(Victim, "Stunned", 5)

                local Animator = VHum:FindFirstChildOfClass("Animator")
                AnimationRemote:FireClient(Player, "MobChoke", "Play")

                local Weld = Instance.new("Weld")
                Weld.Part0 = Root
                Weld.Part1 = VRoot
                Weld.C0 = CFrame.new(0, 0, -3.05) * CFrame.Angles(0, math.rad(-180), 0)
                Weld.Parent = VRoot

                Debris:AddItem(Weld, 3.5)

                coroutine.wrap(function()
                    wait(0.5)
                    NetworkStream.FireClientDistance(
                        Character,
                        "ClientRemote",
                        200,
                        { Character = Character, Victim = Victim, Module = "MobVFX", Function = "ChokeHoldTehe?" }
                    )
                    CameraRemote:FireClient(
                        Player,
                        "ColorCorrection",
                        {
                            Type = "Create",
                            Name = "Gravity",
                            TimeBeforeRemove = 1.25,
                            Length = 0.75,
                            TweenColor = Color3.fromRGB(161, 83, 255),
                        }
                    )
                    if Players:GetPlayerFromCharacter(Victim) then
                        CameraRemote:FireClient(
                            Players:GetPlayerFromCharacter(Victim),
                            "ColorCorrection",
                            {
                                Type = "Create",
                                Name = "Gravity",
                                TimeBeforeRemove = 1.25,
                                Length = 0.75,
                                TweenColor = Color3.fromRGB(161, 83, 255),
                            }
                        )
                    end
                    CameraRemote:FireClient(
                        Player,
                        "CameraShake",
                        { FirstText = 2, SecondText = 12, Amount = 15, Time = 0.1, Type = "Loop" }
                    )
                    wait(0.5)
                    CameraRemote:FireClient(Player, "CreateBlur", { Size = 10, Length = 0.225 })
                    DamageManager.DeductDamage(
                        Character,
                        Victim,
                        KeyData.SerializedKey,
                        CharacterName,
                        { SecondType = "Choke", Type = "Combat", KeysLogged = 3 }
                    )
                    --	Ragdoll.DurationRagdoll(Victim, 2)
                end)()

                Hum.AutoRotate = false
                Root.Anchored = true

                if Animator then
                    local Animation =
                        Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Characters.Mob.MobFlyVictim)
                    Animation:Play()
                end
                NetworkStream.FireClientDistance(
                    Character,
                    "ClientRemote",
                    200,
                    {
                        Character = Character,
                        Distance = 100,
                        Victim = Victim,
                        Module = "MobVFX",
                        Function = "PhyscoChoke",
                    }
                )

                wait(0.65)
                for _ = 1, 16 do
                    StateManager:ChangeState(Character, "IFrame", 0.5)
                    DamageManager.DeductDamage(
                        Character,
                        Victim,
                        KeyData.SerializedKey,
                        CharacterName,
                        { SecondType = "Choke", Type = "Combat", KeysLogged = 3 }
                    )
                    wait(0.1175)
                end
                local BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.Velocity = Vector3.new(0, 35, math.random(1, 2) == 1 and -15 or 15)
                BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
                BodyVelocity.Parent = Victim.PrimaryPart

                Debris:AddItem(BodyVelocity, 0.3)
                Ragdoll.DurationRagdoll(Victim, 1)

                Weld:Destroy()
                SpeedManager.changeSpeed(Character, 5, 1.25, 3.5) --function(Character,Speed,Duration,Priority)
                --StateManager:ChangeState(Character,"Guardbroken",1.25,{AllowedSkills = {["Dash"] = true, ["Block"] = true}})
            end
            Hum.AutoRotate = true
            Root.Anchored = false
        end
    end,

    ["SecondAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")
        local MobData = AbilityData.ReturnData(Player, "SecondAbility", "Mob")

        local TimeEvaluation = os.clock() - PlayerCombo.LastPressed <= 0.8 and true or false
        local NumberEvaluation = (PlayerCombo.Hits < 5 and TimeEvaluation and PlayerCombo.Hits + 1)
            or (PlayerCombo.Hits > 5 and 1)
            or (not PlayerCombo.TimeEvaluation and 1)

        PlayerCombo.Hits = NumberEvaluation == 5 and 0 or NumberEvaluation == 1 and 0 or PlayerCombo.Hits

        local HitResult, ValidEntities = HitboxModule.GetTouchingParts(
            Player,
            {
                SecondType = "Choke",
                ExistTime = 0.35,
                Type = "Combat",
                KeysLogged = NumberEvaluation,
                Size = Vector3.new(8.999, 4.517, 17.267),
                Transparency = 1,
                PositionCFrame = Root.CFrame * CFrame.new(0, 0, -2),
            },
            KeyData.SerializedKey,
            CharacterName
        )
        if HitResult then
            for Index = 1, #ValidEntities do
                local Victim = ValidEntities[Index]
                local VictimPlayer = Players:GetPlayerFromCharacter(Victim)
                local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

                local UnitVector = (Root.Position - VRoot.Position).Unit
                local VictimLook = VRoot.CFrame.LookVector
                local DotVector = UnitVector:Dot(VictimLook)

                if StateManager:Peek(Victim, "Blocking") and DotVector >= -0.5 then
                    local Data = ProfileService:GetPlayerProfile(Player)
                    if Data.Character == "Mob" then
                        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
                        CameraRemote:FireClient(
                            Player,
                            "ChangeUICooldown",
                            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
                        )
                    end
                    return
                end

                local Data = ProfileService:GetPlayerProfile(Player)
                if Data.Character == "Mob" then
                    DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
                    CameraRemote:FireClient(
                        Player,
                        "ChangeUICooldown",
                        { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
                    )
                end

                local Anim =
                    VHum:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Characters.Mob.PhyscoSlamVictim)

                AnimationRemote:FireClient(Player, "PhyscoSlamPlayer", "Play")
                local _ = (VictimPlayer and AnimationRemote:FireClient(VictimPlayer, "PhyscoSlamVictim", "Play"))
                    or (not VictimPlayer and Anim and Anim:Play())

                StateManager:ChangeState(Character, "Guardbroken", 2)
                StateManager:ChangeState(Victim, "Stunned", 3)

                CameraRemote:FireClient(Player, "CameraShake", { FirstText = 8, SecondText = 10 })
                NetworkStream.FireClientDistance(
                    Character,
                    "ClientRemote",
                    200,
                    {
                        Character = Character,
                        Distance = 100,
                        Victim = Victim,
                        Module = "MobVFX",
                        Function = "PhyscoSlamUp",
                    }
                )

                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = { Victim, Character }
                raycastParams.FilterType = Enum.RaycastFilterType.Include

                SpeedManager.changeSpeed(Character, 4, 2.5, 5)

                local RaycastResult = workspace:Raycast(VRoot.Position, Vector3.new(0, -15, 0))
                local Position = RaycastResult and RaycastResult.Position + Vector3.new(0, 18, 0)
                    or VRoot.Position + Vector3.new(0, 18, 0)

                local Tween =
                    TweenService:Create(VRoot, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { Position = Position })
                Tween:Play()
                Tween:Destroy()

                Tween.Completed:Wait()

                if StateManager:Peek(Character, "Stunned") then
                    NetworkStream.FireClientDistance(
                        Character,
                        "ClientRemote",
                        200,
                        {
                            Character = Character,
                            Distance = 100,
                            Victim = Victim,
                            Module = "MobVFX",
                            Function = "CancelSlam",
                        }
                    )

                    local Tween = TweenService:Create(
                        VRoot,
                        TweenInfo.new(0.215, Enum.EasingStyle.Quad),
                        { Position = RaycastResult.Position }
                    )
                    Tween:Play()
                    Tween:Destroy()
                    return
                end

                VRoot.Anchored = true
                wait(1)

                local BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.Velocity = Vector3.new(0, 35, math.random(1, 2) == 1 and -30 or 30)
                BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
                BodyVelocity.Parent = Victim.PrimaryPart

                Debris:AddItem(BodyVelocity, 0.3)
                Ragdoll.DurationRagdoll(Victim, 1)

                VfxHandler.FireProc({ Character = Character, Victim = Victim, Duration = 3, Damage = 1 })

                VRoot.Anchored = false

                NetworkStream.FireClientDistance(
                    Character,
                    "ClientRemote",
                    200,
                    {
                        Character = Character,
                        Distance = 100,
                        Victim = Victim,
                        Module = "MobVFX",
                        Function = "PhyscoSlamDown",
                    }
                )

                local Tween = TweenService:Create(
                    VRoot,
                    TweenInfo.new(0.215, Enum.EasingStyle.Quad),
                    { Position = RaycastResult.Position }
                )
                Tween:Play()
                Tween:Destroy()

                Tween.Completed:Wait()

                DamageManager.DeductDamage(Character, Victim, KeyData.SerializedKey, CharacterName, { Type = "Combat" })
            end
        end
    end,

    ["ThirdAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Mob" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        local ExplosionRange = MoveData.Range
        local RockAmount = MoveData.Rocks
        local RockVelocity = 150
        local RockLifetime = 10
        local AnimationDuration = 1

        StateManager:ChangeState(Character, "Guardbroken", 2)

        local Rocks = {}
        for Index = 1, RockAmount - 1 do
            local RandomPosition = Character.PrimaryPart.Position
                + Vector3.new(math.random(-20, 20), math.random(10, 20), math.random(-20, 20))
            local RandomSize = math.random(3, 6)
            local RandomDelay = math.random() / RockAmount
            Rocks[Index] = {
                Size = RandomSize,
                Position = RandomPosition,
                Delay = RandomDelay,
            }
        end

        NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {
            Character = Character,

            Module = "MobVFX",
            Function = "Physco Rocks",

            Rocks = Rocks,
            AnimationDuration = AnimationDuration,
            RockVelocity = RockVelocity,
            RockLifetime = RockLifetime,
            Distance = 150,
        })

        wait(AnimationDuration)
        local MouseHit = MouseRemote:InvokeClient(Player)
        for Index = 1, #Rocks do
            local RockData = Rocks[Index]
            local Points = RaycastManager:GetSquarePoints(CFrame.new(RockData.Position), RockData.Size, RockData.Size)
            RaycastManager:CastProjectileHitbox({
                Points = Points,
                Direction = (MouseHit.Position - RockData.Position).Unit,
                Velocity = RockVelocity,
                Lifetime = RockLifetime,
                Iterations = 50,
                Visualize = false,
                Function = function(RaycastResult)
                    local ValidEntities = RaycastManager:GetEntitiesFromPoint(
                        RaycastResult.Position,
                        workspace.World.Live:GetChildren(),
                        { [Character] = true },
                        ExplosionRange
                    )
                    for Index = 1, #ValidEntities do
                        local Entity = ValidEntities[Index]

                        VfxHandler.FireProc({ Character = Character, Victim = Entity, Duration = 3, Damage = 1 })
                        DamageManager.DeductDamage(
                            Character,
                            Entity,
                            KeyData.SerializedKey,
                            CharacterName,
                            { Type = "Combat" }
                        )
                    end
                end,
                Ignore = { Character, workspace.World.Visuals },
            })
            wait(0.05)
        end
    end,

    ["FourthAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Mob" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        StateManager:ChangeState(Character, "Guardbroken", 1)

        local MouseHit = MouseRemote:InvokeClient(Player)
        local MousePosition = MouseHit.Position

        local SpawnPoint = CFrame.lookAt(Character.PrimaryPart.Position + Vector3.new(0, 150, 0), MouseHit.Position)
        local Size = ReplicatedStorage.Assets.Effects.Meshes.Meteor.Size.X * 1.5
        local Velocity = 200
        local Lifetime = 10

        NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {
            Character = Character,

            Module = "MobVFX",
            Function = "PhyscoMeteor",

            MouseHit = MouseHit,
            Size = Size,
            SpawnPoint = SpawnPoint,
            Velocity = Velocity,
            Lifetime = Lifetime,
            Distance = 200,
        })

        local Points = RaycastManager:GetSquarePoints(SpawnPoint, Size, Size)
        RaycastManager:CastProjectileHitbox({
            Points = Points,
            Direction = (MouseHit.Position - SpawnPoint.Position).Unit,
            Velocity = Velocity,
            Lifetime = Lifetime,
            Iterations = 50,
            Visualize = false,
            Function = function(RaycastResult)
                local ValidEntities = RaycastManager:GetEntitiesFromPoint(
                    RaycastResult.Position,
                    workspace.World.Live:GetChildren(),
                    { [Character] = true },
                    12
                )
                for Index = 1, #ValidEntities do
                    local Entity = ValidEntities[Index]

                    VfxHandler.FireProc({ Character = Character, Victim = Entity, Duration = 3, Damage = 1 })
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
            end,
            Ignore = { Character, workspace.World.Visuals },
        })
    end,
}

return Mob
