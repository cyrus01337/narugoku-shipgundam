--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ServerScriptService = game:GetService("ServerScriptService")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules
local Metadata = Modules.Metadata
local Shared = Modules.Shared
local CharacterData = Metadata.CharacterData

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote


--|| Modules ||--
local CharacterInfo = require(CharacterData.CharacterInfo)
local SoundManager = require(Shared.SoundManager)

local ToSwapCharacter = require(script.ToSwapCharacter)

local ProfileService = require(ServerScriptService.Server.ProfileService)

return function(Player, Request, Character, Datastore, Type)-- Player:Instance, Character:String, Data:Table
	local Data = ProfileService:GetPlayerProfile(Player)
		
	if Type == "Select" and table.find(Data["Unlocked"],Character) then
		local WarningText = " Alucard is banned."

		if Data.Character == Character then return end
		
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

		Data.Character = CharacterInfo[Character] and Character or Data.Character
		ProfileService:Replicate(Player)
		
		Player:ClearCharacterAppearance()
		local _ = Player.Character:FindFirstChild("Hats") and Player.Character.Hats:Destroy()
		ToSwapCharacter({ToSwap = Data.Character, Player = Player})	
		return
	end
	
	if Data and not table.find(Data["Unlocked"],Character) and Data.Cash >= CharacterInfo[Character]["Cost"] and Type == "Purchase" then
		Data["Cash"] = Data["Cash"] - CharacterInfo[Character].Cost
		local WarningText = " Sugoi!, you unlocked "..Character

		table.insert(Data.Unlocked,Character)
		ProfileService:Replicate(Player)
		
		GUIRemote:FireClient(Player,"Notification",{
			Function = "Initiate",
			Player = Player,
			Color = Color3.new(0.490196, 1, 0.172549),
			Text = ("<font color= 'rgb(%s, %s, %s)'>&lt; "..WarningText.."&gt;</font> as a character!")
		})	

		Data.Character = CharacterInfo[Character] and Character or Data.Character
		-- SoundManager:AddSound("Sugoi!",{
			Volume = 1,
			TimePosition = .1,
			Parent = Player.Character:FindFirstChild("HumanoidRootPart") or workspace.World.Sounds

		}, "Server", {Player = Player, Distance = 5})
		
	elseif Data and not table.find(Data["Unlocked"],Character) and Data.Cash <= CharacterInfo[Character]["Cost"] then
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