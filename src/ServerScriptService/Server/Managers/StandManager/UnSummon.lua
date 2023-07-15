--|| Services ||--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local Debris = game:GetService("Debris")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Effects = Modules.Effects
local Shared = Modules.Shared

--|| Modules ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(Shared.SoundManager)
local StateManager = require(Shared.StateManager)

local Utilities = require(Utility.Utility)

--|| Variables ||--
local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

return function(Player,Data)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

	local ChosenStand = Data.Stand

	local Stands = Character

	local Stand = Stands:FindFirstChild(ChosenStand)

	if not Stand then return end

	-- SoundManager:AddSound("StandPoof",{Parent = Root, Volume = 1.25}, "Client")
	StateManager:ChangeState(Character, "Attacking", 1.25)

	local Weld = Stand.PrimaryPart.Weld

	GlobalFunctions.TweenFunction({
		["Instance"] = Weld,
		["EasingStyle"] = Enum.EasingStyle.Exponential,
		["EasingDirection"] = Enum.EasingDirection.Out,
		["Duration"] = .4,
	},{
		["C0"] = CFrame.new(0,0,0)
	})

	for Index = 0,1,.05 do
		for _,v in ipairs(Stand:GetDescendants()) do
			if v:IsA("Decal") or v:IsA("Part") or v:IsA("MeshPart") then
				v.Transparency = Index
			end
		end
		RunService.Heartbeat:Wait()
	end
	Stand:Destroy()
end