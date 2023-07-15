--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")

local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Effects = Modules.Effects
local Utility = Modules.Utility
local Shared = Modules.Shared

local HitPart2 = Models.Misc.HitPart2

local World = workspace.World
local Visuals = World.Visuals

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local Explosions = require(Effects.Explosions)
local VfxHandler = require(Effects.VfxHandler)
local LightningModule = require(Effects.LightningBolt)

local SoundManager = require(Shared.SoundManager)
local RaycastService = require(Shared.RaycastManager)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Mouse = Player:GetMouse()

local Humanoid = Character:WaitForChild("Humanoid")

local function RemoveTrash(Trash)
	for Index = 1,#Trash do
		local Item = Trash[Index]
		if Item and Item.Parent then
			Item:Destroy()
		end
	end
end

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

function FastWait(Duration)
	Duration = Duration or 1/60
	local StartTime = os.clock()
	while os.clock() - StartTime < Duration do
		RunService.Stepped:Wait()
	end
end

local AokijiVFX = {
	
	["Ice FreezeBreak"] = function(PathData)
		local Victim = PathData.Victim
		local VRoot,VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

		VfxHandler.Iceyzsz(VRoot)
		VfxHandler.Spherezsz({
			Cframe = VRoot.CFrame, 
			TweenDuration1 = .2, 
			TweenDuration2 = .35, 
			Range = 5, 
			MinThick = 12, 
			MaxThick = 18, 
			Part = nil, 
			Color = Color3.fromRGB(110, 168, 255),
			Amount = 15
		})
	end,
	
	["Ice Freeze"] = function(PathData)
		local Character = PathData.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		-- SoundManager:AddSound("FlashFreeze",{Parent = Root, Volume = 7.5},"Client")
		if GlobalFunctions.CheckDistance(Player, 35) then
			GlobalFunctions.FreshShake(100,30,1,.2,0)
		end
		VfxHandler.Iceyzsz(Root)

		local StartTime = os.clock()

		for Index = 1,18 do
			VfxHandler.FloorFreeze(Root.CFrame * CFrame.new(0,1,-Index * 3.8), 100, 10, 15, nil, 3, Vector3.new(15, 0.989, 15), Character)
			wait()
		end
	end,
	
	["Ice Floor"] = function(PathData)
		local Character = PathData.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		local StartTime = os.clock()

		while os.clock() - StartTime <= .5 do
			VfxHandler.FloorFreeze(Root.CFrame * CFrame.new(0,1,-4), 100, 10, 15, nil, 10, Vector3.new(10, 0.989, 10), Character)
			RunService.RenderStepped:Wait()
		end
	end,
	
	["Ice Sword"] = function(PathData)
		local Character = PathData.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
		
		local StartTime = os.clock()
		
		if PathData.Index == 100 then
			VfxHandler.Shockwave2(Root.CFrame * CFrame.Angles(math.rad(90), 0, 0), Root.CFrame * CFrame.Angles(math.rad(90), 0, 0), BrickColor.new("White"), Vector3.new(15, 1, 15), Vector3.new(0, 1, 0), .25, 0, Enum.EasingStyle.Quad, Color3.fromRGB(255, 255, 255), Enum.Material.Neon, "Rings")
		end		

		--// Circle Slash
		if PathData.Index and PathData.Index == 3 then
			local circleslash = script.circleslash:Clone()
			local one = circleslash.one
			local two = circleslash.two
			local StartSizeOne = Vector3.new(15,15,1)
			local StartSizeTwo = Vector3.new(15,15,2)
			local Multiple = 2

			one.Size = StartSizeOne
			two.Size = StartSizeTwo
			circleslash.Parent = Visuals

			one.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
			two.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)

			Debris:AddItem(circleslash, .5)
			--// PointLight
			local PointLight = Instance.new("PointLight")
			PointLight.Color = Color3.fromRGB(120, 201, 255)
			PointLight.Range = 25
			PointLight.Brightness = 1
			PointLight.Parent = one

			local LightTween = TweenService:Create(PointLight, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Range"] = 0, ["Brightness"] = 0})
			LightTween:Play()
			LightTween:Destroy()

			--// Tween one
			local TweenOne = TweenService:Create(one, TweenInfo.new(.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = one.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(-270)),["Size"] = StartSizeOne * Multiple})
			TweenOne:Play()
			TweenOne:Destroy()

			--// Tween two
			local TweenTwo = TweenService:Create(two, TweenInfo.new(.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = two.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(-270)),["Size"] = StartSizeTwo * Multiple})
			TweenTwo:Play()
			TweenTwo:Destroy()

			wait(.05)

			--// Tween Decals
			for _, v in ipairs(one:GetChildren()) do
				if v:IsA("Decal") then
					local tween = TweenService:Create(v, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
					tween:Play()
					tween:Destroy()
				end	
			end

			for _, v in ipairs(two:GetChildren()) do
				local tween = TweenService:Create(v, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
				tween:Play()
				tween:Destroy()
			end
		elseif PathData.Index == 2 then
			local circleslash = script.circleslash:Clone()
			local one = circleslash.one
			local two = circleslash.two
			local StartSizeOne = Vector3.new(15,15,1)
			local StartSizeTwo = Vector3.new(15,15,2)
			local Multiple = 2

			one.Size = StartSizeOne
			two.Size = StartSizeTwo
			circleslash.Parent = Visuals

			one.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
			two.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)

			Debris:AddItem(circleslash, .5)
			--// PointLight
			local PointLight = Instance.new("PointLight")
			PointLight.Color = Color3.fromRGB(120, 201, 255)
			PointLight.Range = 25
			PointLight.Brightness = 1
			PointLight.Parent = one

			local LightTween = TweenService:Create(PointLight, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Range"] = 0, ["Brightness"] = 0})
			LightTween:Play()
			LightTween:Destroy()

			--// Tween one		
			local TweenOne = TweenService:Create(one, TweenInfo.new(.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = one.CFrame * CFrame.Angles(math.rad(3.36),math.rad(-76.51),math.rad(-12.76)),["Size"] = StartSizeOne * Multiple})
			TweenOne:Play()
			TweenOne:Destroy()

			--// Tween two
			local TweenTwo = TweenService:Create(two, TweenInfo.new(.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = two.CFrame * CFrame.Angles(math.rad(3.36),math.rad(-76.51),math.rad(-12.76)),["Size"] = StartSizeTwo * Multiple})
			TweenTwo:Play()
			TweenTwo:Destroy()

			wait(.05)

			--// Tween Decals
			for _, v in ipairs(one:GetChildren()) do
				if v:IsA("Decal") then
					local tween = TweenService:Create(v, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
					tween:Play()
					tween:Destroy()
				end	
			end

			for _, v in ipairs(two:GetChildren()) do
				local tween = TweenService:Create(v, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
				tween:Play()
				tween:Destroy()
			end
		elseif PathData.Index == 1 then
			local circleslash = script.circleslash:Clone()
			local one = circleslash.one
			local two = circleslash.two
			local StartSizeOne = Vector3.new(15,15,1)
			local StartSizeTwo = Vector3.new(15,15,2)
			local Multiple = 2

			one.Size = StartSizeOne
			two.Size = StartSizeTwo
			circleslash.Parent = Visuals

			one.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
			two.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)

			Debris:AddItem(circleslash, .5)
			--// PointLight
			local PointLight = Instance.new("PointLight")
			PointLight.Color = Color3.fromRGB(120, 201, 255)
			PointLight.Range = 25
			PointLight.Brightness = 1
			PointLight.Parent = one

			local LightTween = TweenService:Create(PointLight, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Range"] = 0, ["Brightness"] = 0})
			LightTween:Play()
			LightTween:Destroy()

			--// Tween one
			local TweenOne = TweenService:Create(one, TweenInfo.new(.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = one.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(270)),["Size"] = StartSizeOne * Multiple})
			TweenOne:Play()
			TweenOne:Destroy()

			--// Tween two
			local TweenTwo = TweenService:Create(two, TweenInfo.new(.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = two.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(270)),["Size"] = StartSizeTwo * Multiple})
			TweenTwo:Play()
			TweenTwo:Destroy()

			wait(.05)

			--// Tween Decals
			for _, v in ipairs(one:GetChildren()) do
				if v:IsA("Decal") then
					local tween = TweenService:Create(v, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
					tween:Play()
					tween:Destroy()
				end	
			end

			for _, v in ipairs(two:GetChildren()) do
				local tween = TweenService:Create(v, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
				tween:Play()
				tween:Destroy()
			end
		end
		
		local CFrameIndex = Character["Right Arm"].CFrame * CFrame.Angles(0, math.rad(90), 0)
		
		local SlashEffect = script.effect:Clone()
		SlashEffect.Parent = workspace.World.Visuals
		SlashEffect.Sparks:Emit(25)
		SlashEffect.IceSmoke:Emit(15)
		
		local ToMultiply = 20
		
		local Number = 0
		local RandomIndex = math.random(45, 90) * ToMultiply
		if _G.FPS > 61 then
			RandomIndex = math.random(150, 190) * (ToMultiply * _G.FPS / 60)
		end
		for Index = 1, 25 * _G.FPS / 60 do
			if RandomIndex <= Number then break end
			SlashEffect.CFrame = SlashEffect.CFrame:lerp(CFrameIndex * CFrame.Angles(0, math.rad(Index * ToMultiply * ToMultiply) * 60 / _G.FPS, 0) * CFrame.new(0, 0, 10), 1);
			Number = Number + Index * ToMultiply * _G.FPS / 60
			RunService.RenderStepped:Wait()
		end
		SlashEffect.IceSmoke.Enabled = false
		SlashEffect.Sparks:Emit(25)
		SlashEffect.IceSmoke:Emit(15)
		SlashEffect.cn.ParticleEmitter:Emit(1)
		Debris:AddItem(SlashEffect, 3)
	end,
	
	["Ice Spear"] = function(PathData)
		local Character = PathData.Character 
		local StartPoint = PathData.StartPoint

		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		local Velocity = 150
		local Lifetime = 5

		-- SoundManager:AddSound("IceSpearThrow",{Parent = Root, Volume = 3},"Client")
		VfxHandler.Iceyzsz(Root)

		local MouseHit = PathData.MouseHit
				
		local SwordClone = script.GilgameshSpear:Clone()
		SwordClone.CFrame = CFrame.new(StartPoint.Position, MouseHit.Position) * CFrame.Angles(math.rad(90),math.rad(90),math.rad(180))
		SwordClone.Parent = workspace.World.Visuals	

		VfxHandler.Shockwave2(Root.CFrame * CFrame.Angles(math.rad(90), 0, 0), Root.CFrame * CFrame.Angles(math.rad(90), 0, 0), BrickColor.new("White"), Vector3.new(15, 1, 15), Vector3.new(0, 1, 0), .25, 0, Enum.EasingStyle.Quad, Color3.fromRGB(255, 255, 255), Enum.Material.Neon, "Rings");
		
		Debris:AddItem(SwordClone,1)

		local Direction = (PathData.MouseHit.Position - SwordClone.Position).Unit

		local Size = SwordClone.Size

		local Points = RaycastService:GetSquarePoints(SwordClone.CFrame, Size.X, Size.X)

		local InitialTween = TweenService:Create(SwordClone, TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false, 0), {["CFrame"] = SwordClone.CFrame * CFrame.new(0, 5,0) * CFrame.fromEulerAnglesXYZ(0, 4, 0)})
		InitialTween:Play()
		InitialTween:Destroy()

		local Animate = TweenService:Create(SwordClone, TweenInfo.new(Lifetime, Enum.EasingStyle.Linear), {["CFrame"] =  SwordClone.CFrame * CFrame.new(0, Velocity * Lifetime,0)})
		Animate:Play()
		Animate:Destroy()

		RaycastService:CastProjectileHitbox({
			Points = Points,
			Direction = Direction,
			Velocity = Velocity,
			Lifetime = Lifetime,
			Iterations = 60,
			Visualize = false,
			Function = function(RaycastResult)
				SwordClone:Destroy()
				Explosions.Spear({Character = Character, RaycastResult = RaycastResult, Spear = SwordClone, Distance = PathData.Distance})
			end,
			Ignore = {Character, workspace.World.Visuals}
		})
	end,
		
	["Ice Stomp"] = function(PathData)
		local Character = PathData.Character 
		local RootPart,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
		
		VfxHandler.Iceyzsz(RootPart)
		
		-- SoundManager:AddSound("FlashFreeze",{Parent = RootPart, Volume = 5.5},"Client")
		
		if GlobalFunctions.CheckDistance(Player, 50) then
			GlobalFunctions.FreshShake(100,30,1,.2,0)
		end
		
		local FlashFreeze = script.FlashFreeze:Clone()
		
		local FatSmoke = script.fatsmoke:Clone()
		FatSmoke.CFrame = RootPart.CFrame * CFrame.new(0,0,-5 * (1 + 3))
		FatSmoke.Parent = workspace.World.Visuals
		delay(1,function()
			FatSmoke.smoke.Enabled = false
		end)
		
		Debris:AddItem(FatSmoke,4)
		
		local Ice = FlashFreeze.Ice
		
		local GoalCFrame = RootPart.CFrame * CFrame.new(0,7,-35) * CFrame.fromEulerAnglesXYZ(0,math.rad(180),0)

		Ice["20"].CFrame = RootPart.CFrame * CFrame.new(0,-8,-15) * CFrame.fromEulerAnglesXYZ(0,math.rad(360),0)
		FlashFreeze.Parent = workspace.World.Visuals

		local Tween = TweenService:Create(Ice["20"], TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["CFrame"] = GoalCFrame})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(FlashFreeze,2.5)

		--// Particle Control
		local One, Two = Ice["1"]:FindFirstChild("IceParticle"), Ice["20"]:FindFirstChild("IceParticle");
		One:Emit(100); Two:Emit(100);

		One,Two = Ice["1"]:FindFirstChild("Sparks"), Ice["20"]:FindFirstChild("Sparks");
		One:Emit(50); Two:Emit(50);

		--// PointLight 
		local PointLight = Instance.new("PointLight")
		PointLight.Range = 50
		PointLight.Parent = Ice["20"]
		
		local Tween = TweenService:Create(PointLight, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Brightness"] = 0})
		Tween:Play()
		Tween:Destroy()
		
		VfxHandler.Spherezsz({
			Cframe = RootPart.CFrame * CFrame.new(0,0,-5 * (1 + 3)), 
			TweenDuration1 = .2, 
			TweenDuration2 = .35, 
			Range = 20, 
			MinThick = 20, 
			MaxThick = 40, 
			Part = nil, 
			Color = Color3.fromRGB(110, 168, 255),
			Amount = 25
		})
		
		coroutine.resume(coroutine.create(function()
			FastWait(.1)
		
			for i, v in ipairs(Ice:GetChildren()) do
				v = Ice:FindFirstChild(tostring(i))
				v.Material = Enum.Material.Ice
				RunService.Heartbeat:Wait()
				RunService.Heartbeat:Wait()
				--RunService.Stepped:Wait()
			end
		end))
		
		--// Ball Effect 
		coroutine.wrap(function()
			for Index = 1,3 do
				local Ball = script.Ball:Clone()
				Ball.Color = Color3.fromRGB(99, 206, 255)
				Ball.Material = Enum.Material.ForceField
				Ball.Transparency = 0
				Ball.Size = Vector3.new(35,35,35)
				Ball.CFrame = RootPart.CFrame * CFrame.new(0,0,-5 * (Index + 3))
				Ball.Parent = workspace.World.Visuals

				local Tween = TweenService:Create(Ball, TweenInfo.new(.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Transparency"] = 1, ["Size"] = Vector3.new(60,60,60)})
				Tween:Play()
				Tween:Destroy()
				Debris:AddItem(Ball, .2)
				--
				local cs = script.Ring2:Clone()
				cs.Size = Vector3.new(15, 2, 15)
				local c1,c2 = RootPart.CFrame*CFrame.new(0,0,-1) * CFrame.Angles(math.pi / 2,0,0) ,RootPart.CFrame * CFrame.new(0,0,-50) * CFrame.Angles(math.pi/2,0,0) 
				cs.CFrame = c1
				cs.Material = Enum.Material.Neon
				cs.Parent = workspace.World.Visuals

				local Tween = TweenService:Create(cs,TweenInfo.new(0.35,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0),{["Transparency"] = 1, ["Size"] = Vector3.new(25 + (Index * 10),0,25 + (Index * 10)), ["CFrame"] = c2})
				Tween:Play()
				Tween:Destroy()

				Debris:AddItem(cs,.15)
				wait(.1)
			end
		end)()

		local Tween = TweenService:Create(Ice["20"], TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["CFrame"] = GoalCFrame * CFrame.new(0,0,2)})
		Tween:Play()
		Tween:Destroy()

		for i, v in ipairs(Ice:GetChildren()) do
			v = Ice:FindFirstChild(tostring(i))
			local Tween = TweenService:Create(v, TweenInfo.new(.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Transparency"] = 0})
			Tween:Play()
			Tween:Destroy()
		end
		for i, v in ipairs(Ice:GetChildren()) do
			v = Ice:FindFirstChild(tostring(i))
			v.Material = Enum.Material.Ice
			wait() ---RunService.Heartbeat:Wait()
		end
		wait(1.5)

		--//
		for i, v in ipairs(Ice:GetChildren()) do
			if (v.Name ~= "15") and (v.Name ~= "14") and (v.Name ~= "1") then
				-- SoundManager:AddSound("icey",{Parent = RootPart, Volume = .125},"Client")
				
				coroutine.wrap(function()
					wait()
					v = Ice:FindFirstChild(tostring(v))
					
					if v.Name ~= "17" and v.Name ~= "18" and v.Name ~= "19" and v.Name ~= "20" and v.Name ~= "16" and v.Name ~= "15" and v.Name ~= "14" then
						local Tween = TweenService:Create(v, TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Size"] = Vector3.new(0,0,0),["Transparency"] = 1})
						Tween:Play()
						Tween:Destroy()
					else
						coroutine.wrap(function()
							wait(.125)
							
							local Tween = TweenService:Create(v, TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Size"] = Vector3.new(0,0,0),["Transparency"] = 1})
							Tween:Play()
							Tween:Destroy()
							
							-- SoundManager:AddSound("icey",{Parent = RootPart, Volume = .1},"Client")
						end)()
					end
					
					v.Material = Enum.Material.Glass				
					RunService.Stepped:Wait()
				end)()		
			else
				local Tween = TweenService:Create(v, TweenInfo.new(.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Transparency"] = 1})
				Tween:Play()
				Tween:Destroy()
				
				local Tween = TweenService:Create(v, TweenInfo.new(.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {["Size"] = Vector3.new(0,0,0)})
				Tween:Play()
				Tween:Destroy()
			end
		end		
	end
}
return AokijiVFX