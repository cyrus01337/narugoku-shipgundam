local TS = game:GetService("TweenService")

return function(Character)
	local HRP = Character:WaitForChild("HumanoidRootPart")
	local Hum = Character:WaitForChild("Humanoid")
	
	local FX = script.Particles.LevelUp:Clone()
	local SFX = script.Start:Clone()
	FX.Parent = HRP
	SFX.Parent = HRP
	local Animation = Hum:LoadAnimation(script.Animations.LevelUp)
	
	Animation:Play()	
	SFX:Play()
	
	Animation:GetMarkerReachedSignal("LevelUp"):Connect(function()
		for i, v in pairs(FX:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(v:GetAttribute("EmitCount"))
			elseif v:IsA("PointLight") then
				TS:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Brightness = 1, Range = 15}):Play()
				task.delay(0.2, function()
					TS:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0, Range = 0}):Play()
				end)
			elseif v:IsA("Sound") then
				v:Play()
			end
		end
	end)
	
	game.Debris:AddItem(FX, 2)
	game.Debris:AddItem(SFX, 1)
end
