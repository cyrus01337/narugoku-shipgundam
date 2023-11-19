local StandManager = {}

local StandFunctions = script:GetChildren()

for Index = 1, #StandFunctions do
    local Module = StandFunctions[Index]
    if Module:IsA("ModuleScript") then
        StandManager[Module.Name] = require(Module)
    end
end

return StandManager
