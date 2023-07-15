--|| Services ||--
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

--|| Imports ||--
local Variations = script.Variations

local Client = require(Variations.Client)

local Table = require(Variations.Table)
local Create = require(Variations.Create)
local Voiceline = require(Variations.Voiceline)

local Properties = require(script.Properties)

--|| Remotes ||--
local RemoteFolder = ReplicatedStorage.Remotes

local SoundRemote = RemoteFolder.SoundRemote

--|| Variables ||--
local AssetFolder = ReplicatedStorage.Assets

local Sounds = AssetFolder.Sounds
local Player = Players.LocalPlayer

local SoundHandler = {
	CachedSounds = {},
	QueuedList = {},	
}

local PlaySoundDictionary = {
	["Voiceline"] = function(SoundName, SoundProperties, RemoteData)
		local Sound = Voiceline(SoundHandler.CachedSounds, SoundName, SoundProperties, RemoteData)
		return Sound
	end,
	
	["Client"] = function(SoundName, SoundProperties, RemoteData)
		local Sound = Client(SoundHandler.CachedSounds, SoundName, SoundProperties, RemoteData)
		return Sound
	end,

	["Table"] = function(SoundName, SoundProperties, RemoteData)
		local TableSound = Table(SoundHandler.CachedSounds, SoundName, SoundProperties, RemoteData)
		return TableSound
	end,

	["CreateSound"] = function(SoundName, SoundProperties, RemoteData)
		local Sound = Create(SoundHandler.CachedSounds, SoundName, SoundProperties, RemoteData)
		return Sound
	end,
	
	["Server"] = function(SoundName, SoundProperties, RemoteData)
		local Player = RemoteData.Player

		local Character = Player.Character or Player.CharacterAdded:Wait()
		local RenderPlayers = GetNearPlayers(Character,RemoteData.Distance)

		for _,Player in ipairs(RenderPlayers) do
			SoundRemote:FireClient(Player, SoundName, SoundProperties, "Play") 
		end		
	end,
}

local StopSoundDictionary = {
	["Client"] = function(SoundName, SoundProperties, Side, RemoteData)
		if not SoundHandler.CachedSounds[SoundName] then warn(SoundName.." not found") return end

		for _,ObjectType in ipairs(SoundProperties.Parent:GetDescendants()) do
			if ObjectType:IsA("Sound") and ObjectType.Name == SoundName then
				local Sound = ObjectType
				Sound:Stop(); Sound:Destroy()
			end
		end	
	end,
	
	["Server"] = function(SoundName, SoundProperties, Side, RemoteData)
		local Player = RemoteData.Player

		local Character = Player.Character or Player.CharacterAdded:Wait()
		local RenderPlayers = GetNearPlayers(Character,RemoteData.Distance)

		for _,Player in ipairs(RenderPlayers) do
			SoundRemote:FireClient(Player, SoundName, SoundProperties, "Stop") 
		end	
	end,
	
	["RemoveCreatedSound"] = function(SoundName, SoundProperties, Side, RemoteData)
		if not SoundHandler.CachedSounds[SoundName] then warn(SoundName.." not found") return end
		
		if SoundHandler.CachedSounds[SoundName] then
			SoundHandler.CachedSounds[SoundName]:Stop(); SoundHandler.CachedSounds[SoundHandler]:Destroy()
			SoundHandler.CachedSounds[SoundName] = nil
		end
	end,	
}

function GetNearPlayers(Character,Radius)
	local Table = {}
	local PlayerList = Players:GetPlayers()

	local HumanoidRootPart = Character.PrimaryPart

	for _,Player in ipairs(PlayerList) do
		local EnemyCharacter = Player.Character;
		local EnemyRootPart = EnemyCharacter.PrimaryPart;

		if (EnemyRootPart.Position - HumanoidRootPart.Position).Magnitude <= Radius then
			Table[#Table + 1] = Player
		end
	end
	return Table
end

local Children = Sounds:GetDescendants()

for _,Sound in ipairs(Children) do
	if Sound:IsA("Sound") then
		SoundHandler.CachedSounds[Sound.Name] = Sound
	end
end

function SoundHandler:AddSound(SoundName, SoundProperties, Side, RemoteData)
	local SoundInstance = PlaySoundDictionary[Side](SoundName, SoundProperties, RemoteData)
	return SoundInstance
end

function SoundHandler:StopSound(SoundName, SoundProperties, Side, RemoteData)
	StopSoundDictionary[Side](SoundName, SoundProperties, RemoteData)
end

function SoundHandler:AddQueue(SongTheme)
	SongTheme = (typeof(SongTheme) == "string" and SongTheme) or warn(Properties.INVALID_SOUND_ERROR)

	for _,QueuedStyle in ipairs(SoundHandler.QueuedList) do
		if QueuedStyle == SongTheme then
			return
		end
	end
	SoundHandler.QueuedList[#SoundHandler.QueuedList + 1] = SongTheme
end

function SoundHandler:RemoveQueue(SongTheme)
	SongTheme = (typeof(SongTheme) == "string" and SongTheme) or warn(Properties.INVALID_SOUND_ERROR)

	for _,QueuedStyle in ipairs(SoundHandler.QueuedList) do
		if QueuedStyle == SongTheme then
			SoundHandler.QueuedList[QueuedStyle] = nil
		end
	end
end

task.spawn(function()
	ContentProvider:PreloadAsync(Children)
	warn("preloaded sound assets")
end)

if RunService:IsClient() then
	local SoundSettings = {
		["Play"] = function(SoundName, Data)
			SoundHandler:AddSound(SoundName, Data, "Client")
		end;
		["Stop"] = function(SoundName, Data)
			SoundHandler:StopSound(SoundName, Data, "Client")
		end;
	}

	SoundRemote.OnClientEvent:Connect(function(SoundName,Data,Task)
		SoundSettings[Task](SoundName,Data)
	end)
end

return SoundHandler