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

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local CameraRemote = RemoteFolder.CameraRemote

--|| Imports ||--
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

function DamageManager.DeductDamage(Character,Victim,KeysLogged,ExtraData)
	local VictimPlayer = Players:GetPlayerFromCharacter(Victim)

	local Humanoid, Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
	local VictimHumanoid, VictimRoot =  Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")

	local Damage = 5
	local StunTime = .55
	local EndLag = 0
	local BlockDeduction = 1

	local DamageData = StateManager:ReturnData(Character,"DamageMultiplier")
	local DamageBoost = DamageData.DamageBooster

	if VictimHumanoid.Health >= 1 and Humanoid.Health >= 0 and Victim ~= Character then

		local UnitVector = (Root.Position - VictimRoot.Position).Unit
		local VictimLook = VictimRoot.CFrame.lookVector
		local DotVector = UnitVector:Dot(VictimLook)

		if KeysLogged >= 5 and StateManager:Peek(Victim,"Blocking") then
			local BlockData = StateManager:ReturnData(Victim,"Blocking")
			BlockData.BlockVal = 0
		end

		if StateManager:Peek(Victim,"Blocking") and (DotVector >= -.5) then
			local BlockData = StateManager:ReturnData(Victim,"Blocking")
			if BlockData.BlockVal > 0 then
				BlockData.BlockVal -= BlockDeduction

				NetworkStream.FireClientDistance(Character,"ClientRemote",150,{
					Character = Character,
					Victim = Victim,
					WeaponType = "Combat",
					Module = "CombatVFX",
					Function = "Block"
				}) 

			elseif BlockData.BlockVal <= 0 then
				coroutine.resume(coroutine.create(function()
					StateManager:ChangeState(Victim, "Blocking", false)
					StateManager:ChangeState(Victim, "Guardbroken", 2.5)
					StateManager:ChangeState(Character, "Stunned", 1)
					
					NetworkStream.FireClientDistance(Character,"ClientRemote",150,{
						Character = Character,
						Victim = Victim,
						Module = "CombatVFX",
						Function = "GuardBreak"
					}) 		

					while not StateManager:Peek(Victim,"Guardbroken") do
						Victim.Humanoid.WalkSpeed = 0
						RunService.Stepped:Wait()
					end
					Victim.Humanoid.WalkSpeed = 14
				end))

			elseif os.clock() - BlockData.StartTime <= 30 then
				StateManager:ChangeState(Character, "Stunned", 1)

				SpeedManager.changeSpeed(Character,0,1,3)

				NetworkStream.FireClientDistance(Character,"ClientRemote",150,{
					Character = Character,
					Victim = Victim,
					Module = "CombatVFX",
					Function = "Parry"
				}) 
			end
		elseif StateManager:Peek(Victim,"IFrame") then
			NetworkStream.FireClientDistance(Character,"ClientRemote",50,{Character = Character, Damage = Damage * DamageBoost , Victim = Victim, Module = "PlayerClient", Function = "DamageIndication"})
			VictimHumanoid:TakeDamage(Damage * DamageBoost)

			if KeysLogged < 5 then
				if StateManager:Peek(Character,"InAir") then
					VfxHandler.FaceVictim({Character = Character, Victim = Victim})
				end
				NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, SecondType = "", KeysLogged = KeysLogged, Victim = Victim, Module = "CombatVFX", Function = "Light"})

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
				BodyVelocity.Velocity = (VictimRoot.CFrame.p - Root.CFrame.p).Unit * 10
				BodyVelocity.Parent = Root
				Debris:AddItem(BodyVelocity,.25)

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
				BodyVelocity.Velocity = (VictimRoot.CFrame.p - Root.CFrame.p).Unit * 12
				BodyVelocity.Parent = VictimRoot
				Debris:AddItem(BodyVelocity,.25)
			else
				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
				BodyVelocity.Velocity = CFrame.new(Root.Position,Root.Position + (Root.CFrame.lookVector * 10) + (Root.CFrame.upVector * -10) ).lookVector * 100
				BodyVelocity.Parent = VictimRoot
				Debris:AddItem(BodyVelocity,.25)

				VfxHandler.FaceVictim({Character = Character, Victim = Victim})

				NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Victim = Victim, Module = "CombatVFX", Function = "LastHit"})
			end
		end

		if VictimPlayer and not StateManager:Peek(Victim,"Blocking") then	
			StateManager:ChangeState(Victim, "Stunned", StunTime)
			StateManager:ChangeState(Character, "IFrame", .35)
			StateManager:ChangeState(Character, "Stunned", EndLag)
			while StateManager:Peek(Victim,"Stunned") do
				Victim.Humanoid.WalkSpeed = 0
				RunService.Stepped:Wait()
			end
			Victim.Humanoid.WalkSpeed = 14
		end				
	end	
end

return DamageManager