--|| Services ||--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Debris = game:GetService("Debris")

--|| Variables ||--
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local PlayerGui = Player:WaitForChild("PlayerGui")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Shared = Modules.Shared
local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Metadata = Modules.Metadata

local Characterdata = Metadata.CharacterData

--|| Modules ||--
local CharacterInfo = require(Characterdata.CharacterInfo)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

--|| Tweens ||--
local tasdasdi = TweenInfo.new(.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0)
local PunchEffectTweens = {
	First = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),
	Second = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),
}

function Lerp(a,b,c)
	return a + (b-a) * c
end

local module = {}

function module:Slash(Parent,Position)
	if CharacterInfo[_G.Data.Character]["Combat"] then
		local F1 = Instance.new("ImageLabel")

		F1.AnchorPoint = Vector2.new(.5,.5);
		F1.BorderSizePixel = 0;
		F1.BackgroundTransparency = 1;

		local Aspect = Instance.new("UIAspectRatioConstraint",F1);
		F1.Image = "rbxassetid://1463840694";
		F1.Size = UDim2.new(0,0,0,0)
		F1.Position = Position;
		F1.Parent = Parent;

		local Tween = TweenService:Create(F1,PunchEffectTweens.First,{Size = UDim2.new(.3,0,.3,0),ImageTransparency = 1,Rotation = math.random(-3,3)*10,ImageColor3 = Color3.fromRGB(255,255,255)})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(F1,.2)
	else
		local F1 = Instance.new("ImageLabel")
		F1.AnchorPoint = Vector2.new(.5,.5);
		F1.BorderSizePixel = 0;
		F1.BackgroundTransparency = 1;

		local Aspect = Instance.new("UIAspectRatioConstraint",F1);
		F1.Image = "rbxassetid://1463840694";
		F1.Size = UDim2.new(0,0,0,0)
		F1.Position = Position;
		F1.Parent = Parent;

		local Tween = TweenService:Create(F1,PunchEffectTweens.First,{Size = UDim2.new(.3,0,.3,0),ImageTransparency = 1,Rotation = math.random(-3,3)*10,ImageColor3 = Color3.fromRGB(255,255,255)})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(F1,.2)

		local f3 = Instance.new("ImageLabel")
		f3.AnchorPoint = Vector2.new(.5,.5)
		f3.BorderSizePixel = 0
		f3.BackgroundTransparency = 1
		--F1.ImageColor3 = Color3.fromRGB(255,255,0)
		local Aspect = Instance.new("UIAspectRatioConstraint",F1)
		f3.Image = "rbxassetid://2618549781"
		f3.Parent = Parent
		f3.Size = UDim2.new(0,0,0,0)
		f3.Position = Position
		local Tween = TweenService:Create(F1,PunchEffectTweens.First,{Size = UDim2.new(.22,0,.22,0),ImageTransparency = 1,Rotation = math.random(-3,3)*10,ImageColor3 = Color3.fromRGB(255,255,255)})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(f3,.2)
	end
end

function module.ClickEffect(Frame,Color,growsize)
	if Frame then
		local x,y = Mouse.X - Frame.AbsolutePosition.X,Mouse.Y - Frame.AbsolutePosition.Y
		local Circle = ReplicatedStorage.Assets.Gui.Circle:Clone()
		if Color then
			Circle.ImageColor3 = Color
		end
		Circle.Position = UDim2.new(0,x,0,y,0)
		Circle.Parent = Frame
		
		local Tween = TweenService:Create(Circle,tasdasdi,{Size = UDim2.new(growsize or 6,0,growsize or 6,0),ImageTransparency = 1})
		Tween:Play()
		Tween:Destroy()
		
		Debris:AddItem(Circle,.25)
	end
end

return module