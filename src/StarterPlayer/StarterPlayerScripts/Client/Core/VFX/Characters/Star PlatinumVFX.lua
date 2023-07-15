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
local Effects = ReplicatedStorage.Assets.Effects.Meshes

local Metadata = Modules.Metadata
local Shared = Modules.Shared
local Utility = Modules.Utility

local HitPart2 = Models.Misc.HitPart2

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(Shared.SoundManager)
local RaycastService = require(Shared.RaycastManager)

local TaskScheduler = require(Utility.TaskScheduler)

local Explosions = require(Modules.Effects.Explosions)
local VfxHandler = require(Modules.Effects.VfxHandler)
local CameraShaker = require(Modules.Effects.CameraShaker)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

local Humanoid = Character:WaitForChild("Humanoid")

local function RemoveTrash(Trash)
	for Index = 1,#Trash do
		local Item = Trash[Index]
		if Item and Item.Parent then
			Item:Destroy()
		end
	end
end

local Star_PlatinumVFX = {
	["Barrage"] = function(PathData)
		local Character = PathData.Character 
		local Target = PathData.Target

		local Root,Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
		-- SoundManager:AddSound("Orarararararara",{Parent = Root, Volume = 10, Playing = true}, "Client",{ExectueTween = 1.5})

		for _ = 1,70 do 
			local ToCFrame = Root.CFrame * CFrame.new(0,0,-10)

			local CFrameConfig = CFrame.new((Root.CFrame * CFrame.new(math.random(-3,3),math.random(-2,2),math.random(-4,-3))).p,ToCFrame.p) * CFrame.Angles(math.rad(90),0,0)

			local JojoArm = Effects.Stands.StarPlatinumArm:Clone()
			JojoArm.Color = Color3.fromRGB(232, 186, 200)
			JojoArm.Anchored = true
			JojoArm.Massless = true
			JojoArm.CFrame = CFrameConfig
			JojoArm.Parent = workspace.World.Visuals

			local Tween = TweenService:Create(JojoArm,TweenInfo.new(.5,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{CFrame = JojoArm.CFrame * CFrame.new(0,-math.random(3,5),0)})
			Tween:Play()
			Tween:Destroy()

			wait()

			local Tween = TweenService:Create(JojoArm,TweenInfo.new(.2,Enum.EasingStyle.Quad),{Transparency = 1})
			Tween:Play()
			Tween:Destroy()

			for _,v in ipairs(JojoArm:GetDescendants()) do
				if v:IsA("BasePart") or v:IsA("UnionOperation") then
					local Animate = TweenService:Create(v,TweenInfo.new(.2,Enum.EasingStyle.Quad),{Transparency = 1})
					Animate:Play()
					Animate:Destroy()
				end
			end
			Debris:AddItem(JojoArm,.75)
		end
	end
}

return Star_PlatinumVFX

