--|| Services ||--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Imports ||--
local SoundManager = require(ReplicatedStorage.Modules.Shared.SoundManager)
local StateManager = require(ReplicatedStorage.Modules.Shared.StateManager)

local NetworkStream = require(ReplicatedStorage.Modules.Utility.NetworkStream)
local TaskScheduler = require(ReplicatedStorage.Modules.Utility.TaskScheduler)

--|| Variables ||--
local RNG = Random.new()
local TI2 = TweenInfo.new(.3,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0)

return function(Data)
	local ColorCorrection = script.ColorCorrection:Clone()
	ColorCorrection.Parent = workspace.CurrentCamera

	local Tween = TweenService:Create(ColorCorrection, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out,0,false,0),{TintColor = Color3.fromRGB(255, 0, 0)})
	Tween:Play()
	Tween:Destroy()	

	local ScreenGui = script.ScreenGui:Clone()
	ScreenGui.Frame.Size = UDim2.new(0, 0, 0, 0)
	ScreenGui.Parent = Players.LocalPlayer.PlayerGui
	ScreenGui.Frame.Rotation = math.random(-360, 360)
	ScreenGui.Frame.Position = UDim2.new(math.random(100, 800) / 1000, 0, 0.5, 0)

	TaskScheduler:AddTask(.8,function()
		-- SoundManager:AddSound("SwordSlash", {Parent = Data.Character:FindFirstChild("Head"), Volume = 1.35}, "Client")

		ScreenGui.Frame.Size = UDim2.new(0.15, 0, 4, 0);

		local Tween = TweenService:Create(ScreenGui.Frame, TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out,0,false,0),{Size = UDim2.new(0.15, 0, 4, 0) , SliceScale = -20})
		Tween:Play()
		Tween:Destroy()

		wait(.5)
		Debris:AddItem(ScreenGui, 0.1)
	end)
	TaskScheduler:AddTask(1.5,function()
		wait(1.5)

		local Tween = TweenService:Create(ColorCorrection, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out,0,false,0),{TintColor = Color3.fromRGB(255, 255, 255)})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(ColorCorrection, 0.1)
	end)
end;
