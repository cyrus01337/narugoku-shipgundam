local TS = game:GetService("TweenService")

local onFire = script:WaitForChild("Toggle")

local fireFX = script:WaitForChild("OnFire")

return function(Character, Toggle)
	local HRP = Character:WaitForChild("HumanoidRootPart")
	onFire.Value = Toggle
	
	if Character then
		if onFire.Value then
			local onFireFX = fireFX.OnFire:Clone()
			local wispsFireFX = fireFX.OnFireWisps:Clone()
			local sparksFireFX = fireFX.OnFireSparks:Clone()
			local fireLight = fireFX.FireLight:Clone()
			
			onFireFX.Parent = HRP
			wispsFireFX.Parent = HRP
			sparksFireFX.Parent = HRP
			fireLight.Parent = HRP
			
			onFireFX.Enabled = true
			wispsFireFX.Enabled = true
			sparksFireFX.Enabled = true
			TS:Create(fireLight, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0.7, Range = 10}):Play()
		else
			local onFireFX = HRP:FindFirstChild("OnFire")
			local wispsFireFX = HRP:FindFirstChild("OnFireWisps")
			local sparksFireFX = HRP:FindFirstChild("OnFireSparks")
			local fireLight = HRP:FindFirstChild("FireLight")
			
			if onFireFX and wispsFireFX and sparksFireFX and fireLight then
				onFireFX.Enabled = false
				wispsFireFX.Enabled = false
				sparksFireFX.Enabled = false
				TS:Create(fireLight, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0, Range = 0}):Play()
				
				task.delay(2, function()
					fireLight:Destroy()
					onFireFX:Destroy()
					wispsFireFX:Destroy()
					sparksFireFX:Destroy()
				end)
			end
		end
	end
end
