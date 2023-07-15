--|| Services ||--
local Players = game:GetService("Players")

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Directories ||--
local CombatAnims = ReplicatedStorage.Assets.Animations.Shared.Combat

local Server = ServerScriptService.Server
local Modules = ReplicatedStorage.Modules

local Shared = Modules.Shared 
local Utility = Modules.Utility
local Effects = Modules.Effects

--|| Remotes ||--
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Modules ||--
local StateManager = require(Shared.StateManager)
local SoundManager = require(Shared.SoundManager)

local TaskScheduler = require(Utility.TaskScheduler)
local NetworkStream = require(Utility.NetworkStream)

local HitboxModule = require(script.HitboxModule)
local DamageManager = require(script.DamageManager)

--|| Variables ||--
local Character = script.Parent

local Humanoid,Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")

--|| Debounces ||--
local Combo = 0

if not RunService:IsStudio() then return end

while true do
	if not StateManager:Peek(Character,"Stunned") then
		-- SoundManager:AddSound("beatricegain",{Parent = Character.HumanoidRootPart, Volume = 8}, "Client")
		Character.Humanoid:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Characters.Beatrice.AlShamac):Play()


		NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {Character = Character, Module = "BeatriceVFX", Function = "Al~Shamac"})

		TaskScheduler:AddTask(1.65,function()

			wait(.1)
			Humanoid.AutoRotate = true 

			-- SoundManager:AddSound("Pull",{Parent = Character.HumanoidRootPart, Volume = 1}, "Client")

			local HitResult,ValidEntities = HitboxModule.GetTouchingParts(Character,{ExistTime = 1, Type = "Combat", KeysLogged = 1, Size = Vector3.new(30,30,30), Transparency = 1, PositionCFrame = Character.HumanoidRootPart.CFrame},"Swing", "Killer Queen")
			if HitResult then
				-- SoundManager:AddSound("iceagin", {Parent = Character.HumanoidRootPart, Volume = 2}, "Client")

				for Index = 1, #ValidEntities do
					local Victim = ValidEntities[Index]
					local VRoot,VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")
					local _ = Players:GetPlayerFromCharacter(Victim) and CameraRemote:FireClient(Players:GetPlayerFromCharacter(Victim), "CreateFlashUI", CreateFrameData) and CameraRemote:FireClient(Players:GetPlayerFromCharacter(Victim), "CameraShake", {FirstText = 8, SecondText = 10})

					wait(.325)
					for _,Instances in ipairs(Victim:GetChildren()) do
						if Instances:IsA("BasePart") then
							Instances.Anchored = true
						end
					end

					NetworkStream.FireClientDistance(Character, "ClientRemote", 200, {Character = Character, Victim = Victim,  Module = "BeatriceVFX", Function = "shamac~hit"})

					StateManager:ChangeState(Victim,"Attacking",4)
					StateManager:ChangeState(Victim,"Frozen",4)
					
					local CreateFrameData = { Size = UDim2.new(1,0,1,0); Position = UDim2.new(0,0,0,0);	Color = Color3.fromRGB(0, 0, 0); Duration = 2.35}

					coroutine.resume(coroutine.create(function()
						while not StateManager:Peek(Victim,"Frozen") do
							RunService.Heartbeat:Wait()
						end
						for _,Instances in ipairs(Victim:GetChildren()) do
							if Instances:IsA("BasePart") then
								Instances.Anchored = false
							end
						end	
					end))
				end
			end

		end)
	end
	wait(5.85)
end