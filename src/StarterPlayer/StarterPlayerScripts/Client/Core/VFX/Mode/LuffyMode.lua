--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Shared = Modules.Shared
local Utility = Modules.Utility

local HitPart2 = Models.Misc.HitPart2

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(Shared.SoundManager)

local TaskScheduler = require(Utility.TaskScheduler)

local Explosions = require(Modules.Effects.Explosions)
local VfxHandler = require(Modules.Effects.VfxHandler)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local Humanoid = Character:WaitForChild("Humanoid")

local function RemoveTrash(Trash)
	for i = 1,#Trash do
		local Item = Trash[i]
		if Item and Item.Parent then
			Item:Destroy()
		end
	end
end

local function Lerp(Start, End, Alpha)
	return Start + (End - Start) * Alpha
end

local function BezierCurve(Start, Offset, End, Alpha)
	local FirstLerp = Lerp(Start, Offset, Alpha)
	local SecondLerp = Lerp(Offset, End, Alpha)

	local BezierLerp = Lerp(FirstLerp, SecondLerp, Alpha)

	return BezierLerp
end

local LuffyMode = {	
	["ModeEffects"] = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")
		
		local StartTime = os.clock()
		
		for _,v in ipairs(Character:GetChildren()) do
			if v:IsA("BodyColors") then
				v:Destroy()
				script.GearSecond:Clone().Parent = Character
			end
		end
		
		-- SoundManager:AddSound("Gear2Transformation",{Parent = Root},"Client")
		
		local Particles = {Particles.Gear2Smoke:Clone(),Particles.Gear2SmokeReg:Clone()}

		for _,v in ipairs(Particles) do
			if v:IsA("ParticleEmitter") then
				if v.Name == "Gear2Smoke" then
					for _,x in ipairs(Character:GetChildren()) do
						if x:IsA("BasePart") and x.Name ~= "HumanoidRootPart" then
							local Particle = v:Clone()
							Particle.Enabled = false
							Particle.Parent = x
							Particle.Enabled = true
							
							Debris:AddItem(v,58)
						end
					end
				end
			else
				local Smoke = v:Clone()
				Smoke.Parent = Root
			end
		end
		
		while os.clock() - StartTime <= 58 and _G.Data.Character == "Luffy" do
			RunService.Heartbeat:Wait()
		end
		
		for _,v in ipairs(Character:GetChildren()) do
			if v:IsA("BodyColors") then
				v:Destroy()
				script.Reg:Clone().Parent = Character
			end
		end	
		local _ = Character:FindFirstChild("Gear2On") and Character.Gear2On:Destroy()
		
		for _,v in ipairs(Character:GetChildren()) do
			if v:FindFirstChildOfClass("ParticleEmitter") or v:FindFirstChildOfClass("Smoke") then
				if v:FindFirstChild("Gear2Smoke") then
					v:FindFirstChild("Gear2Smoke").Enabled = false
					Debris:AddItem(v:FindFirstChild("Gear2Smoke"),2)
				end
				if v:FindFirstChildOfClass("Smoke") then
					Debris:AddItem(v:FindFirstChildOfClass("Smoke"),2)
				end
			end
		end
	end
}

return LuffyMode

