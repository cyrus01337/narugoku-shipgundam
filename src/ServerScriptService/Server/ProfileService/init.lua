--|| Services ||--
local Players = game:GetService("Players")

local ScriptContext = game:GetService("ScriptContext")

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")

--||Imports||--
local ProfileService = require(script.ProfileService)

local DefaultData = require(script.DefaultData)

--||Remotes||--
local ReplicateRemote = ReplicatedStorage.Remotes.Replicate

--||Variables||--
local SessionProfiles = {}

local LoadedPlayers = {}

local ProfileWrapper = {}

local MainSessionData = ProfileService.GetProfileStore("PlayerDatav3", DefaultData)

--||Functions||--
local function OnPlayerAdded(Player)
    local PlayerProfile = MainSessionData:LoadProfileAsync("Player_" .. Player.UserId, "ForceLoad")

    if PlayerProfile ~= nil then
        PlayerProfile:Reconcile()

        PlayerProfile:ListenToRelease(function()
            SessionProfiles[Player] = nil

            Player:Kick()
        end)

        if Player:IsDescendantOf(Players) == true then
            SessionProfiles[Player] = PlayerProfile
            LoadedPlayers[Player] = true
        else
            PlayerProfile:Release()
        end
    else
        Player:Kick("Overload of requests.")
    end
end

function ProfileWrapper:GetPlayerProfile(Player)
    if SessionProfiles[Player] then
        return SessionProfiles[Player].Data
    end

    return nil
end

function ProfileWrapper:IsLoaded(Player)
    if LoadedPlayers[Player] == true then
        return true
    end

    return false
end

function ProfileWrapper:Replicate(Player)
    local PlayerProfile = ProfileWrapper:GetPlayerProfile(Player)
    --print(PlayerProfile)
    if PlayerProfile then
        ReplicateRemote:FireClient(Player, PlayerProfile)
    end
end

--||Initalize||--
for _, Player in ipairs(Players:GetPlayers()) do
    OnPlayerAdded(Player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)

Players.PlayerRemoving:Connect(function(Player)
    local CurrentProfile = SessionProfiles[Player]

    if CurrentProfile ~= nil then
        LoadedPlayers[Player] = nil

        CurrentProfile:Release()
    end
end)

return ProfileWrapper
