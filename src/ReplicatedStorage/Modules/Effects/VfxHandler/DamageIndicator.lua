--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Ti22 = TweenInfo.new(.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,true,0)

return function(Victim,DamageAmount)
	local x = math.random(-4,4)
	local DMM = string.sub( tostring(DamageAmount),1,4 )

	local DamageIndicator = ReplicatedStorage.Assets.Models.Parts.Damage:Clone()
	DamageIndicator.CFrame = Victim:FindFirstChild("HumanoidRootPart").CFrame*CFrame.new(x,0,0)
	DamageIndicator.Bill.T1.Text = DMM
	DamageIndicator.Anchored = false
	DamageIndicator.Bill.T1:FindFirstChild("Text").Text = DMM
	DamageIndicator.Parent = workspace.World.Visuals

	local Tween = TweenService:Create(DamageIndicator.Bill.T1:FindFirstChild("Text"),Ti22,{TextColor3 = Color3.fromRGB(162, 234, 255) })
	Tween:Play()
	Tween:Destroy()

	Debris:AddItem(DamageIndicator,.5)

	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.P = 10000
	BodyVelocity.MaxForce = Vector3.new(0,4e4,0)
	BodyVelocity.Velocity = Vector3.new(0,20,0)
	BodyVelocity.Parent = DamageIndicator
	Debris:AddItem(BodyVelocity,.1)
end
