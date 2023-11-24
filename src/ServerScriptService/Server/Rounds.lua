local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local ProfileService = require(ServerScriptService.Server.ProfileService)
local Store = require(ServerStorage.Modules.Store)
local Types = require(ReplicatedStorage.Modules.Shared.Utils.Types)

local INTERMISSION_DURATION = 10
local ROUND_DURATION = 300
local DEFAULT_HEALTH = 100
local TOTAL_REWARDED_IDLERS = 4
local LOBBY_SPAWN: SpawnLocation = workspace:WaitForChild("Lobby").SpawnLocation
local BATTLEFIELD_SPAWN: SpawnLocation = workspace.World:WaitForChild("Map").SpawnLocation
local REWARDS = {
    FIGHTER = 115,
    IDLE = 20,
    WINNER = 225,
}
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

local function getPlayersLegibleForReward(players: Types.Array<Player>): Types.Array<Player>
    local skipped: Types.Array<Player> = {}

    table.sort(players, function(a, b)
        local foundLeaderstatsForPlayerA = a:FindFirstChild("leaderstats")
        local foundLeaderstatsForPlayerB = b:FindFirstChild("leaderstats")

        if not foundLeaderstatsForPlayerA then
            warn(string.format("Leaderstats not found in player %s, skipping reward...", a.Name))
            table.insert(skipped, a)

            return false
        elseif not foundLeaderstatsForPlayerB then
            warn(string.format("Leaderstats not found in player %s, skipping reward...", b.Name))
            table.insert(skipped, b)

            return false
        end

        return a.leaderstats.Points < b.leaderstats.Points
    end)

    return skipped
end

type Winner = Player
type Idlers = Types.Array<Player>
type Fighters = Types.Array<Player>

local function partitionPlayers(players: Types.Array<Player>): (Winner, Fighters, Idlers)
    local playerCount = #players
    local winner = players[1]
    local idlers: Idlers = {}
    local fighters: Fighters = {}

    if playerCount > 1 and playerCount <= TOTAL_REWARDED_IDLERS + 1 then
        for i = 2, playerCount do
            local player = players[i]

            table.insert(idlers, player)
        end

        return winner, fighters, idlers
    end

    for i = 1, TOTAL_REWARDED_IDLERS do
        local idler = players[playerCount - (i - 1)]

        table.insert(idlers, idler)
    end

    local firstIdlerIndex = playerCount + 1 - TOTAL_REWARDED_IDLERS

    for i = 2, firstIdlerIndex do
        local player = players[i]

        table.insert(fighters, player)
    end

    return winner, fighters, idlers
end

local function rewardPlayers(players: Types.Array<Player>)
    local winner, fighters, idlers = partitionPlayers(players)
    local winnerProfile = ProfileService:GetPlayerProfile(winner)
    winnerProfile.Cash += REWARDS.WINNER

    ProfileService:Replicate(winner)

    for _, fighter in fighters do
        local profile = ProfileService:GetPlayerProfile(fighter)
        profile.Cash += REWARDS.FIGHTER

        ProfileService:Replicate(fighter)
    end

    for _, idler in idlers do
        local profile = ProfileService:GetPlayerProfile(idler)
        profile.Cash += REWARDS.IDLE

        ProfileService:Replicate(idler)
    end
end

function Rounds.intermission()
    local toReward = getPlayersLegibleForReward(Store.playersFighting)

    rewardPlayers(toReward)

    for _, player in Store.playersFighting do
        local playerHum: Humanoid = player.Character.Humanoid
        playerHum.Health = math.huge
        playerHum.MaxHealth = math.huge
        player.leaderstats.Points = 0

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
