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
local SoundManager = require(Shared.SoundManager)
local StateManager = require(Shared.StateManager)

--local AnimationManager = require(Shared.AnimationManager)

local Utilities = require(Utility.Utility)

--|| Variables ||--
local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote

local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local CollisionGroup = "StandGroup"

--|| Init ||--
PhysicsService:CreateCollisionGroup(CollisionGroup)
PhysicsService:CollisionGroupSetCollidable("Default",CollisionGroup,false)

local function ModelNetworkOwnership(Player,Model,Debounce)
	if Debounce then
		for _,v in ipairs(Model:GetDescendants()) do
			if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
				v.Anchored = false
				v.Massless = true
				v.CanCollide = false
				PhysicsService:SetPartCollisionGroup(v,CollisionGroup)
			end
		end
	elseif not Debounce then
		for _,v in ipairs(Model:GetDescendants()) do
			if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
				v.Anchored = false
				v.CanCollide = false
				v.Massless = true
				PhysicsService:SetPartCollisionGroup(v,CollisionGroup)
			end
		end
	end
end

return function(Player,Data)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

	local ChosenStand = Data.Stand

	-- SoundManager:AddSound("StandSummon",{Parent = Root, Volume = 1.25}, "Client")
	StateManager:ChangeState(Character, "Attacking", 1.25)

	local StandFolder = Character

	local SelectedStand = ReplicatedStorage.Assets.Models.Stands:FindFirstChild(ChosenStand):Clone()
	SelectedStand.Name = Character.Name.." - Stand"
	SelectedStand.Parent = StandFolder

	local StandHumanoid,StandRoot = SelectedStand:FindFirstChild("Humanoid"), SelectedStand:FindFirstChild("HumanoidRootPart")

	ModelNetworkOwnership(Player,SelectedStand,true)

	local Weld = Instance.new("Weld")
	Weld.Part0 = StandRoot
	Weld.Part1 = Root
	Weld.Parent = StandRoot

	local CalculatedOffset = CFrame.new(1,-0.5,-2)

	coroutine.wrap(function()
		for Index = 0,1,0.05 do
			Weld.C0 = Weld.C0:Lerp(CalculatedOffset,Index)
			RunService.Heartbeat:Wait()
		end
	end)()

	wait(.35)
	local Idle = StandHumanoid:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Stands[ChosenStand].Idle)
	Idle:Play()

	StandRoot.Transparency = 1
end