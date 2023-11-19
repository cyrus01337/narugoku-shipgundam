--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TweenService = game:GetService("TweenService")
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
local TaskScheduler = require(Utility.TaskScheduler)

local DamageManager = require(Managers.DamageManager)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)

local RotatedRegion3 = require(Shared.RotatedRegion3)
local SoundManager = require(Shared.SoundManager)

local HitboxModule = require(script.Parent.Parent.Combat.Combat.HitboxModule)

local RaycastManager = require(Shared.RaycastManager)

local ProfileService = require(Server.ProfileService)

--|| Remote s||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.World.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

local Razor = {
    ["FirstAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Razor" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        local Mouse = MouseRemote:InvokeClient(Player)

        if (Root.Position - Mouse.Position).Magnitude > 500 then
            return
        end

        StateManager:ChangeState(Character, "Guardbroken", 1.85)
        StateManager:ChangeState(Character, "Attacking", 1.85)

        local AimingValue = GlobalFunctions.NewInstance("BoolValue", { Parent = Character, Name = "Aiming" }, 1.85)

        SpeedManager.changeSpeed(Character, 2, 1, 1.25)

        AnimationRemote:FireClient(Player, "HardThrow", "Play", { AdjustSpeed = 0.85 })

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "RazorVFX", Function = "BallPrep" }
        )

        wait(0.75)
        if StateManager:Peek(Character, "Stunned") then
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                21431413400,
                { Character = Character, Module = "RazorVFX", Function = "RemoveBall" }
            )
            return
        end
        CameraRemote:FireClient(Player, "CameraShake", { FirstText = 3, SecondText = 15 })

        local StartPoint = Character["Right Arm"].CFrame * CFrame.new(0, -1, 0)

        local Size = Assets.Models.Misc.Volleyballs.volleyball2.Size

        local Points = RaycastManager:GetSquarePoints(StartPoint, Size.X * 2, Size.X * 2)

        local Velocity = 200
        local Lifetime = 10

        local MouseHit = MouseRemote:InvokeClient(Player)
        local Direction = (MouseHit.Position - StartPoint.Position).Unit

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            {
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
            }
        )

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
                    20
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
        local HumanoidRootPart, Humanoid =
            Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Mouse = MouseRemote:InvokeClient(Player)

        if (HumanoidRootPart.Position - Mouse.Position).Magnitude > 500 then
            return
        end

        local AimingValue = GlobalFunctions.NewInstance("BoolValue", { Parent = Character, Name = "Aiming" }, 1.85)

        StateManager:ChangeState(Character, "Guardbroken", 2)
        StateManager:ChangeState(Character, "Attacking", 2)

        AnimationRemote:FireClient(Player, "VolleyKick", "Play")

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "RazorVFX", Function = "BallPrep" }
        )

        wait(0.5)
        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Razor" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        if StateManager:Peek(Character, "Stunned") then
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                21431413400,
                { Character = Character, Module = "RazorVFX", Function = "RemoveBall" }
            )
            return
        end

        local StartPoint = Character["Right Arm"].CFrame * CFrame.new(0, -1, 0)

        local Size = Assets.Models.Misc.Volleyballs.volleyball2.Size

        local Points = RaycastManager:GetSquarePoints(StartPoint, Size.X * 2, Size.X * 2)

        local Velocity = 200
        local Lifetime = 10

        local MouseHit = MouseRemote:InvokeClient(Player)

        local CFrameTarget = HumanoidRootPart.CFrame * CFrame.new(0, 12, 0)
        local Calculation1, Calculation2 = HumanoidRootPart.Position, HumanoidRootPart.CFrame.upVector * 200
        local RaycastResults = workspace:Raycast(Calculation1, Calculation2, raycastParams)
        local Subtraction = HumanoidRootPart.CFrame - HumanoidRootPart.Position

        local BodyPosition = Instance.new("BodyPosition")
        BodyPosition.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BodyPosition.Position = HumanoidRootPart.Position
        BodyPosition.P = 2e4

        if
            RaycastResults
            and RaycastResults.Position
            and RaycastResults.Position
            and (RaycastResults.Position - Calculation1).Magnitude < 20
        then
            CFrameTarget = CFrame.new(RaycastResults.Position) * Subtraction
        end

        BodyPosition.Parent = HumanoidRootPart
        BodyPosition.Position = CFrameTarget.p
        Debris:AddItem(BodyPosition, 2)

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            {
                Character = Character,
                Module = "RazorVFX",
                Function = "VolleyKick",
                StartPoint = StartPoint,
                MouseHit = MouseHit,
                Lifetime = Lifetime,
                Velocity = Velocity,
                Distance = 100,
            }
        )

        wait(0.5)
        CameraRemote:FireClient(Player, "CameraShake", { FirstText = 3, SecondText = 15 })

        wait(0.35)
        local MouseHit = MouseRemote:InvokeClient(Player)

        local Direction = (MouseHit.Position - StartPoint.Position).Unit
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
                    20
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

    ["ThirdAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local HumanoidRootPart, Humanoid =
            Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Mouse = MouseRemote:InvokeClient(Player)

        if (HumanoidRootPart.Position - Mouse.Position).Magnitude > 500 then
            return
        end

        local AimingValue = GlobalFunctions.NewInstance("BoolValue", { Parent = Character, Name = "Aiming" }, 1.85)

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Razor" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        StateManager:ChangeState(Character, "Guardbroken", 2)
        StateManager:ChangeState(Character, "Attacking", 1.85)

        AnimationRemote:FireClient(Player, "ExplodingThrow", "Play", { Adjustspeed = 0.75 })

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Module = "RazorVFX", Function = "BallPrep", Type = "Explode" }
        )

        wait(0.5)

        if StateManager:Peek(Character, "Stunned") then
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                21431413400,
                { Character = Character, Module = "RazorVFX", Function = "RemoveBall" }
            )
            return
        end

        local StartPoint = Character["Right Arm"].CFrame * CFrame.new(0, -1, 0)

        local Size = Assets.Models.Misc.Volleyballs.volleyball2.Size

        local Points = RaycastManager:GetSquarePoints(StartPoint, Size.X * 2, Size.X * 2)

        local Velocity = 200
        local Lifetime = 10

        local MouseHit = MouseRemote:InvokeClient(Player)

        local CFrameTarget = HumanoidRootPart.CFrame * CFrame.new(0, 12, 0)
        local Calculation1, Calculation2 = HumanoidRootPart.Position, HumanoidRootPart.CFrame.upVector * 200
        local RaycastResults = workspace:Raycast(Calculation1, Calculation2, raycastParams)
        local Subtraction = HumanoidRootPart.CFrame - HumanoidRootPart.Position

        local BodyPosition = Instance.new("BodyPosition")
        BodyPosition.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BodyPosition.Position = HumanoidRootPart.Position
        BodyPosition.P = 2e4

        if
            RaycastResults
            and RaycastResults.Position
            and RaycastResults.Position
            and (RaycastResults.Position - Calculation1).Magnitude < 20
        then
            CFrameTarget = CFrame.new(RaycastResults.Position) * Subtraction
        end

        BodyPosition.Parent = HumanoidRootPart
        BodyPosition.Position = CFrameTarget.p
        Debris:AddItem(BodyPosition, 2)

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            {
                Character = Character,
                Module = "RazorVFX",
                Function = "explodball",
                StartPoint = StartPoint,
                MouseHit = MouseHit,
                Lifetime = Lifetime,
                Velocity = Velocity,
                Distance = 100,
            }
        )

        wait(0.5)
        CameraRemote:FireClient(Player, "CameraShake", { FirstText = 3, SecondText = 15 })

        wait(0.35)
        local MouseHit = MouseRemote:InvokeClient(Player)

        local Direction = (MouseHit.Position - StartPoint.Position).Unit
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
                    23
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
    end,

    ["FourthAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")

        local Data = ProfileService:GetPlayerProfile(Player)
        if Data.Character == "Razor" then
            DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
            CameraRemote:FireClient(
                Player,
                "ChangeUICooldown",
                { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
            )
        end

        local HitResult, ValidEntities = HitboxModule.GetTouchingParts(
            Player,
            {
                SecondType = "Choke",
                ExistTime = 0.35,
                Type = "Combat",
                KeysLogged = math.random(1, 3),
                Size = Vector3.new(2.796, 4.517, 45.267),
                Transparency = 1,
                PositionCFrame = Root.CFrame * CFrame.new(0, 0, -18),
            },
            KeyData.SerializedKey,
            CharacterName
        )
        if HitResult then
            for Index = 1, #ValidEntities do
                local Victim = ValidEntities[Index]
                local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

                local UnitVector = (Root.Position - VRoot.Position).Unit
                local VictimLook = VRoot.CFrame.LookVector
                local DotVector = UnitVector:Dot(VictimLook)

                if StateManager:Peek(Victim, "Blocking") and DotVector >= -0.5 then
                    DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
                    CameraRemote:FireClient(
                        Player,
                        "ChangeUICooldown",
                        { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
                    )
                    return
                end

                NetworkStream.FireClientDistance(
                    Character,
                    "ClientRemote",
                    350,
                    { Character = Character, Victim = Victim, Module = "RazorVFX", Function = "Chop", Distance = 100 }
                )

                wait()
                AnimationRemote:FireClient(Player, "KillerQueenSlap", "Play", { Delay = 0, AdjustSpeed = 0.85 })

                TaskScheduler:AddTask(0.225, function()
                    local Anim = VHum:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Misc.SlamDown)
                    Anim:Play(0.1, 1)
                end)

                Root.CFrame = VRoot.CFrame * CFrame.new(0, 0, 3)
                Humanoid.AutoRotate = false
                Root.Anchored = true

                wait(0.55)
                Humanoid.AutoRotate = true
                Root.Anchored = false

                --	local Tween = TweenService:Create(Root,TweenInfo.new(.005,Enum.EasingStyle.Quad),{Position = VRoot.Position})
                --	Tween:Play()
                --	Tween:Destroy()

                --[[    local ShadowPart = ReplicatedStorage.Assets.Models.Misc.BP:Clone()
				ShadowPart.CFrame = Root.CFrame * CFrame.new(0,0,-40)
				ShadowPart.Parent = workspace.World.Visuals
				
				local BodyPosition = Instance.new("BodyPosition")
				BodyPosition.Position = VRoot.Position + Vector3.new(0,0,-5)
				BodyPosition.MaxForce = Vector3.new(250,250,250) * 500
				BodyPosition.D = 500
				BodyPosition.Parent = Root
				
				Debris:AddItem(ShadowPart,.05)
				Debris:AddItem(BodyPosition,.35) ]]
            end
        end
    end,
}

return Razor
