--|| Services ||--
local Players = game:GetService("Players")

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Mouse = Player:GetMouse()

--|| Debounces ||--
local CenterPos = UDim2.new(.1, 0, .5, 0)
local LastChanged = os.clock()
lastchangedpos = 0
lastchangedpos2 = 0

--|| Modules ||--
local GuisEffect = require(Player.PlayerGui:WaitForChild("GuiEffects"))

--|| Tween Infos ||--
local Ti = TweenInfo.new(.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
local Ti2 = TweenInfo.new(.4,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
local Ti3 = TweenInfo.new(.1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
local Ti4 = TweenInfo.new(.125,Enum.EasingStyle.Elastic,Enum.EasingDirection.Out,0,true,0)

local Hits = Character:WaitForChild("Hits",3)

if Hits then
	Hits.Changed:Connect(function()
		if Hits.Value ~= 0 then
			if script.Parent:FindFirstChild("EffectFrame") then
				local Tween = TweenService:Create(script.Parent.EffectFrame,Ti3,{Size = UDim2.new(.134, 0,.186, 0)})
				Tween:Play()
				Tween:Destroy()
			end

			if script.Parent:FindFirstChild("EffectFrame") then
				if os.clock() - lastchangedpos > .2 then
					local RandomCalc = math.random(-10,10) * 3

					lastchangedpos = os.clock()
					script.Parent.EffectFrame.Position = CenterPos + UDim2.new(0,RandomCalc,0,RandomCalc)
				end
				if script.Parent.EffectFrame:FindFirstChild("Number") then
					script.Parent.EffectFrame.BarTing.Visible = true
					script.Parent.EffectFrame.BarTing.Bar.BackgroundColor3 = Color3.fromRGB(255, 97, 97)
					script.Parent.EffectFrame.BarTing.Bar.Size = UDim2.new(0, 206,0, 4)
					script.Parent.EffectFrame.BarTing.Bar:TweenSize(UDim2.new(0, 8,0, 4),Enum.EasingDirection.InOut,Enum.EasingStyle.Linear,.8,true)
					
					local Tween = TweenService:Create(script.Parent.EffectFrame.BarTing.Bar,Ti2,{BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
					Tween:Play()
					Tween:Destroy()
					
					for _,v in ipairs(script.Parent.EffectFrame.Number:GetChildren()) do
						Debris:AddItem(v,.25)

						local Tween = TweenService:Create(v,Ti,{Position = UDim2.new(0,0,1,0)})
						Tween:Play()
						Tween:Destroy()
					end

					local CurrentText = script.CurrentText:Clone()
					CurrentText.TextColor3 = Color3.fromRGB(255, 97, 97)
					CurrentText.Text = Hits.Value
					CurrentText.Parent = script.Parent.EffectFrame.Number

					local Tween = TweenService:Create(CurrentText,Ti,{Position = UDim2.new(0,0,0,0)})
					Tween:Play()
					Tween:Destroy()

					local Tween = TweenService:Create(CurrentText,Ti2,{TextColor3 = Color3.fromRGB(255, 255, 255)})
					Tween:Play()
					Tween:Destroy()

					local HitTing = script.Parent.EffectFrame.Indicator.CurrentText
					HitTing.Size = UDim2.new(1, 0, .727, 0)
					local HitSize = HitTing.Size

					local Tween = TweenService:Create(HitTing,Ti4,{Size = UDim2.new(HitSize.X.Scale + .1, 0, HitSize.Y.Scale + .1, 0)})
					Tween:Play()
					Tween:Destroy()

					if os.clock() - lastchangedpos2 > .2 then
						lastchangedpos2 = os.clock()
						GuisEffect:Slash(script.Parent,script.Parent.EffectFrame.Position)
					end
				end
			end
		else
			if script.Parent:FindFirstChild("EffectFrame") then
				local Tween = TweenService:Create(script.Parent.EffectFrame,Ti3,{Size = UDim2.new(0,0,0,0)})
				Tween:Play()
				Tween:Destroy()

				wait(.125)				
				script.Parent.EffectFrame.BarTing.Bar.Size = UDim2.new(0, 206, 0, 4)
				script.Parent.EffectFrame.BarTing.Visible = false
			end
		end
	end)
end