--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local SoundManager = require(ReplicatedStorage.Modules.Shared.SoundManager)

return function(Part, Position)
    local GroundSlam = script.GroundSlamThing:Clone()
    GroundSlam.CFrame = CFrame.new(Position) * CFrame.new(0, Part.Size.Y / 4, 0)
    GroundSlam.Rocks.Color = ColorSequence.new(Part.Color)
    GroundSlam.Rocks:Emit(15)
    GroundSlam.ParticleEmitter.Color = ColorSequence.new(Part.Color)
    GroundSlam.ParticleEmitter:Emit(4)
    GroundSlam.Parent = workspace.World.Visuals

    Debris:AddItem(GroundSlam, 2.5)
end
