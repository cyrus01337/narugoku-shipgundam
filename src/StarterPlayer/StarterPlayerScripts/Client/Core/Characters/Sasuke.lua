--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Metadata = Modules.Metadata
local Utility = Modules.Utility

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer

local Mouse = Player:GetMouse()

local function GetNearestFromMouse(Character, Range)	
	local MouseHit = Mouse.Hit

	for _, Entity in ipairs(workspace.World.Live:GetChildren()) do
		if Entity:IsA("Model") and GlobalFunctions.IsAlive(Entity) and Entity ~= Character then
			local EntityPrimary = Entity:FindFirstChild("HumanoidRootPart")
			local Distance = (MouseHit.Position - EntityPrimary.Position).Magnitude

			if Distance <= Range then
				return Entity:FindFirstChild("HumanoidRootPart").CFrame or nil
			end
		end
	end
end

local Sasuke = {
	["FirstAbility"] = function(SerializedKey,KeyName)
		ServerRemote:FireServer(SerializedKey,KeyName)
	end,
	["SecondAbility"] = function(SerializedKey,KeyName)
		ServerRemote:FireServer(SerializedKey,KeyName,{})		
	end,

	["ThirdAbility"] = function(SerializedKey,KeyName)
		ServerRemote:FireServer(SerializedKey,KeyName,{})		
	end,

	["FourthAbility"] = function(SerializedKey,KeyName)
		local DesignatedTarget = Mouse.Hit
		local Victim = nil
		
		local Character = Player.Character or Player.CharacterAdded:Wait()
		local Humanoid = Character:WaitForChild("Humanoid")

		Victim = GetNearestFromMouse(Character,8) or nil
		ServerRemote:FireServer(SerializedKey,KeyName,{Victim = Victim, DesignatedTarget = DesignatedTarget, MouseHit = Mouse.Hit})
	end,
}

return Sasuke