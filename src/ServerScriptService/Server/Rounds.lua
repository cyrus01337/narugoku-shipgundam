local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local Store = require(ServerStorage.Modules.Store)

local INTERMISSION_DURATION = 10
local ROUND_DURATION = 300
local LOBBY_SPAWN: SpawnLocation = workspace:WaitForChild("Lobby").SpawnLocation
local BATTLEFIELD_SPAWN: SpawnLocation = workspace.World:WaitForChild("Map").SpawnLocation
local Rounds = {}

local function stupidTimer(duration: number)
    for i = 1, duration do
        print("Waiting for", duration - i + 1, "second(s)...")
        task.wait(1)
    end
end

function Rounds.intermission()
    BATTLEFIELD_SPAWN.Enabled = false
    LOBBY_SPAWN.Enabled = true

    for _, player in Players:GetPlayers() do
        -- TODO: PLEASE change once state is unified properly
        local cyrus01337State = Store.useStateSliceFor(player)

        if not cyrus01337State.InRound then
            continue
        end

        cyrus01337State.InRound = false

        print(cyrus01337State)
        player:LoadCharacter()
    end

    stupidTimer(INTERMISSION_DURATION)
end

function Rounds.doRound()
    BATTLEFIELD_SPAWN.Enabled = true
    LOBBY_SPAWN.Enabled = false

    for _, player in Players:GetPlayers() do
        local cyrus01337State = Store.useStateSliceFor(player)
        cyrus01337State.InRound = true

        print(cyrus01337State)
        player:LoadCharacter()
    end

    stupidTimer(ROUND_DURATION)
end

return Rounds
