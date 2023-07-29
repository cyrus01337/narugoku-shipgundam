local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local CharacterInfo = require(ReplicatedStorage.Modules.Metadata.CharacterData.CharacterInfo)
local GuiEffects = require(StarterGui.GuiEffects)
local Store = require(ReplicatedStorage.Modules.Store)

local selectedCharacter: string?;
local player = Players.LocalPlayer
local playerGui = player.PlayerGui
-- local Characters = Characterdata.CharacterData:GetChildren()
local playerCharacterTemplate = ReplicatedStorage.Assets.Gui.CharacterTemplate
local displayFrame = playerGui.CharacterSelection.CharacterSelection.Display
-- TODO: Combine connections or replace with maid/janitor
local clickConnections = {}
local otherConnections = {}
local frames = {}


local function typewrite(text: string, ...: TextLabel | TextBox)
    local textElements = {...}

    for i = 1, #text do
        local partialText = string.sub(text, 1, i)

        for _, element in textElements do
            element.Text = partialText
        end

        script.ChatClick:Play()
        task.wait(1/30)
    end
end


local function displayCharacter(charactersData, frame)
	displayFrame.CharacterName.Text = charactersData.Name
	displayFrame.View.Image = charactersData["ImageId"] or ""
	displayFrame.RequiredCash.Text = "$" .. charactersData["Cost"]
	displayFrame.Select.Text = if frame.Locked.ImageTransparency == 1 then "Select" else "Purchase"
	displayFrame.Select.BackgroundColor3 = if frame.Locked.ImageTransparency == 1 then Color3.fromRGB(37, 255, 80) else Color3.fromRGB(255, 11, 64)

	task.spawn(typewrite, charactersData.Description, displayFrame.Description)

	selectedCharacter = charactersData.Name
end


--if #playerGui.CharacterSelection.CharacterSelection.Selection:GetChildren() < #Characters then
--if #Frame:GetChildren() > #Characters then return end

for _, character in ReplicatedStorage.Modules.Metadata.AbilityData.AbilityData:GetChildren() do
	local playerCharInfo = CharacterInfo[character.Name]
	local characterFrame = playerCharacterTemplate:Clone()
	local button = characterFrame:WaitForChild("ViewportFrame", 300).Title
	button.Text = character.Name

	table.insert(clickConnections, button.Activated:Connect(function()
		GuiEffects.ClickEffect(button, false, .8)
		script.ClickMenu:Play()
		displayCharacter(playerCharInfo, characterFrame)
	end))

	characterFrame.Parent = playerGui.CharacterSelection.CharacterSelection.Selection
	characterFrame.Name = character.Name
	characterFrame.MiniPreview.Image = playerCharInfo["PreviewId"] or playerCharInfo["ImageId"]

	table.insert(frames, characterFrame)
end

table.insert(otherConnections, displayFrame.Select.Activated:Connect(function()
	if _G.Data.Unlocked[selectedCharacter] and displayFrame.Select.Text == "Purchase" then return end

	local requestType = if displayFrame.Select.Text == "Select" then "Select" else "Purchase"

	GuiEffects.ClickEffect(displayFrame.Select, false, 2)
	script.ClickMenu:Play()
	ReplicatedStorage.Remotes.ServerRequest:FireServer("CharacterChange", selectedCharacter, requestType)
end))

Store.Frames = frames

-- cyrus01337: when waiting for character frames to load, which requires frames
-- to be populated and an event to be fired, for some reason it doesnt run when
-- left alone my guess is that printing gives the script enough time to do what
-- it needs to do and be processed in the event loop, or its something else
-- related to loading
print("Fired!")
Store.PopulatedFrames:Fire()

return {}
