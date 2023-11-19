--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local MarketPlaceService = game:GetService("MarketplaceService")

local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Shared = Modules.Shared
local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Metadata = Modules.Metadata

local Characterdata = Metadata.CharacterData

--|| Imports ||--
local AnimationManager = require(ReplicatedStorage.Modules.Shared.AnimationManager)

local CharacterInfo = require(Characterdata.CharacterInfo)
local ControlData = require(Metadata.ControlData.ControlData)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Humanoid = Character:WaitForChild("Humanoid")

local DashKeys = {
    ["W"] = "W",
    ["A"] = "A",
    ["S"] = "S",
    ["D"] = "D",
}

local ClickedMouse = 1
local Running, Blocking = false, false

local Combat = {
    ["Block"] = {
        ["Execute"] = function(SerializedKey, KeyName)
            ServerRemote:FireServer(SerializedKey, KeyName, { State = "Execute" })
        end,
        ["Terminate"] = function(SerializedKey, KeyName)
            ServerRemote:FireServer(SerializedKey, KeyName, { State = "Terminate" })
            print("Terminated")
        end,
    },

    ["Run"] = {
        ["Execute"] = function(SerializedKey, KeyName)
            ServerRemote:FireServer(SerializedKey, KeyName, { State = "Execute" })
        end,
        ["Terminate"] = function(SerializedKey, KeyName)
            ServerRemote:FireServer(SerializedKey, KeyName, { State = "Terminate" })
        end,
    },

    ["Aerial"] = function(SerializedKey, KeyName)
        while UserInputService:IsKeyDown(Enum.KeyCode[KeyName]) do
            local _ = _G.SpaceAerial == true and ServerRemote:FireServer(SerializedKey, KeyName)
            wait(0.225)
        end
    end,

    ["Mode"] = function(SerializedKey, KeyName)
        ServerRemote:FireServer(SerializedKey, KeyName)
    end,

    ["Swing"] = function(SerializedKey, KeyName)
        while UserInputService:IsMouseButtonPressed(Enum.UserInputType[KeyName]) do
            ServerRemote:FireServer(SerializedKey, KeyName, { WhichButton = "L" })
            wait(0.15)
        end
    end,

    --["Swing2"] = function(SerializedKey,KeyName)
    --	ServerRemote:FireServer("Swing",KeyName,{WhichButton = "R"})
    --end,

    ["Dash"] = function(SerializedKey, KeyName)
        if KeyName == "Q" then
            for _, Key in ipairs(UserInputService:GetKeysPressed()) do
                local CurrentKey = Key.KeyCode.Name
                if DashKeys[CurrentKey] then
                    ServerRemote:FireServer(SerializedKey, KeyName, { DirectionKey = CurrentKey })
                    break
                end
            end
        end
    end,
}

return Combat
