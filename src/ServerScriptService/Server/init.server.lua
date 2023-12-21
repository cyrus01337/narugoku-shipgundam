local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScriptContext = game:GetService("ScriptContext")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local modules = ReplicatedStorage.Modules
local server = ServerScriptService.Server
local Constants = require(script.Constants)
local AbilityData = require(modules.Metadata.AbilityData.AbilityData)
local CombatData = require(modules.Metadata.CombatData.CombatData)
local ControlData = require(modules.Metadata.ControlData.ControlData)
local DebounceManager = require(script.State.DebounceManager)
local HttpModule = require(script.HttpModule)
local MetadataManager = require(modules.Metadata.MetadataManager)
local ProfileService = require(server.ProfileService)
local Rounds = require(server.Rounds)
local StateManager = require(modules.Shared.StateManager)
local Store = require(ServerStorage.Modules.Store)
local ToSwapCharacter = require(script.ServerRequests.CharacterChange.ToSwapCharacter)

local remotes = ReplicatedStorage.Remotes
local dataRequest: RemoteEvent = remotes.DataRequest
local enteredGame: RemoteEvent = remotes.EnteredGame
local guiRemote: RemoteEvent = remotes.GUIRemote
local serverRemote: RemoteEvent = remotes.ServerRemote
local serverRequest: RemoteEvent = remotes.ServerRequest
-- TODO: Purge
local cachedModules = {}
local requestModules = {}

type ExtraData = {
    State: string,
}

local function logError(error: string, stackTrace: string, scriptObject: BaseScript)
    warn(string.format("Rex-chan caught error:\n\t%s at:\n\t%s", error, stackTrace))
    HttpModule:PostToWebhook("Error", error, stackTrace)
end

local function spawnPlayer(player: Player)
    local playerData = ProfileService:GetPlayerProfile(player)

    if playerData.Character == Constants.NO_CHARACTER then
        local message = string.format("No character selected for %s", player.Name)

        warn(message)

        return
    end

    ToSwapCharacter({ ToSwap = playerData.Character, Player = player })
end

local function initPlayerCharacterMetadata(playerChar: Model)
    local player = Players:GetPlayerFromCharacter(playerChar)

    StateManager.Initiate(playerChar)
    ProfileService:Replicate(player)
end

local function onCharacterAdded(playerChar: Model)
    local player = Players:GetPlayerFromCharacter(playerChar)
    local success, error = pcall(initPlayerCharacterMetadata, playerChar)

    if not success then
        warn(error)

        return
    end

    spawnPlayer(player)
    ProfileService:Replicate(player)

    local playerData = ProfileService:GetPlayerProfile(player)

    guiRemote:FireClient(player, "SkillUI", {
        Function = "ChangeSlots",
        Character = playerData.Character,
    })
end

local function onCharacterRemoving(playerChar: Model)
    local player = Players:GetPlayerFromCharacter(playerChar)
    local playerData = ProfileService:GetPlayerProfile(player)

    StateManager:Remove(playerChar)

    if not playerChar then
        return
    end

    -- Avoid niche error where the profile is invalidated when needed
    if playerData then
        AbilityData.ResetCooldown(player, playerData.Character)
    end
end

local function onPlayerAdded(player: Player)
    -- TODO: Refactor to use a Signal
    while not ProfileService:IsLoaded(player) do
        task.wait(1)
    end

    local playerChar = player.Character or player.CharacterAdded:Wait()

    pcall(function()
        StateManager.Initiate(playerChar)
        MetadataManager.Init(player)
    end)

    onCharacterAdded(playerChar)
    ProfileService:Replicate(player)
    player.CharacterAdded:Connect(onCharacterAdded)
    player.CharacterRemoving:Connect(onCharacterRemoving)
end

local function removePlayerMetadata(player: Player)
    AbilityData.RemoveKey(player)
    CombatData.RemoveKey(player)
    table.remove(Store.playersPastMainMenu, table.find(Store.playersPastMainMenu, player))
    table.remove(Store.playersFighting, table.find(Store.playersFighting, player))
end

local function onServerRemote(player: Player, skillName: string, keyName: string, extraData: ExtraData)
    local playerChar = player.Character or player.CharacterAdded:Wait()
    local playerRootFound: Part? = playerChar:FindFirstChild("HumanoidRootPart")
    local playerHumFound: Humanoid? = playerChar:FindFirstChild("Humanoid")

    if not (playerChar and playerRootFound and playerHumFound and playerHumFound.Health > 0) then
        return
    end

    local isRunning = StateManager:Peek(playerChar, "Running")
    local playerData = ProfileService:GetPlayerProfile(player)
    local characterName = playerData.Character
    local modeData = StateManager:ReturnData(playerChar, "Mode")
    local indexCalculation = if modeData.Mode then characterName .. "Mode" else characterName

    if not indexCalculation then
        warn("character has invalid module")
    end

    local skillData = AbilityData.ReturnData(player, skillName, indexCalculation)
        or CombatData.ReturnData(player, skillName)

    if skillData.Bool and skillData.Bool == true then
        return
    end

    if skillData.Bool ~= nil then
        skillData.Bool = true
    end

    local allowedAttackSkills = StateManager:ReturnData(playerChar, "Attacking").AllowedSkills
    local allowedBlockSkills = StateManager:ReturnData(playerChar, "Blocking").AllowedSkills
    local moduleName = if ControlData.Controls.Combat[keyName] then "Combat" else indexCalculation
    local cachedModule = cachedModules[moduleName][skillName]

    if type(extraData) == "table" and extraData.State == "Terminate" and isRunning then
        cachedModule.Terminate(
            player,
            characterName,
            { SerializedKey = "Run", KeyName = "LeftShift" },
            skillData,
            extraData
        )
    end

    local isBlocking = StateManager:ReturnData(playerChar, "Blocking").IsBlocking
    local hitCooldown = DebounceManager.CheckDebounce(playerChar, skillName, characterName)

    -- TODO: Find out what this does
    if
        player
        and StateManager:Peek(playerChar, "Guardbroken")
        and (StateManager:Peek(playerChar, "Attacking") and not isBlocking or allowedAttackSkills[skillName] or allowedBlockSkills[skillName])
        and not StateManager:Peek(playerChar, "Stunned")
        and hitCooldown
    then
        if
            (isBlocking and allowedBlockSkills[skillName])
            or (not StateManager:Peek(playerChar, "Attacking") and allowedAttackSkills[skillName])
            or StateManager:Peek(playerChar, "Attacking")
        then
            if type(cachedModule) == "table" then
                local stateModuleCallback = cachedModule[extraData.State]

                stateModuleCallback(player, characterName, {
                    SerializedKey = skillName,
                    KeyName = keyName,
                }, skillData, extraData)
            else
                cachedModule(player, characterName, {
                    SerializedKey = skillName,
                    KeyName = keyName,
                }, skillData, extraData, cachedModules)
            end
        end
    elseif type(extraData) == "table" and extraData.State == "Terminate" then
        cachedModule[extraData.State](player, characterName, {
            SerializedKey = skillName,
            KeyName = keyName,
        }, skillData, extraData)
    end

    StateManager:ChangeState(playerChar, "LastAbility", 10, { Skill = skillName })
    StateManager:ChangeState(playerChar, "LastSkill", 5, { Skill = skillData.Name })

    if skillData.Bool ~= nil then
        skillData.Bool = false
    end
end

local function onServerRequest(player: Player, request: string, character: string, type_: string)
    local requestHandlerFound = requestModules[request]

    if requestHandlerFound then
        requestHandlerFound(player, request, character, ProfileService, type_)
    end
end

local function onDataRequest(player: Player)
    local start = time()

    while not ProfileService:IsLoaded(player) or time() - start >= 20 do
        task.wait(1)
    end
end

local function trackUniqueInGamePlayer(player: Player)
    local entryIndexFound = table.find(Store.playersPastMainMenu, player)

    if entryIndexFound then
        return
    end

    Store.tagPlayerPastMainMenu(player)
end

local function setupLobbyDummies()
    local blockDummy = workspace.World.Live:WaitForChild("BlockDummy")
    local parryDummy = workspace.World.Live:WaitForChild("ParryDummy")
    local blockAnimation =
        blockDummy.Humanoid:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Combat.Block.BlockIdle)
    local parryAnimation =
        parryDummy.Humanoid:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Combat.Block.BlockIdle)

    blockAnimation:Play()
    parryAnimation:Play()
end

for _, player in Players:GetPlayers() do
    task.spawn(onPlayerAdded, player)
end

ScriptContext.Error:Connect(logError)
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(removePlayerMetadata)
serverRemote.OnServerEvent:Connect(onServerRemote)
serverRequest.OnServerEvent:Connect(onServerRequest)
dataRequest.OnServerEvent:Connect(onDataRequest)
enteredGame.OnServerEvent:Connect(trackUniqueInGamePlayer)

for _, child in script.ServerRequests:GetChildren() do
    if not child:IsA("ModuleScript") then
        continue
    end

    requestModules[child.Name] = require(child)
end

for _, descendant in script:GetDescendants() do
    if not descendant:IsA("ModuleScript") then
        continue
    end

    cachedModules[descendant.Name] = require(descendant)
end

setupLobbyDummies()

while true do
    if #Store.playersPastMainMenu == 0 then
        Store.PlayerPassedMainMenu:Wait()
    end

    Rounds.intermission()
    Rounds.doRound()
end
