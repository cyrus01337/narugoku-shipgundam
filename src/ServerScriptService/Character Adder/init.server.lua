--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")

local MarketPlaceService = game:GetService("MarketplaceService")

--|| Remotes ||--
local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local GUIRemote = ReplicatedStorage.Remotes.GUIRemote

--|| Imports ||--
local Messages = require(script.Prefixes)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local StateManager = require(ReplicatedStorage.Modules.Shared.StateManager)
local SoundManager = require(ReplicatedStorage.Modules.Shared.SoundManager)

local ProfileService = require(ServerScriptService.Server.ProfileService)

local BannedIds = {
    1078192621,
    262511964,
    330532194,
}

local Connections = {}

local function AddToEntites(Character)
    while Players:FindFirstChild(Character.Name) and Character.Parent ~= workspace.World.Live do
        RunService.Heartbeat:Wait()
        if Players:GetPlayerFromCharacter(Character) and Players:FindFirstChild(Character.Name) then
            Character.Parent = workspace.World.Live
            --ProfileService:Replicate(Players:GetPlayerFromCharacter(Character))
        end
    end
    AnimationRemote:FireClient(
        Players:GetPlayerFromCharacter(Character),
        Character,
        "LoadAnimations",
        ReplicatedStorage.Assets.Animations.Shared:GetDescendants()
    )
    --ProfileService:Replicate(Players:GetPlayerFromCharacter(Character))
end

Players.PlayerAdded:Connect(function(Player)
    local _ = table.find(BannedIds, Player.UserId) and Player:Kick()

    Connections[Player] = Player.CharacterAdded:Connect(function(Character)
        AddToEntites(Character)

        StateManager:ChangeState(Character, "Running", false)
    end)

    local Stats = GlobalFunctions.NewInstance("Folder", { Parent = Player, Name = "leaderstats" })

    GlobalFunctions.NewInstance("NumberValue", { Parent = Stats, Name = "Points", Value = 0 })
    GlobalFunctions.NewInstance("NumberValue", { Parent = Player, Name = "Mode", Value = 0 })
    GlobalFunctions.NewInstance(
        "BoolValue",
        { Parent = Player:WaitForChild("Mode"), Name = "ModeBoolean", Value = false }
    )

    Player:WaitForChild("Mode").Changed:Connect(function(NewValue)
        local ModeValue = Player:WaitForChild("Mode")
        local ModeData = StateManager:ReturnData(Player.Character or Player.CharacterAdded:Wait(), "Mode")

        ModeValue.Value = math.clamp(NewValue, 0, ModeData.MaxModeValue + 5)
        ModeData.ModeValue = ModeValue.Value
    end)

    Player.Chatted:Connect(function(Message)
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Humanoid = Character:FindFirstChild("Humanoid")

        if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, 18729033) then
            for Index, Table in next, Messages do
                if Message == "/e " .. Index and StateManager:Peek(Character, "Emoting") then
                    StateManager:ChangeState(Character, "Emoting", 4e4)
                    -- SoundManager:AddSound(Index,{Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = Table["Volume"], Looped = true}, "Client", {Duration = 1000})
                    AnimationRemote:FireClient(Player, Index, "Play", { Looped = true })

                    while StateManager:Peek(Character, "Attacking") and not StateManager:Peek(Character, "Stunned") do
                        Humanoid.WalkSpeed = Table["WalkSpeed"]
                        Humanoid.JumpPower = Table["JumpPower"]

                        RunService.Heartbeat:Wait()
                    end
                    Humanoid.WalkSpeed = 14
                    Humanoid.JumpPower = 50

                    SoundManager:StopSound(Index, { Parent = Character:FindFirstChild("HumanoidRootPart") }, "Client")
                    AnimationRemote:FireClient(Player, Index, "Stop")
                    StateManager:ChangeState(Character, "Emoting", 0.001)
                end
            end
        end
    end)
    ProfileService:GetPlayerProfile(Player)
end)

Players.PlayerRemoving:Connect(function(Player)
    Connections[Player] = Connections[Player] and Connections[Player]:Disconnect()
end)
