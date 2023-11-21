--|| Services ||--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Debris = game:GetService("Debris")

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

local CenterPos = UDim2.new(0.1, 0, 0.5, 0)
local lastchangedpos = 0
local lastchangedpos2 = 0

--||Assets||--
local HitManager = PlayerGui.HUD

local EffectFrame = HitManager.EffectFrame

local Number = EffectFrame.Number
local Indicator = EffectFrame.Indicator

--|| Tween Infos ||--
local Ti = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local Ti2 = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local Ti3 = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local Ti4 = TweenInfo.new(0.125, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, true, 0)

local DamageIndicator = {
    ["AddText"] = function(UiData)
        if UiData.Number ~= 0 then
            if script.Parent.Parent:FindFirstChild("EffectFrame") then
                local Tween =
                    TweenService:Create(script.Parent.Parent.EffectFrame, Ti3, { Size = UDim2.new(0.134, 0, 0.186, 0) })
                Tween:Play()
                Tween:Destroy()
            end
            local ns = math.random(-10, 10) * 3

            if script.Parent.Parent:FindFirstChild("EffectFrame") then
                if os.clock() - lastchangedpos > 0.2 then
                    lastchangedpos = os.clock()
                    script.Parent.Parent.EffectFrame.Position = CenterPos + UDim2.new(0, ns, 0, ns)
                end
                if script.Parent.Parent.EffectFrame:FindFirstChild("Number") then
                    for i, v in pairs(script.Parent.Parent.EffectFrame.Number:GetChildren()) do
                        Debris:AddItem(v, 0.25)
                        local Tween = TweenService:Create(v, Ti, { Position = UDim2.new(0, 0, 1, 0) })
                        Tween:Play()
                        Tween:Destroy()
                    end

                    local CurrentText = script.Parent.CurrentText:Clone()
                    CurrentText.TextColor3 = Color3.fromRGB(160, 230, 255)
                    CurrentText.Text = UiData.Number or "1"
                    CurrentText.Parent = script.Parent.Parent.EffectFrame.Number

                    local Tween = TweenService:Create(CurrentText, Ti, { Position = UDim2.new(0, 0, 0, 0) })
                    Tween:Play()
                    Tween:Destroy()

                    local Tween = TweenService:Create(CurrentText, Ti2, { TextColor3 = Color3.fromRGB(255, 255, 255) })
                    Tween:Play()
                    Tween:Destroy()

                    local HitTing = script.Parent.Parent.EffectFrame.Indicator.CurrentText
                    HitTing.Size = UDim2.new(1, 0, 0.727, 0)
                    local HitSize = HitTing.Size

                    local Tween = TweenService:Create(
                        HitTing,
                        Ti4,
                        { Size = UDim2.new(HitSize.X.Scale + 0.1, 0, HitSize.Y.Scale + 0.1, 0) }
                    )
                    Tween:Play()
                    Tween:Destroy()

                    if os.clock() - lastchangedpos2 > 0.2 then
                        lastchangedpos2 = os.clock()
                        GuisEffect:Slash(script.Parent.Parent, script.Parent.Parent.EffectFrame.Position)
                    end
                end
            end
            wait(0.35)
            if script.Parent.Parent:FindFirstChild("EffectFrame") then
                local Tween =
                    TweenService:Create(script.Parent.Parent.EffectFrame, Ti3, { Size = UDim2.new(0, 0, 0, 0) })
                Tween:Play()
                Tween:Destroy()
            end
        end
        --[[local Tween = TweenService:Create(EffectFrame,Ti3,{Size = UDim2.new(0.134, 0,.186, 0)})
		Tween:Play()
		Tween:Destroy()
		
		local RandomNumber = math.random(-10,10) * 3
		
		if os.clock() - lastchangedpos > .2 then
			lastchangedpos = os.clock()
			EffectFrame.Position = CenterPos + UDim2.new(0,RandomNumber,0,RandomNumber)
		end
		
		for _,Element in ipairs(Number:GetChildren()) do
			local Tween = TweenService:Create(Element,Ti,{Position = UDim2.new(0,0,1,0)})
			Tween:Play()
			Tween:Destroy()
			
			Debris:AddItem(Element,.25)
			
		end
			local CurrentText = script.Parent.CurrentText:Clone()
			CurrentText.TextColor3 = Color3.fromRGB(160, 230, 255)
			CurrentText.Text = UiData.Number or "1"
			CurrentText.Parent = Number

			local Tween = TweenService:Create(CurrentText,Ti,{Position = UDim2.new(0,0,0,0)})
			Tween:Play()
			Tween:Destroy()

			local Tween = TweenService:Create(CurrentText,Ti2,{TextColor3 = Color3.fromRGB(255, 255, 255)})
			Tween:Play()
			Tween:Destroy()

			local HitTing = Indicator
			HitTing.Size = UDim2.new(1, 0, .727, 0)
			local HitSize = HitTing.Size

			local Tween = TweenService:Create(HitTing,Ti4,{Size = UDim2.new(HitSize.X.Scale + .1, 0, HitSize.Y.Scale + .1, 0)})
			Tween:Play()
			Tween:Destroy()
			
			if os.clock() - lastchangedpos2 >.2 then
				lastchangedpos2 = os.clock()
				GuisEffect:Slash(HitManager,EffectFrame.Position)
			end
		
			wait(.3)
		
			if EffectFrame then
				local Tween = TweenService:Create(EffectFrame,Ti3,{Size = UDim2.new(0,0,0,0)})
				Tween:Play()
				Tween:Destroy()
			end]]
    end,
}

return DamageIndicator
