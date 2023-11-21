--|| Services |--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Directories ||--
local Server = ServerScriptService.Server
local Managers = Server.Managers

local Modules = ReplicatedStorage.Modules
local State = Server.State

local Effects = Modules.Effects
local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Shared = Modules.Shared
local CharacterData = Metadata.CharacterData

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)

local SoundManager = require(Shared.SoundManager)

local AbilityData = require(Metadata.AbilityData.AbilityData)
local CombatData = require(Metadata.CombatData.CombatData)

local CharacterInfo = require(CharacterData.CharacterInfo)

local VfxHandler = require(Effects.VfxHandler)

local StandManager = require(Managers.StandManager)
local ProfileService = require(Server.ProfileService)

local HitboxModule = require(Server.Combat.Combat.HitboxModule)
local Aerial = require(Server.Combat.Combat.Aerial)

local Gilgamesh = require(Server.Characters.Gilgamesh)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote

--|| Remotes ||--
local RemoteFolder = ReplicatedStorage.Remotes

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local AnimationRemote = RemoteFolder.AnimationRemote

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.World.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

local Finishers = {
    ["Hiei"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Humanoid, HumanoidRootPart =
            Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")

        local Victim = ExtraData.Victim
        local VHum, VRoot = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")

        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            200,
            { Character = Character, Victim = Victim, Module = "HieiVFX", Function = "BezierDash" }
        )
        coroutine.wrap(function()
            wait(0.75)
            VfxHandler.RemoveBodyMover(Character)
            HumanoidRootPart.CFrame = VRoot.CFrame * CFrame.new(0, 0, 4)
        end)()
    end,

    ["Gilgamesh"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Humanoid, HumanoidRootPart =
            Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")

        local Victim = ExtraData.Victim
        local VHum, VRoot = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")

        --[[coroutine.wrap(function()
			for Index = 1,2 do
				task.spawn(function()
					Gilgamesh.FirstAbility(Player,CharacterName,KeyData,MoveData,{MouseHit = VRoot.CFrame, Type = "Aerial"})
				end)							
				wait(.35)
			end
		end)()]]
    end,
}

return Finishers
