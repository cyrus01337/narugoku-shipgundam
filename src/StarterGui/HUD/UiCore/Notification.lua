local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 300)
local RewardCounter = 0
local NotificationGui = playerGui.NotificationGui
local NotificationText = NotificationGui.NotificationText
local Notification = {}


function Notification.Initiate(Data)	
	local ItemUi = NotificationText:Clone()
	local ItemText = Data.Text
	local ItemColor = Data.Color
	local ItemR,ItemG,ItemB = unpack{ItemColor.R, ItemColor.G, ItemColor.B}
	ItemR, ItemG, ItemB = math.floor(ItemR * 255), math.floor(ItemG * 255), math.floor(ItemB * 255)

	ItemUi.Visible = true
	ItemUi.Text = ItemText:format(ItemR,ItemG,ItemB)
	ItemUi.Position = UDim2.new(0.421,0,-0.03,0)

	ItemUi.Parent = NotificationGui
	ItemUi:TweenPosition(UDim2.new(.421, 0, (math.clamp(.218 + (RewardCounter * .05), 0.1, .8)), 0), Enum.EasingDirection.Out, Enum.EasingStyle.Elastic, 2, true)
	Debris:AddItem(ItemUi, 5)

	task.spawn(function()
		RewardCounter = RewardCounter + 1
		task.wait(3)
		RewardCounter = RewardCounter  - 1

		local CalculateSide = math.random(1,2) == .75 and .75 or -.75

		ItemUi:TweenPosition(UDim2.new(CalculateSide,0,(math.clamp(.218 + (RewardCounter * .05),.21,.8)),0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,2,true)
	end)

	print("Instantiated notification with reward counter set to", RewardCounter)
end


return Notification