local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local ProfileService = require(ServerScriptService.Server.ProfileService)
local Store = require(ServerStorage.Modules.Store)

local INTERMISSION_DURATION = 10
local ROUND_DURATION = 300
local DEFAULT_HEALTH = 100
local PARTICIPATION_REWARD = 100
local LOBBY_SPAWN: SpawnLocation = workspace:WaitForChild("Lobby").SpawnLocation
local BATTLEFIELD_SPAWN: SpawnLocation = workspace.World:WaitForChild("Map").SpawnLocation
local Rounds = {
    Spawns = {
        Lobby = LOBBY_SPAWN,
        Battlefield = BATTLEFIELD_SPAWN,
    },
}

type DebugTimerCallback = () -> boolean

local function getHalfHeightOf(player: Player): Vector3
    if not player.Character then
        return Vector3.zero
    end

    local _, playerCharBounds = player.Character:GetBoundingBox()

    return Vector3.new(0, playerCharBounds.Y / 2, 0)
end

local function debugTimer(name: string, duration: number, shouldCancel: DebugTimerCallback?)
    for i = 1, duration do
        print("Waiting on", name, "for", duration - i + 1, "second(s)...")
        task.wait(1)

        if shouldCancel ~= nil and shouldCancel() then
            break
        end
    end
end

function Rounds.spawn(player: Player, spawnLocation: SpawnLocation)
    local playerChar = player.Character or player.CharacterAdded:Wait()

    -- cyrus01337: Setting Position/CFrame causes the centre of the player to be
    -- placed at the centre of the spawn, so we add half of the player's height
    -- to achieve perfect placement
    playerChar:PivotTo(spawnLocation.CFrame + getHalfHeightOf(player))
end

function Rounds.intermission()
    -- TODO: Reset score
    for _, player in Store.playersFighting do
        local playerHum: Humanoid = player.Character.Humanoid
        playerHum.Health = math.huge
        playerHum.MaxHealth = math.huge
        local playerData = ProfileService:GetPlayerProfile(player)
        playerData.Cash += PARTICIPATION_REWARD

        ProfileService:Replicate(player)
        table.insert(Store.playersFighting, player)
        Rounds.spawn(player, LOBBY_SPAWN)
    end

    debugTimer("Intermission", INTERMISSION_DURATION)
end

local function legibleToFight(player: Player)
    local playerData = ProfileService:GetPlayerProfile(player)

    return playerData ~= nil
end

local function isEmptyBattlefield()
    return #Store.playersFighting == 0
end

function Rounds.doRound()
    for _, player in Store.playersPastMainMenu do
        if not legibleToFight(player) then
            continue
        end

        local playerHum: Humanoid = player.Character.Humanoid
        playerHum.Health = DEFAULT_HEALTH
        playerHum.MaxHealth = DEFAULT_HEALTH

        table.insert(Store.playersFighting, player)
        Rounds.spawn(player, BATTLEFIELD_SPAWN)
    end

    debugTimer("Round", ROUND_DURATION, isEmptyBattlefield)
end

return Rounds
