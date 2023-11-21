--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

--|| Variables ||--
local Modules = ReplicatedStorage.Modules

local Server = ServerScriptService.Server

local Effects = Modules.Effects
local Utility = Modules.Utility
local Shared = Modules.Shared
local Metadata = Modules.Metadata
local CharacterData = Metadata.CharacterData

--|| Remotes ||--
local RemoteFolder = ReplicatedStorage.Remotes

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local AnimationRemote = RemoteFolder.AnimationRemote

--|| Imports ||--
local ProfileService = require(Server.ProfileService)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local DebounceManager = require(Server.State.DebounceManager)

local SoundManager = require(Shared.SoundManager)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)
local MoveStand = require(Shared.StateManager.MoveStand)

local AbilityData = require(Metadata.AbilityData.AbilityData)

local VfxHandler = require(Effects.VfxHandler)

local NetworkStream = require(Utility.NetworkStream)

local HitboxModule = require(script.Parent.HitboxModule)

local CharacterInfo = require(CharacterData.CharacterInfo)

local Gilgamesh = require(Server.Characters.Gilgamesh)

local Variations = require(script.Parent.ComboVariations)

local Finishers = require(script.Parent.Aerial.Finishers)

return function(Player, CharacterName, KeyData, MoveData, ExtraData)
    local Character = Player.Character

    local Humanoid = Character:FindFirstChild("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

    local Stands = Character
    local PlayerCombo = AbilityData.ReturnData(Player, "PlayerCombos", "GlobalInformation")

    local TimeEvaluation = os.clock() - PlayerCombo.LastPressed <= 0.8 and true or false

    --local NumberEvaluation = (string.len(PlayerCombo.ComboVariation) < 5 and TimeEvaluation and PlayerCombo.KeysLogged + 1) or (string.len(PlayerCombo.ComboVariation) > 5 and 1) or (not PlayerCombo.TimeEvaluation and 1)
    local Side = ExtraData.WhichButton
    local NumberEvaluation = string.len(PlayerCombo.ComboVariation)

    local CombatAnims = ReplicatedStorage.Assets.Animations.Shared.Combat[Side]

    local Type = ExtraData.SwingType or "Combat"
    local AdjustSpeed = 1

    local Data = ProfileService:GetPlayerProfile(Player)
    local CharacterAnimationType = CharacterInfo[Data.Character]["AnimationType"]

    local AnimCombo = CharacterInfo[Data.Character]["AerialCombo"]
    local AdjustAnimConfigurations = (Type == "Sword" and AdjustSpeed and 0.75)
        or (Type == "Combat" and AdjustSpeed and 1)

    local AirCheck = StateManager:Peek(Character, "InAir")
    local HasStand = Stands:FindFirstChild(Character.Name .. " - Stand")

    local PlayerEvaluation = HasStand or Player
    local _ = (
        AirCheck
        and HasStand == nil
        and AnimationRemote:FireClient(Player, CharacterAnimationType .. Side .. NumberEvaluation, "Play")
    )
        or (
            not AirCheck
                and HasStand == nil
                and AnimationRemote:FireClient(
                    Player,
                    AnimCombo .. NumberEvaluation,
                    "Play",
                    { AdjustSpeed = AdjustAnimConfigurations }
                )
            or HasStand
                and HasStand.Humanoid
                    :LoadAnimation(CombatAnims[CharacterAnimationType .. Side .. NumberEvaluation])
                    :Play()
        )

    MoveStand.MoveStand(Character, { Priority = 1, Duration = 0.55 })

    if Variations[PlayerCombo.ComboVariation] ~= nil then
        Variations[PlayerCombo.ComboVariation](Player, CharacterName, KeyData, MoveData, ExtraData)
    end

    PlayerCombo.Hits = NumberEvaluation == 5 and 0 or PlayerCombo.Hits

    -- SoundManager:AddSound(Type.."Swing", {Parent = HumanoidRootPart}, "Client")
    StateManager:ChangeState(Character, "Attacking", 0.225)
    StateManager:ChangeState(Character, "Stunned", NumberEvaluation == 5 and 1.35 or 0)

    --StateManager:ChangeState(Character, "Stunned", NumberEvaluation == 5 and 1 or 0)

    --print(ExtraData.HitboxRange)

    coroutine.wrap(function()
        if Variations[PlayerCombo.ComboVariation] == nil then
            local HitResult, HitObject = HitboxModule.MagnitudeModule(
                Character,
                { Range = ExtraData.HitboxRange or 5, KeysLogged = PlayerCombo.KeysLogged, Type = Type },
                KeyData.SerializedKey,
                CharacterName
            )
            if HitResult then
                local Victim = HitObject.Parent
                local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

                wait(0.225)
                if NumberEvaluation == 3 and not StateManager:Peek(Character, "InAir") then
                    PlayerCombo.KeysLogged = 0
                    PlayerCombo.ComboVariation = ""

                    PlayerCombo.Hits = 0

                    StateManager:ChangeState(Character, "Attacking", 0.5)

                    VfxHandler.RemoveBodyMover(Victim)
                    VfxHandler.FaceVictim({ Character = Character, Victim = Victim })
                    StateManager:ChangeState(Victim, "IFrame", 1.15, { IFrameType = "" })

                    VfxHandler.SlamDown({ Character = Character, Victim = Victim, Duration = 0.85 })
                    RunService.Heartbeat:Wait()

                    NetworkStream.FireClientDistance(
                        Character,
                        "ClientRemote",
                        200,
                        {
                            Character = Character,
                            Victim = Victim,
                            Module = "CombatVFX",
                            Function = "AerialKnockBackEffect",
                        }
                    )
                    local _ = Finishers[Data.Character] ~= nil
                        and Finishers[Data.Character](Player, CharacterName, KeyData, MoveData, { Victim = Victim })
                end
            end
        end
    end)()
    SpeedManager.changeSpeed(Character, 7, 0.8, 2)

    PlayerCombo.LastPressed = os.clock()

    DebounceManager.SetDebounce(Character, "Swing", CharacterName)
    DebounceManager.SetDebounce(Character, "Swing2", CharacterName)
end
