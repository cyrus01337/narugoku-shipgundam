--||Services||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--||Directories||--
local Modules = ReplicatedStorage.Modules

local Metadata = Modules.Metadata
local Utility = Modules.Utility

--||Imports||--

--||Remotes||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--||Variables||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Mouse = Player:GetMouse()

local Humanoid = Character:WaitForChild("Humanoid")

local Rukia = {

    ["FirstAbility"] = function(SerializedKey, KeyName)
        ServerRemote:FireServer(SerializedKey, KeyName, {})
    end,
    ["SecondAbility"] = function(SerializedKey, KeyName)
        ServerRemote:FireServer(SerializedKey, KeyName, {})
    end,

    ["ThirdAbility"] = function(SerializedKey, KeyName)
        ServerRemote:FireServer(SerializedKey, KeyName, {})
    end,

    ["FourthAbility"] = function(SerializedKey, KeyName)
        ServerRemote:FireServer(SerializedKey, KeyName, {})
    end,
}

return Rukia
