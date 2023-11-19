--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

--|| Variables ||--
local RNG = Random.new()
local TI2 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)

return function(Data)
    local Character = Data.Character

    local Positions = {}

    local ModelInstance = Instance.new("Model")
    ModelInstance.Parent = workspace.World.Visuals

    for Index = 1, Data.Amount do
        local offset = Vector3.new(
            math.random(-Data.OffsetRange, Data.OffsetRange),
            math.random(-3, 3),
            math.random(-Data.OffsetRange, Data.OffsetRange)
        )
        local Position = Data.StartPosition
            + (Data.EndPosition - Data.StartPosition).Unit * Index * (Data.EndPosition - Data.StartPosition).Magnitude / Data.Amount
            + offset

        if Index == 0 or Index == Data.Amount then
            offset = Vector3.new(0, 0, 0)
        end
        Positions[#Positions + 1] = Position + offset
    end
    for Index = 1, #Positions do
        if Positions[Index + 1] then
            local part = Instance.new("Part")
            part.BrickColor = BrickColor.new(Data.Color)
            part.Material = "Neon"
            part.CanCollide = false
            part.Anchored = true
            part.CastShadow = false
            part.Size = Vector3.new(Data.With, Data.Width, (Positions[Index] - Positions[Index + 1]).Magnitude)
            part.CFrame = CFrame.new((Positions[Index] + Positions[Index + 1]) / 2, Positions[Index + 1])
            part.Parent = ModelInstance
        end
    end
    return ModelInstance
end
