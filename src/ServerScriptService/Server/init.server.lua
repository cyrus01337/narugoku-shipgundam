local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScriptContext = game:GetService("ScriptContext")
local ServerScriptService = game:GetService("ServerScriptService")

local modules = ReplicatedStorage.Modules
local metadata = modules.Metadata
local server = ServerScriptService.Server
local serverRequests = server.ServerRequests
local shared = modules.Shared
local state = server.State
local AbilityData = require(metadata.AbilityData.AbilityData)
local CombatData = require(metadata.CombatData.CombatData)
local ControlData = require(metadata.ControlData.ControlData)
local DebounceManager = require(state.DebounceManager)
local HttpModule = require(script.HttpModule)
local MetadataManager = require(metadata.MetadataManager)
local ProfileService = require(server.ProfileService)
local StateManager = require(shared.StateManager)
local ToSwapCharacter = require(serverRequests.CharacterChange.ToSwapCharacter)

local INTERMISSION_DURATION = 10
local ROUND_DURATION = 300
local serverRemote = ReplicatedStorage.Remotes.ServerRemote
local serverRequest = ReplicatedStorage.Remotes.ServerRequest
local guiRemote = ReplicatedStorage.Remotes.GUIRemote
local dataRequest = ReplicatedStorage.Remotes.DataRequest
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
    local playerChar = player.Character or player.CharacterAdded:Wait()
    local playerHum = playerChar:WaitForChild("Humanoid") :: Humanoid
    local playerData = ProfileService:GetPlayerProfile(player)
    local playerMode = player:WaitForChild("Mode", 60)
    local playerModeState = StateManager:ReturnData(playerChar, "Mode")
    local mode = if player.Name == "DaWunbo" or player.Name == "Freshzsz" then 285 else 0
    playerMode.Value = mode
    playerModeState.ModeValue = mode

    ToSwapCharacter({ ToSwap = playerData.Character, Player = player })

    playerHum.WalkSpeed = 14

    ProfileService:Replicate(player)
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

    --AddToEntites(playerChar)
    --	ProfileService:Replicate(Players:GetPlayerFromCharacter(playerChar))

    spawnPlayer(player)
    ProfileService:Replicate(Players:GetPlayerFromCharacter(playerChar))

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

    AbilityData.ResetCooldown(player, playerData.Character)
end

local function onPlayerAdded(player: Player)
    -- repeat
    --     wait(0.1)
    -- until ProfileService:IsLoaded(Player) == true

    local playerChar = player.Character or player.CharacterAdded:Wait()

    pcall(function()
        StateManager.Initiate(playerChar)
        MetadataManager.Init(player)
        spawnPlayer(player)
    end)

    --AddToEntites(Character)

    ProfileService:Replicate(player)

    player.CharacterAdded:Connect(onCharacterAdded)
    player.CharacterRemoving:Connect(onCharacterRemoving)
end

local function removePlayerMetadata(player: Player)
    AbilityData.RemoveKey(player)
    CombatData.RemoveKey(player)
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

local function onServerRequest(player: Player, request, character: string, type_)
    local requestHandlerFound = requestModules[request]

    if requestHandlerFound then
        requestHandlerFound(player, request, character, ProfileService, type_)
    end
end

local function onDataRequest(player: Player)
    if not ProfileService:IsLoaded(player) then
        warn(string.format("Unable to process data request for %s", player.Name))
        return
    end

    local start = time()

    repeat
        wait(0.5)
    until ProfileService:IsLoaded(player) or time() - start >= 20

    return ProfileService:GetPlayerProfile(player)
end

local function setupLobbyDummies()
    local BlockDummy = workspace.World.Live.BlockDummy
    local ParryDummy = workspace.World.Live.ParryDummy
    local BlockHum = BlockDummy:FindFirstChild("Humanoid")
    local ParryHum = ParryDummy:FindFirstChild("Humanoid")

    BlockHum:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Combat.Block.BlockIdle):Play()
    ParryHum:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Combat.Block.BlockIdle):Play()
end

local function accurateTimer(duration: number, callback: () -> ())
    local start = time()

    callback()

    local now = time()

    task.wait(duration - (now - start))
end

local function intermission()
    local start = time()

    local now = time()

    task.wait(INTERMISSION_DURATION - (now - start))
end

local function doRound()
    task.wait(ROUND_DURATION)
end

ScriptContext.Error:Connect(logError)
serverRemote.OnServerEvent:Connect(onServerRemote)
serverRequest.OnServerEvent:Connect(onServerRequest)
dataRequest.OnServerEvent:Connect(onDataRequest)

for _, child in serverRequests:GetChildren() do
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

for _, player in Players:GetPlayers() do
    task.spawn(onPlayerAdded, player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(removePlayerMetadata)
setupLobbyDummies()

while true do
    accurateTimer(INTERMISSION_DURATION, intermission)
    accurateTimer(ROUND_DURATION, doRound)
end
