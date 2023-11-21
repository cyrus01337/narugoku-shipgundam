--||Services||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Debris = game:GetService("Debris")

--|| Variables ||--
local RemoteFolder = ReplicatedStorage.Remotes
local AssetFolder = ReplicatedStorage.Assets

local Animations = AssetFolder.Animations
local Sounds = AssetFolder.Sounds

--|| Imports ||--
local Modules = ReplicatedStorage.Modules

local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Shared = Modules.Shared

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local TaskScheduler = require(Utility.TaskScheduler)

local DamageManager = require(ServerScriptService.Server.Managers.DamageManager)

local StateManager = require(Shared.StateManager)
local SoundManager = require(Shared.SoundManager)

local RaycastData = require(script.RaycastData)

local function GetTouchingParts(Part)
    local Connection = Part.Touched:Connect(function() end)
    local Results = Part:GetTouchingParts()

    --Part:Destroy()
    Connection:Disconnect()
    Connection = nil

    return Results
end

local HitboxModule = {}

function HitboxModule.RaycastModule(Player, ExtraData, SkillName, KeyName)
    local Character = Player.Character
    local Humanoid, HumanoidRootPart =
        Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = { Character, workspace.World.Visuals }
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local CharacterParts = Character:GetChildren()
    for Index = 1, #CharacterParts do
        local Instances = CharacterParts[Index]
        if Instances:IsA("BasePart") then
            local StartPoint = Instances.Position
            local EndPoint = (HumanoidRootPart.CFrame * CFrame.new(0, 0, -ExtraData.Size or 4)).Position

            local _ = ExtraData.Visualize
                and GlobalFunctions.Visualize(StartPoint, EndPoint, Color3.fromRGB(255, 57, 57))

            local HalfSize = Instances.Size.X / 2
            local StartRay = (Instances.CFrame * CFrame.new(-HalfSize, 0, 0)).Position
            local EndRay = (Instances.CFrame * CFrame.new(HalfSize, 0, 0)).Position

            local RayParam = RaycastParams.new()
            RayParam.FilterType = Enum.RaycastFilterType.Exclude
            RayParam.FilterDescendantsInstances = { Character, workspace.World.Visuals }

            local RaycastResult = workspace:Raycast(
                StartPoint,
                (EndPoint - StartPoint).Unit * ExtraData.Size or 4,
                RayParam
            ) or {}

            local Part, Position = RaycastResult.Instance, RaycastResult.Position

            if Part then
                if
                    Part:IsA("BasePart")
                    and Part.Parent
                    and Part.Parent:FindFirstChild("Humanoid")
                    and Part.Parent:FindFirstChild("Humanoid").Health > 0
                then
                    local EnemyPlayer = Players:GetPlayerFromCharacter(Part.Parent)
                    local EnemyHumanoid = Part.Parent:FindFirstChild("Humanoid")
                    local Hit = { Object = EnemyHumanoid, Hit = true, ActualPart = Part.Name }
                    delay(0.225, function()
                        if ExtraData.Type and not ExtraData.DmgType == "Snake" then
                            DamageManager.DeductDamage(
                                Character,
                                Part.Parent,
                                SkillName,
                                KeyName,
                                { Type = ExtraData.Type, KeysLogged = ExtraData.KeysLogged, Damage = ExtraData.Damage }
                            )
                        end
                    end)
                    return Hit
                else
                    RaycastData.Hit = {
                        Object = false,
                        Hit = false,
                    }
                end
            end
        end
    end
    return RaycastData.Hit
end

function HitboxModule.RegionModule(Player, ExtraData, SkillName, KeyName)
    local Character = Player.Character
    local Humanoid, HumanoidRootPart =
        Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")

    local Area = HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)

    local StartPoint = Area.p - ExtraData.StartPoint or Vector3.new(2.75, 2.75, 2.75)
    local EndPoint = Area.p + ExtraData.EndPoint or Vector3.new(2.75, 2.75, 2.75)

    local DetectionRegion = Region3.new(StartPoint, EndPoint)
    local DetectionArea =
        workspace:FindPartsInRegion3WithIgnoreList(DetectionRegion, { workspace.World.Visuals, Character }, 50)
    for _, v in ipairs(DetectionArea) do
        if v:IsA("BasePart") and v.Parent then
            if v.Parent:FindFirstChild("Humanoid") and v.Parent:FindFirstChild("Humanoid").Health > 0 then
                local EnemyPlayer = Players:GetPlayerFromCharacter(v.Parent)
                local EnemyHumanoid = v.Parent:FindFirstChild("Humanoid")
                if EnemyHumanoid then
                    if EnemyHumanoid.Health > 0 then
                        delay(0.225, function()
                            --if StateManager:Peek(EnemyHumanoid.Parent,"IFrame") then
                            DamageManager.DeductDamage(
                                Character,
                                EnemyHumanoid.Parent,
                                SkillName,
                                KeyName,
                                { Type = ExtraData.Type, KeysLogged = ExtraData.KeysLogged }
                            )
                            --end
                        end)
                        return true, EnemyHumanoid
                    end
                end
                break
            end
        end
    end
    return false
end

function HitboxModule.GetTouchingParts(Player, ExtraData, SkillName, KeyName)
    local Character = Player.Character

    local Humanoid, Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
    local SecondType = ExtraData.SecondType or ""

    local Hitbox = ReplicatedStorage.Assets.Effects.Meshes.Hitbox:Clone()

    local SpecialMesh = Instance.new("SpecialMesh")
    SpecialMesh.MeshType = "Sphere"
    SpecialMesh.Parent = Hitbox
    Hitbox.Size = ExtraData.Size
    Hitbox.Transparency = ExtraData.Transparency
    Hitbox.Orientation = ExtraData.Orientation or Hitbox.Orientation
    Hitbox.CFrame = ExtraData.PositionCFrame
    Hitbox.Parent = workspace.World.Visuals

    local Zone = GetTouchingParts(Hitbox)

    local IsHit, EntitieList = false, {}
    for _, Hit in ipairs(Zone) do
        if
            not Hit:IsDescendantOf(Character)
            and not Hit:IsDescendantOf(workspace.World.Visuals)
            and Hit.Parent
            and Hit.Parent:FindFirstChild("Humanoid")
        then
            local Victim = Hit.Parent
            local EnemyHumanoid, EnemyRoot =
                Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")
            if
                Victim ~= Character
                and EnemyHumanoid.Health > 0
                and not table.find(EntitieList, Victim)
                and Victim.Parent == workspace.World.Live
            then
                delay(ExtraData.Delay or 0.225, function()
                    DamageManager.DeductDamage(
                        Character,
                        Victim,
                        SkillName,
                        KeyName,
                        { Type = ExtraData.Type, KeysLogged = ExtraData.KeysLogged, SecondType = SecondType }
                    )
                end)
                Debris:AddItem(Hitbox, ExtraData.ExistTime)

                EntitieList[#EntitieList + 1] = Victim
                IsHit = true
            end
        end
    end

    Debris:AddItem(Hitbox, ExtraData.ExistTime)
    return IsHit, EntitieList
end

function HitboxModule.MagnitudeModule(Character, ExtraData, SkillName, KeyName, Ting, Ting2)
    local Hits = {}
    local EnemyHumanoids = {}

    local Humanoid, HumanoidRootPart =
        Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")

    local SecondType = ExtraData.SecondType or ""

    for _, Characters in ipairs(workspace.World.Live:GetChildren()) do
        if Characters:FindFirstChild("HumanoidRootPart") and Characters:FindFirstChild("Humanoid") then
            local Calculation = (
                HumanoidRootPart.Position
                + (HumanoidRootPart.CFrame.lookVector * 3.5)
                - Characters.HumanoidRootPart.Position
            ).Magnitude
            if Calculation <= ExtraData.Range then
                if Characters ~= Character then
                    Hits[#Hits + 1] = Characters
                    ExtraData.Range = Calculation
                end
            end
        end
    end

    for _, EnemyCharacter in ipairs(Hits) do
        local EnemyHumanoid, EnemyRoot =
            EnemyCharacter:FindFirstChild("Humanoid"), EnemyCharacter:FindFirstChild("HumanoidRootPart")
        delay(ExtraData.Delay or 0.225, function()
            if Ting == nil then
                DamageManager.DeductDamage(
                    Character,
                    EnemyCharacter,
                    SkillName,
                    KeyName,
                    { Type = ExtraData.Type, KeysLogged = ExtraData.KeysLogged, SecondType = SecondType },
                    Ting2
                )
            end
        end)
        EnemyHumanoids[#EnemyHumanoids + 1] = EnemyCharacter:FindFirstChild("Humanoid")
    end

    for _, Humanoids in ipairs(EnemyHumanoids) do
        return true, Humanoids
    end
    Hits = nil
    EnemyHumanoids = nil
    return false
end

function HitboxModule.ConeDetection(Character, ExtraData, SkillName, KeyName, Ting)
    local Hits = {}
    local EnemyHumanoids = {}

    local Humanoid, HumanoidRootPart =
        Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
    local SecondType = ExtraData.SecondType or ""

    for _, Characters in ipairs(workspace.World.Live:GetChildren()) do
        if Characters:FindFirstChild("HumanoidRootPart") and Characters:FindFirstChild("Humanoid") then
            local EnemyRootPart = Characters.HumanoidRootPart.Position

            local UnitVector = (HumanoidRootPart.Position - EnemyRootPart.Position).Unit
            local VictimLook = EnemyRootPart.CFrame.lookVector
            local DotVector = UnitVector:Dot(VictimLook)

            local Calculation = (
                HumanoidRootPart.Position
                + (HumanoidRootPart.CFrame.lookVector * 3.5)
                - Characters.HumanoidRootPart.Position
            ).Magnitude
            if Calculation <= ExtraData.Range and DotVector >= (ExtraData.Angle or -0.5) then
                if Characters ~= Character then
                    Hits[#Hits + 1] = Characters
                    ExtraData.Range = Calculation
                end
            end
        end
    end

    for _, EnemyCharacter in ipairs(Hits) do
        local EnemyHumanoid, EnemyRoot =
            EnemyCharacter:FindFirstChild("Humanoid"), EnemyCharacter:FindFirstChild("HumanoidRootPart")
        delay(ExtraData.Delay or 0.225, function()
            if Ting == nil then
                DamageManager.DeductDamage(
                    Character,
                    EnemyCharacter,
                    SkillName,
                    KeyName,
                    { Type = ExtraData.Type, KeysLogged = ExtraData.KeysLogged, SecondType = SecondType }
                )
            end
        end)
        EnemyHumanoids[#EnemyHumanoids + 1] = EnemyCharacter:FindFirstChild("Humanoid")
    end

    for _, Humanoids in ipairs(EnemyHumanoids) do
        return true, Humanoids
    end
    Hits = nil
    EnemyHumanoids = nil
    return false
end
return HitboxModule
