--||Services||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")

--||Directories||--
local Modules = ReplicatedStorage.Modules

local Metadata = Modules.Metadata

--||Imports||--
local AbilityData = require(Metadata.AbilityData.AbilityData)
local CombatData = require(Metadata.CombatData.CombatData)

local StateManager = require(Modules.Shared.StateManager)

--||Module||--
local ChargeManager = {}
local ChargingPlayers = {} -- ChargeManager[ChargingPlayers][Player] = {StartTime = os.clock(), ChargeDuration = 1}}

function ChargeManager.QueuePlayer(Player, Time)
    ChargingPlayers[Player] = {
        StartTime = os.clock(),
        ChargeDuration = 0.5,
    }
end

--RunService.Heartbeat:Connect(function(DeltaTime)
--	if #ChargingPlayers > 0 then
--	for _, Player in ipairs(ChargingPlayers) do

--	end
--end
--end)

return ChargeManager
