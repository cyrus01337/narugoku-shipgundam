--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--|| Modules ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(ReplicatedStorage.Modules.Shared.SoundManager)
local RaycastManager = require(ReplicatedStorage.Modules.Shared.RaycastManager)

local VFXHandler = require(ReplicatedStorage.Modules.Effects.VfxHandler)

--|| Variables ||--
local Player = Players.LocalPlayer 
local Character = Player.Character or Player.CharacterAdded:Wait()

local CurrentCamera = workspace.CurrentCamera

local Assets = ReplicatedStorage.Assets

camShake = require(ReplicatedStorage.Modules.Effects.CameraShaker).new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * shakeCFrame
end)

camShake:Start()

function GetMousePos(X,Y,Z,Boolean)
	local RayMag1 = workspace.CurrentCamera:ScreenPointToRay(X, Y) 
	local NewRay = Ray.new(RayMag1.Origin, RayMag1.Direction * ((Z and Z) or 200))
	local Target,Position,Surface = workspace:FindPartOnRayWithIgnoreList(NewRay, {Character,workspace.World.Visuals})
	if Boolean then
		return Position,Target,Surface
	else
		return Position
	end
end

local function urmom(Particle)
	local Clone = Particle:Clone()
	Particle.Enabled = false
	Clone.Enabled = false
	Clone.Lifetime = NumberRange.new(.25, .5)
	Clone.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 10, 5), NumberSequenceKeypoint.new(1, 0, 0)})
	Clone.Speed = NumberRange.new(50, 100)
	Clone.Drag = 5
	Clone.SpreadAngle = Vector2.new(-360, 360)
	Clone:Emit(40)
	Clone.Parent = Particle.Parent
end

function Current(Raycast,Part2,Length,Spread,Size)
	local Size = math.random((Size * .5),Size * 10) / 10
	local EndPoint = (Raycast.Origin + Raycast.Direction)
	local MagnitudeIndex = (Raycast.Origin-EndPoint).Magnitude
	local Direction = (EndPoint-Raycast.Origin).Unit

	local Part = Part2:Clone()
	Part.Attachment2.Position = Vector3.new(-math.random((Size * .25) * 100,Size * 100) / 100,0,0)
	Part.Attachment1.Position = Vector3.new(math.random((Size * .25) * 100,Size * 100) / 100,0,0)
	Part.CFrame = CFrame.new(Raycast.Origin)
	Part.Name = "urmomlightning"
	Part.Parent = workspace.World.Visuals

	Debris:AddItem(Part,2)

	local OldPosition,OldPartPosition = Part.CFrame.Position,Part.CFrame.Position

	for _ = 0,MagnitudeIndex,MagnitudeIndex * (Length / 100) do
		local Counted = MagnitudeIndex * (Length / 100)
		local X,Y,Z = math.random(-Spread,Spread) / 10,math.random(-Spread,Spread) / 10,math.random(-Spread,Spread) / 10

		Part.CFrame = CFrame.new(OldPosition,EndPoint) * CFrame.new(X,Y,Z)
		OldPartPosition = Part.CFrame.Position
		OldPosition = OldPosition + (Direction * Counted)

		RunService.RenderStepped:Wait()
	end
end

function CreateBoltOnRay(Raycast,Color,SP)
	local Part = script[Color]:GetChildren()[math.random(1,#script[Color]:GetChildren())] 
	Current(Raycast,Part,SP.Bolt.Length,SP.Bolt.Spread,SP.Bolt.Size)
end

function Activate(Raycast,Color,Voltage,SP)
	for _ = 1,Voltage do
		local EndPosition = (Raycast.Origin + Raycast.Direction)
		local CF2 = CFrame.new(EndPosition,Raycast.Origin) * CFrame.new(math.random(-SP.Extra.End,SP.Extra.End),math.random(-SP.Extra.End,SP.Extra.End),math.random(SP.Extra.End,SP.Extra.End * 1.95))
		EndPosition = CF2.Position
		local CF = CFrame.new(Raycast.Origin,EndPosition) * CFrame.new(math.random(-SP.Extra.Start,SP.Extra.Start),math.random(-SP.Extra.Start,SP.Extra.Start),math.random(SP.Extra.Start * .8,SP.Extra.Start))
		CF = CFrame.new(CF.Position,EndPosition)
		local Mag = (EndPosition - CF.Position).Magnitude
		local newRay = Ray.new(CF.Position,CF.LookVector*Mag)

		coroutine.wrap(function()
			CreateBoltOnRay(newRay,Color,SP)
		end)()
	end
end

function DirtEffect(Pos,Character,pos2)
	local Raycast = Ray.new(Pos,Vector3.new(0,-5,0))
	local Target,Position = workspace:FindPartOnRayWithIgnoreList(Raycast,{Character,workspace.World.Visuals,workspace.World.Live})
	if Target then
		local Table = {}
		for _ = 1,1 do
			local Rock = script.Rock:Clone()
			Table[#Table+1] = Rock
			Rock.Position = Position + Vector3.new(math.random(-10,10) / 10,-.5,math.random(-10,10) / 10)
			Rock.Color = Target.Color
			Rock.Material = Target.Material
			Rock.BodyAngularVelocity.AngularVelocity = Vector3.new(math.random(-4,4),math.random(-4,4),math.random(-4,4))
			
			local Tween = TweenService:Create(Rock, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Size"] = Vector3.new(),["Transparency"] = 1})
			Tween:Play()
			Tween:Destroy()
			
			Rock.BodyVelocity.Velocity = Vector3.new(math.random(-30,30)/10,20,math.random(-30,30)/10)
			Rock.Parent = workspace.World.Visuals
			Rock:CanCollideWith(Target)
			
			Debris:AddItem(Rock.BodyVelocity,.1)
		end
		delay(3,function()
			for _,v in ipairs(Table) do
				v:Destroy()
			end
		end)
	end
	return Target,Position
end

local Mouse = Player:GetMouse()
local Table = {}

local raycastparams = RaycastParams.new()
raycastparams.FilterDescendantsInstances = {workspace.World.Map}
raycastparams.FilterType = Enum.RaycastFilterType.Include

local fireballHit = false

local SasukeVFX = {
	["ShurikenHit"] = function(PathData)
		local Character = PathData.Character
		local Humanoid,VRoot = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

		local Slash = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments.Slash:Clone()
		for _,v in ipairs(Slash:GetChildren()) do
			if v.Name ~= "HeavySlash" then
				v.Rate = GlobalFunctions.GetGraphics() * v.Rate
				v.Rotation = NumberRange.new(math.random(80,160))
				delay(.15,function() v.Enabled = false end)
			end
		end		
		Slash.Parent = VRoot
		Debris:AddItem(Slash,.6)

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

			local Connection; Connection = BloodBullet.Touched:Connect(function(Hit)
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

						delay(.5,function()
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
			end) 
		end
	end,
	
	["Shuriken"] = function(PathData)
		local Character = PathData.Character
		local Humanoid,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

		for _ = 1,5 do
			local slash = ReplicatedStorage.Assets.Effects.Meshes.ThreeDSlashEffect:Clone()
			local size = math.random(2,4) * 4
			local sizeadd = math.random(2,4) * 24
			local x,y,z = math.rad(math.random(8,12) * 30), math.rad(math.random(8,12) * 30), math.rad(math.random(8,12) * 30)
			local add = math.random(1,2)
			if add == 2 then
				add = -1
			end
			slash.Transparency = .4
			slash.Size = Vector3.new(2,size,size)
			slash.CFrame = Root.CFrame * CFrame.Angles(x,y,z)
			slash.Parent = workspace.World.Visuals

			local B5 = TweenInfo.new(.3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

			local Tween = TweenService:Create(slash,B5,{Transparency = 1,CFrame = slash.CFrame*CFrame.Angles(math.pi * add,0,0),Size = slash.Size+Vector3.new(0,sizeadd,sizeadd)})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(slash,.3)
		end
	end,

	["Fireball Jutsu"] = function(PathData)
		local Character = PathData.Character
		local Humanoid,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

		local End = Root.CFrame

		local PositionCalculation,PositionCalculation2 = End.Position,End.upVector * -200

		local RaycastResult = workspace:Raycast(PositionCalculation,PositionCalculation2,raycastparams)
		if RaycastResult and RaycastResult.Instance and (RaycastResult.Position - PositionCalculation).Magnitude < 30 then
			local LeftDust = ReplicatedStorage.Assets.Effects.Meshes.JutsuDust:Clone()
			LeftDust.Size = Vector3.new(LeftDust.Size.X,LeftDust.Size.Y,7)
			LeftDust.CFrame = End * CFrame.Angles(0,.3,0 ) * CFrame.new(3,0,0)
			LeftDust.ParticleEmitter.Color = ColorSequence.new(RaycastResult.Instance.Color)
			LeftDust.ParticleEmitter:Emit(10)
			LeftDust.Parent = workspace.World.Visuals

			Debris:AddItem(LeftDust,3)

			local RightDust = ReplicatedStorage.Assets.Effects.Meshes.JutsuDust:Clone()
			RightDust.Size = Vector3.new(RightDust.Size.X,RightDust.Size.Y,7)
			RightDust.CFrame = End * CFrame.Angles(0,-.3,0 ) * CFrame.new(-3,0,0)
			RightDust.ParticleEmitter.Color = ColorSequence.new(RaycastResult.Instance.Color)
			RightDust.ParticleEmitter:Emit(10)
			RightDust.Parent = workspace.World.Visuals

			Debris:AddItem(RightDust,3)
		end		

		local Fireball = ReplicatedStorage.Assets.Effects.Meshes.FireballJutsu:Clone()
		Fireball.CFrame = Root.CFrame * CFrame.new(0,0,-1)
		Fireball.Parent = workspace.World.Visuals

		local Vel = PathData.Velocity
		local LifeT = PathData.Lifetime

		local Position,Part,Surface = GetMousePos(Mouse.X,Mouse.Y,500,true)

		local Direction = (Root.CFrame * CFrame.new(0,0,-4e4).Position - Fireball.Position).Unit
		--local Points = RaycastManager:GetSquarePoints(CFrame.new(Fireball.Position), Fireball.Size.X, Fireball.Size.X)

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
		BodyVelocity.Velocity = Root.CFrame.lookVector * 80
		BodyVelocity.Parent = Fireball

		Fireball.looped:Play()
		Fireball.looped.TimePosition = 3.35

		local Connection; Connection = Fireball.Touched:Connect(function(Hit)
			if not Hit:IsDescendantOf(Character) and not Hit:IsDescendantOf(workspace.World.Visuals) and not Hit:IsDescendantOf(workspace.CurrentCamera) then
				for _,v in ipairs(Fireball:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end

				fireballHit = true
				
				if GlobalFunctions.CheckDistance(Player, 20) then
					GlobalFunctions.FreshShake(100,45,1,.2,0)
				end
				

				local Smoke = script.smoke:Clone()
				Smoke.CFrame = Fireball.CFrame
				Smoke.Attachment.DustEffect:Emit(35)
				Smoke.Parent = workspace.World.Visuals

				Debris:AddItem(Smoke, 2)

				local FireballExplosion = require(script.Explode)
				Fireball.Anchored = true
				Fireball.Parent = workspace.World.Visuals
				urmom(Fireball.Attachment.BurningPart)
				Fireball.looped:Stop()
				FireballExplosion(Fireball.CFrame, Fireball.CFrame, Fireball, RaycastResult.Instance or nil)

				local Tween = TweenService:Create(Fireball.PointLight, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Range"] = 50,  Brightness = 0})
				Tween:Play()
				Tween:Destroy()

				Debris:AddItem(Fireball, 2)

				local Sphere = script.Explode.sphere:Clone()
				Sphere.CFrame = Fireball.CFrame
				Sphere.Material = Enum.Material.ForceField
				Sphere.Transparency = 0
				Sphere.Parent = workspace.World.Visuals

				local Tween = TweenService:Create(Sphere, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
				Tween:Play()
				Tween:Destroy()

				local Tween = TweenService:Create(Sphere.Mesh, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Scale"] = Vector3.new(35, 35, 35)})
				Tween:Play()
				Tween:Destroy()

				Debris:AddItem(Sphere, .5)
				-- SoundManager:AddSound("explosion2",{Parent = Root, Volume = 2},"Client")

				Connection:Disconnect()
				Connection = nil
				delay(.35,function() fireballHit = false end)
				return
			end
		end)

		local EndCalculation = CFrame.new((Root.CFrame * CFrame.new(0, 5, 0)).Position)

		VFXHandler.Spherezsz({
			Cframe = EndCalculation, 
			TweenDuration1 = .25, 
			TweenDuration2 = .35, 
			Range = 5, 
			MinThick = 2, 
			MaxThick = 5, 
			Part = Root, 
			Color = Color3.fromRGB(255, 122, 69), 
			Amount = 12
		})

		for Index = 1,100 do
			local Part = script.Part:Clone()
			--Part.Mesh.Scale = Vector3.new(0, MagnitudeIndex, 0)
			Part.CFrame = Fireball.CFrame *  CFrame.new(0,0,2.5) * CFrame.Angles(math.rad(90), 0, 0)

			local CFrameIndex = Part.CFrame * CFrame.Angles(math.rad(180), 0, 0)
			VFXHandler.Shockwave2(CFrameIndex, CFrameIndex, BrickColor.new("Institutional white"), Vector3.new(15, .5, 15), Vector3.new(0, .5, 0), .35, 0, Enum.EasingStyle.Quad, Color3.fromRGB(255, 255, 255), Enum.Material.Neon, "Rings");

			--Part.Mesh.Scale = Vector3.new(3, MagnitudeIndex, 3)
			Part.Parent = workspace.World.Visuals

			local Tween = TweenService:Create(Part.Mesh, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Scale"] = Vector3.new(0, MagnitudeIndex, 0)})
			Tween:Play()
			Tween:Destroy() 

			local Tween = TweenService:Create(Part, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Color"] = BrickColor.new("Persimmon").Color})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(Part, .25)
			wait(.1)

			if fireballHit then break end
		end
	end,

	["Chidori"] = function(PathData)
		local Character = PathData.Character
		local Humanoid,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")
		
		local po  
		local Clone = script.Effects.Ball:Clone()
		Clone.Parent = Character
		Clone.Weld.Part0 = Character["Right Arm"]
		--Clone.ChidoriLights.Disabled = false
		
		local Sound = -- SoundManager:AddSound("ChidoriStart",{Parent = Root, Volume = 1.5},"Client")
	
		Debris:AddItem(Clone,4)

		local Clone2 = script.Effects.Part2:Clone()
		Clone2.Position = Clone.Position
		Clone2.Parent = workspace.World.Visuals
		Debris:AddItem(Clone2,1)

		local Tween = TweenService:Create(Clone2, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Size"] = Vector3.new(20,20,20)})
		Tween:Play()
		Tween:Destroy()
				
		coroutine.resume(coroutine.create(function()
			for _ = 1,2 do
				local Ring = ReplicatedStorage.Assets.Effects.Meshes.myring:Clone()
				Ring.Size = Vector3.new(12,.3,12)
				Ring.Position = Root.Position
				Ring.Parent = workspace.World.Visuals

				Debris:AddItem(Ring,3)

				local Tween = TweenService:Create(Ring, TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Size"] = Vector3.new(35,.3,35)})
				Tween:Play()
				Tween:Destroy()	
				wait(.2)
			end
		end))
		
		local StartTime = os.clock()
		
		coroutine.resume(coroutine.create(function()
			while os.clock() - StartTime <= 4 do
				local p1,p2 = DirtEffect(Clone.Position,Character,po)
				if p1 then
					po = p2
				end
				wait(.1)
				if Character:FindFirstChild("BreakChidoriClient") then 
					Clone:Destroy()
					break
				end
			end
		end))

		coroutine.wrap(function()
			for _ = 1,48 do
				if Character:FindFirstChild("BreakChidoriClient") then 
					Clone:Destroy()
					break
				end				
				local B = script.Effects.Ball.ChidoriGlow:Clone()
				B.Parent = Clone.Attachment

				local RandomIndex = math.random(10,16)

				local Tween = TweenService:Create(B,TweenInfo.new(.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0 ),{["Range"] = RandomIndex, ["Brightness"] = 0})
				Tween:Play()
				Tween:Destroy()
				--B.GlowChange.Disabled = false
				wait(.2)
			end
		end)()

		wait(.5)
		VFXHandler.RockExplosion({
			Pos = Root.Position, 
			Quantity = 12, 
			Radius = 5,
			Size = Vector3.new(1,1,1), 
			Duration = 2, 
		})			
		local Raycast = Ray.new(Root.Position + Vector3.new(0,30,0),Vector3.new(0,-60,0))
		Activate(Raycast,"Blue",20,{Extra = {Start = 20,End = 20},Bolt = {Spread = 20, Size = 3, Length = 10}})
		camShake:ShakeOnce(14,28,0,1)
	end,
	
	["ChidoriHit"] = function(PathData)
		local Character = PathData.Character
		local Humanoid,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

		local Victim = PathData.Victim
		local VRoot,VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")
		
		-- SoundManager:AddSound("ChidoriHit",{Parent = Root, Volume = .8},"Client")
		-- SoundManager:AddSound("SwordHit",{Parent = Root},"Client")
		camShake:ShakeOnce(14,28,0,1)
		
		local ChidoriExplosion = ReplicatedStorage.Assets.Effects.Meshes.ChidoriExplosion:Clone()
		ChidoriExplosion.CFrame = VRoot.CFrame
		ChidoriExplosion.Parent = Character
		Debris:AddItem(ChidoriExplosion,1)

		local Blood = script.Effects.UntrainedChidori.Blood.Attachment:Clone()
		Blood.ParticleEmitter:Emit(25)
		Blood.Parent = Character["Right Arm"] 

		Debris:AddItem(Blood,2)
		
		local EndCalculation = CFrame.new((Root.CFrame * CFrame.new(0, 5, 0)).Position)

		VFXHandler.Spherezsz({
			Cframe = EndCalculation, 
			TweenDuration1 = .3, 
			TweenDuration2 = .475, 
			Range = 10, 
			MinThick = 2, 
			MaxThick = 5, 
			Part = Root, 
			Color = Color3.fromRGB(119, 255, 226), 
			Amount = 25
		})
		VFXHandler.Orbies({Parent = Victim.HumanoidRootPart, Speed = .35, Cframe = CFrame.new(0,0,3), Amount = 12, Circle = true})

		for _ = 1,6 do
			local Base2 = ChidoriExplosion.ChidoriSparks2:Clone()
			Base2.Transparency = 0
			Base2.CFrame = ChidoriExplosion.CFrame * CFrame.new(0,0,0) * CFrame.Angles(math.random(-999,999),math.random(-999,999),math.random(-999,999))
			Base2.Parent = ChidoriExplosion			

			local RandomIndex = math.random(10,16)

			local Tween = TweenService:Create(Base2,TweenInfo.new(.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0 ),{Transparency = 1; Size = Vector3.new(RandomIndex, RandomIndex, RandomIndex)})
			Tween:Play()
			Tween:Destroy()

			Debris:AddItem(Base2,1)
		end

		local Tween = TweenService:Create(ChidoriExplosion.ChidoriGlow,TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out,0,false,0),{Brightness = 0, Range = 40})
		Tween:Play()
		Tween:Destroy()
		
		for _ = 1,2 do
			local Ring = ReplicatedStorage.Assets.Effects.Meshes.myring:Clone()
			Ring.Size = Vector3.new(12,.3,12)
			Ring.Position = Root.Position
			Ring.Parent = workspace.World.Visuals

			Debris:AddItem(Ring,3)

			local Tween = TweenService:Create(Ring, TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Size"] = Vector3.new(35,.3,35)})
			Tween:Play()
			Tween:Destroy()	
			wait(.2)
		end
	end,
}

return SasukeVFX