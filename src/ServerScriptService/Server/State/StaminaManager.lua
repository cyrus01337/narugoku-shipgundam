--||Services||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--||Directories||--
local Modules = ReplicatedStorage.Modules

local Metadata = Modules.Metadata

--||Imports||--
local AbilityData = require(Metadata.AbilityData.AbilityData)
local CombatData = require(Metadata.CombatData.CombatData)

--||Module||--
local StaminaManager = {}

function StaminaManager.CheckStamiina(Character, SerializedKey, CharacterName)
    local Player = Players:GetPlayerFromCharacter(Character)
    local PlayerSettings = Character:FindFirstChild("PlayerSettings")

    local Stamina = PlayerSettings:GetAttribute("Stamina")
    local ModifierCopy = AbilityData.ReturnData(Player, SerializedKey, CharacterName)
        or CombatData.ReturnData(Player, SerializedKey)

    PlayerSettings:SetAttribute("Stamina", Stamina)

    if Stamina <= ModifierCopy.Stamina then
        return true
    end

    return false
end

function StaminaManager.SetStamina(Character, SerializedKey, CharacterName, NumberToSet)
    local Player = Players:GetPlayerFromCharacter(Character)
    local PlayerSettings = Character:FindFirstChild("PlayerSettings")

    local Stamina = PlayerSettings:GetAttribute("Stamina")
    local ModifierCopy = AbilityData.ReturnData(Player, SerializedKey, CharacterName)
        or CombatData.ReturnData(Player, SerializedKey)

    PlayerSettings:SetAttribute("Stamina", NumberToSet or Stamina + NumberToSet)
end

return StaminaManager
