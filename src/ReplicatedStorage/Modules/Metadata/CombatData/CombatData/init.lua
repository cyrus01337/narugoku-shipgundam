--||Services||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--||Directories||--

local Modules = ReplicatedStorage.Modules

local Metadata = Modules.Metadata
local Utility = Modules.Utility

--|| Imports ||--
local Utility = require(Utility.Utility)

local CombatPresets = require(script.CombatPresets)

--||Remotes||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local CombatData = {}

function CombatData.CreateProfile(Player)
    CombatData[Player.Name] = {
        ["Combat"] = Utility.GetDeepCopy(CombatPresets),
    }
end

function CombatData.ReturnData(Player, PathIndex)
    PathIndex = (type(PathIndex) == "string" and PathIndex) or warn("Invalid type.")

    return CombatData[Player.Name]["Combat"][PathIndex] or warn("path was not specified")
end

function CombatData.RemoveKey(Player)
    CombatData[Player.Name] = nil
    local _ = CombatData[Player.Name] == nil and warn("cleared combat data for", Player.Name)
end

return CombatData
