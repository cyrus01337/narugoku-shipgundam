--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Directories ||--
local Server = ServerScriptService.Server

local Managers = Server.Managers

local Modules = ReplicatedStorage.Modules
local Assets = ReplicatedStorage.Assets

local State = Server.State

local Effects = Modules.Effects
local Shared = Modules.Shared
local Metadata = Modules.Metadata
local Utility = Modules.Utility

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local AbilityData = require(Metadata.AbilityData.AbilityData)

local VfxHandler = require(Effects.VfxHandler)

local AbilityData = require(Metadata.AbilityData.AbilityData)

local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)

local DamageManager = require(Managers.DamageManager)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)

local SoundManager = require(Shared.SoundManager)
local RaycastManager = require(Shared.RaycastManager)

local TaskScheduler = require(Utility.TaskScheduler)

local ProfileService = require(Server.ProfileService)

local ShurikenThrow = require(script.ShurikenThrow)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

local function RaycastTarget(Radius,Character)
	local MouseHit = MouseRemote:InvokeClient(Players:GetPlayerFromCharacter(Character))

	local Root = Character:FindFirstChild("HumanoidRootPart")
	local RayParam = RaycastParams.new()
	RayParam.FilterDescendantsInstances = { Character, workspace.World.Visuals }
	RayParam.FilterType = Enum.RaycastFilterType.Exclude

	local RaycastResult = workspace:Raycast(Root.Position, (MouseHit.Position - Root.Position).Unit * Radius, RayParam) or {}
	local Target, Position = RaycastResult.Instance, RaycastResult.Position 

	if Target and Target:FindFirstAncestorWhichIsA("Model"):FindFirstChild("Humanoid") then
		local Victim = Target:FindFirstAncestorWhichIsA("Model")
		if Victim ~= Character then
			return Victim,Position or nil
		end
	end
end

local function GetNearestFromMouse(Character, Range)
	local MouseHit = MouseRemote:InvokeClient(Players:GetPlayerFromCharacter(Character))

	for _, Entity in ipairs(workspace.World.Live:GetChildren()) do
		if Entity:IsA("Model") and GlobalFunctions.IsAlive(Entity) and Entity ~= Character then
			local EntityPrimary = Entity:FindFirstChild("HumanoidRootPart")
			local Distance = (MouseHit.Position - EntityPrimary.Position).Magnitude

			if Distance <= Range then
				return Entity or nil
			end
		end
	end
end

local CameraData = {
	LifeTime = .15;
	EasingStyle = Enum.EasingStyle.Linear;
	EasingDirection = Enum.EasingDirection.Out;
	Return = true;
	Properties = {FieldOfView = 80}
}

local Itachi = {
	["FirstAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		AnimationRemote:FireClient(Player,"Fireball Jutsu","Play")

		-- local Sound = SoundManager:AddSound("Handsigns",{Parent = Root},"Client")
		StateManager:ChangeState(Character,"Attacking",Sound.TimeLength + .35)

		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)

		TaskScheduler:AddTask(Sound.TimeLength,function()
			if StateManager:Peek(Character,"Stunned") then return end

			CameraRemote:FireClient(Player,"TweenObject",CameraData)
			-- local Sound = SoundManager:AddSound("Release",{Parent = Root},"Client")

			local Velocity = 200
			local Lifetime = 10

			NetworkStream.FireClientDistance(Character,"ClientRemote",200,{
				Character = Character,

				Module = "ItachiVFX",
				Function = "Fireball Jutsu",

				Velocity = Velocity,
				Lifetime = Lifetime,
			})

			wait(.35)
			local StartPoint = Root.CFrame * CFrame.new(0,-1,0)

			local Size = Assets.Models.Misc.Volleyballs.volleyball2.Size

			local Points = RaycastManager:GetSquarePoints(StartPoint, Size.X * 2, Size.X * 2)

			local MouseHit = MouseRemote:InvokeClient(Player)
			local Direction = (MouseHit.Position - StartPoint.Position).Unit

			local Direction = (Root.CFrame * CFrame.new(0,0,-4e4).Position - StartPoint.Position).Unit

			RaycastManager:CastProjectileHitbox({
				Points = Points,
				Direction = Direction,
				Velocity = Velocity,
				Lifetime = Lifetime,
				Iterations = 75,
				Visualize = false,
				Function = function(RaycastResult)
					local ValidEntities = RaycastManager:GetEntitiesFromPoint(RaycastResult.Position, workspace.World.Live:GetChildren(), {[Character] = true}, 8)
					for Index = 1, #ValidEntities do
						local Entity = ValidEntities[Index]
						local VRoot = Entity:FindFirstChild("HumanoidRootPart")
						local EnemyHumanoid = Entity:FindFirstChild("Humanoid")

						VfxHandler.FireProc({Character = Character, Victim = Entity, Damage = .5, Duration = 5})
						DamageManager.DeductDamage(Character,Entity,KeyData.SerializedKey,CharacterName,{Type = "Combat"})
					end
				end,
				Ignore = {Character, workspace.World.Visuals}
			})
		end)
	end,

	["SecondAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)

		local ChidoriValue = GlobalFunctions.NewInstance("NumberValue",{Value = 0,Parent = Character},4)
		StateManager:ChangeState(Character,"Attacking",4)

		-- SoundManager:AddSound("ChidoriItachi",{Parent = Root, Volume = 5}, "Client")

		AnimationRemote:FireClient(Player,"ChidoriStart","Play")
		-- SoundManager:AddSound("Chidori",{Parent = Root, Volume = .8}, "Client")

		ClientRemote:FireAllClients{Character = Character, Module = "ItachiVFX", Function = "Chidori"}
		CameraRemote:FireClient(Player, "CreateBlur", {Size = 25; Length = .5})
		Root.Anchored = true
		Humanoid.WalkSpeed = 30

		StateManager:ChangeState(Character,"IFrame",.5, {IFrameType = ""})

		wait(.5)
		Root.Anchored = false
		Humanoid.WalkSpeed = 30
		AnimationRemote:FireClient(Player,"ChidoriStart","Stop")

		local Clone = ReplicatedStorage.Assets.Effects.Meshes.ChidoriHitbox:Clone()
		Clone.Transparency = 1
		Clone.Parent = Character
		Clone.Weld.Part0 = Character["Right Arm"]

		Debris:AddItem(Clone,4)

		local Connection; Connection = Clone.Touched:Connect(function(Hit)
			if not Hit:IsDescendantOf(Character) and Hit:IsDescendantOf(workspace.World.Live) then
				if Hit.Parent:FindFirstChild("Humanoid") and Hit.Parent.Humanoid.Health > 0 then
					local Victim = Hit.Parent
					local VHum,VRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")

					Humanoid.WalkSpeed = 3
					VHum.WalkSpeed = 2
					StateManager:ChangeState(Character,"Attacking",2)
					StateManager:ChangeState(Victim,"Attacking",1.5)
					StateManager:ChangeState(Character,"IFrame",.8, {IFrameType = ""})

					GlobalFunctions.NewInstance("BoolValue",{Parent = Character, Name = "BreakChidoriClient"},1)
					AnimationRemote:FireClient(Player,"ChidoriAttack","Play")

					local Weld = Instance.new("Weld")
					Weld.Part0 = Root
					Weld.Part1 = VRoot
					Weld.C0 = CFrame.new(0,0,-3.05) * CFrame.Angles(0,math.rad(-180),0)
					Weld.Parent = VRoot

					Humanoid.AutoRotate = false

					coroutine.wrap(function()
						wait(.5)
						-- SoundManager:AddSound("CombatSwing",{Parent = Root, Volume = 2},"Client")

						AnimationRemote:FireClient(Player,"ChidoriAttack","Stop")
						AnimationRemote:FireClient(Player,"ChidoriAttackEnd","Play")
						Debris:AddItem(Weld,.35)

						wait(.2)
						ClientRemote:FireAllClients{Character = Character, Victim = Victim, Module = "ItachiVFX", Function = "ChidoriHit"}
						Weld:Destroy()
						DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{Type = "Combat"})
						Humanoid.WalkSpeed = 14
						VHum.WalkSpeed = 14
						Humanoid.AutoRotate = true
					end)()
					Clone:Destroy()

					Connection:Disconnect()
					Connection = nil
				end
			end
		end)

		local ValueConnection; ValueConnection = ChidoriValue:GetPropertyChangedSignal("Value"):Connect(function()
			if ChidoriValue.Value == 1 then
				AnimationRemote:FireClient(Player,"ChidoriStart","Play")
			elseif ChidoriValue.Value == 2 then
				AnimationRemote:FireClient(Player,"ChidoriStart","Stop")
				AnimationRemote:FireClient(Player,"ChidoriRun","Play",{Looped = true})
			end
		end)

		local StartTime = os.clock()

		while os.clock() - StartTime <= 3.35 and not Character:FindFirstChild("BreakChidoriClient") do
			if Humanoid.MoveDirection == Vector3.new() then
				ChidoriValue.Value = 1
				SpeedManager.changeSpeed(Character,14,.35,6e6) --function(Character,Speed,Duration,Priority)
			else
				ChidoriValue.Value = 2
				SpeedManager.changeSpeed(Character,32,.35,6e6) --function(Character,Speed,Duration,Priority)
			end
			if Character:FindFirstChild("BreakChidoriClient") then
				break
			end
			RunService.Heartbeat:Wait()
		end
		Humanoid.WalkSpeed = 14
		StateManager:ChangeState(Character,"Attacking",.1)
		ChidoriValue:Destroy()

		AnimationRemote:FireClient(Player,"ChidoriRun","Stop")
		delay(.1,function() AnimationRemote:FireClient(Player,"ChidoriStart","Stop") end)

		ValueConnection:Disconnect()
		ValueConnection = nil
	end,

	["ThirdAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData,Modules)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		local ItachiData = AbilityData.ReturnData(Player,"ThirdAbility","Itachi")

		if ItachiData.StoredSkill == "" then
			local Victim = RaycastTarget(80,Character) or GetNearestFromMouse(Character,8)
			if not Victim then return end

			if StateManager:Peek(Victim,"Blocking") then return end

			local VictimPlayer = Players:GetPlayerFromCharacter(Victim) or warn"no valid player"
			local VHum,VRoot = Victim:FindFirstChild("Humanoid"),Victim:FindFirstChild("HumanoidRootPart")

			local Data = ProfileService:GetPlayerProfile(VictimPlayer)

			local SkillData = StateManager:ReturnData(Victim,"LastAbility")
			local CopiedData = AbilityData.ReturnData(Player,SkillData.Skill,Data.Character)

			ItachiData.CopiedSkillData = CopiedData

			if ItachiData.CopiedSkillData and ItachiData.CopiedSkillData.Copyable and ItachiData.CopiedSkillData.Copyable == true then
				ItachiData.Cooldown = 3

				CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
				DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)

				CameraRemote:FireClient(Player,"Sharingan")
				CameraRemote:FireClient(VictimPlayer,"Sharingan")

				local CharacterIndex = VictimPlayer and Data.Character or Victim.Name

				ItachiData.CopiedSkillData = CopiedData
				ItachiData.StoredSkill = SkillData.Skill
				ItachiData.SharinganContact = Data.Character

				-- SoundManager:AddSound("SharinganItachi",{Parent = Root, Volume = 3.5, Looped = true}, "Client", {Duration = 1})
				-- SoundManager:AddSound("SharinganActivate",{Parent = Root, Volume = .5}, "Client")
			end
		else
			local CacheModule = Modules[ItachiData.SharinganContact][ItachiData.StoredSkill]

			local SkillData = AbilityData.ReturnData(Player,ItachiData.StoredSkill,ItachiData.SharinganContact)
			local CopiedData = AbilityData.ReturnData(Player,ItachiData.StoredSkill,ItachiData.SharinganContact)

			ItachiData.Cooldown = ItachiData.CopiedSkillData.Cooldown

			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)

			CacheModule(Player,ItachiData.SharinganContact,{
				SerializedKey = ItachiData.StoredSkill,
				KeyName = ItachiData.StoredSkill == "FirstAbility" and "Z" or ItachiData.StoredSkill == "SecondAbility" and "X" or ItachiData.StoredSkill == "ThirdAbility" and "C" or "V"
			},SkillData,ExtraData)

			ItachiData.StoredSkill = ""
			ItachiData.SharinganContact = ""
			--StateManager:ChangeState(Character,"Copied",1)
		end
	end,

	["FourthAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)

		if not Humanoid:GetState() == Enum.HumanoidStateType.Landed and Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then return end

		AnimationRemote:FireClient(Player,"ShurikenThrow","Play")
		StateManager:ChangeState(Character,"Guardbroken",1)

		TaskScheduler:AddTask(.2,function()
			Humanoid.Jump = true
		end)

		wait(.5)
		CameraRemote:FireClient(Player, "CameraShake", {FirstText = 2, SecondText = 6})
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "ItachiVFX", Function = "Shuriken"})

		local ItachiData = AbilityData.ReturnData(Player,"FourthAbility","Itachi")
		ItachiData.Falling = Humanoid:GetState() == Enum.HumanoidStateType.Freefall and true or false

		local _ = ItachiData.Falling and GlobalFunctions.NewInstance("BodyVelocity",{Parent = Root, MaxForce = Vector3.new(100000000, 100000000, 100000000), Velocity = Vector3.new(0,20,0)},.15)

		SpeedManager.changeSpeed(Character,4,1.5,3) --function(Character,Speed,Duration,Priority)

		coroutine.wrap(function()
			for Index = 1,3 do
				wait(.05)
				-- local Sound = SoundManager:AddSound("ShurikenThrow",{Parent = Root, Pitch = math.random(14,15) / 10}, "Client")
				-- Sound.Pitch = Index >= 2 and math.random(14,15) / 10 or Sound.Pitch
			end
		end)()

		for Index = 1,3 do
			if Index >= 2 then
				ItachiData.Spread = 2.6
			end
			if ExtraData.Victim == nil then ExtraData.Victim = nil end
			if ExtraData.Victim then ItachiData.Spread = 2.6 end

			ShurikenThrow.Activate(Character,ExtraData.MouseHit,ItachiData.Spread,ExtraData.Victim,{KeyData = KeyData, CharacterName = CharacterName})
		end
	end
}

return Itachi
