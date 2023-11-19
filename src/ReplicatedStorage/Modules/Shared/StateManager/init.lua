-- Block/Parry dummies don't start blocking again after their block is broken
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local StatePresets = require(script.StatePresets)
local Utility = ReplicatedStorage.Modules.Utility
local TableUtility = require(Utility.Utility)
local Metadata = ReplicatedStorage.Modules.Metadata
local MetadataManager = require(Metadata.MetadataManager)

local INVALID_PATH_ERROR = "Requested Path is an invalid path or type."
local StateManager = {}
local Branch = {}
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote
local StateRemote = ReplicatedStorage.Remotes.StateRemote

function Branch.NormalInteger(BranchTree, PathIndex)
    return os.clock() - BranchTree.StartTime >= BranchTree.Duration
end

function Branch.SpecialInteger(BranchTree, PathIndex)
    return os.clock() - BranchTree.StartTime <= BranchTree.Duration
end

function Branch.Boolean(BranchTree, PathIndex)
    local branchFound = BranchTree["Is" .. PathIndex]

    if branchFound then
        return branchFound
    end
end

-- TODO: Rewrite to a real class and apply good practices
function StateManager.Initiate(character)
    local newState = {
        InitiatedTime = os.clock(),
        StateData = TableUtility.GetDeepCopy(StatePresets),
    }
    StateManager[character] = newState

    return newState
end

function StateManager:Remove(characterIndex)
    StateManager[characterIndex] = nil
end

function StateManager:Peek(CharacterIndex, PathIndex)
    local BranchTree = StateManager:ReturnData(CharacterIndex, PathIndex)

    return type(BranchTree) == "table" and Branch[BranchTree.Type](BranchTree, PathIndex) or nil
end

if RunService:IsClient() then
    local Player = Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local CurrentState = StateManager.Initiate(Character)

    function StateManager:ReturnData(CharacterIndex, PathIndex)
        return CurrentState[CharacterIndex][PathIndex]
    end

    Player.CharacterAdded:Connect(function(Character)
        CurrentState = StateManager.Initiate(Character)
    end)

    Player.CharacterRemoving:Connect(function(Character)
        StateManager:Remove(Character)
        CurrentState = nil
    end)

    StateRemote.OnClientEvent:Connect(function(NewData)
        CurrentState.StateData[NewData.State] = NewData.BranchTree

        repeat
            task.wait()
        until _G.ModeSignal

        _G.ModeSignal:Fire({ ChosenState = NewData.State, ChosenStateData = NewData.NewState })
    end)

    return StateManager
elseif RunService:IsServer() then
    local StatePresets = require(script.StatePresets)
    local TableUtility = require(Utility.Utility)

    function StateManager:ChangeState(CharacterIndex, PathIndex, ToChangeValue, ToChangeData)
        local BranchTree = StateManager:ReturnData(CharacterIndex, PathIndex)
        if type(BranchTree) == "table" then
            if BranchTree.Type == "NormalInteger" or BranchTree.Type == "SpecialInteger" then
                BranchTree.StartTime = os.clock()
                BranchTree.Duration = ToChangeValue
                --print(PathIndex,ToChangeValue)

                if ToChangeData then
                    for State, Value in pairs(BranchTree) do
                        if ToChangeData[State] then
                            BranchTree[State] = ToChangeData[State]
                        end
                    end
                end
            else
                BranchTree.StartTime = os.clock()
                BranchTree.Duration = 0

                BranchTree["Is" .. PathIndex] = ToChangeValue

                if ToChangeData then
                    for State, Value in pairs(BranchTree) do
                        if ToChangeData[State] then
                            BranchTree[State] = ToChangeData[State]
                        end
                    end
                end
            end

            local ValidPlayer = Players:GetPlayerFromCharacter(CharacterIndex)

            --if ValidPlayer then
            --	StateRemote:FireClient(ValidPlayer,{State = PathIndex, NewState = BranchTree})
            --end
        end
    end

    function StateManager:ReturnData(CharacterIndex, PathIndex)
        if not CharacterIndex then
            warn(CharacterIndex .. "has left game or disconnected")
            return
        end

        return StateManager[CharacterIndex] and StateManager[CharacterIndex].StateData[PathIndex] or nil
    end

    function StateManager:AppendState(CharacterIndex, StateData)
        local StateType = StateData.Type or warn("did not find")
        local StateName = StateData.Name or warn("did not find")

        local StateToAppend = {
            StartTime = os.clock(),
            Duration = 0,

            ["Is" .. StateData.Name] = false,

            Type = StateType,
        }

        StateManager[CharacterIndex].StateData[StateName] = StateToAppend
    end

    task.spawn(function()
        StateManager.Initiate(workspace.World.Live.HitDummy)

        StateManager.Initiate(workspace.World.Live.AttackingDummy)

        --StateManager.Initiate(workspace.World.Live.Beatrice)
        --StateManager:ChangeState(workspace.World.Live.Beatrice, "LastAbility", 4e4, {Skill = "FirstAbility"})

        StateManager.Initiate(workspace.World.Live.BlockDummy)
        StateManager:ChangeState(workspace.World.Live.BlockDummy, "Blocking", true)

        StateManager.Initiate(workspace.World.Live.ParryDummy)
        StateManager:ChangeState(workspace.World.Live.ParryDummy, "Blocking", true)

        StateManager.Initiate(workspace.World.Live.IFrameDummy)
        StateManager:ChangeState(workspace.World.Live.IFrameDummy, "IFrame", 15454525545245)

        MetadataManager.Init(workspace.World.Live.AttackingDummy)
    end)

    return StateManager
end
