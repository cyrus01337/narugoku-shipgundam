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

local ProfileService = require(Server.ProfileService)

--||Remotes||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

--||Functions||--
local function GetMouseTarget(Target, Character)
    if
        Target
        and Target:IsA("BasePart")
        and not Target:IsDescendantOf(Character)
        and GlobalFunctions.IsAlive(Target.Parent)
    then
        return true, Target.Parent
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

local function RadialPoints(CF, Points, Distance)
    local List = {}
    for Index = 1, Points do
        local Degree = ((2 * math.pi) / Points) * Index
        local Z = math.sin(Degree) * Distance
        local X = math.cos(Degree) * Distance
        local CFrameIndex = CF * CFrame.new(X, math.random(5, 10), Z)
        List[Index] = CFrameIndex
    end
    return List
end

local Gilgamesh = {
    ["FirstAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character

        local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")

        local Humanoid = Character:FindFirstChild("Humanoid")
        local Root = Character:FindFirstChild("HumanoidRootPart")

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Gilgamesh" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            local _ = ExtraData.Type == nil
                and CameraRemote:FireClient(
                    Player,
                    "ChangeUICooldown",
                    { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
                )
        end

        StateManager:ChangeState(Character, "Attacking", 1.5, { AllowedSkills = { ["Swing"] = true } })
        local MouseHit = MouseRemote:InvokeClient(Player)

        local StartPoint = CFrame.lookAt(
            (Character.PrimaryPart.CFrame * CFrame.new(math.random(-5, 5), math.random(3, 10), math.random(-10, -5))).Position,
            MouseHit.Position
        )

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "GilgameshVFX", Function = "OpenPortal", StartPoint = StartPoint }
        )

        wait(1)
        local MouseHit = MouseRemote:InvokeClient(Player)

        local Size = Assets.Models.Swords.GilgameshSpear.Size

        local Points = RaycastManager:GetSquarePoints(StartPoint, Size.X * 2, Size.X * 2)

        local Velocity = 250
        local Lifetime = 10

        local DelayBetweenProjectiles = 1

        local Direction = (MouseHit.Position - StartPoint.Position).Unit

        NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {
            Character = Character,

            Module = "GilgameshVFX",
            Function = "Zashu",

            StartPoint = StartPoint,
            MouseHit = ExtraData.Type == "Aerial" and ExtraData.MouseHit or MouseHit,

            Lifetime = Lifetime,
            Velocity = Velocity,

            Distance = 100,
            Direction = Direction,

            UnitRay = ExtraData.UnitRay,
        })

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
                    workspace.World.Live:GetChildren(),
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
                        { Type = "Combat" }
                    )
                end
            end,
            Ignore = { Character, workspace.World.Visuals },
        })
    end,

    ["SecondAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character

        local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")

        local Humanoid = Character:FindFirstChild("Humanoid")
        local Root = Character:FindFirstChild("HumanoidRootPart")

        local Victim = GetNearestFromMouse(Character, 8) ---GetMouseTarget(ExtraData.MouseTarget, Character) or GetNearPlayers(Character,35)
        if not Victim then
            return
        end
        local VRoot = Victim:FindFirstChild("HumanoidRootPart")

        local Velocity = 235
        local Lifetime = 8

        StateManager:ChangeState(Character, "Attacking", 2.35, { AllowedSkills = { ["Swing"] = true } })

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Gilgamesh" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        local MouseHit = MouseRemote:InvokeClient(Player)

        local Size = Assets.Models.Swords.GilgameshSpear.Size

        local DelayBetweenProjectiles = 0.75

        local StoredStartPositions = {}

        for _ = 1, 7 do
            local StartPoint = CFrame.lookAt(
                (Character.PrimaryPart.CFrame * CFrame.new(
                    math.random(-15, 15),
                    math.random(6, 17),
                    math.random(-15, 0)
                )).Position,
                MouseHit.Position
            )
            StoredStartPositions[#StoredStartPositions + 1] = StartPoint

            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                {
                    Character = Character,
                    Module = "GilgameshVFX",
                    Function = "OpenPortal",
                    StartPoint = StartPoint,
                    Type = "Loop",
                }
            )
        end

        wait(0.5)

        local MouseHit = MouseRemote:InvokeClient(Player)

        NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {
            Character = Character,

            Module = "GilgameshVFX",
            Function = "GatesOfBabylon",

            StartPoints = StoredStartPositions,
            MouseHit = VRoot.CFrame,

            Lifetime = Lifetime,
            Velocity = Velocity,

            UnitRay = ExtraData.UnitRay,
            Distance = 185,
            MagDistance = 200,
        })

        for Index = 1, 5 do
            local CurrentStartPosition = StoredStartPositions[Index]

            local Points = RaycastManager:GetSquarePoints(CurrentStartPosition, Size.X * 2, Size.X * 2)

            local Direction = (VRoot.CFrame.Position - CurrentStartPosition.Position).Unit

            coroutine.wrap(function()
                wait(DelayBetweenProjectiles - math.random(0.1, 0.3))
                RaycastManager:CastProjectileHitbox({
                    Points = Points,
                    Direction = Direction,
                    Velocity = Velocity + 5,
                    Lifetime = Lifetime,
                    Iterations = 50,
                    Visualize = false,
                    Function = function(RaycastResult)
                        local ValidEntities = RaycastManager:GetEntitiesFromPoint(
                            RaycastResult.Position,
                            workspace.World.Live:GetChildren(),
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
                                { Type = "Combat" }
                            )
                        end
                    end,
                    Ignore = { Character, workspace.World.Visuals },
                })
            end)()
        end
    end,

    ["ThirdAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character

        local Humanoid = Character:FindFirstChild("Humanoid")
        local Root = Character:FindFirstChild("HumanoidRootPart")

        local Hit = false
        local Next

        local Target = GetNearestFromMouse(Character, 8) ---GetMouseTarget(ExtraData.MouseTarget, Character) or GetNearPlayers(Character,35)
        if not Target then
            return
        end

        local VRoot = Target:FindFirstChild("HumanoidRootPart")

        local UnitVector = (Root.Position - VRoot.Position).Unit
        local VictimLook = VRoot.CFrame.LookVector
        local DotVector = UnitVector:Dot(VictimLook)

        local Data = ProfileService:GetPlayerProfile(Player)

        if StateManager:Peek(Target, "Blocking") and DotVector >= -0.5 then
            NetworkStream.FireClientDistance(Character, "ClientRemote", 150, {
                Character = Character,
                Victim = Target,
                WeaponType = "Combat",
                Module = "CombatVFX",
                Function = "Block",
            })
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
            return
        end

        if (Target.PrimaryPart.Position - Root.Position).Magnitude >= 200 then
            return
        end

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Gilgamesh" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")

        local Velocity = 200
        local Lifetime = 5

        local MainPortal = Assets.Effects.Particles.MainPortal
        local Distance = (MainPortal.BeamStart.Position - MainPortal.BeamEnd.Position).Magnitude

        local Size = Assets.Models.Swords.GilgameshSpear.Size

        local DelayBetweenProjectiles = 1

        local StoredStartPositions = {}

        StateManager:ChangeState(Character, "Attacking", 1.5)
        local MouseHit = MouseRemote:InvokeClient(Player)

        for _ = 1, 4 do
            local StartPoint = CFrame.lookAt(
                (Character.PrimaryPart.CFrame * CFrame.new(
                    math.random(-15, 15),
                    math.random(6, 17),
                    math.random(-15, 0)
                )).Position,
                MouseHit.Position
            )
            StoredStartPositions[#StoredStartPositions + 1] = StartPoint

            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                {
                    Character = Character,
                    Module = "GilgameshVFX",
                    Function = "OpenPortal",
                    StartPoint = StartPoint,
                    Type = "Loop",
                }
            )
        end

        NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {
            Character = Character,

            Module = "GilgameshVFX",
            Function = "Enkidu",

            StartPoints = StoredStartPositions,
            MouseHit = VRoot.CFrame,

            Lifetime = Lifetime,
            Velocity = Velocity,

            --UnitRay = ExtraData.UnitRay,
        })

        for Index = 1, 4 do
            local CurrentStartPosition = StoredStartPositions[Index]

            local Direction = (VRoot.CFrame.Position - CurrentStartPosition.Position).Unit

            local Points = RaycastManager:GetSquarePoints(CurrentStartPosition, Size.X, Size.X)

            RaycastManager:CastProjectileHitbox({
                Points = Points,
                Direction = Direction,
                Velocity = Velocity,
                Lifetime = Lifetime,
                Iterations = 30,
                Visualize = false,
                Function = function(RaycastResult)
                    local Target = RaycastResult.Instance
                    if
                        Target
                        and Target:IsA("BasePart")
                        and not Target:IsDescendantOf(Character)
                        and GlobalFunctions.IsAlive(Target.Parent)
                    then
                        Next = Target.Parent
                        DamageManager.DeductDamage(
                            Character,
                            Target.Parent,
                            KeyData.SerializedKey,
                            CharacterName,
                            { Type = "Combat" }
                        )

                        NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {
                            Character = Character,

                            Module = "GilgameshVFX",
                            Function = "ChainEffect",

                            Target = Target,
                        })
                        StateManager:ChangeState(Target.Parent, "Stunned", 3.5)
                        Hit = true
                    end
                end,
                Ignore = { Character, workspace.World.Visuals },
            })
        end
        wait(1)
        if Hit then
            local MouseHit = MouseRemote:InvokeClient(Player)

            local StartPoint = CFrame.lookAt(
                (
                    Character.PrimaryPart.CFrame
                    * CFrame.new(math.random(-5, 5), math.random(3, 10), math.random(-10, -5))
                ).Position,
                MouseHit.Position
            )

            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                { Character = Character, Module = "GilgameshVFX", Function = "OpenPortal", StartPoint = StartPoint }
            )

            wait(0.5)
            local Size = Assets.Models.Swords.GilgameshSpear.Size
            local Points = RaycastManager:GetSquarePoints(StartPoint, Size.X * 2, Size.X * 2)
            local Velocity = 200
            local Lifetime = 10
            local DelayBetweenProjectiles = 1
            local Direction = Next
                and (Next:FindFirstChild("HumanoidRootPart").CFrame.Position - StartPoint.Position).Unit
            local MouseHit = MouseRemote:InvokeClient(Player)

            NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {
                Character = Character,

                Module = "GilgameshVFX",
                Function = "Zashu",

                StartPoint = StartPoint,
                MouseHit = Next:FindFirstChild("HumanoidRootPart"),

                Lifetime = Lifetime,
                Velocity = Velocity,

                Distance = 100,
                Direction = Direction,

                UnitRay = ExtraData.UnitRay,
            })

            RaycastManager:CastProjectileHitbox({
                Points = Points,
                Direction = Direction,
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
                        DamageManager.DeductDamage(
                            Character,
                            Target.Parent,
                            KeyData.SerializedKey,
                            CharacterName,
                            { Type = "Sword" }
                        )
                        NetworkStream.FireClientDistance(
                            Character,
                            "ClientRemote",
                            200,
                            { Character = Character, Module = "SwordVFX", Function = "Light", Victim = Target.Parent }
                        )
                    end
                end,
                Ignore = { Character, workspace.World.Visuals },
            })

            Hit = false
            Next = nil
        end
    end,

    ["FourthAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character

        local Humanoid = Character:FindFirstChild("Humanoid")
        local Root = Character:FindFirstChild("HumanoidRootPart")

        local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")
        local Target = ExtraData.MouseTarget

        local IsTarget, Target = GetMouseTarget(Target, Character)
        if not IsTarget then
            return
        end

        if (Target.PrimaryPart.Position - Root.Position).Magnitude >= 100 then
            return
        end

        if StateManager:Peek(Target, "Blocking") then
            NetworkStream.FireClientDistance(Character, "ClientRemote", 150, {
                Character = Character,
                Victim = Target,
                WeaponType = "Combat",
                Module = "CombatVFX",
                Function = "Block",
            })
            local Data = ProfileService:GetPlayerProfile(Player)
            if Data.Character == "Gilgamesh" then
                DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
                CameraRemote:FireClient(
                    Player,
                    "ChangeUICooldown",
                    { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
                )
            end
            return
        end

        local EnemyCharacter = Target:FindFirstChild("HumanoidRootPart") and Target
        if not EnemyCharacter then
            return
        end

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Gilgamesh" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        EnemyCharacter.PrimaryPart.Anchored = true
        --	if not EnemyCharacter.Parent:FindFirstChild("PrimaryPart") or not EnemyCharacter:FindFirstChild("PrimaryPart") then return end
        --	if not EnemyCharacter.Parent:FindFirstChild("PrimaryPart") or not EnemyCharacter:FindFirstChild("PrimaryPart") then return end
        local Velocity = 135
        local Lifetime = 10

        StateManager:ChangeState(Character, "Attacking", 2.35)

        local Size = Assets.Models.Swords.GilgameshSpear.Size

        local DelayBetweenProjectiles = 1

        local StoredStartPositions = {}

        local Points = RadialPoints(EnemyCharacter.PrimaryPart.CFrame, 8, 20)

        for _, Point in ipairs(Points) do
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                {
                    Character = Character,
                    Module = "GilgameshVFX",
                    Function = "OpenPortal",
                    StartPoint = Point,
                    Type = "Loop",
                }
            )
        end

        wait(0.5)

        local MouseHit = MouseRemote:InvokeClient(Player)

        NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {
            Character = Character,

            Module = "GilgameshVFX",
            Function = "Punishment",

            StartPoints = Points,
            Target = EnemyCharacter,

            Lifetime = Lifetime,
            Velocity = Velocity,

            UnitRay = ExtraData.UnitRay,
            Distance = 185,
            MagDistance = 200,
        })

        for Index = 1, 8 do
            local CurrentStartPosition = Points[Index]

            local Points = RaycastManager:GetSquarePoints(CurrentStartPosition, Size.X * 2, Size.X * 2)

            local Direction = (EnemyCharacter.PrimaryPart.Position - CurrentStartPosition.Position).Unit

            coroutine.wrap(function()
                wait(DelayBetweenProjectiles)
                RaycastManager:CastProjectileHitbox({
                    Points = Points,
                    Direction = Direction,
                    Velocity = Velocity + 5,
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
                            DamageManager.DeductDamage(
                                Character,
                                Target.Parent,
                                KeyData.SerializedKey,
                                CharacterName,
                                { Type = "Combat" }
                            )
                        end
                    end,
                    Ignore = { Character, workspace.World.Visuals },
                })
            end)()
        end
        EnemyCharacter.PrimaryPart.Anchored = false
    end,
}

return Gilgamesh
