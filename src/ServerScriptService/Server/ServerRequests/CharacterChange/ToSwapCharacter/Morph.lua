local AppearanceManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local CharacterInfo = require(ReplicatedStorage.Modules.Metadata.CharacterData.CharacterInfo)

local MorphFolder = ReplicatedStorage.Assets.Characters

local Include = {"Accessory","Clothing", "CharacterMesh", "BodyColors", "ShirtGraphic", "MeshPart", "Hat", "Hats", "FakeHead"}

local function Weld(Part1,Part0,CFrame0,CFrame1)
	Part1.Position = Part0.Position
	
	
	local we = Instance.new("Weld",Part0)
	we.Part1 = Part1
	we.Part0 = Part0
	we.C0 = CFrame0 or CFrame.new()
	we.C1 = CFrame1 or CFrame.new()
	return we
end
local function SetProperties(Object, Settings)

	for Property, Value in pairs(Settings) do
		if Object[Property] then
			Object[Property] = Value
		end
	end

end

local function property(Object)
	Object.Anchored = false
	Object.CanCollide = false
	Object.CastShadow = false
	Object.CanTouch = false
	Object.Massless = true
end

local function ResetAppearance(Character)

	for _, Basepart in ipairs(Character:GetDescendants()) do
		if table.find(Include, Basepart.Name) then
			Basepart:Destroy()
		end
	end

end
-- function

local function SetHats(Character, Morph)
	if Morph:FindFirstChild("Hats") == nil then return end

	local NewFolder = Instance.new("Folder")
	NewFolder.Name = "HatFolder"

	NewFolder.Parent = Character

	
	for _, Item in ipairs(Morph.Hats:GetDescendants()) do
		if Item:IsA("BasePart")  then
			
		
			local ParentItem = Character:WaitForChild(Item.Parent.Name)
			local RelativeCFrame =  Morph:WaitForChild(Item.Parent.Name).CFrame:toObjectSpace(Item.CFrame)
			
			local Hat = Item:Clone()
			
			--print(ParentItem)

			property(Hat)

			Weld(Hat,ParentItem , RelativeCFrame)

			Hat.Parent = NewFolder
		end
	end

end

function AppearanceManager.Morph(Character, Morph)
	local SelectedMorph = MorphFolder:FindFirstChild(Morph)

	if Character == nil or SelectedMorph == nil then return end

	if Character.Torso:FindFirstChild("roblox") then Character.Torso.roblox:Destroy() end
	if Character.Head:FindFirstChild("face") then Character.Head.face:Destroy() end
	if Character:FindFirstChild("HatFolder") then Character:FindFirstChild("HatFolder"):Destroy() end

	ResetAppearance(Character)

	SetHats(Character,SelectedMorph)
	
--	local Face = Character:FindFirstChild("FakeHead"):FindFirstChild("face")
--	Face.Texture = CharacterInfo[SelectedCharacter]["FaceId"]
	
	for _, Basepart in ipairs(SelectedMorph:GetChildren()) do
		if Basepart:IsA("BodyColors") or Basepart:IsA("CharacterMesh") or Basepart:IsA("Clothing") then
			Basepart:Clone().Parent = Character
		elseif Basepart.Name == "Head"  then
			local FakeHead = Basepart:Clone()
			FakeHead.Name = "FakeHead"
			
			property(FakeHead)

			Character:FindFirstChild("Head").Transparency = Basepart.Transparency
			
			
			Weld(FakeHead, Character:FindFirstChild("Head"))

			FakeHead.Parent = Character
			
			local Face = FakeHead:FindFirstChild("face")
			
			--if FakeHead:FindFirstChild("face") == nil then
				local FaceDecal = Instance.new("Decal")
				FaceDecal.Texture = CharacterInfo[Morph].FaceId
				
				FaceDecal.Parent = Face
			
				FaceDecal.Name = "face"
			--else
				--Face.Texture = CharacterInfo[Morph].FaceId
			--end
			
		end
	end
end


return AppearanceManager