--|| Services ||--
local Players = game:GetService("Players")

local TweenService = game:GetService("TweenService")

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

local World = workspace.World

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

local ProfileService = require(Server.ProfileService)

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

local Natsu = {

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
                if Data.Character == "Natsu" then
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

                Debris:AddItem(Weld, 3)

                coroutine.wrap(function()
                    wait(0.5)
                    CameraRemote:FireClient(
                        Player,
                        "CameraShake",
                        { FirstText = 2, SecondText = 12, Amount = 13, Time = 0.1, Type = "Loop" }
                    )
                    wait(1.8)
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
                    CameraRemote:FireClient(Player, "CameraShake", { FirstText = 6, SecondText = 12 })
                    DamageManager.DeductDamage(
                        Character,
                        Victim,
                        KeyData.SerializedKey,
                        CharacterName,
                        { SecondType = "Choke", Type = "Combat", KeysLogged = math.random(1, 3) }
                    )
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
                        Module = "NatsuVFX",
                        Function = "Fire Dragon's Iron Fist",
                    }
                )

                for _ = 1, 10 do
                    StateManager:ChangeState(Character, "IFrame", 0.5)
                    DamageManager.DeductDamage(
                        Character,
                        Victim,
                        KeyData.SerializedKey,
                        CharacterName,
                        { SecondType = "Choke", Type = "Combat", KeysLogged = math.random(1, 3) }
                    )
                    wait(0.1175)
                end
                Weld:Destroy()
                --StateManager:ChangeState(Character,"Guardbroken",1.25,{AllowedSkills = {["Dash"] = true, ["Block"] = true}})
            end
            Hum.AutoRotate = true
            Root.Anchored = false
        end
    end,

    ["SecondAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Natsu" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        StateManager:ChangeState(Character, "Guardbroken", 2.5)

        --[[ Fire Animation ]]
        --
        AnimationRemote:FireClient(Player, "CrimsonLotus", "Play")

        --[[ Skill Start Up, Fly Upwards ]]
        --
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Distance = 100, Module = "NatsuVFX", Function = "CrimsonLotusStart" }
        )

        --[[ BodyMover ]]
        --
        local MAX_HEIGHT = 50
        local GoalPosition = Character.HumanoidRootPart.Position + Vector3.new(0, MAX_HEIGHT, 0)

        --[[ Raycast ]]
        --
        local StartPosition = Character.HumanoidRootPart.Position
        local EndPosition = Character.HumanoidRootPart.CFrame * CFrame.new(0, MAX_HEIGHT, 0)

        local RayData = RaycastParams.new()
        RayData.FilterDescendantsInstances = { Character, World.Live, World.Visuals } or World.Visuals
        RayData.FilterType = Enum.RaycastFilterType.Exclude
        RayData.IgnoreWater = true

        local ray = workspace:Raycast(StartPosition, EndPosition.Position, RayData)
        if ray then
            local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
            if partHit then
                MAX_HEIGHT = -Vector3.new(0, 10, 0)
                partHit = nil
                pos = nil
                normVector = nil
                ray = nil
            end
        end

        local BodyPosition = Instance.new("BodyPosition")
        BodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        BodyPosition.P = 200
        BodyPosition.D = 35
        BodyPosition.Parent = Character.HumanoidRootPart
        BodyPosition.Position = GoalPosition
        Debris:AddItem(BodyPosition, 1.5)

        wait(1.5)

        --[[ Predefine a No Contact Function to Call ]]
        --
        local function NoContact()
            local MousePos = MouseRemote:InvokeClient(Player).Position
            local Direction = (Character.HumanoidRootPart.CFrame.LookVector).Unit * 100
            BodyPosition:Destroy()
            --[[ Move Towards Goal ]]
            --
            local BodyPosition = Instance.new("BodyPosition")
            BodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            BodyPosition.P = 200
            BodyPosition.D = 50
            BodyPosition.Position = Direction
            BodyPosition.Parent = Character.HumanoidRootPart
            Debris:AddItem(BodyPosition, 1.5)

            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                {
                    Character = Character,
                    ContactPoint = Direction,
                    Distance = 100,
                    Module = "NatsuVFX",
                    Function = "CrimsonLotusLand",
                }
            )
        end

        --[[ Crash Down to Mouse Position ]]
        --
        local RAY_DISTANCE = 1000
        local MAX_DISTANCE = 200
        local REACHED_DISTANCE = 8

        local SKILL_TIME_ELAPSED = 2
        local MousePos = MouseRemote:InvokeClient(Player).Position
        local Direction = (MousePos - Character.HumanoidRootPart.Position).Unit * RAY_DISTANCE
        local FoundContact = false

        --[[ Raycast ]]
        --
        local StartPosition = Character.HumanoidRootPart.Position
        local EndPosition = Direction

        local RayData = RaycastParams.new()
        RayData.FilterDescendantsInstances = { Character, World.Live, World.Visuals } or World.Visuals
        RayData.FilterType = Enum.RaycastFilterType.Exclude
        RayData.IgnoreWater = true

        local ray = workspace:Raycast(StartPosition, EndPosition, RayData)

        if ray then
            local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
            if partHit then
                if (Character.HumanoidRootPart.Position - pos).Magnitude > MAX_DISTANCE then
                    FoundContact = false
                    return NoContact(Direction)
                end

                BodyPosition:Destroy()
                --[[ Move Towards Goal ]]
                --
                local BodyPosition = Instance.new("BodyPosition")
                BodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                BodyPosition.P = 200
                BodyPosition.D = 20
                BodyPosition.Parent = Character.HumanoidRootPart
                BodyPosition.Position = pos
                Debris:AddItem(BodyPosition, 1.5)
                FoundContact = true

                --[[ Check if a landing spot is found, otherwise, return false to do a normal landing. ]]
                --
                local oldTime = os.clock()
                while (Character.HumanoidRootPart.Position - pos).Magnitude >= REACHED_DISTANCE do
                    local newClock = os.clock()
                    if newClock - oldTime >= SKILL_TIME_ELAPSED then
                        warn("skill time exceeded time restraint")
                        FoundContact = false
                        NoContact(Direction)
                        break
                    end
                    wait()
                end

                if not FoundContact then
                    return NoContact(Direction)
                end

                --[[ Found a Landing Spot. ]]
                --

                local ValidEntities = RaycastManager:GetEntitiesFromPoint(
                    pos,
                    workspace.World.Live:GetChildren(),
                    { [Character] = true },
                    30
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
                --[[ TEMPORARY screen effects ]]
                --
                CameraRemote:FireClient(Player, "CameraShake", {
                    FirstText = 6,
                    SecondText = 12,
                })
                NetworkStream.FireClientDistance(
                    Character,
                    "ClientRemote",
                    10,
                    { Character = Character, Distance = 10, Module = "NatsuVFX", Function = "NatsuScreen" }
                )

                --[[ Fire Found Landing Effects ]]
                --
                BodyPosition:Destroy()
                NetworkStream.FireClientDistance(
                    Character,
                    "ClientRemote",
                    200,
                    {
                        Character = Character,
                        Distance = 100,
                        ContactPoint = pos,
                        Module = "NatsuVFX",
                        Function = "CrimsonLotusLand",
                    }
                )
            end
        end

        --[[ Nothing found in Ray, proceeding down. ]]
        --
        if not FoundContact then
            NoContact(Direction)
        end
    end,

    ["ThirdAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Natsu" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        --[[ Set States ]]
        --
        StateManager:ChangeState(Character, "Guardbroken", 2)
        SpeedManager.changeSpeed(Character, 4, 2, 1.25)

        --[[ Fire Animation ]]
        --
        AnimationRemote:FireClient(Player, "PurgatoryDragon", "Play")

        --[[ Fire Client ]]
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            {
                Character = Character,
                Distance = 100,
                ContactPoint = Root.CFrame,
                Module = "NatsuVFX",
                Function = "PurgatoryDragonFire",
            }
        )
        wait(1)

        if StateManager:Peek(Character, "Stunned") then
            return
        end

        local ValidEntities = RaycastManager:GetEntitiesFromPoint(
            Root.CFrame,
            workspace.World.Live:GetChildren(),
            { [Character] = true },
            30
        )
        for Index = 1, #ValidEntities do
            local Entity = ValidEntities[Index]
            VfxHandler.FireProc({ Character = Character, Victim = Entity, Duration = 3, Damage = 1 })
            DamageManager.DeductDamage(Character, Entity, KeyData.SerializedKey, CharacterName, { Type = "Combat" })
        end
        --[[ TEMPORARY screen effects ]]
        --
        CameraRemote:FireClient(Player, "CameraShake", {
            FirstText = 6,
            SecondText = 12,
        })
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            10,
            { Character = Character, Distance = 10, Module = "NatsuVFX", Function = "NatsuScreen" }
        )
    end,

    ["FourthAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Natsu" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        --[[ Set States ]]
        --
        StateManager:ChangeState(Character, "Guardbroken", 2)
        SpeedManager.changeSpeed(Character, 4, 2, 1.25)

        local AimingValue = GlobalFunctions.NewInstance("BoolValue", { Parent = Character, Name = "Aiming" }, 2)

        --[[ Fire Animation ]]
        --
        AnimationRemote:FireClient(Player, "DragonRoar", "Play", { AdjustSpeed = 0.75 })

        wait(0.35)
        if StateManager:Peek(Character, "Stunned") then
            return
        end
        --[[ Fire Client ]]
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            {
                Character = Character,
                Distance = 100,
                ContactPoint = Root.CFrame,
                Module = "NatsuVFX",
                Function = "FireDragonRoar",
            }
        )

        wait(1.15)

        HitboxModule.GetTouchingParts(
            Player,
            {
                ExistTime = 2,
                Type = "Combat",
                KeysLogged = 1,
                Size = Vector3.new(12.565, 10.009, 53.62),
                Transparency = 1,
                PositionCFrame = Root.CFrame * CFrame.new(0, 0, -25),
            },
            KeyData.SerializedKey,
            CharacterName
        )

        --[[ TEMPORARY screen effects ]]
        --
        CameraRemote:FireClient(Player, "CameraShake", {
            FirstText = 6,
            SecondText = 12,
        })
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            10,
            { Character = Character, Distance = 10, Module = "NatsuVFX", Function = "NatsuScreen" }
        )
    end,
}

return Natsu
