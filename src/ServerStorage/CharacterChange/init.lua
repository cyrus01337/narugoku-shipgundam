local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
-- local ServerStorage = game:GetService("ServerStorage")

local CharacterData = ReplicatedStorage.Modules.Metadata.CharacterData
local CharacterInfo = require(CharacterData.CharacterInfo)
local ProfileService = require(ServerScriptService.Server.ProfileService)
-- local SoundManager = require(Shared.SoundManager)
local ToSwapCharacter = require(script.ToSwapCharacter)

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote


return function(player: Player, request: any, character: string, Datastore, Type)-- Player:Instance, Character:String, Data:Table
	local Data = ProfileService:GetPlayerProfile(player)

	if Type == "Select" and table.find(Data["Unlocked"], character) then
		local WarningText = " Alucard is banned."

		if Data.Character == character then return end

		if character == "Alucard" then
			GUIRemote:FireClient(player, "Notification", {
				Function = "Initiate",
				Player = player,
				Color = Color3.new(0.407843, 0.258824, 1),
				Text = ("<font color= 'rgb(%s, %s, %s)'>&lt; " .. WarningText .. "&gt;</font> lol.")
			})

			-- SoundManager:AddSound("Baka!", {
			-- 	Volume = 1,
			-- 	TimePosition = .1,
			-- 	Parent = Player.Character:FindFirstChild("HumanoidRootPart") or workspace.World.Sounds

			-- }, "Server", {Player = Player, Distance = 5})

			return
		end

		local playerChar = player.Character :: Model
		Data.Character = if CharacterInfo[character] then character else Data.Character

		ProfileService:Replicate(player)
		player:ClearCharacterAppearance()

		local hatsFound = playerChar:FindFirstChild("Hats")

		if hatsFound then
			playerChar.Hats:Destroy()
		end

		ToSwapCharacter({ToSwap = Data.Character, Player = player})

		return
	end

	if Data and not table.find(Data["Unlocked"], character) and Data.Cash >= CharacterInfo[character]["Cost"] and Type == "Purchase" then
		Data["Cash"] = Data["Cash"] - CharacterInfo[character].Cost
		local WarningText = " Sugoi!, you unlocked "..character

		table.insert(Data.Unlocked,character)
		ProfileService:Replicate(player)

		GUIRemote:FireClient(player,"Notification",{
			Function = "Initiate",
			Player = player,
			Color = Color3.new(0.490196, 1, 0.172549),
			Text = ("<font color= 'rgb(%s, %s, %s)'>&lt; "..WarningText.."&gt;</font> as a character!")
		})

		Data.Character = CharacterInfo[character] and character or Data.Character
		-- SoundManager:AddSound("Sugoi!",{
		-- 	Volume = 1,
		-- 	TimePosition = .1,
		-- 	Parent = Player.Character:FindFirstChild("HumanoidRootPart") or workspace.World.Sounds
		-- }, "Server", {Player = Player, Distance = 5})
	elseif Data and not table.find(Data["Unlocked"], character) and Data.Cash <= CharacterInfo[character]["Cost"] then
		local WarningText = " insufficient funds"

		-- SoundManager:AddSound("Baka!",{
		-- 	Volume = 1,
		-- 	TimePosition = .1,
		-- 	Parent = Player.Character:FindFirstChild("HumanoidRootPart") or workspace.World.Sounds
		-- }, "Server", {Player = Player, Distance = 5})

		GUIRemote:FireClient(player,"Notification",{
			Function = "Initiate",
			Player = player,
			Color = Color3.new(1,0,0),
			Text = ("<font color= 'rgb(%s, %s, %s)'>&lt; "..WarningText.."&gt;</font> need more before unlocking this character.")
		})
	end
end
