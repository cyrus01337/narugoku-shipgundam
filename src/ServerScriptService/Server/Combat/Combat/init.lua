--|| Services |--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local MarketPlaceService = game:GetService("MarketplaceService")

--|| Directories ||--
local Server = ServerScriptService.Server
local Managers = Server.Managers

local Modules = ReplicatedStorage.Modules
local State = Server.State

local Effects = Modules.Effects
local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Shared = Modules.Shared
local CharacterData = Metadata.CharacterData

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)

local SoundManager = require(Shared.SoundManager)

local AbilityData = require(Metadata.AbilityData.AbilityData)
local CombatData = require(Metadata.CombatData.CombatData)

local CharacterInfo = require(CharacterData.CharacterInfo)

local VfxHandler = require(Effects.VfxHandler)

local StandManager = require(Managers.StandManager)
local ProfileService = require(Server.ProfileService)

local DashTypes = require(script.DashTypes)
local HitboxModule = require(script.HitboxModule)
local Aerial = require(script.Aerial)
local SwingVariations = require(script.SwingVariations)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote

--|| Variables ||--
local CharacterModules = {}

for _,Module in ipairs(Server.Characters:GetDescendants()) do
	if Module:IsA("ModuleScript") then
		CharacterModules[Module.Name] = require(Module)
	end
end 

--|| Functions ||--
local function RemoveTrash(Trash)
	for Index = 1,#Trash do
		local Item = Trash[Index]
		if Item and Item.Parent then
			Item:Destroy()
		end
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Map}
raycastParams.FilterType = Enum.RaycastFilterType.Include

local CameraData = {Size = 30, Length = .25}

local Combat = {

	["Run"] = {
		["Execute"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
			local Character = Player.Character
			local Humanoid,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

			if not StateManager:Peek(Character,"Emoting") then return end

			StateManager:ChangeState(Character, "Running", true)

			if Humanoid.MoveDirection == Vector3.new() then return end
			local Data = ProfileService:GetPlayerProfile(Player)
			
			local HasCombat = CharacterInfo[Data.Character]["Combat"]
			local WhichRunAnimation = HasCombat and "Running" or "SwordRunning"

			AnimationRemote:FireClient(Player,WhichRunAnimation,"Play", {Looped = true, Weight = 8, FadeTime = 1.5})

			local ModeData = StateManager:ReturnData(Character, "Mode")
			local SkillData = StateManager:ReturnData(Character,"LastSkill")

			local SpeedIndex = Data.Character == "Killua" and ModeData.Mode and 35 or ModeData.Mode and 30 or 28
			Humanoid.WalkSpeed = SpeedIndex

			StateManager:ChangeState(Character, "Running", true)
			CameraRemote:FireClient(Player,"ChangeCameraType",true)

			while StateManager:Peek(Character,"Running") do
				local SkillData = StateManager:ReturnData(Character,"LastSkill")
				if not StateManager:Peek(Character,"Blocking") and StateManager:Peek(Character,"Dashing") then
					Humanoid.WalkSpeed = SpeedIndex
				end

				if Humanoid.MoveDirection == Vector3.new() or not StateManager:Peek(Character,"Attacking") or StateManager:Peek(Character,"Stunned") or SkillData.Skill == "Swing" or not StateManager:Peek(Character,"Guardbroken") then -- or SkillData.Skill == "Block" then
					StateManager:ChangeState(Character, "Running", false)
					CameraRemote:FireClient(Player,"ChangeCameraType",false)

					AnimationRemote:FireClient(Player,WhichRunAnimation,"Stop")
					Humanoid.WalkSpeed = 14
					break 
				end
				RunService.Heartbeat:Wait()
			end 
			CameraRemote:FireClient(Player,"ChangeCameraType",false)
		end,

		["Terminate"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
			local Character = Player.Character
			local Humanoid,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")
			
			local Data = ProfileService:GetPlayerProfile(Player)

			local HasCombat = CharacterInfo[Data.Character]["Combat"]
			local WhichRunAnimation = HasCombat and "Running" or "SwordRunning"

			StateManager:ChangeState(Character, "Running", false)

			AnimationRemote:FireClient(Player,WhichRunAnimation,"Stop")
			Humanoid.WalkSpeed = 14 
			
			CameraRemote:FireClient(Player,"ChangeCameraType",false)
			local _ = Character:FindFirstChild(WhichRunAnimation) and Character.Running:Destroy()
		end,
	},

	["Block"] = {

		["Execute"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
			local Character = Player.Character
			local Humanoid,Root  = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

			local Data = ProfileService:GetPlayerProfile(Player)	
			local HasCombat = CharacterInfo[Data.Character]["Combat"]

			local HasStand = Character:FindFirstChild(Character.Name.." - Stand")
			
			local PlayerCombo = AbilityData.ReturnData(Player,"PlayerCombos","GlobalInformation")
			local SkillData = CombatData.ReturnData(Player,"Block")
			
			local TimeIndex = os.clock() - PlayerCombo.BlockStartTime <= 1.35 and true or false
			SkillData.CanParry = TimeIndex
			
			PlayerCombo.BlockStartTime = os.clock()
			
			StateManager:ChangeState(Character, "Blocking" ,true, {AllowedSkills = {["Dash"] = true}, IsBlocking = true})
			StateManager:ChangeState(Character,"Attacking", 0, {AllowedSkills = {["Dash"] = true}})
			
			local WhichRunAnimation = HasCombat and "Running" or "SwordRunning"

			local _ = StateManager:Peek(Character,"Running") and AnimationRemote:FireClient(Player,WhichRunAnimation,"Stop") and Character:FindFirstChild("Running") and Character.Running:Destroy()
			
			coroutine.wrap(function()
				while StateManager:Peek(Character,"Blocking") do
					if StateManager:Peek(Character,"Dashing") then				
						Humanoid.WalkSpeed = 5
						Humanoid.JumpPower = 35						
					end	
					RunService.Heartbeat:Wait()
				end
				local _ = StateManager:Peek(Character,"Running") and AnimationRemote:FireClient(Player,WhichRunAnimation,"Play", {Looped = true}) and GlobalFunctions.NewInstance("BoolValue",{Parent = Character, Name = "Running"})
			end)()

			if HasStand then 
				local Weld = HasStand.PrimaryPart.Weld
				local StandHum = HasStand:FindFirstChild("Humanoid")		

				StandHum:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Combat.Block.BlockIdle):Play()

				local StandData = StateManager:ReturnData(Character,"StandAttack")

				GlobalFunctions.TweenFunction({
					["Instance"] = Weld,
					["EasingStyle"] = Enum.EasingStyle.Exponential,
					["EasingDirection"] = Enum.EasingDirection.Out,
					["Duration"] = .4,
				},{
					["C0"] = StandData.InStand
				})
				return
			end

			local DifferentBlock = CharacterInfo[Data.Character]["BlockAnimation"]
			
			local AnimationIndex = DifferentBlock or not HasCombat and "SwordBlockIdle" or "BlockIdle"
			AnimationRemote:FireClient(Player,AnimationIndex,"Play",{Looped = true})
			
			--local _ = not HasCombat and NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Module = "SwordVFX", Function = "AppearSword"}) 

			--local _  = (HasCombat and AnimationRemote:FireClient(Player, "BlockIdle", "Play", {Looped = true})) or (not HasCombat and AnimationRemote:FireClient(Player, "SwordBlockIdle", "Play", {Looped = true}))	
		end,

		["Terminate"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
			local Character = Player.Character
			local Humanoid,Root  = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

			local Data = ProfileService:GetPlayerProfile(Player)			
			local HasCombat = CharacterInfo[Data.Character]["Combat"]

			local HasStand = Character:FindFirstChild(Character.Name.." - Stand")

			Humanoid.WalkSpeed = 14
			Humanoid.JumpPower = 50

			StateManager:ChangeState(Character, "Blocking", false, {BlockVal = 1000, IsBlocking = false})

			--StateManager:ChangeState(Character,"Attacking",0)

			if HasStand then 
				local Weld = HasStand.PrimaryPart.Weld
				local StandHum = HasStand:FindFirstChild("Humanoid")		

				for _,Animation in ipairs(StandHum:GetPlayingAnimationTracks()) do
					if Animation.Name == "BlockIdle" then
						Animation:Stop()
						break
					end
				end

				local StandData = StateManager:ReturnData(Character,"StandAttack")

				GlobalFunctions.TweenFunction({
					["Instance"] = Weld,
					["EasingStyle"] = Enum.EasingStyle.Exponential,
					["EasingDirection"] = Enum.EasingDirection.Out,
					["Duration"] = .4,
				},{
					["C0"] = StandData.OutStand
				})
				return
			end

			local DifferentBlock = CharacterInfo[Data.Character]["BlockAnimation"]

			local AnimationIndex = DifferentBlock or not HasCombat and "SwordBlockIdle" or "BlockIdle"
			AnimationRemote:FireClient(Player,AnimationIndex,"Stop")
			
			--local _ = not HasCombat and NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Module = "SwordVFX", Function = "HideSword"}) 
			--local _ = (HasCombat and AnimationRemote:FireClient(Player, "BlockIdle", "Stop")) or (not HasCombat and AnimationRemote:FireClient(Player, "SwordBlockIdle", "Stop"))	
		end,

	},

	["Mode"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

		local ModeData = StateManager:ReturnData(Character, "Mode")
		local CombatCopy = CombatData.ReturnData(Character,"Dash")

		local ModeNumber = Player:WaitForChild("Mode")
		local ModeBoolean = ModeNumber and ModeNumber.ModeBoolean
		local Stats = Player:WaitForChild("leaderstats")
		local Points = Stats and Stats.Points 

		if ModeBoolean.Value then return end
		if ModeNumber.Value <= ModeData.MaxModeValue then return end
		local LastRemovedSecond = os.clock()

		local Data = ProfileService:GetPlayerProfile(Player)

		local CachedCharacter = Data.Character

		StateManager:ChangeState(Character,"Mode",58)		
		AnimationRemote:FireClient(Player,Data.Character.."Transformation","Play")

		GUIRemote:FireClient(Player,"SkillUI",{
			Function = "ChangeSlots",
			Character = Data.Character,
			HasMode = true
		})

		CameraRemote:FireClient(Player, "BreakCooldown", {Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})

		Humanoid.Health = 100
		StateManager:ChangeState(Character,"IFrame",.5, {IFrameType = ""})

		ModeData.Mode = true
		ModeBoolean.Value = true
		CharacterModules[Data.Character.."Mode"]["Transformation"](Player,CharacterName,KeyData,MoveData,ExtraData)

		local DashCooldown = Data.Character == "Killua" and .5 or .5

		CombatCopy["DashType"] = Data.Character == "Killua" and "Killua" or "Mode"
		CombatCopy["Cooldown"] = DashCooldown

		while Character and Humanoid.Health >= 1 and Data.Character == CachedCharacter do
			local ModeData = StateManager:ReturnData(Character, "Mode")
			if os.clock() - LastRemovedSecond >= 1 and ModeData then
				ModeNumber.Value -= 5
				LastRemovedSecond = os.clock()
			end
			if ModeData and ModeNumber.Value <= 0 or not ModeData then StateManager:ChangeState(Character,"Mode",.01) break end
			wait(1)
		end
		CombatCopy["Cooldown"] = 1.75
		CombatCopy["DashType"] = "Normal"
		GUIRemote:FireClient(Player,"SkillUI",{
			Function = "ChangeSlots",
			Character = Data.Character,
		})
		ModeData.Mode = false
		ModeBoolean.Value = false
	end,

	["Aerial"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Humanoid,HumanoidRootPart = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")

		local Hits = Character:FindFirstChild("Hits")

		local PlayerCombo = AbilityData.ReturnData(Player,"PlayerCombos","GlobalInformation")

		local Stands = Character

		local HasStand = Stands:FindFirstChild(Character.Name.." - Stand")

		local AerialAnims = ReplicatedStorage.Assets.Animations.Shared.Combat.Aerial

		local Number = -4

		local Data = ProfileService:GetPlayerProfile(Player)
		local AnimationIndex = CharacterInfo[Data.Character]["AerialAnimation"] or "AerialStartUp"	

		if Hits.Value >= 3 and Humanoid.JumpPower <= 0 and Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
			SpeedManager.changeSpeed(Character,2,2.,4e4,nil,false)

			local _ = (HasStand and HasStand.Humanoid:LoadAnimation(AerialAnims["AerialStartUp"]):Play()) or (HasStand == nil and AnimationRemote:FireClient(Player, AnimationIndex, "Play", {FadeTime = .1, Weight = 1}))
			local _ = (HasStand and Number and -6.35) or (HasStand == nil and Number and -4)

			-- SoundManager:AddSound("CombatSwing", {Parent = HumanoidRootPart, Looped = false, Volume = .25}, "Client")
			StateManager:ChangeState(Character, "Attacking", .275)
			
			local CFrameTarget = HumanoidRootPart.CFrame * CFrame.new(0,12,0)
			local Calculation1,Calculation2 = HumanoidRootPart.Position , HumanoidRootPart.CFrame.upVector * 200
			local RaycastResults = workspace:Raycast(Calculation1,Calculation2,raycastParams)
			local Subtraction = HumanoidRootPart.CFrame - HumanoidRootPart.Position

			local BodyPosition = Instance.new("BodyPosition")
			BodyPosition.MaxForce = Vector3.new(9e9,9e9,9e9)
			BodyPosition.Position = HumanoidRootPart.Position
			BodyPosition.P = 2e4

			if RaycastResults and RaycastResults.Position and (RaycastResults.Position - Calculation1).Magnitude < 20 then
				CFrameTarget = CFrame.new(RaycastResults.Position) * Subtraction
			end

			coroutine.wrap(function()
				local HitResult,HitObject = HitboxModule.MagnitudeModule(Character, {Range = 5, KeysLogged = PlayerCombo.KeysLogged}, KeyData.SerializedKey, CharacterName)
				if HitResult then
					PlayerCombo.KeysLogged = 0
					PlayerCombo.ComboVariation = ""

					PlayerCombo.Hits = 0
				
					local Victim = HitObject.Parent
					local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

					CameraRemote:FireClient(Player, "CameraShake", {FirstText = 12, SecondText = 8})
					--NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, KeysLogged = PlayerCombo.KeysLogged, Victim = Victim, Module = "CombatVFX", Function = "Light"})

					StateManager:ChangeState(Character,"Stunned",.55)
					StateManager:ChangeState(Character,"InAir",2.25)

					StateManager:ChangeState(Victim,"InAir",2.25)
					StateManager:ChangeState(Victim,"Stunned",.85)

					Aerial(Player,{
						Type = "Start",
						Victim = Victim,
						Position = CFrameTarget * CFrame.new(0,0,-5.75).p,
						Duration = 2.25,
					})

					VfxHandler.FaceVictim({Character = Character, Victim = Victim})

					BodyPosition.Parent = HumanoidRootPart
					BodyPosition.Position = CFrameTarget.p
					Debris:AddItem(BodyPosition,2.25)
				else
					BodyPosition:Destroy()
				end
			end)()
		end
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
	end,

	["Swing"] = function(Player,CharacterName,KeyData, MoveData, ExtraData)
		local Data = ProfileService:GetPlayerProfile(Player)

		local HasCombat = CharacterInfo[Data.Character]["Combat"]
		local HasGun = CharacterInfo[Data.Character]["Gun"]
		
		local PlayerCombo = AbilityData.ReturnData(Player,"PlayerCombos","GlobalInformation")
		
		PlayerCombo.ComboVariation = os.clock() - PlayerCombo.LastPressed <= 1  and PlayerCombo.ComboVariation or ""
		PlayerCombo.ComboVariation = string.len(PlayerCombo.ComboVariation) >= 5 and "" or PlayerCombo.ComboVariation
		PlayerCombo.ComboVariation = ExtraData.WhichButton == "L" and PlayerCombo.ComboVariation.."L" or PlayerCombo.ComboVariation.."R"
		
		PlayerCombo.KeysLogged = string.len(PlayerCombo.ComboVariation)
	--	print(PlayerCombo.ComboVariation == 1 and "Initiate" or "AddIndicator")
		
		GUIRemote:FireClient(Player, "ComboIndicator", {
			Character = Player.Character,
			
			Function = (PlayerCombo.ComboVariation == "L" or PlayerCombo.ComboVariation == "R") and "Initiate"  or "AddIndicator" ,
			Variation = PlayerCombo.ComboVariation
		})
		
		local _ = string.len(PlayerCombo.ComboVariation) >= 5 and StateManager:ChangeState(Player.Character,"Guardbroken",1.35)
						
		local _  = (HasCombat and SwingVariations(Player, CharacterName, KeyData, MoveData, {SwingType = "Combat", HitboxRange = 7, ComboInput = PlayerCombo.ComboVariation, WhichButton = ExtraData.WhichButton}))
			or (not HasCombat and SwingVariations(Player, CharacterName, KeyData, MoveData, {SwingType = "Sword", HitboxRange = 7.5, WhichButton = ExtraData.WhichButton, ComboInput = PlayerCombo.ComboVariation}))	
		
		PlayerCombo.LastPressed = os.clock()
	end,

	["Dash"] = function(Player,CharacterName,KeyData,MoveData,ExtraData)
		local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")
		
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)		
		
		local CombatCopy = CombatData.ReturnData(Character,"Dash")
		DashTypes[MoveData.DashType.."Dash"](Character,ExtraData,MoveData,CombatCopy)
	end,
}

return Combat