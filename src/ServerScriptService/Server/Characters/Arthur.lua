 --||Services||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--||Directories||--
local Server = ServerScriptService.Server

local Modules = ReplicatedStorage.Modules

local State = Server.State

local Shared = Modules.Shared
local Metadata = Modules.Metadata
local Utility = Modules.Utility

--|| Imports ||--


local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)

--||Remotes||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote


local Arthur = {
	["FirstAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		print("FIRST SKILL")
		local Character = Player.Character
		
	
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
	end,
	
}



return Arthur