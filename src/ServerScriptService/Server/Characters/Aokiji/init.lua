--|| Services ||--
local Players = game:GetService("Players")

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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

local RaycastManager = require(Shared.RaycastManager)
local TaskScheduler = require(Utility.TaskScheduler)

local Ragdoll = require(ServerStorage.Modules.Ragdoll)

local HitboxModule = require(Server.Combat.Combat.HitboxModule)

local ProfileService = require(Server.ProfileService)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

local PositionCalc = workspace.World.Enviornment.TestPart.Position.Y + 0.125

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

local function CreateFloorFunc(
    Random1,
    Random2,
    CFrame1,
    CFrame2,
    DesignatedCFrame,
    Duration,
    Size,
    Character,
    Transparency,
    HitList
)
    local IceFloor = Instance.new("Part")
    IceFloor.Size = Size
    IceFloor.CanCollide = true
    IceFloor.Anchored = true
    IceFloor.Name = "iceFloorHitbox"
    IceFloor.CFrame = CFrame.new(CFrame1, CFrame1 + CFrame2) * CFrame.Angles(math.rad(-90), 0, 0)
    IceFloor.Transparency = Transparency or 0.25
    IceFloor.CFrame = IceFloor.CFrame * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)
    IceFloor.Parent = workspace.World.Enviornment

    if Duration == nil then
        Duration = 2
    end

    coroutine.resume(coroutine.create(function()
        wait(Duration)
        HitList = {}
        local Tween = TweenService:Create(
            IceFloor,
            TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
            { ["Size"] = Vector3.new(0, 0, 0) }
        )
        Tween:Play()
        Tween:Destroy()

        Debris:AddItem(IceFloor, 0.5)
    end))
    return IceFloor
end

local function FloorFreeze(
    Area,
    RaycastBelow,
    Random1,
    Random2,
    Debounce,
    Duration,
    Size,
    Character,
    Transparency,
    CharacterName,
    KeyData,
    Hitlist
)
    Hitlist = {}
    local CFrameIndex = CFrame.new(Area.p)

    local RayParam = RaycastParams.new()
    RayParam.FilterType = Enum.RaycastFilterType.Include
    RayParam.FilterDescendantsInstances = { workspace.World.Map, workspace.World.Enviornment }

    local Origin = CFrameIndex.Position
    local Direction = CFrameIndex.UpVector * -RaycastBelow

    local RaycastResult = workspace:Raycast(Origin, Direction, RayParam) or {
        Position = Origin + Direction,
    }

    local Target, Position, Surface = RaycastResult.Target, RaycastResult.Position, RaycastResult.Normal

    if
        Target
        and (Target.Name ~= "iceFloorHitbox" or Debounce)
        and (PositionCalc < Position.Y or Position.Y < workspace.World.Enviornment.TestPart2.Position.Y)
    then
        local Ice = nil
        Ice =
            CreateFloorFunc(Random1, Random2, Position, Surface, nil, Duration, Size, Character, Transparency, Hitlist)
        Ice.Touched:Connect(function(Hit)
            if
                Hit:IsDescendantOf(workspace.World.Live)
                and Hit.Parent:FindFirstChild("Humanoid")
                and not Hit:IsDescendantOf(Character)
                and not Hit.Parent:FindFirstChild("floorFreezehit")
                and not StateManager:Peek(Hit.Parent, "Blocking")
                and not table.find(Hitlist, Hit.Parent)
            then
                table.insert(Hitlist, Hit.Parent)
                VfxHandler.IceProc(Hit.Parent, 6)

                coroutine.wrap(function()
                    wait(0.5)
                    for Index = 1, 12 do
                        DamageManager.DeductDamage(
                            Character,
                            Hit.Parent,
                            KeyData.SerializedKey,
                            CharacterName,
                            { Type = "Combat" }
                        )
                        wait(0.1)
                    end
                    local BodyVelocity = Instance.new("BodyVelocity")
                    BodyVelocity.Velocity = Vector3.new(0, 35, math.random(1, 2) == 1 and -30 or 30)
                    BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
                    BodyVelocity.Parent = Hit.Parent.PrimaryPart

                    Debris:AddItem(BodyVelocity, 0.3)
                    Ragdoll.DurationRagdoll(Hit.Parent, 1)

                    NetworkStream.FireClientDistance(
                        Character,
                        "ClientRemote",
                        150,
                        { Victim = Hit.Parent, Module = "AokijiVFX", Function = "Ice FreezeBreak" }
                    )
                end)()
            end
        end)

        if Target.CanCollide then
            Ice.CanCollide = false
            return
        else
            Ice.CanCollide = true
            return
        end
    end
    if Position.Y <= PositionCalc and workspace.World.Enviornment.TestPart2.Position.Y < Position.Y then
        local CFrameCalculation = CFrame.new(Position.X, PositionCalc + 5, Position.Z)
        RaycastBelow = 6

        local RayParam = RaycastParams.new()
        RayParam.FilterDescendantsInstances = { workspace.World.Map, workspace.World.Enviornment }
        RayParam.FilterType = Enum.RaycastFilterType.Include

        local RaycastResult = workspace:Raycast(
            CFrameCalculation.Position,
            CFrameCalculation.UpVector * -RaycastBelow,
            RayParam
        ) or {}
        local Target, Position, Surface = RaycastResult.Target, RaycastResult.Position, RaycastResult.Normal

        if Target == nil then
            CreateFloorFunc(
                Random1,
                Random2,
                nil,
                nil,
                CFrame.new(Position.X, PositionCalc, Position.Z),
                Duration,
                Size,
                Character,
                Transparency
            )
        end
    end
end

local Aokiji = {
    ["FirstAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Mouse = MouseRemote:InvokeClient(Player)
        if (Root.Position - Mouse.Position).Magnitude >= 40 then
            return
        end

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Aokiji" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")

        Character["AokijiSword"].Blade.Transparency = 1
        Character["AokijiSword"].Blade.smoke.Enabled = false
        Character["AokijiSword"].Blade.sparkz.Enabled = false

        AnimationRemote:FireClient(Player, "SpearThrow", "Play", { AdjustSpeed = 0.5 })

        SpeedManager.changeSpeed(Character, 4, 0.5, 3, false) --function(Character,Speed,Duration,Priority)
        StateManager:ChangeState(Character, "Attacking", 0.35)

        local MouseHit = MouseRemote:InvokeClient(Player)

        local StartPoint = Character["Right Arm"].CFrame * CFrame.new(0, 0, -5)
        GlobalFunctions.NewInstance("BoolValue", { Parent = Character, Name = "Aiming" }, 0.35)

        wait(0.35)

        local MouseHit = MouseRemote:InvokeClient(Player)

        local Size = Assets.Models.Swords.GilgameshSpear.Size

        local Points = RaycastManager:GetSquarePoints(StartPoint, Size.X * 2, Size.X * 2)

        local Velocity = 100
        local Lifetime = 10

        local DelayBetweenProjectiles = 1

        local Direction = (MouseHit.Position - StartPoint.Position).Unit

        NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {
            Character = Character,

            Module = "AokijiVFX",
            Function = "Ice Spear",

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
                    7.5
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
        wait(0.85)
        Character["AokijiSword"].Blade.Transparency = 0
        Character["AokijiSword"].Blade.smoke.Enabled = true
        Character["AokijiSword"].Blade.sparkz.Enabled = true
    end,

    ["SecondAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local HumanoidRootPart, Humanoid =
            Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Aokiji" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        --local Victim = RaycastTarget(300,Character) or GetNearestFromMouse(Character,25)
        --if not Victim then return end

        AnimationRemote:FireClient(Player, "AokijiSword", "Play")

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            150,
            { Character = Character, Module = "AokijiVFX", Function = "Ice Floor" }
        )

        StateManager:ChangeState(Character, "IFrame", 1, { IFrameType = "" })
        StateManager:ChangeState(Character, "Attacking", 2.65)

        SpeedManager.changeSpeed(Character, 4, 2.35, 3) --function(Character,Speed,Duration,Priority)
        --NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Victim = Victim, Module = "SanjiModeVFX", Function = "TeleportKick", Duration = .125})

        --	NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "TanjiroVFX", Function = "WaterWheel", Debounce = not StateManager:Peek(Character,"InAir") and true and false})
        local AokijiData = AbilityData.ReturnData(Player, "SecondAbility", "Aokiji")

        TaskScheduler:AddTask(0.35, function()
            -- SoundManager:AddSound("SwordSwing",{Parent = HumanoidRootPart, Volume = 5},"Client")
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                { Character = Character, Module = "AokijiVFX", Function = "Ice Sword", Index = 100 }
            )
            HitboxModule.MagnitudeModule(
                Character,
                { Range = 10, KeysLogged = 1, Type = "Sword" },
                KeyData.SerializedKey,
                CharacterName
            )

            wait(0.35)
            for Index = 1, 2 do
                HitboxModule.MagnitudeModule(
                    Character,
                    { Delay = 0.185, Range = 7.5, KeysLogged = 1, Type = "Sword" },
                    KeyData.SerializedKey,
                    CharacterName
                )
                -- SoundManager:AddSound("SwordSwing",{Parent = HumanoidRootPart, Volume = 5},"Client")
                NetworkStream.FireClientDistance(
                    Character,
                    "ClientRemote",
                    200,
                    { Character = Character, Module = "AokijiVFX", Function = "Ice Sword", Index = Index }
                )
                wait(0.25)
            end
            wait(0.35)
            AokijiData.Guardbreak = true
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                { Character = Character, Module = "AokijiVFX", Function = "Ice Sword", Index = 3 }
            )
            HitboxModule.MagnitudeModule(
                Character,
                { Delay = 0.1, Range = 7.5, KeysLogged = 1, Type = "Sword" },
                KeyData.SerializedKey,
                CharacterName
            )

            CameraRemote:FireClient(Player, "CameraShake", { FirstText = 4, SecondText = 6 })
            -- SoundManager:AddSound("HeavySwordSwing",{Parent = HumanoidRootPart, Volume = 5},"Client")

            wait(0.2)
            AokijiData.Guardbreak = false
        end)

        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(2e4, 2e4, 2e4)
        BodyVelocity.Name = "fdfsfdsfsdfszxzzdxfzf"
        BodyVelocity.Parent = HumanoidRootPart
        Debris:AddItem(BodyVelocity, 0.35)

        while BodyVelocity and RunService.Stepped:Wait() do
            BodyVelocity.Velocity = HumanoidRootPart.CFrame.LookVector * 100

            if HumanoidRootPart:FindFirstChild("fdfsfdsfsdfszxzzdxfzf") == nil then
                break
            end
        end
    end,

    ["ThirdAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local HumanoidRootPart, Humanoid =
            Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Aokiji" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        AnimationRemote:FireClient(Player, "IceStomp", "Play")
        wait(0.385)

        local AokijiData = AbilityData.ReturnData(Player, "ThirdAbility", "Aokiji").HitList
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            150,
            { Character = Character, Module = "AokijiVFX", Function = "Ice Freeze" }
        )

        for Index = 1, 18 do
            FloorFreeze(
                HumanoidRootPart.CFrame * CFrame.new(0, 1, -Index * 3.8),
                100,
                10,
                15,
                nil,
                1.75,
                Vector3.new(10, 0.989, 10),
                Character,
                1,
                CharacterName,
                KeyData,
                AokijiData
            )
            wait()
        end
    end,

    ["FourthAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Aokiji" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        StateManager:ChangeState(Character, "Attacking", 0.385)

        AnimationRemote:FireClient(Player, "IceStomp", "Play")
        SpeedManager.changeSpeed(Character, 4, 1, 3, false) --function(Character,Speed,Duration,Priority)

        wait(0.45)
        if StateManager:Peek(Character, "Stunned") then
            return
        end
        local HitResult, ValidEntities = HitboxModule.GetTouchingParts(
            Player,
            {
                ExistTime = 2,
                Type = "Combat",
                Size = Vector3.new(25.147, 18.374, 42.655),
                Transparency = 1,
                PositionCFrame = Root.CFrame * CFrame.new(0, 0, -25),
            },
            KeyData.SerializedKey,
            CharacterName
        )
        if HitResult then
            for Index = 1, #ValidEntities do
                local Entity = ValidEntities[Index]

                VfxHandler.IceProc(Entity, 3)

                local BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.Velocity = Vector3.new(0, 35, math.random(1, 2) == 1 and -30 or 30)
                BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
                BodyVelocity.Parent = Entity.PrimaryPart

                Debris:AddItem(BodyVelocity, 0.3)
                Ragdoll.DurationRagdoll(Entity, 1)
            end
        end
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "AokijiVFX", Function = "Ice Stomp" }
        )
    end,
}

return Aokiji
