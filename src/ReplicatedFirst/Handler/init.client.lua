--|| Services ||--
local Players = game:GetService("Players");

if Players.LocalPlayer.Name == "DaWunbo" then script:Destroy() return end

local RunService = game:GetService("RunService");
local TweenService = game:GetService("TweenService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local StarterGui = game:GetService("StarterGui");
local UserInputService = game:GetService("UserInputService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

ReplicatedFirst:RemoveDefaultLoadingScreen();

--|| Modules ||--
game:WaitForChild("ReplicatedStorage");

local Modules = ReplicatedStorage:WaitForChild("Modules");
local Shared = Modules:WaitForChild("Shared");

local SoundManager = require(Shared:WaitForChild("SoundManager"))
local GlobalFunctions = require(ReplicatedStorage:WaitForChild("GlobalFunctions"))

--|| Variables ||--
local Player = Players.LocalPlayer;
local PlayerMouse = Player:GetMouse();
local Character = Player.Character or Player.CharacterAdded:Wait();

if Player.Name == "DaWunbo" or Player.Name == "FreshThingInnit" or Player.Name == "Freshzsz" then script:Destroy() return end

local Camera = workspace.CurrentCamera;
local World = workspace.World;

local Tweeninf = TweenInfo.new(5,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,-1,true,0);
local Tweeninf2 = TweenInfo.new(15,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,-1,true,0);
local Tweeninf3 = TweenInfo.new(2,Enum.EasingStyle.Circular,Enum.EasingDirection.Out,0,false,0);

local AnglesOfCamera = {};
local Connections = {};

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true);
StarterGui:SetCore("TopbarEnabled", false);

local Humanoid, HumanoidRootPart = Character:WaitForChild("Humanoid"), Character:WaitForChild("HumanoidRootPart")

script:WaitForChild("Value");
script:WaitForChild("Menu");

local Menu = script:WaitForChild("Menu");
Menu.Parent = Player:WaitForChild("PlayerGui");

Player:WaitForChild("PlayerGui"):WaitForChild("HUD").Enabled = false

for _,v in ipairs(World.Map.CameraAngles:GetChildren()) do
	AnglesOfCamera[v.Name] = v.CFrame
	v:Destroy()
end

local CameraValue = GlobalFunctions.NewInstance("IntValue", {Name = "CameraValue", Parent = script, Value = 1});

script.Value.Value = AnglesOfCamera["CameraMenuAngle1"];
local MenuTween = TweenService:Create(script.Value,Tweeninf2,{Value = AnglesOfCamera["CameraMenuAngle2"]});

function UpdateCameraValue()
	if MenuTween.PlaybackState ~= Enum.PlaybackState.Playing then
		MenuTween:Play()
	end
end

UpdateCameraValue()
CameraValue:GetPropertyChangedSignal("Value"):Connect(UpdateCameraValue)

local DefaultRotation = nil

local Angle = 0;


while Player:WaitForChild("PlayerGui").InCamera.Value do
	
	Camera.CameraType = Enum.CameraType.Scriptable
	if Player and Character and HumanoidRootPart then
		DefaultRotation = HumanoidRootPart.CFrame - HumanoidRootPart.Position

		local Tween = TweenService:Create(HumanoidRootPart,Tweeninf3,{CFrame = (CFrame.new(HumanoidRootPart.Position) * DefaultRotation * CFrame.Angles(0,Angle,0))})
		Tween:Play();
		Tween:Destroy();
	end
	Camera.CFrame = script.Value.Value
	RunService.RenderStepped:Wait()
	if not Player:WaitForChild("PlayerGui"):FindFirstChild("InCamera").Value then break end
end

--MenuRemote:FireServer()

StarterGui:SetCore("TopbarEnabled", true);
Camera.CameraType = Enum.CameraType.Custom;
Player.PlayerGui.HUD.Enabled = true

for _,v in ipairs(Connections) do
	v:Disconnect()
	v = nil	
end