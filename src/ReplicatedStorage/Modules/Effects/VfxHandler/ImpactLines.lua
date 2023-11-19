--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Imports ||--

--|| Variables ||--
local RNG = Random.new()
local TI2 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)

return function(Data)
    local Character = Data.Character
    local Amount = Data.Amount
    local Type = Data.Type

    if Character then
        coroutine.resume(coroutine.create(function()
            for Index = 1, Amount do
                local Part = Instance.new("Part")
                Part.Anchored = true
                Part.CanCollide = false
                Part.Material = "Neon"
                Part.Name = "ImpactLines"
                if Type == "volleyblall" then
                    Part.BrickColor = math.random(1, 2) == 1 and BrickColor.new("Institutional white")
                        or BrickColor.new("Black")
                else
                    Part.BrickColor = Data.Color or BrickColor.new("Institutional white")
                end
                Part.Transparency = RNG:NextNumber(0.2, 0.5)
                Part.Size = Vector3.new(0.11, 0.11, RNG:NextNumber(3, 4.5))
                Part.Position = Character.PrimaryPart.Position
                    + Vector3.new(0, 2, 0)
                    + Vector3.new(RNG:NextNumber(-4, 4), RNG:NextNumber(-7, 4), RNG:NextNumber(-4, 4))
                Part.CFrame =
                    CFrame.new(Part.Position, Character.PrimaryPart.Position + Character.PrimaryPart.Velocity * 100)
                Part.Parent = workspace.World.Visuals

                local Tween = TweenService:Create(
                    Part,
                    TI2,
                    {
                        Position = Part.Position + Part.CFrame.lookVector * -RNG:NextNumber(-5, -Amount),
                        Transparency = 1,
                        Size = Part.Size / 2,
                    }
                )
                Tween:Play()
                Tween:Destroy()

                Debris:AddItem(Part, 0.8)
                wait(Data.Delay or 0)
            end
        end))
    end
end
