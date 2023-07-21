--|| Services ||--
local Players = game:GetService("Players")

local ServerStorage = game:GetService("ServerStorage")
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
local VfxHandler = require(Effects.VfxHandler)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local AbilityData = require(Metadata.AbilityData.AbilityData)

local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)

local DamageManager = require(Managers.DamageManager)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)

local SoundManager = require(Shared.SoundManager)

local HitboxModule = require(script.Parent.Parent.Combat.Combat.HitboxModule)

local RaycastManager = require(Shared.RaycastManager)
local TaskScheduler = require(Utility.TaskScheduler)

local Ragdoll = require(ServerStorage.Modules.Ragdoll)

local World = workspace.World

local ProfileService = require(Server.ProfileService)

local Effects = Assets.Effects
local Trails = Effects.Trails

local HakiDodge = 0;

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

local CreateFrameData = { Size = UDim2.new(1,0,1,0); Position = UDim2.new(0,0,0,0);	Color = Color3.fromRGB(255, 221, 82); Duration = .5}

local function RaycastTarget(Radius,Character)
	local MouseHit = MouseRemote:InvokeClient(Players:GetPlayerFromCharacter(Character))	

	local Root = Character:FindFirstChild("HumanoidRootPart")

	local RayParam = RaycastParams.new()
	RayParam.FilterDescendantsInstances = { Character, workspace.World.Visuals }
	RayParam.FilterType = Enum.RaycastFilterType.Exclude

	local RaycastResult = workspace:Raycast(Root.Position, (MouseHit.Position - Root.Position).Unit * Radius, RayParam)
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

local Katakuri = {
	["FirstAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
		
		local Mouse = MouseRemote:InvokeClient(Player)
		if (Root.Position - Mouse.Position).Magnitude >= 35 then return end		
		
		StateManager:ChangeState(Character,"Attacking",2)
		AnimationRemote:FireClient(Player,"FlowingMochi","Play")
		
		wait(.45)
		if StateManager:Peek(Character,"Stunned") then return end
		
		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})	
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
		
		--[[ Fire Client ]]--
		local StartPosition = Character.HumanoidRootPart.Position
		local Range = 1000;
		local MouseHit = MouseRemote:InvokeClient(Player)
		local GoalPosition = (MouseHit.Position - StartPosition).Unit * Range
		local EndPosition;

		local RayData = RaycastParams.new()
		RayData.FilterDescendantsInstances = {Character, World.Live, World.Visuals} or World.Visuals
		RayData.FilterType = Enum.RaycastFilterType.Exclude
		RayData.IgnoreWater = true

		local ray = workspace:Raycast(StartPosition, GoalPosition, RayData)
		--[[ new Bezier ]]--
		if ray then
			--[[ Set Ray Variables ]]--
			local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
			if partHit then
				--[[ Fire Client ]]--						
				NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Distance = 100, ContactPoint = pos, Module = "KatakuriVFX", Function = "FlowingMochi"})
				wait(.2)
				local ValidEntities = RaycastManager:GetEntitiesFromPoint(pos, workspace.World.Live:GetChildren(), {[Character] = true}, 25)
				for Index = 1, #ValidEntities do
					local Entity = ValidEntities[Index]

					DamageManager.DeductDamage(Character,Entity,KeyData.SerializedKey,CharacterName, {Type = "Combat"})

					local BodyVelocity = Instance.new("BodyVelocity")
					BodyVelocity.Velocity = Vector3.new(0,35,math.random(1,2) == 1 and -15 or 15)
					BodyVelocity.MaxForce = Vector3.new(100000,100000,100000)
					BodyVelocity.Parent = Entity.PrimaryPart

					Debris:AddItem(BodyVelocity,.3)
					Ragdoll.DurationRagdoll(Entity, 1)	
				end				
			end
			SpeedManager.changeSpeed(Character,6,1,4) --function(Character,Speed,Duration,Priority)
			StateManager:ChangeState(Character,"Stunned",1)	
		end	
	end,

	["SecondAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		StateManager:ChangeState(Character,"IFrame",.35)
		StateManager:ChangeState(Character,"Stunned",4e4)
		AnimationRemote:FireClient(Player,"MoguraFlow","Play")

		local Data = ProfileService:GetPlayerProfile(Player)
		if Data.Character == "Katakuri" then
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		end

		wait(.35)
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KatakuriVFX", Function = "MoguraFlow"})
		for Index = 1,7 do
			-- SoundManager:AddSound("BarrageSwing", {Parent = Root, Volume = 3, PlaybackSpeed = 1.4}, "Client")
			local HitResult,HitObject = HitboxModule.MagnitudeModule(Character, {Delay = 0, Range = 5, KeysLogged = math.random(1,3), Type = "Combat"}, KeyData.SerializedKey, CharacterName)
			if HitResult then
				local Victim = HitObject.Parent

				local VRoot,VHum = Victim:FindFirstChild("HumanoidRootPart"),Victim:FindFirstChild("Humanoid")
				CameraRemote:FireClient(Player,"CameraShake",{ FirstText = 1, SecondText = 5})

				-- SoundManager:AddSound("Punched1",{Parent = Character:FindFirstChild("HumanoidRootPart"),Volume = 5},"Client")

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
				BodyVelocity.Velocity = (VRoot.CFrame.p - Root.CFrame.p).Unit * 8
				BodyVelocity.Parent = Root
				Debris:AddItem(BodyVelocity,.25)					

				local Look = CFrame.new(VRoot.Position,Root.Position).lookVector

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,0,4e4)
				BodyVelocity.Velocity = Look * -10
				BodyVelocity.Parent = VRoot
				Debris:AddItem(BodyVelocity,.2)					
			end
			wait(.125)
		end
		StateManager:ChangeState(Character,"Stunned",.2)
		SpeedManager.changeSpeed(Character,0,.2,3) --function(Character,Speed,Duration,Priority)	
	end,

	["ThirdAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})		
		
        StateManager:ChangeState(Character,"IFrame",.35)	
		StateManager:ChangeState(Character,"Guardbroken",3)
		
		AnimationRemote:FireClient(Player,"MochiRoll","Play")
		NetworkStream.FireClientDistance(Character,"ClientRemote",1000,{Character = Character, Module = "KatakuriVFX", Function = "MochiRoll"})

		local BodyPosition = Instance.new("BodyPosition")
		BodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		BodyPosition.P = 200
		BodyPosition.D = 25
		BodyPosition.Position = (Root.CFrame * CFrame.new(0,25,-25)).Position
		BodyPosition.Parent = Root
		
		Debris:AddItem(BodyPosition, 0.25)
		
		wait(.35)
		local Donut = ReplicatedStorage.Assets.Models.Misc.Donut:Clone()
		Donut.Size = Vector3.new(5, 15, 15)
		Donut.CFrame = Root.CFrame * CFrame.new(0,5,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
		Donut.Transparency = 1
		Donut.Parent = World.Visuals

		local Weld = Instance.new("Motor6D")
		Weld.Part0 = Root
		Weld.Part1 = Donut
		Weld.C0 = CFrame.new(0,3,0)
		Weld.Parent = Donut
		Debris:AddItem(Weld, 3)

		Donut.Anchored = false
						
		local Data = AbilityData.ReturnData(Player,"ThirdAbility","Katakuri")

		Donut.Touched:Connect(function(Hit)
			if Hit:IsDescendantOf(workspace.World.Live) and Hit.Parent:FindFirstChild("Humanoid") and not Hit:IsDescendantOf(Character) and not Data.HitDebounce then					
				DamageManager.DeductDamage(Character,Hit.Parent,KeyData.SerializedKey,CharacterName,{Type = "Combat"})
				Data.HitDebounce = true
				coroutine.wrap(function()
					wait(.1)
					Data.HitDebounce = false
				end)()
			end
		end)
		
		while Weld.Parent do
			if StateManager:Peek(Character,"Stunned") then
				Weld:Destroy()
				Donut:Destroy()

				StateManager:ChangeState(Character,"Guardbroken",.01)
				ClientRemote:FireAllClients{Character = Character, Module = "KatakuriVFX", Function = "RemoveMoichiRoll"}

				SpeedManager.changeSpeed(Character,6,1,4) --function(Character,Speed,Duration,Priority)
				StateManager:ChangeState(Character,"Stunned",1)	
			end
			RunService.Heartbeat:Wait()
		end
		AnimationRemote:FireClient(Player,"MochiRoll","Stop")
	end,
		
	["FourthAbility"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
		
		--SpeedManager.changeSpeed(Character,2,1.35,5) --function(Character,Speed,Duration,Priority)
		
		local IFrameDuration = 2.5 -- set to what u want wunbo san >.<
		
		StateManager:ChangeState(Character, "IFrame" , IFrameDuration, {IFrameType = "ObservationHaki"})
		
		local One = Trails.ObservationHaki:Clone()
		One.Parent = Character["Head"]

		local Two = Trails.ObservationHaki:Clone()
		Two.Parent = Character["Head"]
		for i = 1,3 do
			local Attachment = Instance.new("Attachment")
			Attachment.Parent = Character["Head"]
			if i == 1 then
				Attachment.Position = Vector3.new(0, 0, -0.5)
				One.Attachment0 = Attachment
				Two.Attachment0 = Attachment
			elseif i == 2  then
				Attachment.Position = Vector3.new(0.4, 0, -0.5)
				One.Attachment1 = Attachment
			else
				Attachment.Position = Vector3.new(-0.4, 0, -0.5)
				Two.Attachment1 = Attachment
			end
		end
		
		Debris:AddItem(One, IFrameDuration)
		Debris:AddItem(Two, IFrameDuration)
		
		-- SoundManager:AddSound("KatakuriHaki",{Parent = Character:FindFirstChild("HumanoidRootPart"), TimePosition = 0.35, Volume = 2},"Client")
	end;
	
	["ObservationHaki"] = function(Data)
		-- do ur magic here wunbo chan
		local Character = Data.Character
		local Victim = Data.Victim
		
		local Player = Players:FindFirstChild(Character.Name)
		--[[Server Effects here/ Camera shake to client]]--
		
		local direction = "Back"; 
		HakiDodge += 1
		
		local DirectionList = {"Left", "Right", "Back"}
	--	if HakiDodge == 1 then
		--	direction = "Right"
		--elseif HakiDodge == 2 then
		--	direction = "Left"
		--else
		--	HakiDodge = 0
		--end	
		AnimationRemote:FireClient(Player,"Observation"..DirectionList[math.random(1,#DirectionList)], "Play",{AdjustSpeed = 1})
		NetworkStream.FireClientDistance(Character,"ClientRemote",50,{Character = Character, Module = "KatakuriVFX", Function = "Foresight"})
	end,
}

return Katakuri