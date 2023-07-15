--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Shared = Modules.Shared
local Metadata = Modules.Metadata

--| |Imports ||--
local StateManager = require(Shared.StateManager)
local AbilityData = require(Metadata.AbilityData.AbilityData)
local CombatData = require(Metadata.CombatData.CombatData)

--| |Module ||--
local DebounceManager = {}

function DebounceManager.CheckDebounce(Character,SerializedKey,CharacterName)
	SerializedKey = (type(SerializedKey) == "string" and SerializedKey) or warn("Invalid type.")

	local Player = Players:GetPlayerFromCharacter(Character);	

	local ModeData = StateManager:ReturnData(Character, "Mode")
	local IndexCalculation = ModeData.Mode and CharacterName.."Mode" or CharacterName

	local ModifierCopy = AbilityData.ReturnData(Player,SerializedKey,IndexCalculation) or CombatData.ReturnData(Player,SerializedKey)

	if os.clock() - ModifierCopy.StartTime >= ModifierCopy.Cooldown then
		return true
	end	
	return false
end

function DebounceManager.SetDebounce(Character,SerializedKey,CharacterName,TimeToSet)
	SerializedKey = (type(SerializedKey) == "string" and SerializedKey) or warn("Invalid type.")
	CharacterName = (type(CharacterName) == "string" and CharacterName ) or warn("Invalid type.")

	local Player = Players:GetPlayerFromCharacter(Character)

	local ModeData = StateManager:ReturnData(Character, "Mode")
	local IndexCalculation = ModeData.Mode and CharacterName.."Mode" or CharacterName

	local ModifierCopy = AbilityData.ReturnData(Player,SerializedKey,IndexCalculation) or CombatData.ReturnData(Player,SerializedKey)
	ModifierCopy.StartTime = TimeToSet or os.clock()
end

return DebounceManager