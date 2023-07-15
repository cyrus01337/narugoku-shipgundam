--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules
local Assets = ReplicatedStorage.Assets

local Metadata = Modules.Metadata
local Utility = Modules.Utility

local Shared = Modules.Shared

local Effects = Assets.Effects
--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local TaskScheduler = require(Utility.TaskScheduler)

local SoundManager = require(Shared.SoundManager)

local VfxHandler = require(Modules.Effects.VfxHandler)
local CameraShaker = require(Modules.Effects.CameraShaker)

local SpeedManager = require(Shared.StateManager.Speed)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	Camera.CFrame = Camera.CFrame * shakeCFrame
end)	

local Humanoid = Character:WaitForChild("Humanoid")

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Map}
raycastParams.FilterType = Enum.RaycastFilterType.Include

local CombatVFX = {	
	
	AppearSword = function(Data)
		local Character = Data.Character
		
		SpeedManager.AppearSword(Character)
	end,
	
	HideSword = function(Data)
		local Character = Data.Character
		
		SpeedManager.HideSword(Character)
	end,

	Light = function(Data)
		local Character = Data.Character
		local Victim = Data.Victim
		local KeysLogged = Data.KeysLogged

		local VHumanoid,VRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")	
		local Animator = VHumanoid:FindFirstChildOfClass("Animator")

		VfxHandler.Orbies({Parent = VRoot, Speed = .35, Cframe = CFrame.new(0,0,3), Amount = 6, Circle = true})

		local PunchedParticle = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments.Punched:Clone()
		PunchedParticle.Parent = VRoot
		for _,v in ipairs(PunchedParticle:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Rate = 0
				v:Emit(1)
			end
		end
		Debris:AddItem(PunchedParticle,1.35)

		local Slash = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments.Slash:Clone()
		for _,v in ipairs(Slash:GetChildren()) do
			v.Rate = GlobalFunctions.GetGraphics() * v.Rate
			v.Rotation = NumberRange.new(math.random(80,160))
			delay(.15,function() v.Enabled = false end)
		end		
		Slash.Parent = VRoot
		Debris:AddItem(Slash,.6)

		-- SoundManager:AddSound("SwordSlash", {Parent = Character.HumanoidRootPart, Looped = false, Volume = 1.35}, "Client")

		if Victim and Animator and Humanoid then
			local Animation = Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Combat.HitReaction["HitReaction"..(KeysLogged == 0 and 1 or (KeysLogged or 1))]) --KeysLogged == 0 and 1 or KeysLogged
			Animation:Play()
		end

		local DoBlood = math.random(1,2)

		if DoBlood == 2 then
			for Index = 1, math.random(3,5) do
				local BloodBullet = script.bloodbullet:Clone()
				BloodBullet.CFrame = VRoot.CFrame
				BloodBullet.Velocity = Vector3.new(0, 0, 0) + Vector3.new(math.random(-15, 15), math.random(15, 50), math.random(-15, 15))
				BloodBullet.CanCollide = false
				BloodBullet.Parent = workspace.World.Visuals

				local RandomCalculation = math.random(100, 200) / 10000
				BloodBullet.Attachment2.Position = Vector3.new(-RandomCalculation, 0, 0)
				BloodBullet.Attachment.Position = Vector3.new(RandomCalculation, 0, 0)

				Debris:AddItem(BloodBullet,2)

			--[[local Connection; Connection = BloodBullet.Touched:Connect(function(Hit)
					if not Hit:IsDescendantOf(workspace.World.Live) and not Hit:IsDescendantOf(workspace.World.Visuals) and not Hit:IsDescendantOf(workspace.CurrentCamera) then
						BloodBullet.Anchored = true
						BloodBullet.CanCollide = false
						local CFrameCalc = BloodBullet.CFrame * CFrame.new(0, 10, 0)
						local Target,Position,Surface = workspace:FindPartOnRayWithIgnoreList(Ray.new(CFrameCalc.p, CFrameCalc.upVector * -25), { workspace.World.Live, workspace.World.Visuals })
						if Target then
							local BloodStain = script.blood:Clone()
							BloodStain.CFrame = CFrame.new(Position, Position + Surface) * CFrame.Angles(math.rad(90), math.rad(math.random(-360, 360)), 0)
							BloodStain.Size = Vector3.new(0, 0, 0)
							BloodStain.Anchored = false
							BloodStain.CanCollide = false							
							BloodStain.Parent = workspace.World.Visuals

							local SizeCalc = math.random(100, 400) / 100

							local Tween = TweenService:Create(BloodStain,TweenInfo.new(math.random(200, 800) / 1000, Enum.EasingStyle.Quad, Enum.EasingDirection.Out,0,false,0),{Size = Vector3.new(SizeCalc, 0, SizeCalc)})
							Tween:Play()
							Tween:Destroy()

							TaskScheduler:AddTask(.5,function()
								for _,Instances in ipairs(BloodStain:GetChildren()) do
									if Instances:IsA("Decal") then
										TweenService:Create(Instances,TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Transparency = 1}):Play()
									end
								end
							end)

							Debris:AddItem(BloodStain,1)

							local WeldConstraint = Instance.new("WeldConstraint")
							WeldConstraint.Part0 = Target
							WeldConstraint.Part1 = BloodStain
							WeldConstraint.Parent = BloodStain
						end
						Debris:AddItem(BloodBullet,.75)

						Connection:Disconnect()
						Connection = nil
						return
					end
				end) ]]
			end
		end
	end,

	LastHit = function(Data)
		local Character = Data.Character
		local Victim = Data.Victim

		local VHumanoid,VRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")	
		local Animator = VHumanoid:FindFirstChildOfClass("Animator")

		local Result = workspace:Raycast(VRoot.Position, VRoot.CFrame.upVector * -15, raycastParams)
		if Result and Result.Instance then
			local DirtStep = ReplicatedStorage.Assets.Effects.Particles.DirtStep:Clone()
			DirtStep.ParticleEmitter.Enabled = true
			DirtStep.CFrame = VRoot.CFrame * CFrame.new(0,-1.85,.225)
			DirtStep.ParticleEmitter.Color = ColorSequence.new(Result.Instance.Color) 
			DirtStep.Parent = VRoot

			local WeldConstraint = Instance.new("WeldConstraint"); 
			WeldConstraint.Part0 = VRoot
			WeldConstraint.Part1 = DirtStep;
			WeldConstraint.Parent = DirtStep

			delay(.5,function() DirtStep.ParticleEmitter.Enabled = false end)
			Debris:AddItem(DirtStep,1)		
		end

		local Slash = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments.Slash:Clone()
		for _,v in ipairs(Slash:GetChildren()) do
			v.Rate = GlobalFunctions.GetGraphics() * v.Rate
			v.Rotation = NumberRange.new(math.random(80,160))
			delay(.15,function() v.Enabled = false end)
		end		
		Slash.Parent = VRoot
		Debris:AddItem(Slash,.6)

		VfxHandler.Orbies({Parent = VRoot, Speed = .5, Size = Vector3.new(.2, .3, 3.79), Cframe = CFrame.new(0,0,5), Amount = 5, Circle = true, Sphere = true})

		local PunchedParticle = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments.Punched:Clone()
		PunchedParticle.Parent = VRoot
		for _,v in ipairs(PunchedParticle:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Rate = 0
				v:Emit(1)
			end
		end
		Debris:AddItem(PunchedParticle,1.35)

		-- SoundManager:AddSound("CombatKnockback", {Parent = Character.HumanoidRootPart, Looped = false, Volume = 3.75}, "Client")

		if Animator then
			local Animation = Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Combat.HitReaction.HitReaction5)
			Animation:Play()
		end
	end,
}

return CombatVFX
