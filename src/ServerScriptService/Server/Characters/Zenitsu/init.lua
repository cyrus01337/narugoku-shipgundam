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

local RotatedRegion3 = require(Shared.RotatedRegion3)
local SoundManager = require(Shared.SoundManager)

local HitboxModule = require(script.Parent.Parent.Combat.Combat.HitboxModule)

local RaycastManager = require(Shared.RaycastManager)
local TaskScheduler = require(Utility.TaskScheduler)

local Ragdoll = require(ServerStorage.Modules.Ragdoll)

local ProfileService = require(Server.ProfileService)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.World.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

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

    if Target and Target:IsDescendantOf(workspace.World.Live) then
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

-- sheate system , variations, hitbox for thudnerflash and clap, rumble and flash (whirlwind copy), six fold thunder flash and clap, sleep bar full effect

local Zenitsu = {
    ["FirstAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        StateManager:ChangeState(Character, "Guardbroken", 1.5)

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "ZenitsuVFX", Function = "ThunderClapandFlash" }
        )
        TaskScheduler:AddTask(0.725, function()
            HitboxModule.GetTouchingParts(Player, {
                Delay = 0.935,
                ExistTime = 2,
                Type = "Sword",
                KeysLogged = math.random(1, 3),
                Size = Vector3.new(12.417, 4.517, 58.929),
                Transparency = 1,
                PositionCFrame = Root.CFrame * CFrame.new(0, 0, -18.5),
            }, KeyData.SerializedKey, CharacterName)
            NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {
                Character = Character,
                Module = "ZenitsuVFX",
                Function = "Menbere",
                Distance = 100,
                ContactPointCFrame = Root.CFrame,
            })
        end)

        --local Aiming = GlobalFunctions.NewInstance("BoolValue",{Parent = Character, Name = "Aiming"},.45)
        AnimationRemote:FireClient(Player, "ThunderClapAndFlash", "Play")

        local Data = ProfileService:GetPlayerProfile(Player)

        SpeedManager.changeSpeed(Character, 1, 2.35, 5e5)

        wait(0.75)

        NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {
            Character = Character,
            Module = "ZenitsuVFX",
            Function = "Dash",
            Distance = 100,
            ContactPointCFrame = Root.CFrame,
        })

        CameraRemote:FireClient(Player, "CreateFlashUI", CreateFrameData)

        local EndPoint = Root.CFrame * CFrame.new(0, 0, -44)
        local Rotation = Root.CFrame - Root.Position

        Root.CFrame = CFrame.new(EndPoint.Position) * Rotation

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)

        wait(0.85)
        -- SoundManager:AddSound("UnSheath",{Parent = Root, Volume = 1},"Client")
    end,

    ["SecondAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local HumanoidRootPart, Humanoid =
            Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        AnimationRemote:FireClient(Player, "StartSleep", "Play")
        -- SoundManager:AddSound("ScreamingZenit",{Parent = HumanoidRootPart, Volume = 2},"Client")
        StateManager:ChangeState(Character, "Guardbroken", 4e4)

        delay(0.2, function()
            CameraRemote:FireClient(Player, "TweenObject", {
                LifeTime = 0.35,
                EasingStyle = Enum.EasingStyle.Linear,
                EasingDirection = Enum.EasingDirection.Out,
                Return = true,
                Properties = { FieldOfView = 100 },
            })
        end)
        TaskScheduler:AddTask(1, function()
            AnimationRemote:FireClient(Player, "Sleeping")

            NetworkStream.FireOneClient(
                Player,
                "ClientRemote",
                1,
                { Character = Character, Module = "ZenitsuVFX", Function = "SleepChangeCameraTorso" }
            )
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                { Character = Character, Module = "ZenitsuVFX", Function = "Sleeping" }
            )
            AnimationRemote:FireClient(Player, "Sleeping", "Play", { FadeTime = 0.2, Looped = true })
            SpeedManager.changeSpeed(Character, 0, 4e4, 4e4)
            HumanoidRootPart.Anchored = true

            local ModeData = StateManager:ReturnData(Character, "Mode")
            local ModeNumber = Player:WaitForChild("Mode", 60)

            if ModeData.Mode then
                return
            end

            while true do
                local ZenitsuData = AbilityData.ReturnData(Player, "SecondAbility", "Zenitsu")
                ZenitsuData.Sleeping = true

                local SkillData = StateManager:ReturnData(Character, "LastSkill")
                if Player:FindFirstChild("ZenitsuBar") then
                    if Player.ZenitsuBar.Value <= 295 then
                        Player.ZenitsuBar.Value += 0.55
                    end
                end
                CameraRemote:FireClient(
                    Player,
                    "CustomBarToValue",
                    { Character = "Zenitsu", WhichValue = "ZenitsuBar" }
                )
                if ModeNumber.Value <= ModeData.MaxModeValue then
                    ModeNumber.Value += 0.2
                end
                wait()
                --if Player.ZenitsuBar.Value >= 295 then break end
                if SkillData.Skill == "Swing" or StateManager:Peek(Character, "Stunned") then
                    break
                end
                RunService.Heartbeat:Wait()
            end
            local ZenitsuData = AbilityData.ReturnData(Player, "SecondAbility", "Zenitsu")
            ZenitsuData.Sleeping = false

            NetworkStream.FireOneClient(
                Player,
                "ClientRemote",
                1,
                { Character = Character, Module = "ZenitsuVFX", Function = "SleepRevertCamera" }
            )

            coroutine.wrap(function()
                while Player:FindFirstChild("ZenitsuBar") do
                    Player.ZenitsuBar.Value -= 3
                    CameraRemote:FireClient(
                        Player,
                        "CustomBarToValue",
                        { Character = "Zenitsu", WhichValue = "ZenitsuBar" }
                    )
                    wait(2)
                    if ZenitsuData.Sleeping then
                        break
                    end
                    if Player.ZenitsuBar.Value <= 0 then
                        break
                    end
                end
                CameraRemote:FireClient(
                    Player,
                    "CustomBarToValue",
                    { Character = "Zenitsu", WhichValue = "ZenitsuBar" }
                )
            end)()
            HumanoidRootPart.Anchored = false

            StateManager:ChangeState(Character, "Guardbroken", 0.01)
            AnimationRemote:FireClient(Player, "Sleeping", "Stop")
            AnimationRemote:FireClient(Player, "StartSleep", "Stop")

            SpeedManager.changeSpeed(Character, 14, 0.15, 4e4)
            GlobalFunctions.NewInstance("BoolValue", { Parent = Character, Name = "StopSleeping" }, 1)

            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
        end)
    end,

    ["ThirdAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local HumanoidRootPart, Humanoid =
            Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Bar = Player:FindFirstChild("ZenitsuBar")

        if Bar.Value <= 75 then
            local WarningText = "Not Enough Sleeping Bar"

            GUIRemote:FireClient(Player, "Notification", {
                Function = "Initiate",
                Player = Player,
                Color = Color3.new(1, 0.215686, 0.160784),
                Text = ("<font color= 'rgb(%s, %s, %s)'>&lt; " .. WarningText .. "&gt;</font> for this skill."),
            })
            return
        end

        StateManager:ChangeState(Character, "Guardbroken", 0.5)

        GlobalFunctions.NewInstance("BoolValue", { Parent = Character, Name = "Aiming" }, 0.75)
        AnimationRemote:FireClient(Player, "DistanceThunder", "Play", { AdjustSpeed = 1.35 })
        SpeedManager.changeSpeed(Character, 0, 0.85, 4e4)

        wait(0.2)
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "ZenitsuVFX", Function = "Distance Thunder" }
        )
        CameraRemote:FireClient(
            Player,
            "CameraShake",
            { FirstText = 6, SecondText = 12, Amount = 2, Time = 0.1, Type = "Loop" }
        )

        local CreateFrameData = {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Color = Color3.fromRGB(202, 195, 97),
            Duration = 0.75,
        }
        CameraRemote:FireClient(Player, "CreateFlashUI", CreateFrameData)

        local StartPoint = Character["Right Arm"].CFrame * CFrame.new(0, -1, 0)

        local Size = Assets.Models.Misc.Volleyballs.volleyball2.Size

        local Points = RaycastManager:GetSquarePoints(StartPoint, Size.X * 2, Size.X * 2)

        local Velocity = 300
        local Lifetime = 10

        local MouseHit = MouseRemote:InvokeClient(Player)
        local Direction = (MouseHit.Position - StartPoint.Position).Unit

        NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {
            Character = Character,
            Module = "RazorVFX",
            Function = "HardThrow",
            StartPoint = StartPoint,
            MouseHit = MouseHit,
            Lifetime = Lifetime,
            Velocity = Velocity,
            Distance = 100,
            Direction = Direction,
            Ponts = Points,
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
                    10
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

        local Bar = Player:FindFirstChild("ZenitsuBar")

        if Bar.Value <= 130 then
            local WarningText = "Not Enough Sleeping Bar"

            GUIRemote:FireClient(Player, "Notification", {
                Function = "Initiate",
                Player = Player,
                Color = Color3.new(1, 0.215686, 0.160784),
                Text = ("<font color= 'rgb(%s, %s, %s)'>&lt; " .. WarningText .. "&gt;</font> for this skill."),
            })
            return
        end

        StateManager:ChangeState(Character, "Guardbroken", 1)

        local Victim = RaycastTarget(80, Character) or GetNearestFromMouse(Character, 8)
        if not Victim then
            return
        end

        StateManager:ChangeState(Character, "Attacking", 0.3)

        local VRoot = Victim:FindFirstChild("HumanoidRootPart")

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "ZenitsuVFX", Function = "Zap", Position = VRoot.Position }
        )
        AnimationRemote:FireClient(Player, "RiceSpirit", "Play", { AdjustSpeed = 1.15 })

        delay(0.15, function()
            DamageManager.DeductDamage(
                Character,
                Victim,
                KeyData.SerializedKey,
                CharacterName,
                { Type = "Sword", KeysLogged = ExtraData.KeysLogged }
            )
        end)

        wait(0.235)
        Humanoid.AutoRotate = false
        -- SoundManager:AddSound("Lightning_Release_2",{Parent = Root},"Client")
        local Beam = ReplicatedStorage.Assets.Effects.Meshes.Whirldwindball:Clone()
        Beam.BrickColor = BrickColor.new("Pastel light blue")
        Beam.Shape = "Cylinder"
        Beam.CanCollide = false
        Beam.Anchored = true
        Beam.Material = "Neon"
        local End = (Root.CFrame.Position - VRoot.CFrame.Position).Magnitude
        Beam.Size = Vector3.new(End, 5, 5)
        Beam.CFrame = CFrame.new(Root.CFrame.Position, VRoot.CFrame.Position)
            * CFrame.new(0, 0, -End / 2)
            * CFrame.fromEulerAnglesXYZ(0, math.rad(90), 0)
        Beam.Parent = workspace.World.Visuals

        Debris:AddItem(Beam, 0.25)
        GlobalFunctions.TweenFunction({
            ["Instance"] = Beam,
            ["EasingStyle"] = Enum.EasingStyle.Quad,
            ["EasingDirection"] = Enum.EasingDirection.Out,
            ["Duration"] = 0.25,
        }, { ["Size"] = Vector3.new(End, 0, 0) })
        SpeedManager.changeSpeed(Character, 0, 1.35, 4e4)

        Root.CFrame = VRoot.CFrame * CFrame.new(0, 0, 4)

        TaskScheduler:AddTask(0.5, function()
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                200,
                { Character = Character, Module = "ZenitsuVFX", Function = "Rice Spirit" }
            )
            CameraRemote:FireClient(
                Player,
                "CameraShake",
                { FirstText = 8, SecondText = 12, Amount = 2, Time = 0.1, Type = "Loop" }
            )
            -- SoundManager:AddSound("UnSheath",{Parent = Root, Volume = 1},"Client")
            Humanoid.AutoRotate = true
            DamageManager.DeductDamage(
                Character,
                Victim,
                KeyData.SerializedKey,
                CharacterName,
                { Type = "Sword", KeysLogged = ExtraData.KeysLogged }
            )
        end)

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
    end,
}
return Zenitsu
