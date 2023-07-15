--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Effects = Modules.Effects
local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Shared = Modules.Shared

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local TaskScheduler = require(Utility.TaskScheduler)

local SoundManager = require(Shared.SoundManager)
local StateManager = require(Shared.StateManager)

local LightningModule = require(Effects.LightningBolt) 
local VfxHandler = require(Effects.VfxHandler)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Humanoid = Character:WaitForChild("Humanoid")

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Map}
raycastParams.FilterType = Enum.RaycastFilterType.Include

local PlayerClient = {	

	DamageIndication = function(Data)
		local Character = Data.Characater
		local Victim = Data.Victim
		
		local VHum = Victim:FindFirstChild("Humanoid")

		local Damage = Data.Damage
		VfxHandler.DamageIndicator(Victim,Damage)
				
		local StartTime = os.clock()

		while os.clock() - StartTime <= Data.StunTime do
			VHum.WalkSpeed = 0
			VHum.JumpPower = 0

			RunService.Stepped:Wait()
		end
		VHum.WalkSpeed = 14
		VHum.JumpPower = 50
		
		StartTime = os.clock()
	end,
	
	ModeDash = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")
		
		-- SoundManager:AddSound("Shunpo",{Parent = Root, Volume = 3.85}, "Client")
		VfxHandler.AfterImage({Character = Character, Duration = 1, StartTransparency = .2, Color = Color3.fromRGB(0,0,0)})

		local Effect = script.DashEffect:Clone()
		Effect.CFrame = Root.CFrame
		Effect.Parent = workspace.World.Visuals
		Effect.ParticleEmitter:Emit(20)
		
		Debris:AddItem(Effect,.5)
		
		local Attachment = Instance.new("Attachment", Root)
		Attachment.Position = Vector3.new(Root.Size.X / 2, 0, 0)
		
		local Tween = TweenService:Create(Attachment, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {Position = Vector3.new(0, 0, 0)})
		Tween:Play()
		Tween:Destroy()
		
		local Attachment2 = Instance.new("Attachment", Root)
		Attachment2.Position = Vector3.new(-Root.Size.X / 2, 0, 0)
		
		local Tween = TweenService:Create(Attachment2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {Position = Vector3.new(0, 0, 0)})
		Tween:Play()
		Tween:Destroy()
		
		local TrailEffect = script.Trail:Clone();
		TrailEffect.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
		TrailEffect.Attachment0 = Attachment
		TrailEffect.Attachment1 = Attachment2
		TrailEffect.Transparency = NumberSequence.new(0.8, 1)
		TrailEffect.WidthScale = NumberSequence.new(1)
		TrailEffect.Parent = Root
		
		wait(.18)
		TrailEffect.Enabled = false
		
		Debris:AddItem(Attachment, TrailEffect.Lifetime)
		Debris:AddItem(Attachment2, TrailEffect.Lifetime)
		Debris:AddItem(TrailEffect, TrailEffect.Lifetime)
		
		--[[local Part = Instance.new("Part")
		Part.CFrame = Data.ContactPointCFrame
		Part.Parent = workspace.World.Visuals
		Part.Transparency = 1
		
		Debris:AddItem(Part,1)
		
		-- SoundManager:AddSound("ModeDash", {Parent = Root, Volume = 5}, "Client")

		local SecondVanish = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments.SecondVanish:Clone()
		VfxHandler.Emit(SecondVanish.ParticleEmitter,5)
		SecondVanish.Parent = Part
		
		Debris:AddItem(SecondVanish,1)
		
		local Vanish = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments.Vanish:Clone()
		VfxHandler.Emit(Vanish.ParticleEmitter,3)		
		Vanish.Parent = Part
		
		Debris:AddItem(Vanish,1)]]	
	end,

	Dash = function(Data)
		local Character = Data.Character
		local Root = Character:FindFirstChild("HumanoidRootPart")

		local Cframe = Root.CFrame * CFrame.new(0,0,-3)	
		local r1 = Cframe.p + Vector3.new(0,30,0)
		local r2 = Cframe.upVector * -200

		VfxHandler.ImpactLines({Character = Character, Amount = 8})
		VfxHandler.AfterImage({Character = Character, Duration = .3, StartTransparency = .25,})

		-- SoundManager:AddSound("Dodge", {Parent = Root}, "Client")

		local Results = workspace:Raycast(r1,r2,raycastParams)
		if Results and Results.Instance and (Cframe.p - Results.Position).Magnitude < 5 then	
			local Dust = ReplicatedStorage.Assets.Effects.Particles.DashDust:Clone()
			Dust.CFrame = Root.CFrame * CFrame.new(0,0,-3)
			Dust.Particle.Color = ColorSequence.new(Results.Instance.Color)
			Dust.Particle:Emit(12)
			Dust.Parent = workspace.World.Visuals
			
			Debris:AddItem(Dust,1.5)
		end
	end,
	
	GodspeedDash = function(Data)
		local Character = Data.Character
		
		local Root = Character:FindFirstChild("HumanoidRootPart")
		
		local ContactPointCFrame = Data.ContactPointCFrame

		VfxHandler.AfterImage({Character = Character, Duration = 1, StartTransparency = .2, Color = Color3.fromRGB(110, 153, 202) })
		-- SoundManager:AddSound("LightningDash",{Parent = Root, Volume = 2.25},"Client")

		local Light = Instance.new("PointLight")
		Light.Color = Color3.fromRGB(110, 153, 202)
		Light.Brightness = 8
		Light.Range = 35
		Light.Parent = Root

		TaskScheduler:AddTask(.15,function()
			local Dust = ReplicatedStorage.Assets.Effects.Particles.GodSpeedDust:Clone()
			Dust.CFrame =  Root.CFrame * CFrame.new(0,-3,0)
			Dust.Particle.SpreadAngle = Vector2.new(0, 200)
			Dust.Size = Vector3.new(0,0,0)
			Dust.Particle.EmissionDirection = "Back"
			Dust.Particle.Enabled = true
			Dust.Particle:Clear()
			Dust.Particle:Emit(200)
			Dust.Parent = workspace.World.Visuals

			Debris:AddItem(Dust, 2.5)
		end)
		
		local Max = 200
		TaskScheduler:AddTask(.2,function()
			for Index = 1,10 do
				local Max = Max - 10
				local startPos = ContactPointCFrame.p
				local endPos = Root.CFrame.p
				local amount = 10
				local width = .35
				local offsetRange = 1

				local Model = VfxHandler.Lightning({
					StartPosition = startPos,
					EndPosition = endPos, 
					Amount = amount, 
					Width = width, 
					OffsetRange = offsetRange,
					Color = "Pastel Blue";
				})

				for _,Part in ipairs(Model:GetChildren()) do
					Part.CanCollide = false
					GlobalFunctions.TweenFunction({["Instance"] = Part,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.In,["Duration"] = .1,},{["Size"] = Vector3.new(0,0,0)})
				end
				Debris:AddItem(Model, .1) 
				Debris:AddItem(Light, .1)
				Light.Brightness = Light.Brightness - 1         
				wait(.01)
			end	
		end)
	end,

	LightningStun = function(BackData)
		local Character = BackData.Character
		local Victim = BackData.Victim

		local VRoot, Root = Victim:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("HumanoidRootPart")
		
		local Animator = Victim:FindFirstChild("Humanoid"):FindFirstChildOfClass("Animator")

		local Attach = Victim["Torso"]:FindFirstChild("BodyFrontAttachment")
		local Parents = {Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Head"),Victim:FindFirstChild("Left Arm"), Victim:FindFirstChild("Right Leg")}

		for _,BodyParts in ipairs(Victim:GetChildren()) do
			local LightningParticle = ReplicatedStorage.Assets.Effects.Particles.LightningProc:Clone()
			LightningParticle.Parent = BodyParts

			Debris:AddItem(LightningParticle,.75)
		end	

		if Animator then
			local Animation = Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Combat.HitReaction["HitReaction"..(math.random(1,2))]) --KeysLogged == 0 and 1 or KeysLogged
			Animation:Play()
		end
		
		local Attach2 = Instance.new("Attachment")
		Attach2.Parent = Parents[math.random(1, 4)]
		Attach2.Position = Vector3.new(.5,.5,.5)

		local Bolts = LightningModule.new(Attach,Attach2,50)
		Bolts.PulseLength = .8
		Bolts.Color = Color3.fromRGB(117, 237, 255)

		Debris:AddItem(Attach2,2)
		-- SoundManager:AddSound("LightningSizzle", {Parent = Root, Volume = 2}, "Client")
	end;
}

return PlayerClient
