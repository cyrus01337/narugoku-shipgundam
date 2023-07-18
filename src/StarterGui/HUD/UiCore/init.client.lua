local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local GuisEffect = require(playerGui:WaitForChild("GuiEffects"))
local Store = require(ReplicatedStorage.Modules.Store)
local Signal = require(ReplicatedStorage.Modules.Utility.Signal)
-- local SoundManager = require(ReplicatedStorage.Modules.Shared.SoundManager)
-- local Frames = require(game.StarterPlayer.StarterPlayerScripts.Client.Core.Gui.CharacterSelect)

local OUT_POSITION = UDim2.new(1.1, 0, 0.081, 0)
local IN_POSITION = UDim2.new(0.2, 0, 0.081, 0)
local playerMouse = player:GetMouse()
local playerChar = player.Character or player.CharacterAdded:Wait()
local playerHumanoid = playerChar:WaitForChild("Humanoid")
local points = player:WaitForChild("Mode")
local inMenu = false
local musicOn = false
local debounce = false
local hud = script.Parent
local cashUI = script.Parent.Cash
local menu = hud.Menu.Button
local music = hud.Music.Button
local characterSelection = playerGui.CharacterSelection.CharacterSelection
local ReplicateRemote = ReplicatedStorage.Remotes.Replicate
local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local versionGui = playerGui:WaitForChild("Version")
local versionText = versionGui:WaitForChild("VersionText")
local CachedModules = {}
-- FIXME: cyrus01337: this could be a memory leak...
local connections = {}
_G.SpaceAerial = true
_G.CameraLock = false
_G.DataSignal = Signal.New()
_G.FPS = 60

for _, child in script:GetDescendants() do
	if child:IsA("ModuleScript") then
		CachedModules[child.Name] = require(child)
	end
end

GUIRemote.OnClientEvent:Connect(function(ui, data)
	local moduleFound = CachedModules[ui]

	if not moduleFound then return end

	local uiHandlerFound = moduleFound[data.Function]

	if uiHandlerFound then
		uiHandlerFound(data)
	end
end)

--local CharacterSelectionScreen = playerGui:WaitForChild("CharacterSelection")
--local FrameSelection = CharacterSelectionScreen:WaitForChild("CharacterSelection").Selection
--local AvaialableCharacters = ReplicatedStorage.Modules.Metadata.AbilityData.AbilityData:GetChildren()
table.insert(connections, menu.MouseButton1Down:Connect(function()
	if debounce then return end

	debounce = true

	GuisEffect.ClickEffect(menu, false, .8)
	-- SoundManager:AddSound("ClickMenu", {Parent = playerGui}, "Client")

	if not inMenu then
		inMenu = true
		characterSelection:TweenPosition(IN_POSITION)
	else
		inMenu = false
		characterSelection:TweenPosition(OUT_POSITION)
	end

	task.wait(1)

	debounce = false
end))

table.insert(connections, music.MouseButton1Down:Connect(function()
	if musicOn then
		playerGui.Music.Volume = 0
		musicOn = false
	else
		playerGui.Music.Volume = 1
		musicOn = true
	end
end))

-- Connections[#Connections + 1] = AerialTing.MouseButton1Down:Connect(function()
-- 	GuisEffect.ClickEffect(AerialTing, false, .8)
-- 	SoundManager:AddSound("ClickMenu", {Parent = playerGui}, "Client")

-- 	if _G.SpaceAerial then
-- 		AerialTing.Parent.TextLabel.Text = "SPACE FOR AERIAL: OFF"
-- 		_G.SpaceAerial = true
-- 	else
-- 		AerialTing.Parent.TextLabel.Text = "SPACE FOR AERIAL: ON"
-- 		_G.SpaceAerial = true
-- 	end
-- end)

hud.RageFrame.RageBar:TweenSize(UDim2.new(points.Value / 295,0, .588, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .25)

points:GetPropertyChangedSignal("Value"):Connect(function()
	local TextTing = points.Value <= 285 and "RAGE" or "H TO MODE"
	hud.RageFrame.Rage.Text = TextTing

	if points.Value <= 285 then
		hud.RageFrame.RageBar:TweenSize(UDim2.new(points.Value / 295, 0, .588, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .05)
	end
end)

playerHumanoid:GetPropertyChangedSignal("Health"):Connect(function()
	local healthFrame = hud.CharacterInfo.HealthFrame
	local tweenSizeArgs = {UDim2.new(playerHumanoid.Health / playerHumanoid.MaxHealth, 0, 1, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear}

	healthFrame.HealthBckg.HealthBar:TweenSize(table.unpack(tweenSizeArgs), .25, true)
	healthFrame.HealthBckg.HealthBarRed:TweenSize(table.unpack(tweenSizeArgs), .35, true)
end)

-- local Clocker = nil
Clocker = os.clock()

-- local StartTime = 0
-- local Table = {}
-- local PlayerConnections = {}

--[[
RunService.Heartbeat:Connect(function()
	StartTime = os.clock()
	for Index = #Table, 1, -1 do
		Table[Index + 1] = StartTime - 1 <= Table[Index] and Table[Index] or nil;
	end
	Table[1] = StartTime

	_G.FPS = math.floor(os.clock() - Clocker >= 1 and #Table or #Table / (os.clock() - Clocker))

	FpsText.Text = _G.FPS
	FpsText.UIGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), (Color3.new(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), FpsText.Text / 50)));
end)
--]]
--[[_G.StateSignal = Signal.New()

_G.StateSignal:Connect(function(Data)
	local State, StateData = Data.ChosenState, Data.ChosenStateData
	_G.States = {State = State, StateData = StateData}
end)]]

_G.Data = {
	Level =  0,
	Xp = 0,
	Character = "Gilgamesh",
	Cash = 25000,
	Unlocked = {},
	Skins = {}
}

ReplicateRemote.OnClientEvent:Connect(function(data)
	_G.Data = data
	local unlockedCharacter = data.Unlocked

	if Store.Frames == nil then
		Store.PopulatedFrames:Wait()
	end

	for _, frame in Store.Frames do
		local unlockedCharacterFound = unlockedCharacter[frame.Name]
		local lockedFrameImage = frame:WaitForChild("Locked", 300)
		local miniPreviewImage = frame:WaitForChild("MiniPreview", 300)
		local characterSelectionScreen = playerGui:WaitForChild("CharacterSelection", 300)
		local displayFrame = characterSelectionScreen.CharacterSelection.Display

		cashUI.Text = "$" .. data.Cash
		lockedFrameImage.ImageTransparency = if unlockedCharacterFound then 1 else .5
		miniPreviewImage.ImageTransparency = if unlockedCharacterFound then .35 else .85
		displayFrame.Select.Text = if frame.Locked.ImageTransparency == 1 then "Select" else "Purchase"
		displayFrame.Select.BackgroundColor3 = if frame.Locked.ImageTransparency == 1 then Color3.fromRGB(37, 255, 80) else Color3.fromRGB(255, 11, 64)
	end
end)

playerChar.ChildAdded:Connect(function(Child)
	--if Child:IsA("BoolValue") and Child.Name == "Running" and _G.CameraLock then
	--UserGameSettings.RotationType = Enum.RotationType.MovementRelative
	--end
	if Child:IsA("BoolValue") and Child.Name == "Aiming" then
		local Positioner = playerChar.HumanoidRootPart:FindFirstChild"Positioner" or Instance.new("BodyVelocity")
		Positioner.Name = "Positioner"
		Positioner.MaxForce = Vector3.new(1,1,1) * 50000
		Positioner.Velocity = Vector3.new(0,0,0)
		Positioner.Parent = playerChar.HumanoidRootPart

		local Rotater = playerChar.HumanoidRootPart:FindFirstChild"Rotater" or Instance.new("BodyGyro")
		Rotater.Name = "Rotater"
		Rotater.MaxTorque = Vector3.new(1,1,1) * 50000
		Rotater.D = 150
		Rotater.P = 5000
		Rotater.Parent = playerChar.HumanoidRootPart

		while playerChar:FindFirstChild("Aiming") do
			task.wait()

			Rotater.CFrame = CFrame.lookAt(playerChar.HumanoidRootPart.Position, playerMouse.Hit.Position)
		end

		Positioner:Destroy()
		Rotater:Destroy()
	elseif Child:IsA("StringValue") and Child.Name == "Aiming" then
		local Positioner = playerChar.HumanoidRootPart:FindFirstChild"Positioner" or Instance.new("BodyVelocity")
		Positioner.Name = "Positioner"
		Positioner.MaxForce = Vector3.new(1,1,1) * 50000
		Positioner.Velocity = Vector3.new(0,0,0)
		Positioner.Parent = playerChar.HumanoidRootPart

		local Rotater = playerChar.HumanoidRootPart:FindFirstChild"Rotater" or Instance.new("BodyGyro")
		Rotater.Name = "Rotater"
		Rotater.MaxTorque = Vector3.new(1,1,1) * 50000
		Rotater.D = 150
		Rotater.P = 5000
		Rotater.Parent = playerChar.HumanoidRootPart

		while playerChar:FindFirstChild("Aiming") do
			task.wait()

			Rotater.CFrame = CFrame.lookAt(playerChar.HumanoidRootPart.Position, workspace.World.Live[Child.Value].HumanoidRootPart.Position)
		end

		Positioner:Destroy()
		Rotater:Destroy()
	end
end)

local StartTime = os.clock()

playerHumanoid:GetPropertyChangedSignal("Jump"):Connect(function()
	if not playerHumanoid.Jump then return end

	if os.clock() - StartTime >= 1 then
		playerHumanoid.Jump = true
		StartTime = os.clock()
	else
		playerHumanoid.Jump = false
	end
end)

versionText.Text = string.format("Server version: %s", game.PlaceVersion)
-- SoundManager:AddSound({"4599716452", "4979571623", "4979571623", "4979571623"}, {Volume = .35, Parent = playerGui}, "Table")
