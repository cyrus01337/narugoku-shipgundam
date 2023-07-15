--||Services||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--||Directories||--
local Server = ServerScriptService.Server

local Modules = ReplicatedStorage.Modules
local State = Server.State

local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Effects = Modules.Effects
local Shared = Modules.Shared

--|| Remotes ||--
local RemoteFolder = ReplicatedStorage.Remotes

local ChangeSpeed = RemoteFolder.ChangeSpeed
local GUIRemote = RemoteFolder.GUIRemote
local CameraRemote = RemoteFolder.CameraRemote

--|| Imports ||--
local ProfileService = require(Server.ProfileService)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)

local VfxHandler = require(Effects.VfxHandler)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)

local SoundManager = require(Shared.SoundManager)

local AbilityData = require(Metadata.AbilityData.AbilityData)
local CombatData = require(Metadata.CombatData.CombatData)

local CameraData = {Size = 30, Length = .25}

local function ClearTable(Table)
	for Array in ipairs(Table) do
		Table[Array] = nil
	end
end

local DamageManager = {
	DamagedEntities = {},
}

local BlockFunctions = {
	["Parry"] = function(Character, Victim,  BlockData, BlockDeduction, Type)
		local Humanoid,Root = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")
		
		local SkillData = CombatData.ReturnData(Players:GetPlayerFromCharacter(Character),"Block")
		if not SkillData.CanParry then return end
		
		StateManager:ChangeState(Character, "Stunned", 1.15)

		NetworkStream.FireClientDistance(Character,"ClientRemote",150,{
			Character = Character,
			Module = "CombatVFX",
			Function = "Parry"
		})
	end,
	
	["Block"] = function(Character, Victim, BlockData, BlockDeduction, Type)
		BlockData.BlockVal -= BlockDeduction

		NetworkStream.FireClientDistance(Character,"ClientRemote",150,{
			Character = Character,
			Victim = Victim,
			WeaponType = Type,
			Module = "CombatVFX",
			Function = "Block"
		}) 
	end,
	
	["Guardbreak"] = function(Character, Victim, BlockData, BlockDeduction, Type,ExtraData)
		local VictimHumanoid, VictimRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")
		
		local ModeData = StateManager:ReturnData(Character, "Mode")
		local DamageData = StateManager:ReturnData(Character,"DamageMultiplier")
		
		local DamageBoost = DamageData.DamageBooster
		
		StateManager:ChangeState(Victim, "Blocking", false)
		StateManager:ChangeState(Victim, "Guardbroken", 1.875)
		
		local IndexCalculation = ModeData.Mode and ExtraData.CharacterName.."Mode" or ExtraData.CharacterName or warn"character has invalid module"
		
		local ModifierCopy = AbilityData.ReturnData(Players:GetPlayerFromCharacter(Character),ExtraData.SkillName,IndexCalculation) or CombatData.ReturnData(Players:GetPlayerFromCharacter(Character),ExtraData.SkillName) 
		local Damage = ModifierCopy.Damage
		
		VictimHumanoid:TakeDamage(Damage / 2 * DamageBoost)
		NetworkStream.FireClientDistance(Character,"ClientRemote",50,{Character = Character, Damage = Damage / 2 * DamageBoost , Victim = Victim, Module = "PlayerClient", Function = "DamageIndication", StunTime = 0})

		NetworkStream.FireClientDistance(Character,"ClientRemote",150,{
			Character = Character,
			Victim = Victim,
			Module = "CombatVFX",
			Function = "GuardBreak"
		}) 
	end,
}

function DamageManager.DeductDamage(Character,Victim,SkillName,CharacterName,ExtraData,Blur)
	local Player = Players:GetPlayerFromCharacter(Character)
	local VictimPlayer = Players:GetPlayerFromCharacter(Victim)

	local KeysLogged = AbilityData.ReturnData(Player,"PlayerCombos","GlobalInformation").KeysLogged
	local ComboData = AbilityData.ReturnData(Player,"PlayerCombos","GlobalInformation")
	local Type = ExtraData and ExtraData.Type or "Combat"
	local SecondType = ExtraData and ExtraData.SecondType or ""
	
	ExtraData = ExtraData or {Type = Type, SecondType = SecondType}
	
	local Humanoid, Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
	local VictimHumanoid, VictimRoot =  Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")

	SkillName = (type(SkillName) == "string" and SkillName) or warn("Invalid type.")

	local ModeData = StateManager:ReturnData(Character, "Mode")

	local IndexCalculation = ModeData.Mode and CharacterName.."Mode" or CharacterName or warn"character has invalid module"
	local ModifierCopy = AbilityData.ReturnData(Player,SkillName,IndexCalculation) or CombatData.ReturnData(Player,SkillName) 
	
	--print(ExtraData.Damage)

	local Damage = ExtraData.Damage or ModifierCopy.Damage
	local StunTime = ModifierCopy.StunTime or .625
	local EndLag = ModifierCopy.Endlag or 0
	local Guardbreak = ModifierCopy.Guardbreak
	local BlockDeduction = ModifierCopy.BlockDeduction or 1

	local UnitVector = (Root.Position - VictimRoot.Position).Unit
	local VictimLook = VictimRoot.CFrame.lookVector
	local DotVector = UnitVector:Dot(VictimLook)

	local DamageData = StateManager:ReturnData(Character,"DamageMultiplier")
	local DamageBoost = DamageData.DamageBooster
	
	local PlayerCombo = AbilityData.ReturnData(Player,"PlayerCombos","GlobalInformation")
	
	if VictimHumanoid.Health <= 0 or Humanoid.Health == 0 then return end
	if Victim == Character or StateManager:ReturnData(Victim, "Attacking") == nil then return end
	--print(StateManager:ReturnData(Victim, "IFrame"))
	if not StateManager:Peek(Victim, "IFrame") then

		local IFrameData = StateManager:ReturnData(Victim, "IFrame")

		local IFrameType = IFrameData.IFrameType
		
	
		if IFrameType == "" then return end
	
		
		local VictimPlayer = Players:GetPlayerFromCharacter(Victim)
		local VictimData = ProfileService:GetPlayerProfile(VictimPlayer)

		local CharacterModule = require(Server.Characters[VictimData.Character])


		local ObservationData = {
			Character = Victim,
			Victim = Character,

			SkillName = SkillName,
			CharacterName = CharacterName,

			ExtraData = ExtraData,

			ModifierCopy = ModifierCopy,


		}
	
		CharacterModule[IFrameType](ObservationData)

	
		return 
	end

	local BlockData = StateManager:ReturnData(Victim, "Blocking")
	local IsBlocking = StateManager:Peek(Victim, "Blocking") and DotVector >= -.5 and true or false

	local GuardbreakCalculation = not string.find(SkillName,"Ability") and string.len(PlayerCombo.ComboVariation) >= 5 and true or false
	Guardbreak = GuardbreakCalculation or Guardbreak

	local BlockBreak = (Guardbreak or BlockData.BlockVal == 0 or string.len(PlayerCombo.ComboVariation) == 5 and Guardbreak and true) or false
	local PerfectBlock = (os.clock() - BlockData.StartTime <= .135 and true) or false

	if StateManager:Peek(Victim,"ForceField") then
		if Players:GetPlayerFromCharacter(Victim) then
			local Data = ProfileService:GetPlayerProfile(Players:GetPlayerFromCharacter(Victim))

			CameraRemote:FireClient(VictimPlayer, "CameraShake", {FirstText = 8, SecondText = 10})
			NetworkStream.FireClientDistance(Character,"ClientRemote",250,{Character = Victim, Module = Data.Character.."VFX", Function = "boingzz"})
		end
		return
	end

	if IsBlocking then
		local BlockTypeEvaluation = BlockBreak and "Guardbreak" or PerfectBlock and "Parry" or "Block"
		BlockFunctions[BlockTypeEvaluation](Character, Victim, BlockData, BlockDeduction, Type,{SkillName = SkillName, CharacterName = CharacterName})
	else
		NetworkStream.FireClientDistance(Character,"ClientRemote",50,{Character = Character, Damage = Damage * DamageBoost , Victim = Victim, Module = "PlayerClient", Function = "DamageIndication", StunTime = StunTime})
		local Damage = SecondType == "Choke" and (VictimHumanoid.Health - Damage * DamageBoost) <= 0 and 0 or Damage
		VictimHumanoid:TakeDamage(Damage * DamageBoost)

		local ModeNumber = Player:WaitForChild("Mode")
		local Stats = Player:WaitForChild("leaderstats")
		local Points = Stats and Stats.Points

		Points.Value += ModifierCopy.ModePoints or math.random(3,5)

		coroutine.wrap(function()
			local ModeData = StateManager:ReturnData(Character, "Mode")

			if ModeData.Mode then return end

			if ModeNumber.Value <= ModeData.MaxModeValue then
				if Player.Name == "Freshzsz" or Player.Name == "DaWunbo" then
					ModeNumber.Value += 285
				else
					ModeNumber.Value += ModifierCopy.ModePoints or math.random(3,5)
				end
			end
		end)()

		ComboData.Hits = ComboData.Hits + 1

		local Hits = Character:FindFirstChild("Hits")
		if Hits then
			Hits.Value += 1
		end

		local _ = StateManager:Peek(Character,"InAir") and VfxHandler.FaceVictim({Character = Character, Victim = Victim})

		local ForwardVelocity = (VictimRoot.CFrame.p - Root.CFrame.p).Unit * 12
		local BackwardVelocity = CFrame.new(Root.Position,Root.Position + (Root.CFrame.lookVector * 10) + (Root.CFrame.upVector * 1.25)).lookVector * 100

		local VelocityCalculation = (string.len(PlayerCombo.ComboVariation) < 5 or PlayerCombo.KeysLogged < 5) and ForwardVelocity or BackwardVelocity

		if not string.find(SkillName,"Ability") then
			NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, SecondType = SecondType, KeysLogged = KeysLogged, Victim = Victim, Module = Type.."VFX", Function = "Light"})
			
			local _ = string.len(PlayerCombo.ComboVariation) >= 5 and VfxHandler.RemoveBodyMover(Victim)
			
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4)
			BodyVelocity.Velocity = VelocityCalculation
			BodyVelocity.Parent = VictimRoot
			Debris:AddItem(BodyVelocity,.25)
			
		--	if string.len(PlayerCombo.ComboVariation) == 5 then
				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4)
				BodyVelocity.Velocity = (VictimRoot.CFrame.p - Root.CFrame.p).Unit * 12
				BodyVelocity.Parent = Root
				Debris:AddItem(BodyVelocity,.25)
		--	end	

			if string.len(PlayerCombo.ComboVariation) == 5 then
				VfxHandler.FaceVictim({Character = Character, Victim = Victim})
				
				local Data = ProfileService:GetPlayerProfile(Player)			
				local ModeNumber = Player:WaitForChild("Mode")
				local ModeBoolean = ModeNumber and ModeNumber.ModeBoolean
				
				local _ = ModeBoolean.Value and Data.Character == "Sanji" and math.random(1,2) == 1 and VfxHandler.FireProc({Character = Character, Victim = Victim, Duration = 2, Damage = 1})
				
				CameraRemote:FireClient(Player, "CameraShake",{FirstText = 8, SecondText = 4, FourthText = 1})
				--local _ = Blur == nil and CameraRemote:FireClient(Player,"CreateBlur",CameraData)
				local _ = Blur == nil and NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Victim = Victim, Module = Type.."VFX", Function = "LastHit"})				
			end
		else
			NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, SecondType = SecondType, KeysLogged = math.random(1,4), Victim = Victim, Module = Type.."VFX", Function = "Light"})
		end
	end

	if not StateManager:Peek(Victim,"Blocking") then	
		StateManager:ChangeState(Victim, "Stunned", StunTime)
		local _ = not StateManager:Peek(Victim,"Frozen") and StateManager:ChangeState(Victim,"Frozen",0)
		StateManager:ChangeState(Character, "IFrame", .135)
	end	
end

return DamageManager