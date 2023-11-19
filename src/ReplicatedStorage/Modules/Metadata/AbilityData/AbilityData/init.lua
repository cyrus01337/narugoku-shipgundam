--||Services||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--||Directories||--

local Modules = ReplicatedStorage.Modules

local Metadata = Modules.Metadata
local Utility = Modules.Utility

--|| Imports ||--
local Utility = require(Utility.Utility)

local CachedModules = {}

for _, Module in ipairs(script:GetDescendants()) do
    if Module:IsA("ModuleScript") then
        CachedModules[Module.Name] = require(Module)
    end
end

--||Remotes||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local AbilityData = {}

local GlobalInformation = {
    ["PlayerCombos"] = {
        LastPressed = os.clock(),
        BlockStartTime = os.clock(),
        KeysLogged = 0,
        LastKey = nil,
        Hits = 0,
        DamagedEntities = {},
        ComboVariation = "",
    },
}
function AbilityData.CreateProfile(Player)
    AbilityData[Player.Name] = {}

    AbilityData[Player.Name]["GlobalInformation"] = Utility.GetDeepCopy(GlobalInformation)

    --print(Player.Name)
    for CharacterIndex, CharacterData in pairs(CachedModules) do
        AbilityData[Player.Name][CharacterIndex] = Utility.GetDeepCopy(CharacterData)
    end
end

function AbilityData.ReturnData(Player, PathIndex, CharacterName)
    PathIndex = (type(PathIndex) == "string" and PathIndex) or warn("Invalid type.")
    CharacterName = (typeof(CharacterName) == "string" and CharacterName) or warn("Invalid type.")

    return AbilityData[Player.Name][CharacterName][PathIndex] or nil
end

function AbilityData.ResetCooldown(Player, CharacterName)
    if AbilityData[Player.Name][CharacterName] then
        for _, Ability in pairs(AbilityData[Player.Name][CharacterName]) do
            Ability.StartTime = 0
        end
    end
end
function AbilityData.RemoveKey(Player)
    AbilityData[Player.Name] = nil
    local _ = AbilityData[Player.Name] == nil and warn("cleared ability data for", Player.Name)
end

return AbilityData
