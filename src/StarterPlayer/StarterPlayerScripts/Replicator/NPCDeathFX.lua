-- SERVICES --
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

-- FUNCTIONS --
return function(Character)
    task.delay(5, function()
        for i, v in pairs(Character:GetDescendants()) do
            if v:IsA("MeshPart") or v:IsA("Part") or v:IsA("Decal") then
                -- Transparency Tween --
                local tweenTime = 2

                local ImpTween = TS:Create(
                    v,
                    TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Transparency = 1 }
                )
                ImpTween:Play()

                task.delay(tweenTime, function()
                    --print("Tween Completed - NPCDeathFX")
                end)
            end
        end
    end)
end
