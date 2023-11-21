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

local CharacterChangeBind = script.Parent.ToSwapCharacter

--|| Modules ||--
local CharacterInfo = require(CharacterData.CharacterInfo)
local StandManager = require(Server.Managers.StandManager)

local ResizeCharacterModule = require(ServerStorage.Modules.ResizeChar)

--|| Functions ||--
local function Weld(Part1, Part0, CFrame0, CFrame1)
    Part1.Position = Part0.Position
    local we = Instance.new("Weld", Part1)
    we.Part1 = Part1
    we.Part0 = Part0
    we.C0 = CFrame0 or CFrame.new()
    we.C1 = CFrame1 or CFrame.new()
    return we
end

local function property(Object)
    Object.Anchored = false
    Object.CanCollide = false
    Object.CastShadow = false
    Object.CanTouch = false
    Object.Massless = true
end

return function(Data)
    local Character, Player = Data.ToSwap, Data.Player

    if not Player or Character == nil then
        return
    end

    local Face = Player.Character:FindFirstChild("FakeHead"):FindFirstChild("face")
    Face.Texture = CharacterInfo[Character]["FaceId"]

    local CharacterToSwap = ServerStorage.Characters:FindFirstChild(Character)
    if not CharacterToSwap then
        warn(Character, "is not a valid character model in ServerStorage > Characters")
        return
    end

    --StateManager:ChangeState(Character, "Attacking", 1000000000)

    for _, Swaps in ipairs(CharacterToSwap:GetChildren()) do
        if Swaps:IsA("Clothing") then
            local CharacterStuff = Swaps:Clone()
            CharacterStuff.Parent = Player.Character or Player.CharacterAdded:Wait()
        end
    end

    if CharacterToSwap:FindFirstChild("Hats") then
        local HatFolder = Instance.new("Folder", Character)
        HatFolder.Name = "Hats"
        for i, v in ipairs(CharacterToSwap.Hats:GetDescendants()) do
            if v:IsA("BasePart") then
                local rel = CharacterToSwap:FindFirstChild(v.Parent.Name).CFrame:toObjectSpace(v.CFrame)
                local hat = v:clone()
                property(hat)
                Weld(hat, Character:FindFirstChild(v.Parent.Name), rel)
                hat.Parent = HatFolder
            end
        end
    end

    GUIRemote:FireClient(Player, "SkillUI", {
        Function = "ChangeSlots",
        Character = Character,
    })

    if CharacterInfo[Data.ToSwap]["Resize"] then
        ResizeCharacterModule(Player, CharacterInfo[Data.ToSwap]["ToSize"])
    else
        ResizeCharacterModule(Player, 1)
    end

    Player.Character:FindFirstChild("FakeHead").Size = Player.Character:FindFirstChild("Head").Size

    for _, v in ipairs(Player.Character:GetDescendants()) do
        if string.find(v.Name, "Sword") then
            v:Destroy()
        end
    end

    StandManager.UnSummon(Player, { Stand = Player.Name .. " - Stand" })
    local _ = CharacterInfo[Data.ToSwap]["Stand"] and StandManager.Summon(Player, { Stand = Character })

    if CharacterInfo[Data.ToSwap]["Gun"] then
        if CharacterInfo[Data.ToSwap]["Gun"].DualGun then
            local RightGun = ReplicatedStorage.Assets.Models.Guns:FindFirstChild(Data.ToSwap .. "GunR"):Clone()
            RightGun.Parent = Player.Character or Player.CharacterAdded:Wait()

            local MotorWeld = Instance.new("Motor6D")
            MotorWeld.Name = "Handle"
            MotorWeld.Part0 = Player.Character["Right Arm"]
            MotorWeld.Part1 = RightGun.Handle
            MotorWeld.C0 = CFrame.new(0, -1, 0)
            MotorWeld.Parent = Player.Character["Right Arm"]

            local LeftGun = ReplicatedStorage.Assets.Models.Guns:FindFirstChild(Data.ToSwap .. "GunL"):Clone()
            LeftGun.Parent = Player.Character or Player.CharacterAdded:Wait()

            local MotorWeld = Instance.new("Motor6D")
            MotorWeld.Name = "Handle"
            MotorWeld.Part0 = Player.Character["Left Arm"]
            MotorWeld.Part1 = LeftGun.Handle
            MotorWeld.C0 = CFrame.new(0, -1, 0)
            MotorWeld.Parent = Player.Character["Left Arm"]
        else
            for _, v in ipairs(Player.Character:GetDescendants()) do
                if string.find(v.Name, "gun") then
                    v:Destroy()
                end
            end
        end
    end

    if not CharacterInfo[Data.ToSwap]["Combat"] and not CharacterInfo[Data.ToSwap]["Gun"] then
        local Sword = ReplicatedStorage.Assets.Models.Swords:FindFirstChild(Data.ToSwap .. "Sword"):Clone()
        Sword.Parent = Player.Character or Player.CharacterAdded:Wait()
        local MotorWeld = Instance.new("Motor6D")
        MotorWeld.Name = "Handle"
        MotorWeld.Part0 = Player.Character["Right Arm"]
        MotorWeld.Part1 = Sword.Handle
        MotorWeld.C0 = CFrame.new(0, -1, 0)
        MotorWeld.Parent = Player.Character["Right Arm"]
    elseif not CharacterInfo[Data.ToSwap]["Stand"] then
        StandManager.UnSummon(Player, { Stand = Player.Name .. " - Stand" })
    end
end
