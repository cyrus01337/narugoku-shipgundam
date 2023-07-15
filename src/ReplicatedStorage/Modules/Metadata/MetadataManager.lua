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

for _,Module in pairs(script.Parent:GetDescendants()) do
	if Module:IsA("ModuleScript") and Module.Name ~= script.Name then
		CachedModules[Module.Name] = require(Module)
	end
end

--||Remotes||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--||Module||--
local MetadataManager = {}

function MetadataManager.Init(Player)
	
--	print("start")
	
	for _,Module in pairs(CachedModules) do
		
		if Module.CreateProfile then
			Module.CreateProfile(Player)
		end
		
	end
--	print("finished here")
end


return MetadataManager