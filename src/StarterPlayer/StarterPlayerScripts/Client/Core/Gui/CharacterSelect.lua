local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local Remotes = ReplicatedStorage.Remotes
-- Getting the characters 
local Modules = ReplicatedStorage.Modules
local Metadata = Modules.Metadata
local Characters = Metadata.AbilityData.AbilityData:GetChildren()
local Characterdata = Metadata.CharacterData
--local Characters = Characterdata.CharacterData:GetChildren()
--Getting the GUI Assets
local Assets = ReplicatedStorage.Assets
local GuiAssets = Assets.Gui
local PlayerHUD = PlayerGui.HUD
local CharacterTemplate = GuiAssets.CharacterTemplate
--Getting the Selections GUI
local CharacterSelectionScreen = PlayerGui.CharacterSelection
local DisplayFrame = CharacterSelectionScreen.CharacterSelection.Display
local CashText = PlayerHUD.Cash

--Modules
local GuiEffects = require(StarterGui.GuiEffects)
local CharacterInfo = require(Characterdata.CharacterInfo)

local SkillUiModule = require(PlayerHUD.UiCore.SkillUI)
--e.e
local ServerRequest = Remotes.ServerRequest

--Tables
local CurrentlyUnlocked = {}
local ClickConnections = {}
local OtherConnections = {}
_G.Frames = {} -- im so sorry, didnt want to move the whole script to starter gui >>//Fresh<<//

local Frames = {}

--CurrentlySelected
local SelectedCharacter = nil

local NewNumber = os.clock() + math.random(1,9999) + math.random(1,9999)..math.random(1,9999)
Number = NewNumber

--Main things
local function DisplayCharacter(CharactersData, Frame)
	DisplayFrame.CharacterName.Text = CharactersData.Name
	DisplayFrame.View.Image = CharactersData["ImageId"] or ""
	DisplayFrame.RequiredCash.Text = "$"..CharactersData["Cost"]	
	DisplayFrame.Select.Text = Frame.Locked.ImageTransparency == 1 and "Select" or "Purchase"
	DisplayFrame.Select.BackgroundColor3 = Frame.Locked.ImageTransparency == 1 and Color3.fromRGB(37, 255, 80) or Color3.fromRGB(255, 11, 64)

	if Number == NewNumber then
		coroutine.wrap(function()
			for Index = 1, #CharactersData.Description do
				if Number == NewNumber then
					local TextEffect = string.sub(CharactersData.Description,1,Index)
					DisplayFrame.Description.Text = TextEffect
					script.ChatClick:Play()
					wait()
				end
			end
		end)()
	end
	SelectedCharacter = CharactersData.Name
end



local function ClearGrid(Frame)
	Frame:ClearAllChildren()
	for _, Connection in ipairs(ClickConnections) do
		Connection:Disconnect()
		Connection = nil
	end
end

local function CreateGrid(Frame)
	--if #Frame:GetChildren() > #Characters then return end

	for _, Character in ipairs(Characters) do
		local CharacterFrame = CharacterTemplate:Clone()
		local Button = CharacterFrame:WaitForChild("ViewportFrame").Title
		Button.Text = Character.Name
		ClickConnections[#ClickConnections + 1] = Button.Activated:Connect(function()
			GuiEffects.ClickEffect(Button, false, .8)
			script.ClickMenu:Play()
			DisplayCharacter(CharacterInfo[Character.Name], CharacterFrame)
		end)
		CharacterFrame.Parent = Frame
		CharacterFrame.Name = Character.Name
		CharacterFrame.MiniPreview.Image = CharacterInfo[Character.Name]["PreviewId"] or CharacterInfo[Character.Name]["ImageId"]

		_G.Frames[#_G.Frames + 1] = CharacterFrame
	end
end

--if #CharacterSelectionScreen.CharacterSelection.Selection:GetChildren() < #Characters then
CreateGrid(CharacterSelectionScreen.CharacterSelection.Selection)



OtherConnections[#OtherConnections + 1] = DisplayFrame.Select.Activated:Connect(function()
	
	
	if _G.Data.Unlocked[SelectedCharacter] and DisplayFrame.Select.Text == "Purchase" then return end
	GuiEffects.ClickEffect(DisplayFrame.Select, false, 2)
	script.ClickMenu:Play()
	local _ = (DisplayFrame.Select.Text == "Select" and ServerRequest:FireServer("CharacterChange", SelectedCharacter, "Select")) or ServerRequest:FireServer("CharacterChange", SelectedCharacter,"Purchase")	
end)

return {}