--|| Services ||--
local RunService = game:GetService("RunService")

local Utility = {}

function Utility:deepSearchFolder(Folder, Type, InfoTable)
    local NewTable = InfoTable or {}
    Type = Type or "Animation"

    local Children = Folder:GetChildren()

    for i, Object in ipairs(Children) do
        if Object:IsA(Type) then
            NewTable[#NewTable + 1] = Object
        elseif Object:IsA("Folder") or Object:IsA("ModuleScript") then
            self:deepSearchFolder(Object, Type, NewTable)
        end
    end

    return NewTable
end

function Utility.GetDeepCopy(Table)
    local Copy = {}

    for Index, Value in pairs(Table) do
        local IndexType, ValueType = type(Index), type(Value)

        if IndexType == "table" and ValueType == "table" then
            Index, Value = Utility.GetDeepCopy(Index), Utility.GetDeepCopy(Value)
        elseif ValueType == "table" then
            Value = Utility.GetDeepCopy(Value)
        elseif IndexType == "table" then
            Index = Utility.GetDeepCopy(Index)
        end

        Copy[Index] = Value
    end

    return Copy
end

-- TODO: replace this with task.wait everywhere
function Utility:FastWait(YieldTime, Yield)
    Yield = Yield or RunService.Stepped
    local StartTime = os.clock()
    while os.clock() - StartTime < YieldTime do
        Yield:Wait()
    end
end

function Utility.assert(condition: any, message: string?)
    message = message or "Assertion failed"

    if condition then
        error(message)
    end
end

return Utility
