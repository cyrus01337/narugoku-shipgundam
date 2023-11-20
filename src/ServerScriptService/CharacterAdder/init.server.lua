local MarketPlaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local messages = require(script.Prefixes)
local StateManager = require(ReplicatedStorage.Modules.Shared.StateManager)
local SoundManager = require(ReplicatedStorage.Modules.Shared.SoundManager)
local ProfileService = require(ServerScriptService.Server.ProfileService)

local animationRemote = ReplicatedStorage.Remotes.AnimationRemote
local leaderstatsTemplate = ServerStorage:WaitForChild("LeaderstatsTemplate", 60)
local connections: { [Player]: RBXScriptConnection } = {}
local bannedIDs = {
    1078192621,
    262511964,
    330532194,
}

local function addEntity(playerChar: Model)
    local player = Players:GetPlayerFromCharacter(playerChar) :: Player

    while playerChar.Parent ~= workspace.World.Live do
        if playerChar.Parent == nil then
            playerChar.AncestryChanged:Wait()
        end

        playerChar.Parent = workspace.World.Live
        --ProfileService:Replicate(Players:GetPlayerFromCharacter(Character))
    end

    animationRemote:FireClient(
        player,
        playerChar,
        "LoadAnimations",
        ReplicatedStorage.Assets.Animations.Shared:GetDescendants()
    )
    --ProfileService:Replicate(Players:GetPlayerFromCharacter(Character))
end

local function initPlayerCharacterMetadata(playerChar: Model)
    addEntity(playerChar)
    StateManager:ChangeState(playerChar, "Running", false)
end

-- TODO: Refactor using Cmdr
local function processChatEmotes(message: string, speaker: Player?)
    if not speaker then
        return
    end

    local Character = speaker.Character or speaker.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChild("Humanoid")

    if MarketPlaceService:UserOwnsGamePassAsync(speaker.UserId, 18729033) then
        for index, emotes in messages do
            if message == "/e " .. index and StateManager:Peek(Character, "Emoting") then
                local isAttacking = StateManager:Peek(Character, "Attacking")
                    and not StateManager:Peek(Character, "Stunned")

                StateManager:ChangeState(Character, "Emoting", 4e4)
                -- SoundManager:AddSound(Index,{Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = Table["Volume"], Looped = true}, "Client", {Duration = 1000})
                animationRemote:FireClient(speaker, index, "Play", { Looped = true })

                if isAttacking then
                    Humanoid.WalkSpeed = emotes.WalkSpeed
                    Humanoid.JumpPower = emotes.JumpPower

                    while isAttacking do
                        isAttacking = StateManager:Peek(Character, "Attacking")
                            and not StateManager:Peek(Character, "Stunned")

                        RunService.Heartbeat:Wait()
                    end
                end

                Humanoid.WalkSpeed = 14
                Humanoid.JumpPower = 50

                SoundManager:StopSound(index, { Parent = Character:FindFirstChild("HumanoidRootPart") }, "Client")
                animationRemote:FireClient(speaker, index, "Stop")
                StateManager:ChangeState(Character, "Emoting", 0.001)
            end
        end
    end
end

local function onPlayerAdded(player: Player)
    local playerBanned = table.find(bannedIDs, player.UserId)

    if playerBanned then
        player:Kick()

        return
    end

    local playerLeaderstats = leaderstatsTemplate:Clone()
    playerLeaderstats.Name = "leaderstats"
    playerLeaderstats.Parent = player
    local playerChar = player.Character or player.CharacterAdded:Wait()
    local playerMode = player:WaitForChild("Mode", 60) :: NumberValue

    initPlayerCharacterMetadata(playerChar)
    player.CharacterAdded:Connect(initPlayerCharacterMetadata)
    player.Chatted:Connect(processChatEmotes)

    playerMode.Changed:Connect(function(mode)
        local ModeData = StateManager:ReturnData(playerChar, "Mode")
        playerMode.Value = math.clamp(mode, 0, ModeData.MaxModeValue + 5)
        ModeData.ModeValue = playerMode.Value
    end)

    ProfileService:GetPlayerProfile(player)
end

local function onPlayerRemoving(player: Player)
    local connectionFound = connections[player]

    if not connectionFound then
        return
    end

    connectionFound:Disconnect()

    connections[player] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
