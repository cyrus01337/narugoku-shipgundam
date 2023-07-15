--|| Services ||--
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--||Imports||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

--||Remotes||--
local Remotes = ReplicatedStorage.Remotes

local CachedRemotes = {}

local Children = Remotes:GetChildren()

for _,Remote in ipairs(Children) do
	if Remote:IsA("RemoteEvent") or Remote:IsA("RemoteFunction") then
		CachedRemotes[Remote.Name] = Remote
	end
end

local NetworkStream = {}

function NetworkStream.FireClientDistance(Entity,RemoteName,RenderDistance,...)
	RenderDistance = RenderDistance or 20

	local RenderPlayers = GlobalFunctions.GetNearPlayers(Entity,RenderDistance)

	for _,Player in ipairs(RenderPlayers) do
		CachedRemotes[RemoteName]:FireClient(Player,...)
	end
end

function NetworkStream.FireOneClient(Player, RemoteName, RenderDistance,...)
	RenderDistance = RenderDistance or 20
	
	CachedRemotes[RemoteName]:FireClient(Player,...)
end
return NetworkStream