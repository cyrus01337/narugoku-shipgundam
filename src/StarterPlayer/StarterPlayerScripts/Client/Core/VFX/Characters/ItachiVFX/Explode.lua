--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local CollectionService = game:GetService("CollectionService")

--|| Imports ||--
local VFXHandler = require(ReplicatedStorage.Modules.Effects.VfxHandler)

return function(MenbereCFrame, MenbereCFrame2, Menbere, RaycastResult)
    local CFrameCalculation = Menbere.CFrame * CFrame.new(0, 0, 3) * CFrame.Angles(math.rad(-90), 0, 0)

    VFXHandler.Spherezsz({
        Cframe = CFrameCalculation,
        TweenDuration1 = 0.2,
        TweenDuration2 = 0.2,
        Range = 15,
        MinThick = 20,
        MaxThick = 40,
        Part = nil,
        Color = Color3.fromRGB(255, 122, 69),
        Amount = 25,
    })

    Menbere.back.Enabled = false
    Menbere.back:Clear()
    Menbere.back2.Enabled = false
    Menbere.back2:Clear()
    Menbere.Smoke.Size = NumberSequence.new((math.random(8, 15)))
    Menbere.Smoke.Color = ColorSequence.new(RaycastResult.Color)
    Menbere.Smoke:Emit(25)
    Menbere.BurningPart.Transparency = NumberSequence.new(0)

    local DustEffect = script.dust:Clone()
    DustEffect.CFrame = Menbere.CFrame
    DustEffect.Attachment.Rocks.Color = ColorSequence.new(RaycastResult.Color)
    DustEffect.Attachment.Rocks:Emit(35)

    DustEffect.Parent = workspace.World.Visuals
    Debris:AddItem(DustEffect, 2)

    local Tween = TweenService:Create(
        DustEffect.PointLight,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { ["Range"] = 40, Brightness = 0 }
    )
    Tween:Play()
    Tween:Destroy()

    for _ = 1, 10 do
        local ScaleIndex = math.random(150, 300) / 100
        local SecondScaleIndex = math.random(250, 500) / 100

        local Sphere = script.sphere:Clone()
        Sphere.CFrame = MenbereCFrame
        Sphere.Mesh.Scale = Vector3.new(ScaleIndex, ScaleIndex, ScaleIndex)
        Sphere.Parent = workspace.World.Visuals

        local Tween =
            TweenService:Create(Sphere, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                ["CFrame"] = Sphere.CFrame * CFrame.new(
                    math.random(-3000, 3000) / 100,
                    math.random(-3000, 3000) / 100,
                    math.random(-3000, 3000) / 100
                ),
            })
        Tween:Play()
        Tween:Destroy()

        local Tween = TweenService:Create(
            Sphere.Mesh,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Scale"] = Vector3.new(0, 0, 0) }
        )
        Tween:Play()
        Tween:Destroy()

        Debris:AddItem(Sphere, 0.35)

        local Sphere2 = script.sphere:Clone()
        Sphere2.CFrame = MenbereCFrame
        Sphere2.Color = Color3.fromRGB(255, 89, 89)
        Sphere2.Mesh.Scale = Vector3.new(SecondScaleIndex, SecondScaleIndex, SecondScaleIndex)
        Sphere2.Parent = workspace.World.Visuals

        local Tween =
            TweenService:Create(Sphere2, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                ["CFrame"] = Sphere2.CFrame * CFrame.new(
                    math.random(-3000, 3000) / 100,
                    math.random(-3000, 3000) / 100,
                    math.random(-3000, 3000) / 100
                ),
            })
        Tween:Play()
        Tween:Destroy()

        local Tween = TweenService:Create(
            Sphere2.Mesh,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Scale"] = Vector3.new(0, 0, 0) }
        )
        Tween:Play()
        Tween:Destroy()

        Debris:AddItem(Sphere2, 0.35)
    end
end
