local DashTypes = {}

local Dashes = script:GetChildren()

for Index = 1, #Dashes do
    local Module = Dashes[Index]
    if Module:IsA("ModuleScript") then
        DashTypes[Module.Name] = require(Module)
    end
end

return DashTypes
