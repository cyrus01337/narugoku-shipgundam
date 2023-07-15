--|| Services ||--
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules
local Metadata = Modules.Metadata
local Shared = Modules.Shared
local CharacterData = Metadata.CharacterData

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Modules ||--
local CharacterInfo = require(CharacterData.CharacterInfo)

local SoundManager = require(Shared.SoundManager)
local StateManager  = require(Shared.StateManager)

local ProfileService = require(ServerScriptService.Server.ProfileService)

local ToSwapCharacter = require(script.ToSwapCharacter)

return function(Player, Request, Character, Datastore, Type)-- Player:Instance, Character:String, Data:Table
	local Data = ProfileService:GetPlayerProfile(Player)
		
	if Type == "Select" and Data.Unlocked[Character] then
		if Data.Character == Character then return end
		
		local ModeData = StateManager:ReturnData(Player.Character or Player.CharacterAdded:Wait(), "Mode")	
		ModeData.Mode = false
		
		Player:WaitForChild("Mode").Value = 0
		
		local WarningText = " Alucard is banned."

		if Character == "Alucard" then
			GUIRemote:FireClient(Player,"Notification",{
				Function = "Initiate",
				Player = Player,
				Color = Color3.new(0.407843, 0.258824, 1),
				Text = ("<font color= 'rgb(%s, %s, %s)'>&lt; "..WarningText.."&gt;</font> lol.")
			})	
			
			-- SoundManager:AddSound("Baka!",{
				Volume = 1,
				TimePosition = .1,
				Parent = Player.Character:FindFirstChild("HumanoidRootPart") or workspace.World.Sounds

			}, "Server", {Player = Player, Distance = 5})
			return
		end
		
		local _ = CharacterInfo[Data.Character]["HasBar"] and CameraRemote:FireClient(Player,"HideCharacterBar",{Character = Data.Character})
		
		for _,v in ipairs(Player:GetChildren()) do
			if string.find(v.Name,"Bar") then
				v:Destroy()
			end
		end	
		Data.Character = Character
		ProfileService:Replicate(Player)
		
		Player:ClearCharacterAppearance()
		ToSwapCharacter({ToSwap = Data.Character, Player = Player})	
		return
	end
	
	print(Character, CharacterInfo[Character])
	
	if Data and not Data.Unlocked[Character] and Data.Cash >= CharacterInfo[Character]["Cost"] and Type == "Purchase" then
		Data["Cash"] = Data["Cash"] - CharacterInfo[Character].Cost
		local WarningText = " Sugoi!, you unlocked "..Character

		Data.Unlocked[Character] = Character
		
		ProfileService:Replicate(Player)
		
		GUIRemote:FireClient(Player,"Notification",{
			Function = "Initiate",
			Player = Player,
			Color = Color3.new(0.490196, 1, 0.172549),
			Text = ("<font color= 'rgb(%s, %s, %s)'>&lt; "..WarningText.."&gt;</font> as a character!")
		})	

		--Data.Character = CharacterInfo[Character] and Character or Data.Character
		-- SoundManager:AddSound("Sugoi!",{
			Volume = 1,
			TimePosition = .1,
			Parent = Player.Character:FindFirstChild("HumanoidRootPart") or workspace.World.Sounds

		}, "Server", {Player = Player, Distance = 5})
		
	elseif Data and not Data.Unlocked[Character] and Data.Cash <= CharacterInfo[Character]["Cost"] then
		local WarningText = " insufficient funds"
		
		-- SoundManager:AddSound("Baka!",{
			Volume = 1,
			TimePosition = .1,
			Parent = Player.Character:FindFirstChild("HumanoidRootPart") or workspace.World.Sounds

		}, "Server", {Player = Player, Distance = 5})		
		
		GUIRemote:FireClient(Player,"Notification",{
			Function = "Initiate",
			Player = Player,
			Color = Color3.new(1,0,0),
			Text = ("<font color= 'rgb(%s, %s, %s)'>&lt; "..WarningText.."&gt;</font> need more before unlocking this character.")
		})		
	end
end