local Explosions = {}

local Effects = script:GetDescendants()

for i = 1, #Effects do
    local Module = Effects[i]
    if Module:IsA("ModuleScript") then
        Explosions[Module.Name] = require(Module)
    end
end

return Explosions
