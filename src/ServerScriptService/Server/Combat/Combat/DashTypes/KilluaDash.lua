--|| Services ||--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Effects = Modules.Effects
local Shared = Modules.Shared

--|| Remotes ||--
local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote

--|| Modules ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(Shared.SoundManager)

local NetworkStream = require(Utility.NetworkStream)

local VfxHandler = require(Effects.VfxHandler)

--|| Variables ||--
local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Visuals}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

return function(Character,ExtraData,MoveData,DashCopy)
	local Player = Players:GetPlayerFromCharacter(Character)

	local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
	local MoveDirection = Humanoid.MoveDirection

	local DirectionKey = ExtraData.DirectionKey

	local DashingForce = DashCopy.DashingForce

	if not DashCopy.CanDash then return end

	VfxHandler.RemoveBodyMover(Character)
	VfxHandler.PlayerInvis({Character = Character, Duration = .25})
	--[[
	MoveDirection = Vector3.new(0, 0, 0) and (Root.CFrame.lookVector * 1) or MoveDirection
	
	local BodyPosition = Instance.new("BodyPosition")
	BodyPosition.Name = "GodspeedDash"
	BodyPosition.Position = (Root.CFrame * CFrame.new(DashCopy["Keys"][DirectionKey].Direction.X, 0, DashCopy["Keys"][DirectionKey].Direction.Z)).Position
	BodyPosition.MaxForce = Vector3.new(2e4,4e4,4e4)
	BodyPosition.P = 1000
	BodyPosition.D = 30
	BodyPosition.Parent = Root
--]]

	local AccurancyRange = 3
	local TeleportationRange = 20

	local EndCFrame = Character.PrimaryPart.CFrame * CFrame.new(0, 0, -TeleportationRange)

	local DetectionRay = workspace:Raycast(Root.Position, Vector3.new(0, 0, -10), raycastParams)
	if DetectionRay then
		local Target = DetectionRay.Instance
		if Target:IsA("BasePart") and Target:IsDescendantOf(workspace.World.Map) then
			local Distance = (Target.Position - Root.Position).Magnitude - AccurancyRange

			EndCFrame = CFrame.new(0, 0, -Distance)
		end
	end
	NetworkStream.FireClientDistance(Character, "ClientRemote", 150, {Character = Character , Module = "PlayerClient", Function = "GodspeedDash", ContactPointCFrame = Root.CFrame})

	Root.CFrame = EndCFrame
end	
