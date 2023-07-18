--|| Services ||--
local Players = game:GetService("Players")

local ScriptContext = game:GetService("ScriptContext")

-- local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- local RunService = game:GetService("RunService")

--|| Directories ||--
local Server = ServerScriptService.Server

local Modules = ReplicatedStorage.Modules
-- local Assets = ReplicatedStorage.Assets

local State = Server.State
local ServerRequests = Server.ServerRequests

local Shared = Modules.Shared

local Metadata = Modules.Metadata
-- local Utility = Modules.Utility

--|| Imports ||--
local ProfileService = require(Server.ProfileService)

local StateManager  = require(Shared.StateManager)
local ControlData = require(Metadata.ControlData.ControlData)

local CombatData = require(Metadata.CombatData.CombatData)
local AbilityData = require(Metadata.AbilityData.AbilityData)

local MetadataManager = require(Metadata.MetadataManager)
-- local CharacterInfo = require(Metadata.CharacterData.CharacterInfo)

local DebounceManager = require(State.DebounceManager)

local ToSwapCharacter = require(ServerRequests.CharacterChange.ToSwapCharacter)

local CacheModules = {}
local RequestModules = {}
-- local Connections = {}

local HttpModule = require(script.HttpModule)

ScriptContext.Error:Connect(function(Error,stackTrace,scriptObject)
	warn(string.format("Rex-chan caught error: \n %s at: \n %s",Error,stackTrace))
	HttpModule:PostToWebhook("Error",Error,stackTrace)
end)

for _,Module in ipairs(ServerRequests:GetChildren()) do
	if Module:IsA("ModuleScript") then
		RequestModules[Module.Name] = require(Module)
	end
end

for _,Module in ipairs(script:GetDescendants()) do
	if Module:IsA("ModuleScript")  then
		CacheModules[Module.Name] = require(Module)
	end
end

--|| Remotes ||--
-- local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local ServerRequest = ReplicatedStorage.Remotes.ServerRequest

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
-- local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
-- local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local DataRequest = ReplicatedStorage.Remotes.DataRequest

local function RespawnPlayer(Player)
	-- local Character = Player.Character or Player.CharacterAdded:Wait()


	local Data = ProfileService:GetPlayerProfile(Player)



	ToSwapCharacter({ToSwap = Data.Character, Player = Player})

--	local Mode = Player:WaitForChild("Mode")
--	local ModeData = StateManager:ReturnData(Character, "Mode")

	--local ModeIndex = Player.Name == "DaWunbo" or Player.Name == "Freshzsz" and 285 or 0

	--Mode.Value = ModeIndex
	--ModeData.ModeValue = ModeIndex

--	local Humanoid = Character:WaitForChild("Humanoid")
--	Humanoid.WalkSpeed = 14




	ProfileService:Replicate(Player)
end


local function OnPlayerAdded(Player)
	repeat wait(.1) until ProfileService:IsLoaded(Player) == true

	-- local PlayerGroupID = Player:GetRoleInGroup(9559760)


	local Character = Player.Character or Player.CharacterAdded:Wait()

	pcall(function()
		StateManager.Initiate(Character)
		MetadataManager.Init(Player)


		RespawnPlayer(Player)
	end)


	--AddToEntites(Character)

	ProfileService:Replicate(Player)


	Player.CharacterAdded:Connect(function(Character)
		Character:WaitForChild("Humanoid")

		pcall(function()
			StateManager.Initiate(Character)
			ProfileService:Replicate(Player)

		end)



		--AddToEntites(Character)
	--	ProfileService:Replicate(Players:GetPlayerFromCharacter(Character))
		--

		-- local StartTime = os.clock()



		wait(.7)

		RespawnPlayer(Player)

		ProfileService:Replicate(Players:GetPlayerFromCharacter(Character))

		local Data = ProfileService:GetPlayerProfile(Player)

		GUIRemote:FireClient(Player,"SkillUI",{
			Function = "ChangeSlots",
			Character = Data.Character,
		})


	end)

	Player.CharacterRemoving:Connect(function(Character)
		local Data = ProfileService:GetPlayerProfile(Player)

		StateManager:Remove(Character)
		local _ = Character ~= nil and AbilityData.ResetCooldown(Player,Data.Character)
	end)
end


for _, Player in ipairs(Players:GetPlayers()) do
	OnPlayerAdded(Player)
end
--|| Main ||--
Players.PlayerAdded:Connect(OnPlayerAdded)

Players.PlayerRemoving:Connect(function(Player)
	AbilityData.RemoveKey(Player)
	CombatData.RemoveKey(Player)
end)

ServerRemote.OnServerEvent:Connect(function(Player,SkillName,KeyName,ExtraData)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

	if Character == nil then return end
	if Humanoid.Health <= 0 then return end

	local IsRunning = StateManager:Peek(Character,"Running")

	local Data = ProfileService:GetPlayerProfile(Player)
	local CharacterName = Data.Character

	local ModeData = StateManager:ReturnData(Character, "Mode")

	local IndexCalculation = ModeData.Mode and CharacterName.."Mode" or CharacterName or warn"character has invalid module"

	local SkillData = AbilityData.ReturnData(Player,SkillName,IndexCalculation) or CombatData.ReturnData(Player,SkillName)
	if SkillData.Bool and SkillData.Bool == true then return end

	if SkillData.Bool ~= nil then
		SkillData.Bool = true
	end

	-- local CurrentSkill = StateManager:ReturnData(Character, "LastSkill")

	local AllowedAttackSkills = StateManager:ReturnData(Character, "Attacking").AllowedSkills
	local AllowedBlockSkills = StateManager:ReturnData(Character, "Blocking").AllowedSkills

	local Conditional = ControlData.Controls.Combat[KeyName] and "Combat"
	local CacheModule = CacheModules[Conditional or IndexCalculation][SkillName]

	local _ = type(ExtraData) == "table" and ExtraData["State"] == "Terminate" and IsRunning and CacheModule["Terminate"](Player,CharacterName,{SerializedKey = "Run",KeyName = "LeftShift"},SkillData,ExtraData)

	local IsBlocking = StateManager:ReturnData(Character,"Blocking").IsBlocking

	if Player and StateManager:Peek(Character,"Guardbroken") and (StateManager:Peek(Character,"Attacking") and not IsBlocking or AllowedAttackSkills[SkillName] or AllowedBlockSkills[SkillName]) and not StateManager:Peek(Character,"Stunned") and DebounceManager.CheckDebounce(Character,SkillName,CharacterName) then
		if (IsBlocking and AllowedBlockSkills[SkillName]) or (not StateManager:Peek(Character, "Attacking") and AllowedAttackSkills[SkillName]) or StateManager:Peek(Character, "Attacking") then
			if type(CacheModule) == "table" then
				CacheModule[ExtraData.State](Player,CharacterName,{
					SerializedKey = SkillName,
					KeyName = KeyName
				},SkillData,ExtraData)
			else
				CacheModule(Player,CharacterName,{
					SerializedKey = SkillName,
					KeyName = KeyName
				},SkillData,ExtraData,CacheModules)
			end
		end
	elseif type(ExtraData) == "table" and ExtraData["State"] == "Terminate" then
		CacheModule[ExtraData.State](Player,CharacterName,{
			SerializedKey = SkillName,
			KeyName = KeyName
		},SkillData,ExtraData)
	end
	StateManager:ChangeState(Character, "LastAbility", 10, {Skill = SkillName})
	StateManager:ChangeState(Character, "LastSkill", 5, {Skill = SkillData.Name})

	if SkillData.Bool ~= nil then
		SkillData.Bool = false
	end
end)

ServerRequest.OnServerEvent:Connect(function(Player, Request, Character, Type)
	local requestHandlerFound = RequestModules[Request]

	if requestHandlerFound then
		requestHandlerFound(Player, Request, Character, ProfileService, Type)
	end
end)

DataRequest.OnServerEvent:Connect(function(Player)
	if ProfileService:IsLoaded(Player) == false then
		local StartTime = os.clock()

		repeat wait(.5) until ProfileService:IsLoaded(Player) == true or os.clock() - StartTime >= 20
		return ProfileService:GetPlayerProfile(Player)
	else
		return ProfileService:GetPlayerProfile(Player)
	end
end)

task.spawn(function()
	local BlockDummy = workspace.World.Live.BlockDummy
	local ParryDummy = workspace.World.Live.ParryDummy

	local BlockHum,ParryHum = BlockDummy:FindFirstChild("Humanoid"), ParryDummy:FindFirstChild("Humanoid")

	BlockHum:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Combat.Block.BlockIdle):Play()
	ParryHum:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Combat.Block.BlockIdle):Play()
end)
