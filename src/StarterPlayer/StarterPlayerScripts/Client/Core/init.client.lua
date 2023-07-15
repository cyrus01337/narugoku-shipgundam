--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ContentProvider = game:GetService("ContentProvider")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules
local Remotes = ReplicatedStorage.Remotes

local Metadata = Modules.Metadata
local Shared = Modules.Shared
local Utility = Modules.Utility

--|| Imports ||--
local ControlData = require(Metadata.ControlData.ControlData)
local AnimationManager = require(Shared.AnimationManager)

local TaskScheduler = require(Utility.TaskScheduler)
local Signal = require(Utility.Signal)

local AbilityData = require(game.ReplicatedStorage.Modules.Metadata.AbilityData.AbilityData)

--local StateManager = require(Shared.StateManager)

local CachedModules = {} -- To be required after everything is done to make sure all data is there
local PlayerConnections = {}

--|| Remotes ||--
local ClientRemote = Remotes.ClientRemote
local ServerRemote = Remotes.ServerRemote

local ReplicateRemote = Remotes.Replicate

local GetMouse = Remotes.GetMouse
local AnimationRemote = Remotes.AnimationRemote
local CameraRemote = Remotes.CameraRemote
local ChangeSpeed = Remotes.ChangeSpeed
local GetKeyHeld = Remotes.GetKeyHeld
local DefaultFOV = 70
local T

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local PlayerMouse = Player:GetMouse()

local Humanoid = Character:WaitForChild("Humanoid")

local AnimationSettings = {
	["Play"] = function(AnimationName, AnimationData)
		AnimationManager.PlayAnimation(AnimationName,AnimationData)
	end,
	["Stop"] = function(AnimationName, AnimationData)
		AnimationManager.StopAnimation(AnimationName,AnimationData)
	end,
	["LoadAnimations"] = function(Character, ClassNames)
		AnimationManager.LoadAnimations(Character, ClassNames)
	end,
}
local function FunRun()
	local properties = {FieldOfView = DefaultFOV + 10}
	local Info = TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0.1)
	T = game:GetService("TweenService"):Create(game.Workspace.CurrentCamera,Info,properties)
	T:Play()

end

local function FunRunEnd()
	local properties = {FieldOfView = DefaultFOV}
	local Info = TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0.1)
	T = game:GetService("TweenService"):Create(game.Workspace.CurrentCamera,Info,properties)
	T:Play()
	
end
--|| Functions ||-- 
local LastWTap = 0
UserInputService.InputBegan:Connect(function(Input,Typing)
	if not Typing then
		local KeyEvaluation = (Input.KeyCode == Enum.KeyCode.Unknown and Input.UserInputType.Name or Input.KeyCode.Name)

		local Combat = ControlData.Controls.Combat[KeyEvaluation]
		local Ability = ControlData.Controls.Ability[KeyEvaluation]

		local ExecuteEvaluation = (Combat or Ability)

		if ExecuteEvaluation == "Run" then
			local Cached = LastWTap
			LastWTap = time()

			if (time() - Cached) > 0.5 then
				return
			end
			FunRun()
		end
		
		pcall(function()
			local ChosenModule = CachedModules[(Ability and _G.Data.Character) or (Combat and "Combat") or ExecuteEvaluation][Ability or Combat or ExecuteEvaluation]
			if typeof(ChosenModule) == "table" then
				ChosenModule["Execute"](ExecuteEvaluation,KeyEvaluation)
			else
				ChosenModule(ExecuteEvaluation,KeyEvaluation)
			end
		end)    
	end
end)


UserInputService.InputEnded:Connect(function(Input,Typing)
	if not Typing then
		local KeyEvaluation = (Input.KeyCode == Enum.KeyCode.Unknown and Input.UserInputType.Name or Input.KeyCode.Name)

		local Combat = ControlData.Controls.Combat[KeyEvaluation]
		local Ability = ControlData.Controls.Ability[KeyEvaluation]

		local ExecuteEvaluation = ( Combat or Ability)
		if ExecuteEvaluation == "Run" then
			FunRunEnd()
		end
		pcall(function()
			local ChosenModule = CachedModules[(Ability and _G.Data.Character) or (Combat and "Combat") or ExecuteEvaluation][Ability or Combat or ExecuteEvaluation]
			if typeof(ChosenModule) == "table" then
				ChosenModule["Terminate"](ExecuteEvaluation,KeyEvaluation)
			end
		end)
	end
end)

for _, Module in ipairs(script:GetDescendants()) do
	if Module:IsA("ModuleScript") then
		CachedModules[Module.Name] = require(Module)
	end
end

AnimationRemote.OnClientEvent:Connect(function(AnimationName,Task,AnimationData)
	AnimationSettings[Task](AnimationName,AnimationData)
end)

CameraRemote.OnClientEvent:Connect(function(Task,Data)
	CachedModules["CameraEffects"][Task](Data)
end)

ClientRemote.OnClientEvent:Connect(function(PathData)
	CachedModules[PathData.Module][PathData.Function](PathData)
end)

ChangeSpeed.OnClientEvent:Connect(function(Data)
	local Character = Player.Character
	local Humanoid = Character:WaitForChild"Humanoid"

	PlayerConnections[#PlayerConnections + 1] = RunService.Stepped:Connect(function()
		Humanoid.WalkSpeed = Data.WalkSpeed
		Humanoid.JumpPower = Data.JumpPower		
	end)

	TaskScheduler:AddTask(Data.Duration,function()
		Humanoid.WalkSpeed = Data.OldWalkSpeed
		Humanoid.JumpPower = Data.OldJumpPower
		for _,Connections in ipairs(PlayerConnections) do 
			Connections:Disconnect()
			Connections = nil
		end
	end)
end)

local function Mouse()
	PlayerMouse.TargetFilter = workspace.World.Visuals
	local Mouse = PlayerMouse.Hit
	return Mouse
end
GetMouse.OnClientInvoke = Mouse

local function HoldingKey(Key,Type)
	if Type == "Mouse" then
		if UserInputService:IsMouseButtonPressed(Key) then
			return true or false
		end
	elseif Type == "Key" then
		if UserInputService:IsKeyDown(Key) then
			return true or false
		end
	end
end
GetKeyHeld.OnClientInvoke = HoldingKey

--[[LastBlink = {}

while true do
	local Character = Player.Character or Player.CharacterAdded:Wait()

	
	if Character and Character:FindFirstChild("Head") and Character:FindFirstChild("FakeHead") then
		if LastBlink[Character] == nil then
			LastBlink[Character] = os.clock()
		end

		local FakeHead = Character.FakeHead
		local Face = FakeHead:FindFirstChild("face")

		if table.find(CachedModules["RegularFaces"],Face.Texture) then
			if os.clock() - LastBlink[Character] > math.random(5,7) then
				LastBlink[Character] = os.clock()

				local FaceTexture = Face.Texture			

				local BlinkFaceTexture = CachedModules["BlinkingFaces"][table.find(CachedModules["RegularFaces"],Face.Texture)]
				Face.Texture = BlinkFaceTexture

				wait(.1)	
				if Face and Face.Texture == BlinkFaceTexture then
					Face.Texture = FaceTexture
				end
			end
		else
			LastBlink[Character] = os.clock()
		end
	end
	RunService.RenderStepped:Wait()
end ]]