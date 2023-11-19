-- SERVICES --
local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")

-- FUNCTIONS --
return function(Action, ...)
    local Args = { ... }

    if Action == "Splash" then
        local TargetPosition = Args[1]
        local WaterPart = Args[2]

        local splashAttachment = Instance.new("Attachment")
        splashAttachment.Parent = WaterPart
        splashAttachment.WorldPosition = TargetPosition
        game.Debris:AddItem(splashAttachment, 5)

        coroutine.wrap(function()
            for i, v in pairs(script.Splash:GetChildren()) do
                if v:IsA("ParticleEmitter") then
                    local fx = v:Clone()
                    fx.Parent = splashAttachment
                    fx:Emit(fx:GetAttribute("EmitCount"))
                end
            end
        end)()
    end
end
