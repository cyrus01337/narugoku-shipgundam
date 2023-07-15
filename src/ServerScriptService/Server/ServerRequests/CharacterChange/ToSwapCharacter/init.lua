--|| Services ||--
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--|| Directories ||--
local Server = ServerScriptService.Server

local Modules = ReplicatedStorage.Modules
local Metadata = Modules.Metadata
local CharacterData = Metadata.CharacterData

local GUIRemote = ReplicatedStorage.Remotes.GUIRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local CharacterChangeBind = script.Parent.ToSwapCharacter

--|| Modules ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local CharacterInfo = require(CharacterData.CharacterInfo)
local StandManager = require(Server.Managers.StandManager)

local ResizeCharacterModule = require(ServerStorage.Modules.ResizeChar)

local AppearanceManager = require(script.Morph)

return function(Data)
	local SelectedCharacter,Player = Data.ToSwap,Data.Player
	
	local Character = Player.Character or Player.CharacterAdded:Wait()
	


    --warn"Switching"
	
	AppearanceManager.Morph(Character, SelectedCharacter)
	
	
	
	
	--StateManager:ChangeState(Character, "Attacking", 1000000000) 



	GUIRemote:FireClient(Player,"SkillUI",{
		Function = "ChangeSlots",
		Character = SelectedCharacter,
	})

	if CharacterInfo[Data.ToSwap]["Resize"] then
		ResizeCharacterModule(Player, CharacterInfo[Data.ToSwap]["ToSize"]) 
	else
		ResizeCharacterModule(Player, 1)
	end

	--Player.Character:FindFirstChild("FakeHead").Size = Player.Character:FindFirstChild("Head").Size
		
	for _,v in ipairs(Player.Character:GetDescendants()) do
		if string.find(v.Name,"Sword") then
			v:Destroy()
		end
	end	

	StandManager.UnSummon(Player,{Stand = Player.Name.." - Stand"})	
	local _ = CharacterInfo[Data.ToSwap]["Stand"] and StandManager.Summon(Player,{Stand = SelectedCharacter})
	
	if CharacterInfo[Data.ToSwap]["HasBar"] then
		GlobalFunctions.NewInstance("NumberValue",{Parent = Player, Name = CharacterInfo[Data.ToSwap]["BarName"], Value = 0})
		CameraRemote:FireClient(Player,"EnableCharacterBar",{Type = "Peek", Character = Data.ToSwap})
	end
	
	if CharacterInfo[Data.ToSwap]["Gun"] then
		if CharacterInfo[Data.ToSwap]["Gun"].DualGun then
			local RightGun = ReplicatedStorage.Assets.Models.Guns:FindFirstChild(Data.ToSwap.."GunR"):Clone()
			RightGun.Parent = Player.Character or Player.CharacterAdded:Wait()

			local MotorWeld = Instance.new("Motor6D")
			MotorWeld.Name = "Handle"
			MotorWeld.Part0 = Player.Character["Right Arm"]
			MotorWeld.Part1 = RightGun.Handle
			MotorWeld.C0 = CFrame.new(0,-1,0)
			MotorWeld.Parent = Player.Character["Right Arm"]

			local LeftGun = ReplicatedStorage.Assets.Models.Guns:FindFirstChild(Data.ToSwap.."GunL"):Clone()
			LeftGun.Parent = Player.Character or Player.CharacterAdded:Wait()

			local MotorWeld = Instance.new("Motor6D")
			MotorWeld.Name = "Handle"
			MotorWeld.Part0 = Player.Character["Left Arm"]
			MotorWeld.Part1 = LeftGun.Handle
			MotorWeld.C0 = CFrame.new(0,-1,0)
			MotorWeld.Parent = Player.Character["Left Arm"]
		else
			for _,v in ipairs(Player.Character:GetDescendants()) do
				if string.find(v.Name,"gun") then
					v:Destroy()
				end
			end	
		end
	end

	if not CharacterInfo[Data.ToSwap]["Combat"] and not CharacterInfo[Data.ToSwap]["Gun"] then
		local Sword = ReplicatedStorage.Assets.Models.Swords:FindFirstChild(Data.ToSwap.."Sword"):Clone()
		Sword.Parent = Player.Character or Player.CharacterAdded:Wait()
				
		local MotorWeld = Instance.new("Motor6D")
		MotorWeld.Name = "Handle"
		MotorWeld.Part0 = Player.Character["Right Arm"]
		MotorWeld.Part1 = Sword.Handle
		MotorWeld.C0 = CFrame.new(0,-1,0)
		MotorWeld.Parent = Sword.Handle
		
		
		if ReplicatedStorage.Assets.Models.Swords:FindFirstChild(Data.ToSwap.."SheateSword") then
			GlobalFunctions.NewInstance("StringValue",{Parent = Player.Character, Name = "SwordEffect"})

			local Sword = ReplicatedStorage.Assets.Models.Swords:FindFirstChild(Data.ToSwap.."SheateSword"):Clone()
			Sword.Parent = Player.Character or Player.CharacterAdded:Wait()

			local MotorWeld = Instance.new("Motor6D")
			MotorWeld.Name = "Handle"
			MotorWeld.Part0 = Player.Character["Left Arm"]
			MotorWeld.Part1 = Sword.Handle
			MotorWeld.C0 = CFrame.new(0,-1,0)
			MotorWeld.Parent = Sword.Handle
		end		
	elseif not CharacterInfo[Data.ToSwap]["Stand"] then
		StandManager.UnSummon(Player,{Stand = Player.Name.." - Stand"})
	end
end