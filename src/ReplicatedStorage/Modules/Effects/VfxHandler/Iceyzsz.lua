--|| Services ||--
local Debris = game:GetService("Debris")

return function(Root)
    for _, v in ipairs(Root.Parent:GetChildren()) do
        if v:IsA("BasePart") then
            local ParticleHolder = Instance.new("Part")
            ParticleHolder.Anchored = true
            ParticleHolder.Transparency = 1
            ParticleHolder.CanCollide = false
            ParticleHolder.Size = v.Size
            ParticleHolder.CFrame = v.CFrame
            ParticleHolder.Parent = workspace.World.Visuals
            Debris:AddItem(ParticleHolder, 2)

            local IceParticle = script.IceSmoke:Clone()
            IceParticle.Parent = ParticleHolder
            IceParticle:Emit(3)

            local IceParticle2 = script.Sparks:Clone()
            IceParticle2.Parent = ParticleHolder
            IceParticle2:Emit(3)
        end
    end
end
