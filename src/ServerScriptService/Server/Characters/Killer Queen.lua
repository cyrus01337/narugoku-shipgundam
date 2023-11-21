--|| Services ||--
local Players = game:GetService("Players")

local TweenService = game:GetService("TweenService")

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PhysicsService = game:GetService("PhysicsService")
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
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local AbilityData = require(Metadata.AbilityData.AbilityData)

local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)
local MoveStand = require(Shared.StateManager.MoveStand)

local SoundManager = require(Shared.SoundManager)
local RaycastManager = require(Shared.RaycastManager)

local HitboxModule = require(script.Parent.Parent.Combat.Combat.HitboxModule)

local DamageManager = require(Managers.DamageManager)
local StandManager = require(Managers.StandManager)

local VfxHandler = require(Effects.VfxHandler)

local Ragdoll = require(ServerStorage.Modules.Ragdoll)

local TaskScheduler = require(Utility.TaskScheduler)

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
        return true, Target.Parent or false
    end
end

local function Lerp(Start, End, Alpha)
    return Start + (End - Start) * Alpha
end

local function BezierCurve(Start, Offset, End, Alpha)
    local FirstLerp = Lerp(Start, Offset, Alpha)
    local SecondLerp = Lerp(Offset, End, Alpha)

    local BezierLerp = Lerp(FirstLerp, SecondLerp, Alpha)

    return BezierLerp
end

local KillerQueenAnimations = ReplicatedStorage.Assets.Animations.Shared.Stands["Killer Queen"]

function SetProjectileDebounce(Projectile)
    local Debounce = Instance.new("BoolValue")
    Debounce.Parent = Projectile
    Debounce.Name = "Projectile"
    Debounce.Value = false

    return Debounce
end

--|| Init ||--

local function BreakBomb(Character, KillerQueenData, KeyData, CharacterName)
    local Player = Players:GetPlayerFromCharacter(Character)
    local Root = Character:FindFirstChild("HumanoidRootPart")

    local Stand = Character:FindFirstChild(Character.Name .. " - Stand")
    local Weld = Stand.PrimaryPart.Weld

    local StandHum = Stand:FindFirstChild("Humanoid")

    coroutine.wrap(function()
        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = 10, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)

        local LastHitData = StateManager:ReturnData(Character, "LastHit")

        StateManager:ChangeState(workspace.World.Live[LastHitData.LastTarget], "Blocking", false)

        if LastHitData.LastTarget == "" then
            KillerQueenData.Cooldown = 10
            KillerQueenData.Damage = 5
            KillerQueenData.HasBomb = false
            return
        end
        KillerQueenData.Damage = 15
        KillerQueenData.Cooldown = 10

        -- local Sound = SoundManager:AddSound("SwitchOn",{Parent = Root, Volume = 5}, "Server" ,{Player = Player, Distance = 10})

        local Anim = StandHum:LoadAnimation(KillerQueenAnimations["KillerQueenSwitch"])
        Anim:Play()
        Anim:AdjustSpeed(0.35)

        wait(1.225)
        -- local Sound = SoundManager:AddSound("Click",{Parent = Root, Volume = 7.5}, "Server" ,{Player = Player, Distance = 10})

        wait(0.2)
        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
        BodyVelocity.Velocity = CFrame.new(
            Root.Position,
            Root.Position + (Root.CFrame.lookVector * 10) + (Root.CFrame.upVector * -10)
        ).lookVector * 100
        BodyVelocity.Parent = workspace.World.Live[LastHitData.LastTarget]:FindFirstChild("HumanoidRootPart")
        Debris:AddItem(BodyVelocity, 0.25)
        Ragdoll.DurationRagdoll(workspace.World.Live[LastHitData.LastTarget], 1)

        VfxHandler.FireProc({
            Character = Character,
            Victim = workspace.World.Live[LastHitData.LastTarget],
            Duration = 3,
            Damage = 1,
        })
        DamageManager.DeductDamage(
            Character,
            workspace.World.Live[LastHitData.LastTarget],
            KeyData.SerializedKey,
            CharacterName,
            { Type = "Combat", KeysLogged = 1 }
        )
        CameraRemote:FireClient(Player, "CreateBlur", { Size = 15, Length = 0.25 })
        NetworkStream.FireOneClient(
            Player,
            "ClientRemote",
            5,
            {
                Character = Character,
                Victim = workspace.World.Live[LastHitData.LastTarget],
                Module = "Killer QueenVFX",
                Function = "RemoveBomb",
                Distance = 100,
            }
        )
        if Players:GetPlayerFromCharacter(workspace.World.Live[LastHitData.LastTarget]) then
            NetworkStream.FireOneClient(
                Players:GetPlayerFromCharacter(workspace.World.Live[LastHitData.LastTarget]),
                "ClientRemote",
                5,
                {
                    Character = Character,
                    Victim = workspace.World.Live[LastHitData.LastTarget],
                    Module = "Killer QueenVFX",
                    Function = "RemoveBomb",
                    Distance = 100,
                }
            )
        end
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            350,
            {
                Character = Character,
                Victim = workspace.World.Live[LastHitData.LastTarget],
                Module = "Killer QueenVFX",
                Function = "Switch Bomb",
                Distance = 100,
            }
        )
        StateManager:ChangeState(Character, "LastHit", 0.5, { LastTarget = "" })
        KillerQueenData.Damage = 5
    end)()
    KillerQueenData.HasBomb = false
end

local Killer_Queen = {

    ["FirstAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)

        local Stand = Character:FindFirstChild(Character.Name .. " - Stand")
        local Weld = Stand.PrimaryPart.Weld

        StateManager:ChangeState(Character, "Stunned", 3)

        local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")

        local TimeEvaluation = os.clock() - PlayerCombo.LastPressed <= 0.8 and true or false

        AnimationRemote:FireClient(Player, "KillerQueen", "Play", { Looped = true })

        wait(0.3)

        local BarrageAnimation = Stand.Humanoid:LoadAnimation(
            ReplicatedStorage.Assets.Animations.Shared.Stands["Killer Queen"]["BarrageAnim"]
        )
        BarrageAnimation:Play()
        BarrageAnimation.Looped = true

        coroutine.wrap(function()
            for Index = 0, 2, 0.05 do
                for _, v in ipairs(Stand:GetChildren()) do
                    if string.find(v.Name, "Arm") then
                        v.Transparency = Index
                        for _, Parts in ipairs(v:GetDescendants()) do
                            if
                                Parts:IsA("BasePart")
                                or Parts:IsA("Part")
                                or Parts:IsA("UnionOperation")
                                or Parts:IsA("MeshPart")
                            then
                                Parts.Transparency = Index
                            end
                        end
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end)()

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "Killer QueenVFX", Function = "Barrage" }
        )
        SpeedManager.changeSpeed(Character, 4, 3, 2) --function(Character,Speed,Duration,Priority)

        MoveStand.MoveStand(Character, { Priority = 2, Duration = 3 })

        for _ = 1, 20 do
            wait(0.125)
            local NumberEvaluation = (PlayerCombo.KeysLogged < 5 and TimeEvaluation and PlayerCombo.KeysLogged + 1)
                or (PlayerCombo.KeysLogged > 5 and 1)
                or (not PlayerCombo.TimeEvaluation and 1)

            PlayerCombo.Hits += 1
            PlayerCombo.KeysLogged = NumberEvaluation

            local HitObject = HitboxModule.RaycastModule(
                Player,
                { Visualize = false, DmgType = "Snake", Size = 10, KeysLogged = math.random(1, 3), Type = "Sword" },
                KeyData.SerializedKey,
                CharacterName
            )
            if HitObject.Hit then
                local Victim = HitObject.Object.Parent
                local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

                CameraRemote:FireClient(Player, "CameraShake", { FirstText = 1, SecondText = 3.5 })

                local BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
                BodyVelocity.Velocity = (VRoot.CFrame.p - Root.CFrame.p).Unit * 6
                BodyVelocity.Parent = Root
                Debris:AddItem(BodyVelocity, 0.25)

                local BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
                BodyVelocity.Name = "SnakeAwakenKnockback"
                BodyVelocity.Velocity = (VRoot.CFrame.p - Root.CFrame.p).Unit * 7
                BodyVelocity.Parent = VRoot
                Debris:AddItem(BodyVelocity, 0.25)

                DamageManager.DeductDamage(
                    Character,
                    Victim,
                    KeyData.SerializedKey,
                    CharacterName,
                    { Type = ExtraData.Type, KeysLogged = ExtraData.KeysLogged }
                )
            end
        end
        BarrageAnimation:Stop()
        AnimationRemote:FireClient(Player, "KillerQueen", "Stop")

        for Index = 0, 2, 0.05 do
            for _, v in ipairs(Stand:GetChildren()) do
                if string.find(v.Name, "Arm") then
                    v.Transparency = 0
                    for _, Parts in ipairs(v:GetDescendants()) do
                        if
                            Parts:IsA("BasePart")
                            or Parts:IsA("Part")
                            or Parts:IsA("UnionOperation")
                            or Parts:IsA("MeshPart")
                        then
                            Parts.Transparency = 0
                        end
                    end
                end
            end
            RunService.Heartbeat:Wait()
        end
        StateManager:ChangeState(Character, "Stunned", 0.5)
    end,

    ["SecondAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Mouse = MouseRemote:InvokeClient(Player)
        if (Root.Position - Mouse.Position).Magnitude > 30 then
            return
        end

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)

        local Stands = Character

        local Stand = Stands:FindFirstChild(Character.Name .. " - Stand")
        local Weld = Stand.PrimaryPart.Weld

        local StandHum = Stand:FindFirstChild("Humanoid")

        local CalculatedOffset = CFrame.new(0, 0, 3)
        local CalculatedOffsetIn = CFrame.new(1, -0.5, -2)

        StateManager:ChangeState(Character, "Attacking", 2)
        SpeedManager.changeSpeed(Character, 4, 2, 2) --function(Character,Speed,Duration,Priority)

        local CoinAnimation = StandHum:LoadAnimation(KillerQueenAnimations["CoinFlip"])
        CoinAnimation:AdjustSpeed()
        CoinAnimation:Play()

        wait(0.175)
        MoveStand.MoveStand(Character, { Priority = 1.25, Duration = 2 })

        wait(0.325)
        local Mouse = MouseRemote:InvokeClient(Player)

        local StartPosition = (Stand.PrimaryPart.CFrame * CFrame.new(0, 2, -3)).Position

        local Coin = ReplicatedStorage.Assets.Effects.Meshes.Coin:Clone()
        Coin.Anchored = false
        Coin.CanCollide = true
        Coin.Massless = false
        Coin.CFrame = CFrame.new(StartPosition)
        Coin.Parent = workspace.World.Visuals

        -- SoundManager:AddSound("CoinFlip",{Parent = Root, Volume = 8.75}, "Server",{Player = Player, Distance = 5})

        Coin:SetNetworkOwner(Player)

        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BodyVelocity.Velocity = Mouse.lookVector * 45
        BodyVelocity.Parent = Coin
        Debris:AddItem(BodyVelocity, 0.15)

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Coin = Coin, Module = "Killer QueenVFX", Function = "Coin Flip", Distance = 100 }
        )

        local ProjectileDebounce = SetProjectileDebounce(Coin)

        local Connection
        Connection = Coin.Touched:Connect(function(Hit)
            if Hit then
                if
                    (not Hit:IsDescendantOf(Character))
                    and (not Hit:IsDescendantOf(workspace.World.Visuals))
                    and not ProjectileDebounce.Value
                then
                    ProjectileDebounce.Value = true
                    Coin:SetNetworkOwner(nil)
                    wait(0.25)
                    NetworkStream.FireClientDistance(
                        Character,
                        "ClientRemote",
                        200,
                        {
                            Character = Character,
                            Coin = Coin,
                            Module = "Killer QueenVFX",
                            Function = "Coin Toss",
                            Distance = 100,
                        }
                    )
                    wait(0.5)
                    CameraRemote:FireClient(Player, "CreateBlur", { Size = 15, Length = 0.25 })
                    HitboxModule.GetTouchingParts(
                        Player,
                        {
                            ExistTime = 2,
                            Type = "Combat",
                            KeysLogged = math.random(1, 3),
                            Size = Vector3.new(18.712, 19.86, 21.681),
                            Transparency = 1,
                            PositionCFrame = Coin.CFrame,
                        },
                        KeyData.SerializedKey,
                        CharacterName
                    )

                    Debris:AddItem(Coin, 0.5)
                end
            end
            Connection:Disconnect()
            Connection = nil
        end)

        wait(0.75)
        Debris:AddItem(Coin, 1)

        SpeedManager.changeSpeed(Character, 6, 0.75, 4) --function(Character,Speed,Duration,Priority)
        StateManager:ChangeState(Character, "Stunned", 0.75)

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
    end,

    ["ThirdAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local KillerQueenData = AbilityData.ReturnData(Player, "ThirdAbility", "Killer Queen")

        local Stand = Character:FindFirstChild(Character.Name .. " - Stand")
        local Weld = Stand.PrimaryPart.Weld

        local StandHum = Stand:FindFirstChild("Humanoid")

        StateManager:ChangeState(Character, "Attacking", 0.8, { AllowedSkills = { ["Dash"] = true } })
        SpeedManager.changeSpeed(Character, 4, 0.8, 2) --function(Character,Speed,Duration,Priority)

        MoveStand.MoveStand(Character, { Priority = 5.25, Duration = 1.5 })

        if KillerQueenData.HasBomb then
            BreakBomb(Character, KillerQueenData, KeyData, CharacterName)
            KillerQueenData.HasBomb = false
        else
            local CoinAnimation = StandHum:LoadAnimation(KillerQueenAnimations["KillerQueenSlap"])
            CoinAnimation:Play()
            CoinAnimation:AdjustSpeed(0.75)

            -- SoundManager:AddSound("KillerQueenCall",{Parent = Root, Volume = 5}, "Server" ,{Player = Player, Distance = 10})

            KillerQueenData.HasBomb = false
            local HitResult, HitObject = HitboxModule.MagnitudeModule(
                Character,
                { Delay = 0.185, Range = 7, KeysLogged = math.random(1, 3) },
                KeyData.SerializedKey,
                CharacterName
            )
            if HitResult then
                local Victim = HitObject.Parent
                local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

                if not StateManager:Peek(Victim, "Blocking") or StateManager:Peek(Victim, "IFrame") then
                    if StateManager:Peek(Victim, "Blocking") then
                        CameraRemote:FireClient(
                            Player,
                            "ChangeUICooldown",
                            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
                        )
                        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
                        return
                    end
                    KillerQueenData.HasBomb = true
                    local StartTime = os.clock()

                    coroutine.wrap(function()
                        while KillerQueenData.HasBomb do
                            RunService.Heartbeat:Wait()
                            local LastHitData = StateManager:ReturnData(Character, "LastHit")

                            if os.clock() - StartTime >= 10 then
                                BreakBomb(Character, KillerQueenData, KeyData, CharacterName)
                                break
                            end
                            if Stand == nil then
                                NetworkStream.FireOneClient(
                                    Player,
                                    "ClientRemote",
                                    5,
                                    {
                                        Character = Character,
                                        Victim = workspace.World.Live[LastHitData.LastTarget],
                                        Module = "Killer QueenVFX",
                                        Function = "RemoveBomb",
                                        Distance = 100,
                                    }
                                )
                                StateManager:ChangeState(Character, "LastHit", 0.5, { LastTarget = "" })
                                KillerQueenData.Damage = 5
                                break
                            end
                        end
                    end)()
                    StateManager:ChangeState(Character, "Attacking", 0.8, { AllowedSkills = { ["Dash"] = true } })
                    StateManager:ChangeState(Character, "LastHit", 524525, { LastTarget = Victim.Name })
                    CameraRemote:FireClient(Player, "CameraShake", { FirstText = 3, SecondText = 12 })
                    NetworkStream.FireOneClient(
                        Player,
                        "ClientRemote",
                        5,
                        {
                            Character = Character,
                            Victim = Victim,
                            Module = "Killer QueenVFX",
                            Function = "Add Bomb",
                            Distance = 100,
                        }
                    )

                    KillerQueenData.Cooldown = 3

                    if Players:GetPlayerFromCharacter(Victim) then
                        NetworkStream.FireOneClient(
                            Players:GetPlayerFromCharacter(Victim),
                            "ClientRemote",
                            5,
                            {
                                Character = Character,
                                Victim = Victim,
                                Module = "Killer QueenVFX",
                                Function = "Add Bomb",
                                Distance = 100,
                            }
                        )
                    end
                end
            end
        end
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

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Killer Queen" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        local Stand = Character:FindFirstChild(Character.Name .. " - Stand")

        StateManager:ChangeState(Character, "Attacking", 1.75)
        SpeedManager.changeSpeed(Character, 4, 2, 2) --function(Character,Speed,Duration,Priority)

        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Parent = Root
        BodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
        BodyVelocity.Velocity = Root.CFrame.lookVector * 30
        Debris:AddItem(BodyVelocity, 0.3)

        local _ = Stand and StandManager.UnSummon(Player, { Stand = Player.Name .. " - Stand" })
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "Killer QueenVFX", Function = "Traced Steps", Distance = 100 }
        )

        wait(0.235)
        local HitResult, HitObject = HitboxModule.MagnitudeModule(
            Character,
            { Delay = 2, Range = 7, KeysLogged = math.random(1, 3) },
            KeyData.SerializedKey,
            CharacterName
        )
        if HitResult then
            local Victim = HitObject.Parent
            local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

            StateManager:ChangeState(Character, "Stunned", 2)
            StateManager:ChangeState(Character, "IFrame", 1.5, { IFrameType = "" })

            local Weld = Instance.new("Weld")
            Weld.Part0 = Root
            Weld.Part1 = VRoot
            Weld.C0 = CFrame.new(0, 0, -3.05) * CFrame.Angles(0, math.rad(-180), 0)
            Weld.Parent = VRoot

            Debris:AddItem(Weld, 1.85)

            Humanoid.AutoRotate = false
            Root.Anchored = true

            AnimationRemote:FireClient(Player, "KillerQueenGrab", "Play")

            local Anim = VHum:LoadAnimation(
                ReplicatedStorage.Assets.Animations.Shared.Stands["Killer Queen"]["TracedStepsVictim"]
            )
            Anim:Play()
            Anim:AdjustSpeed(0.75)

            CameraRemote:FireClient(Player, "CameraShake", { FirstText = 3, SecondText = 12 })
            StateManager:ChangeState(Victim, "Stunned", 2)

            TaskScheduler:AddTask(2, function()
                NetworkStream.FireClientDistance(
                    Character,
                    "ClientRemote",
                    200,
                    {
                        Character = Character,
                        Victim = Victim,
                        Module = "Killer QueenVFX",
                        Function = "Traced Steps Explode",
                        Distance = 100,
                    }
                )

                Humanoid.AutoRotate = true
                Root.Anchored = false

                AnimationRemote:FireClient(Player, "KillerQueenGrab", "Stop")
            end)
        end

        wait(0.35)
        local _ = Stand and StandManager.Summon(Player, { Stand = "Killer Queen" })
    end,
}

return Killer_Queen
