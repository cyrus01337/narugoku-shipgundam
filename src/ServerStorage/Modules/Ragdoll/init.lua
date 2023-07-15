--|| Services ||--
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

--local Target = script.Parent
local module = {}

function sub(...)
	coroutine.wrap(...)()
end
local Target = script.Parent

function module.DurationRagdoll(Target,Duration,Knockout)
	coroutine.resume(coroutine.create(function()
		if Players:GetPlayerFromCharacter(Target) == nil then return end

		if Target:FindFirstChild("Ragdolled") then
			return
		end
		if Target:FindFirstChild("NoRagdoll") then
			return
		end
		local Player = Players:GetPlayerFromCharacter(Target)
		local Humanoid = Target.Humanoid

		local Motors = {}
		local Adoornments = {}
		local BodyParts = {Target:FindFirstChild("Right Arm"), Target:FindFirstChild("Left Arm"), Target:FindFirstChild("Right Leg"), Target:FindFirstChild("Left Leg"), Target["Head"]}

		local Base = Target["Torso"]

		Target.HumanoidRootPart.Velocity = Vector3.new(0,0,10)

		for _, Child in pairs(Base:GetChildren()) do
			if Child:IsA("Motor6D") then
				table.insert(Motors, Child)
			end
		end
		local function RemoveMotors()
			for Index, Motor in pairs(Motors) do
				-- if Motor.Name == "Neck" then
				Motor.Enabled = false
			--[[else
				Motor.Parent = nil
			end--]]
			end
		end
		local function RestoreMotors()
			for Parent, Motor in pairs(Motors) do
				-- if Motor.Name == "Neck" then
				Motor.Enabled = true
			--[[else
				Motor.Parent = Base
			end--]]
			end
		end
		local function CreateAdoornments()
			for _, BodyPart in pairs(BodyParts) do
				local Attachment0 = Instance.new("Attachment")
				local Attachment1 = Instance.new("Attachment")

				local Constraint = Instance.new("BallSocketConstraint")

				Attachment0.Parent = BodyPart
				Attachment1.Parent = Base

				if BodyPart.Name == "Right Arm" then
					Attachment0.CFrame = CFrame.new(0,BodyPart.Size.Y/2,0)
					Attachment1.CFrame = Attachment0.CFrame * CFrame.new(1.25,0,0)
				elseif BodyPart.Name == "Right Leg" then
					Attachment0.CFrame = CFrame.new(0,BodyPart.Size.Y/2,0)
					Attachment1.CFrame = Attachment0.CFrame * CFrame.new(.5,-BodyPart.Size.Y,0)
				elseif BodyPart.Name == "Left Arm" then
					Attachment0.CFrame = CFrame.new(0,BodyPart.Size.Y/2,0)
					Attachment1.CFrame = Attachment0.CFrame * CFrame.new(-1.25,0,0)
				elseif BodyPart.Name == "Left Leg" then
					Attachment0.CFrame = CFrame.new(0,BodyPart.Size.Y/2,0)
					Attachment1.CFrame = Attachment0.CFrame * CFrame.new(-.5,-BodyPart.Size.Y,0)
				elseif BodyPart.Name == "Head" then
					Attachment0.CFrame = CFrame.new(0,-BodyPart.Size.Y/2,0)
					Attachment1.CFrame = Attachment0.CFrame * CFrame.new(0,BodyPart.Size.Y + (BodyPart.Size.Y/2),0)
				end

				Attachment0.Name = BodyPart.Name .. "ExtraJoint"
				Attachment1.Name = BodyPart.Name .. "ExtraAttachment"

				Constraint.Attachment0 = Attachment0
				Constraint.Attachment1 = Attachment1

				Constraint.Parent = BodyPart

				Adoornments[Attachment0] = Attachment0
				Adoornments[Attachment1] = Attachment1
				Adoornments[Constraint] = Constraint
			end
		end
		local function RemoveAdoornments()
			for _, Adoornment in pairs(Adoornments) do
				Adoornment:Destroy()
			end
		end

		local collisionBoxes = {}
		if not Player then
			local Parts = {Target["Right Arm"];Target["Left Arm"];Target["Right Leg"];Target["Left Leg"]}
			for i, v in pairs(Parts) do
				local box = v:Clone()
				box.Transparency = 1
				box.Massless = true
				box.CanCollide = true
				box.Anchored = false
				box.Name = "CollisionBox"
				box.Size = box.Size/4

				local weld = Instance.new("Weld")
				weld.Part0 = v
				weld.Part1 = box
				weld.Parent = box

				box.Parent = Target
				table.insert(collisionBoxes,box)
			end
		end

		if Knockout then
			local KnockoutLevel = Knockout[2]
			Duration = Duration * KnockoutLevel

			local KnockedOut = Instance.new("NumberValue")
			KnockedOut.Name = "KnockedOut"
			KnockedOut.Value = KnockoutLevel
			KnockedOut.Parent = Target
			Debris:AddItem(KnockedOut, Duration)
		end

		local AntiRotate = Instance.new("BoolValue")
		AntiRotate.Name = "AntiRotate"
		AntiRotate.Parent = Target

		local CombatDisable = Instance.new("BoolValue")
		CombatDisable.Name = "Staggered"
		CombatDisable.Parent = Target

		local Ragdoll = Instance.new("NumberValue")
		Ragdoll.Name = "Ragdolled"
		Ragdoll.Value = Duration
		Ragdoll.Parent = Target

		for _, AnimationTrack in pairs(Humanoid:GetPlayingAnimationTracks()) do
			AnimationTrack:Stop()
		end

		CreateAdoornments()

		Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		if not Knockout then
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		end
		sub(function()
			wait()
			RemoveMotors()
		end)
		Humanoid.PlatformStand = true

		-- Target.HumanoidRootPart:SetNetworkOwner(nil)

		local ClientScript = script.StateSetter:Clone()
		ClientScript.Disabled = false
		ClientScript.Parent = Target

		local null = {}
		for i,v in pairs(Target.HumanoidRootPart:GetChildren()) do
			if v.ClassName == "BodyGyro" then
				null[v.Parent] = v
				v.Parent = nil
			end
		end

		local Timer = tick()
		while tick() - Timer < Duration and wait() do
			if Humanoid.Health <= 0 then
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
				Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				break
			end
			if Target:FindFirstChild("GetUpTag") then
				break
			end
			if Target:FindFirstChild("NoGetup") then
				repeat
					Target.ChildRemoved:Wait()
				until not Target:FindFirstChild("NoGetup")
			end
		end

		for i,v in pairs(null) do
			v.Parent = i
		end

		for a,b in pairs(collisionBoxes) do
			b:Destroy()
		end

		Ragdoll:Destroy()

		CombatDisable:Destroy()

		AntiRotate:Destroy()

		Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		if ClientScript and ClientScript:FindFirstChild("Ended") then
			ClientScript.Ended.Value = true
			delay(1,function() ClientScript:Destroy() end)
		end

		Humanoid.PlatformStand = false


		RemoveAdoornments()
		RestoreMotors()

		-- Target.HumanoidRootPart:SetNetworkOwnershipAuto()

		for _, AnimationTrack in ipairs(Humanoid:GetPlayingAnimationTracks()) do
			AnimationTrack:Stop()
		end
	end))
end

return module