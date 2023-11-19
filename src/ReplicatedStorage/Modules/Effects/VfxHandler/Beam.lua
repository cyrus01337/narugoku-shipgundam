--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Tween1 = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.World.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

return function(
    Cframe,
    ToZ,
    ToX,
    Duration,
    Color,
    Width0,
    Width1,
    LightEmission,
    Texture,
    Transparency,
    TextureLength,
    TextureSpeed
)
    local BeamShock = script.BeamShock:Clone()
    BeamShock.Parent = workspace.World.Visuals
    BeamShock.CFrame = Cframe
    Debris:AddItem(BeamShock, Duration + 0.1)

    local Attachment11 = BeamShock.Attachment11
    local Attachment21 = BeamShock.Attachment21
    Attachment11.Position = Vector3.new(0, ToZ / 4, -ToX / 4)
    Attachment21.Position = Vector3.new(0, ToZ / 4, ToX / 4)
    local CurveCalc = ToX / 2
    BeamShock.Beam.CurveSize0 = -CurveCalc / 4
    BeamShock.Beam.CurveSize1 = CurveCalc / 4
    BeamShock.Beam.Width0 = Width0
    BeamShock.Beam.Width1 = Width1
    if Color then
        BeamShock.Beam.Color = Color
        BeamShock.Beam2.Color = Color
    end
    if TextureSpeed then
        BeamShock.Beam.TextureSpeed = TextureSpeed
        BeamShock.Beam2.TextureSpeed = TextureSpeed
    end
    if Texture then
        BeamShock.Beam.Texture = Texture
        BeamShock.Beam2.Texture = Texture
    end
    if TextureLength then
        BeamShock.Beam.TextureLength = TextureLength
        BeamShock.Beam2.TextureLength = TextureLength
    end
    if Transparency then
        BeamShock.Beam.Transparency = Transparency
        BeamShock.Beam2.Transparency = Transparency
    end
    if LightEmission then
        BeamShock.Beam.LightEmission = LightEmission
        BeamShock.Beam2.LightEmission = LightEmission
    end
    BeamShock.Beam.LightInfluence = 0
    BeamShock.Beam2.LightInfluence = 0
    BeamShock.Beam2.CurveSize0 = CurveCalc / 4
    BeamShock.Beam2.CurveSize1 = -CurveCalc / 4
    BeamShock.Beam2.Width0 = Width0
    BeamShock.Beam2.Width1 = Width1

    local Tween = TweenService:Create(
        Attachment11,
        TweenInfo.new(Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
        { Position = Vector3.new(0, ToZ, -ToX) }
    )
    Tween:Play()
    Tween:Destroy()

    local Tween = TweenService:Create(
        Attachment21,
        TweenInfo.new(Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
        { Position = Vector3.new(0, ToZ, ToX) }
    )
    Tween:Play()
    Tween:Destroy()

    local Tween = TweenService:Create(
        BeamShock.Beam,
        TweenInfo.new(Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
        {
            CurveSize0 = -CurveCalc,
            CurveSize1 = CurveCalc,
            Width0 = 0,
            Width1 = 0,
        }
    )
    Tween:Play()
    Tween:Destroy()

    local Tween = TweenService:Create(
        BeamShock.Beam2,
        TweenInfo.new(Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
        {
            CurveSize0 = CurveCalc,
            CurveSize1 = -CurveCalc,
            Width0 = 0,
            Width1 = 0,
        }
    )
    Tween:Play()
    Tween:Destroy()
end
