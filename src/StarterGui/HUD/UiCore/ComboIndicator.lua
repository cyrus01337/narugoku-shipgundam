--|| Services ||--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Debris = game:GetService("Debris")

local Runservice = game:GetService("RunService")

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Mouse = Player:GetMouse()

local PlayerGui = Player:WaitForChild("PlayerGui")

--|| Modules ||--
local GuisEffect = require(PlayerGui:WaitForChild("GuiEffects"))

--||Remotes||--
local GUIRemote = ReplicatedStorage.Remotes.GUIRemote

--|| Debounces ||--
local CenterPos = UDim2.new(.1, 0, .5, 0)
local lastchangedpos = 0
local lastchangedpos2 = 0

--||Assets||--
local HitManager = PlayerGui.HUD

local EffectFrame = HitManager.EffectFrame

local Number = EffectFrame.Number
local Indicator = EffectFrame.Indicator

local ComboIndicator = HitManager:WaitForChild("ComboIndicator")
local ComboText = HitManager:WaitForChild("ComboText")

--|| Tween Infos ||--
local Ti = TweenInfo.new(.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
local Ti2 = TweenInfo.new(.4,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
local Ti3 = TweenInfo.new(.1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
local Ti4 = TweenInfo.new(.125,Enum.EasingStyle.Elastic,Enum.EasingDirection.Out,0,true,0)

local Suggested = ""

local ComboList = {"LLLLR","LRRL","LLRRL"}
local OriginalTime = os.clock()

local Hits = Character:WaitForChild("Hits")
local Current = false

local CurrentIndicatorData = {}


local function RemoveIndicator()
	Suggested = ""

	ComboIndicator.Text = ""
	ComboText.Text = ""

	ComboIndicator.Visible = false
	ComboText.Visible = false

	Current = false

	table.clear(CurrentIndicatorData)
	

end

local function UpdateUi()
	ComboText.Text = ""
	Suggested = ""

	--if ComboIndicator.Text == "LRRL" then RemoveIndicator() return  end
	if string.len(ComboIndicator.Text)  < 3 then return end

	for _,Child in ipairs(ComboList) do
		if  string.sub(string.lower(Child), 1, string.len(ComboIndicator.Text)) == string.lower(ComboIndicator.Text) then
			if string.len(string.sub(Child, string.len(ComboIndicator.Text))) == 0 then return end

			ComboText.Text = ComboIndicator.Text..string.sub(Child, string.len(ComboIndicator.Text) + 1)
			--ComboText.Text = string.sub(Child, string.len(ComboIndicator.Text) )		
			--Suggested = string.sub(Child, string.len(ComboIndicator.Text))
			Suggested = Child
		end
	end
end



local ComboIndicator = {
	["Initiate"] = function(UiData)
		OriginalTime = os.clock()

		ComboIndicator.Visible = true
		ComboText.Visible = true

		Current = true

		ComboIndicator.Text = UiData.Variation

		UpdateUi()

		CurrentIndicatorData[#CurrentIndicatorData + 1] = {ComboIndicator = ComboIndicator, OriginalTime =  OriginalTime }	
		--RemoveIndicator(
	end,

	["AddIndicator"] = function(UiData)
		OriginalTime = os.clock()

		ComboIndicator.Text = UiData.Variation
		UpdateUi()
	end,

	["RemoveIndicator"] = function(UiData)	
		RemoveIndicator()
	end,
}



Runservice.Heartbeat:Connect(function(DeltaTime)
	if #CurrentIndicatorData == 0 then return end
	if ComboIndicator.Text == "" then return end
	if ComboIndicator == nil or ComboText == nil then return end

	for _, Indicator in ipairs(CurrentIndicatorData) do
		local ComboIndicator = Indicator.ComboIndicator
		local OriginalTime = Indicator.OriginalTime
		
		if string.len(ComboIndicator.Text) <= 5 and Current == true then
			if os.clock() - OriginalTime > 2 then
				RemoveIndicator()
			end
		end
	end
	


end)

return ComboIndicator