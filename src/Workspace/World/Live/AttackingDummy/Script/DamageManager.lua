--||Services||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--||Directories||--
local Server = ServerScriptService.Server

local Modules = ReplicatedStorage.Modules
local State = Server.State

local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Effects = Modules.Effects
local Shared = Modules.Shared

--|| Remotes ||--
local RemoteFolder = ReplicatedStorage.Remotes

local ChangeSpeed = RemoteFolder.ChangeSpeed
local GUIRemote = RemoteFolder.GUIRemote
local CameraRemote = RemoteFolder.CameraRemote

--|| Imports ||--
local ProfileService = require(Server.ProfileService)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)

local VfxHandler = require(Effects.VfxHandler)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)

local SoundManager = require(Shared.SoundManager)

local AbilityData = require(Metadata.AbilityData.AbilityData)
local CombatData = require(Metadata.CombatData.CombatData)

local CameraData = { Size = 30, Length = 0.25 }

local function ClearTable(Table)
    for Array in ipairs(Table) do
        Table[Array] = nil
    end
end

local DamageManager = {
    DamagedEntities = {},
}

function DamageManager.DeductDamage(Character, Victim, SkillName, CharacterName, KeysLogged, ExtraData)
    local VictimPlayer = Players:GetPlayerFromCharacter(Victim)

    local Humanoid, Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
    local VictimHumanoid, VictimRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")

    local Damage = 5
    local StunTime = 0.55
    local EndLag = 0
    local BlockDeduction = 1

    local DamageData = StateManager:ReturnData(Character, "DamageMultiplier")
    local DamageBoost = DamageData.DamageBooster

    local ModeData = StateManager:ReturnData(Character, "Mode")

    local IndexCalculation = ModeData.Mode and CharacterName .. "Mode"
        or CharacterName
        or warn("character has invalid module")
    local ModifierCopy = AbilityData.ReturnData(Character, SkillName, IndexCalculation)
        or CombatData.ReturnData(Character, SkillName)

    local Damage = ModifierCopy.Damage
    local StunTime = ModifierCopy.StunTime or 0.625
    local EndLag = ModifierCopy.Endlag or 0
    local Guardbreak = ModifierCopy.Guardbreak
    local BlockDeduction = ModifierCopy.BlockDeduction or 1

    local UnitVector = (Root.Position - VictimRoot.Position).Unit
    local VictimLook = VictimRoot.CFrame.lookVector
    local DotVector = UnitVector:Dot(VictimLook)

    local DamageData = StateManager:ReturnData(Character, "DamageMultiplier")
    local DamageBoost = DamageData.DamageBooster

    if VictimHumanoid.Health >= 1 and Humanoid.Health >= 0 and Victim ~= Character then
        if StateManager:Peek(Victim, "ForceField") then
            if Players:GetPlayerFromCharacter(Victim) then
                local Data = ProfileService:GetPlayerProfile(Players:GetPlayerFromCharacter(Victim))

                CameraRemote:FireClient(VictimPlayer, "CameraShake", { FirstText = 8, SecondText = 10 })
                NetworkStream.FireClientDistance(
                    Character,
                    "ClientRemote",
                    250,
                    { Character = Victim, Module = Data.Character .. "VFX", Function = "boingzz" }
                )
            end
            return
        end

        if not StateManager:Peek(Victim, "IFrame") then
            local IFrameData = StateManager:ReturnData(Victim, "IFrame")

            local IFrameType = IFrameData.IFrameType
            if IFrameType == "" then
                return
            end

            local VictimPlayer = Players:GetPlayerFromCharacter(Victim)
            local VictimData = ProfileService:GetPlayerProfile(VictimPlayer)

            local CharacterModule = require(Server.Characters[VictimData.Character])

            local ObservationData = {
                Character = Victim,
                Victim = Character,

                SkillName = SkillName,
                CharacterName = CharacterName,

                ExtraData = ExtraData,

                ModifierCopy = ModifierCopy,
            }

            CharacterModule[IFrameType](ObservationData)

            return
        end

        local UnitVector = (Root.Position - VictimRoot.Position).Unit
        local VictimLook = VictimRoot.CFrame.lookVector
        local DotVector = UnitVector:Dot(VictimLook)

        if KeysLogged >= 5 and StateManager:Peek(Victim, "Blocking") then
            local BlockData = StateManager:ReturnData(Victim, "Blocking")
            BlockData.BlockVal = 0
        end

        if StateManager:Peek(Victim, "Blocking") and (DotVector >= -0.5) then
            local BlockData = StateManager:ReturnData(Victim, "Blocking")
            if BlockData.BlockVal > 0 then
                BlockData.BlockVal -= BlockDeduction

                NetworkStream.FireClientDistance(Character, "ClientRemote", 150, {
                    Character = Character,
                    Victim = Victim,
                    WeaponType = "Combat",
                    Module = "CombatVFX",
                    Function = "Block",
                })
            elseif BlockData.BlockVal <= 0 then
                StateManager:ChangeState(Victim, "Blocking", false)
                StateManager:ChangeState(Victim, "Stunned", 1.75)
                StateManager:ChangeState(Victim, "Guardbroken", 1.75)

                NetworkStream.FireClientDistance(Character, "ClientRemote", 150, {
                    Character = Character,
                    Victim = Victim,
                    Module = "CombatVFX",
                    Function = "GuardBreak",
                })
            elseif os.clock() - BlockData.StartTime <= 30 then
                StateManager:ChangeState(Character, "Stunned", 1)

                SpeedManager.changeSpeed(Character, 0, 1, 3)

                NetworkStream.FireClientDistance(Character, "ClientRemote", 150, {
                    Character = Character,
                    Victim = Victim,
                    Module = "CombatVFX",
                    Function = "Parry",
                })
            end
        elseif StateManager:Peek(Victim, "IFrame") then
            NetworkStream.FireClientDistance(
                Character,
                "ClientRemote",
                50,
                {
                    Character = Character,
                    Damage = 5,
                    Victim = Victim,
                    Module = "PlayerClient",
                    Function = "DamageIndication",
                    StunTime = StunTime,
                }
            )
            VictimHumanoid:TakeDamage(5)

            if KeysLogged < 5 then
                if StateManager:Peek(Character, "InAir") then
                    VfxHandler.FaceVictim({ Character = Character, Victim = Victim })
                end
                NetworkStream.FireClientDistance(
                    Character,
                    "ClientRemote",
                    150,
                    {
                        Character = Character,
                        SecondType = "",
                        KeysLogged = KeysLogged,
                        Victim = Victim,
                        Module = "CombatVFX",
                        Function = "Light",
                    }
                )

                local BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
                BodyVelocity.Velocity = (VictimRoot.CFrame.p - Root.CFrame.p).Unit * 10
                BodyVelocity.Parent = Root
                Debris:AddItem(BodyVelocity, 0.25)

                local BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
                BodyVelocity.Velocity = (VictimRoot.CFrame.p - Root.CFrame.p).Unit * 12
                BodyVelocity.Parent = VictimRoot
                Debris:AddItem(BodyVelocity, 0.25)
            else
                local BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.MaxForce = Vector3.new(4e4, 4e4, 4e4)
                BodyVelocity.Velocity = CFrame.new(
                    Root.Position,
                    Root.Position + (Root.CFrame.lookVector * 10) + (Root.CFrame.upVector * -10)
                ).lookVector * 100
                BodyVelocity.Parent = VictimRoot
                Debris:AddItem(BodyVelocity, 0.25)

                VfxHandler.FaceVictim({ Character = Character, Victim = Victim })

                NetworkStream.FireClientDistance(
                    Character,
                    "ClientRemote",
                    150,
                    { Character = Character, Victim = Victim, Module = "CombatVFX", Function = "LastHit" }
                )
            end
        end

        if VictimPlayer and not StateManager:Peek(Victim, "Blocking") then
            StateManager:ChangeState(Victim, "Stunned", StunTime)
            StateManager:ChangeState(Character, "IFrame", 0.35)
            StateManager:ChangeState(Character, "Stunned", EndLag)
        end
    end
end

return DamageManager
