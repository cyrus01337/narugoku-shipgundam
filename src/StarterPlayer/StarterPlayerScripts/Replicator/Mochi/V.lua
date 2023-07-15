-- SERVICES --
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TS = game:GetService("TweenService")

-- FOLDERS --
local Remotes = RS:WaitForChild("Remotes")
local Modules = RS:WaitForChild("Modules")

-- MAIN VARIABLES --


-- FUNCTIONS --
return function(Action, Projectile, State)
	if Action == "Hit" then
		coroutine.wrap(function()
			local attachment = Instance.new("Attachment")
			attachment.Parent = Projectile
			
			local sound = RS.Sounds.Mochi.MochiShotHit:Clone()
			sound.Parent = Projectile
			sound:Play()
			game.Debris:AddItem(sound, .5)
			
			for i, v in pairs(script:WaitForChild("HitFX"):GetChildren()) do
				local fx = v:Clone()
				fx.Parent = attachment
				fx:Emit(fx:GetAttribute("EmitCount"))
			end
		end)()
	elseif Action == "Shot" then
		local gun = Projectile
		coroutine.wrap(function()
			if State == "Start" then
				local attachment = Instance.new("Attachment")
				attachment.Parent = gun
				attachment.Position = Vector3.new(-3.4, 0, 0)
				
				for i, v in pairs(script:WaitForChild("ShotVFX"):GetChildren()) do
					local fx = v:Clone()
					fx.Parent = attachment
					fx.Enabled = true
				end
			else
				local attachment = gun:FindFirstChild("Attachment")
				if attachment then
					for i, v in pairs(attachment:GetChildren()) do
						v.Enabled = false
					end
				end
			end
			
		end)()
	end
end