--|| Services ||--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Effects = Modules.Effects
local Shared = Modules.Shared

--|| Modules ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local CameraShaker = require(Effects.CameraShaker)
local LightningExplosion = require(Effects.LightningBolt.LightningExplosion)
local VfxHandler = require(Effects.VfxHandler)

local SoundManager = require(Shared.SoundManager)

local Camera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
    Camera.CFrame = Camera.CFrame * shakeCFrame
end)

function CreateLightning(Start, End, numberofparts)
    local Lightning = Instance.new("Folder", workspace.World.Visuals)
    Lightning.Name = "Lightning"
    Debris:AddItem(Lightning, 2)
    local lastcf = Start
    local Distance = (Start - End).Magnitude / numberofparts

    for Index = 1, numberofparts do
        local x, y, z = math.random(-2, 2) * 5, math.random(-2, 2) * 5, math.random(-2, 2) * 5
        if Index == numberofparts then
            x = 0
            y = 0
            z = 0
        end
        local Color = Index % 2 == 0 and "Pastel blue-green" or "Pastel blue-green"

        local newcframe = CFrame.new(lastcf, End + Vector3.new(x, y, z)) * CFrame.new(0, 0, -Distance)
        local newdisance = (lastcf - newcframe.p).Magnitude

        local Part = Instance.new("Part")
        Part.Material = Enum.Material.Neon
        Part.BrickColor = BrickColor.new(Color)
        Part.TopSurface = Enum.SurfaceType.SmoothNoOutlines
        Part.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
        Part.CanCollide = false
        Part.Anchored = true
        Part.CastShadow = false
        Part.Size = Vector3.new(0.25, 0.25, newdisance)
        Part.CFrame = CFrame.new(lastcf, newcframe.p) * CFrame.new(0, 0, -newdisance / 2)
        Part.Parent = Lightning

        -- SoundManager:AddSound("LightningSizzle", {Parent = Part, Volume = 3}, "Client")

        local Ti2 = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
        local Ti3 = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 4, true, 0)

        TweenService:Create(Part, Ti2, { Size = Vector3.new(0, 0, newdisance) }):Play()
        TweenService:Create(Part, Ti3, { Transparency = 1 }):Play()
        Debris:AddItem(Part, 0.4)
        lastcf = newcframe.p
    end
end

local function createhugelightning(Start, End, numberofparts, player)
    local lastcf = Start
    local Distance = (Start - End).Magnitude / numberofparts
    local Lightning = Instance.new("Folder")
    Lightning.Name = "lightasd"
    Lightning.Parent = workspace.World.Visuals
    Debris:AddItem(Lightning, 1.4)

    for Index = 1, numberofparts do
        local x, y, z =
            math.random(-2, 2) * math.clamp(numberofparts, 5, 99999),
            math.random(-2, 2) * math.clamp(numberofparts, 5, 99999),
            math.random(-2, 2) * math.clamp(numberofparts, 5, 99999)
        if Index == numberofparts then
            x = 0
            y = 0
            z = 0
        end
        local newcframe = CFrame.new(lastcf, End + Vector3.new(x, y, z)) * CFrame.new(0, 0, -Distance)
        local newdisance = (lastcf - newcframe.p).Magnitude
        local Part = Instance.new("Part")
        Part.Material = Enum.Material.Neon
        Part.Color = Color3.fromRGB(128, 187, 219)
        Part.TopSurface = Enum.SurfaceType.SmoothNoOutlines
        Part.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
        Part.CanCollide = false
        Part.Anchored = true
        Part.CastShadow = false
        Part.Size = Vector3.new(0.7, 0.7, newdisance)
        Part.CFrame = CFrame.new(lastcf, newcframe.p) * CFrame.new(0, 0, -newdisance / 2)
        Part.Parent = Lightning

        local Ti2 = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)

        coroutine.resume(coroutine.create(function()
            wait(Index / 20)
            TweenService
                :Create(Part, Ti2, { Size = Vector3.new(0, 0, newdisance), Color = Color3.fromRGB(253, 234, 141) })
                :Play()
            Debris:AddItem(Part, 0.4)
        end))
        lastcf = newcframe.p
    end
end

function createhugelightning2(Start, End, numberofparts, player)
    local lastcf = Start
    local Distance = (Start - End).Magnitude / numberofparts

    local Lightning = Instance.new("Folder")
    Lightning.Name = "lightasd"
    Lightning.Parent = workspace.World.Visuals
    Debris:AddItem(Lightning, 2)

    for Index = 1, numberofparts do
        local X, Y, Z =
            math.random(-2, 2) * math.clamp(numberofparts, 5, 99999),
            math.random(-2, 2) * math.clamp(numberofparts, 5, 99999),
            math.random(-2, 2) * math.clamp(numberofparts, 5, 99999)
        if Index == numberofparts then
            X = 0
            Y = 0
            Z = 0
        end
        local newcframe = CFrame.new(lastcf, End + Vector3.new(X, Y, Z)) * CFrame.new(0, 0, -Distance)
        local newdisance = (lastcf - newcframe.p).Magnitude

        local Part = Instance.new("Part")
        Part.Material = Enum.Material.Neon
        Part.Color = Color3.fromRGB(128, 187, 219)
        Part.TopSurface = Enum.SurfaceType.SmoothNoOutlines
        Part.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
        Part.CanCollide = false
        Part.Anchored = true
        Part.CastShadow = false
        Part.Size = Vector3.new(0.7, 0.7, newdisance)
        Part.CFrame = CFrame.new(lastcf, newcframe.p) * CFrame.new(0, 0, -newdisance / 2)
        Part.Parent = Lightning

        coroutine.resume(coroutine.create(function()
            wait(Index / 20)

            local Ti24 = TweenInfo.new(0.14, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)

            local Tween = TweenService:Create(
                Part,
                Ti24,
                { ["Size"] = Vector3.new(0, 0, newdisance), ["Color"] = Color3.fromRGB(253, 234, 141) }
            )
            Tween:Play()
            Tween:Destroy()

            Debris:AddItem(Part, 0.24)
        end))
        lastcf = newcframe.p
    end
end

--|| Variables ||--
local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local RingTween = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

return function(Data)
    local Character = Data.Character
    local Root = Character:FindFirstChild("HumanoidRootPart")

    local RiceSpiritSlash = Instance.new("Folder")
    RiceSpiritSlash.Name = "RiceSpiritSlash"
    RiceSpiritSlash.Parent = workspace.World.Visuals
    Debris:AddItem(RiceSpiritSlash, 1)

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = { Character, workspace.World.Visuals }
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    coroutine.resume(coroutine.create(function()
        for Index = 1, 2 do
            -- SoundManager:AddSound("Lightning_Release_2",{Parent = Root},"Client")
            wait(0.2)
        end
    end))

    VfxHandler.Spherezsz({
        Cframe = Root.CFrame,
        TweenDuration1 = 0.2,
        TweenDuration2 = 0.35,
        Range = 12,
        MinThick = 20,
        MaxThick = 20,
        Part = nil,
        Color = BrickColor.new("Cool yellow").Color,
        Amount = 5,
    })

    VfxHandler.Spherezsz({
        Cframe = Root.CFrame,
        TweenDuration1 = 0.2,
        TweenDuration2 = 0.35,
        Range = 12,
        MinThick = 20,
        MaxThick = 40,
        Part = nil,
        Color = BrickColor.new("Pastel blue-green").Color,
        Amount = 8,
    })

    LightningExplosion.new(
        Root.Position,
        0.35,
        12,
        ColorSequence.new(Color3.fromRGB(255, 251, 134)),
        ColorSequence.new(Color3.fromRGB(117, 237, 255), Color3.fromRGB(255, 251)),
        nil
    )

    coroutine.resume(coroutine.create(function()
        wait(0.1)
        local amont = math.random(4, 6)
        for _ = 1, amont do
            local Startcf = Root.CFrame * CFrame.new(math.random(-2, 2), math.random(-3, 0), 0)
            local EndCf = Startcf * CFrame.new(0, 0, math.random(8, 14) * 2)
            local RandomIndex = math.random(1, 3)
            if RandomIndex ~= 1 then
                local r1 = EndCf.p + Vector3.new(0, 40, 0)
                local r2 = EndCf.upVector * -200
                local results = workspace:Raycast(r1, r2, raycastParams)
                if results and results.Instance and (results.Position - r1).Magnitude < 100 then
                    EndCf = results.Position
                end
            end
            if typeof(Startcf) == "CFrame" then
                Startcf = Startcf.p
            end
            if typeof(EndCf) == "CFrame" then
                EndCf = EndCf.p
            end
            CreateLightning(Startcf, EndCf, math.random(2, 3))
            wait(0.2)
        end
    end))

    VfxHandler.RockTing(Root.CFrame, 1)

    local DistanceIndex = 1 - math.clamp((Camera.CFrame.Position - Root.Position).Magnitude, 0, 150) / 150
    local ColorCorrectionEffect = Instance.new("ColorCorrectionEffect")
    ColorCorrectionEffect.Parent = Camera

    local Ti = TweenInfo.new(0.12, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)
    local DistanceIndex = 1
        - math.clamp((workspace.CurrentCamera.CFrame.Position - Root.Position).Magnitude, 0, 70) / 70

    TweenService:Create(ColorCorrectionEffect, Ti, { Brightness = DistanceIndex }):Play()
    Debris:AddItem(ColorCorrectionEffect, 2)

    for Index = 1, math.random(5, 7) do
        local slash = game.ReplicatedStorage.Assets.Effects.Meshes.ThreeDSlashEffect:Clone()
        local size = math.random(2, 4) * 12
        local sizeadd = math.random(2, 4) * 24
        local x, y, z =
            math.rad(math.random(8, 12) * 30), math.rad(math.random(8, 12) * 30), math.rad(math.random(8, 12) * 30)
        local add = math.random(1, 2)
        if add == 2 then
            add = -1
        end
        slash.Transparency = 0.4
        slash.Size = Vector3.new(2, size, size)
        slash.CFrame = Root.CFrame * CFrame.Angles(x, y, z)
        slash.Parent = RiceSpiritSlash
        local B5 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

        TweenService:Create(
            slash,
            B5,
            {
                Transparency = 1,
                CFrame = slash.CFrame * CFrame.Angles(math.pi * add, 0, 0),
                Size = slash.Size + Vector3.new(0, sizeadd, sizeadd),
            }
        ):Play()
        Debris:AddItem(slash, 0.3)
    end

    for Index = 1, 5 do
        local slash = script.Slash:Clone()
        local size = math.random(2, 4) * 4
        local sizeadd = math.random(2, 4) * 30
        local x, y, z =
            math.rad(math.random(8, 12) * 30), math.rad(math.random(8, 12) * 30), math.rad(math.random(8, 12) * 30)
        local add = math.random(1, 2)
        if add == 2 then
            add = -1
        end
        slash.Transparency = 0.5
        slash.Size = Vector3.new(2, size, size)
        slash.CFrame = Root.CFrame * CFrame.Angles(x, y, z)
        slash.Parent = RiceSpiritSlash
        local B5 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

        TweenService:Create(
            slash,
            B5,
            {
                Transparency = 1,
                CFrame = slash.CFrame * CFrame.Angles(math.pi * add, 0, 0),
                Size = slash.Size + Vector3.new(0, sizeadd, sizeadd),
            }
        ):Play()
        Debris:AddItem(slash, 0.3)
    end

    local slash = script.Slash:Clone()
    local size = math.random(2, 4) * 4
    local sizeadd = math.random(1, 5) * 30
    local x, y, z =
        math.rad(math.random(8, 12) * 30), math.rad(math.random(8, 12) * 30), math.rad(math.random(8, 12) * 30)
    local add = math.random(1, 2)
    if add == 2 then
        add = -1
    end
    slash.Transparency = 0.6
    slash.Color = Color3.fromRGB(4, 175, 236)
    slash.Size = Vector3.new(2, size, size)
    slash.CFrame = Root.CFrame * CFrame.Angles(x, y, z)
    slash.Parent = RiceSpiritSlash
    local B5 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

    TweenService:Create(
        slash,
        B5,
        {
            Transparency = 1,
            CFrame = slash.CFrame * CFrame.Angles(math.pi * add, 0, 0),
            Size = slash.Size + Vector3.new(0, sizeadd, sizeadd),
        }
    ):Play()
    Debris:AddItem(slash, 0.3)

    for _ = 1, math.random(5, 6) do
        for Index = 1, math.random(1, 2) do
            local x, y, z = math.random(-2, 2) * 27, math.random(-2, 2) * 27, math.random(-2, 2) * 27
            local position = Root.Position + Vector3.new(x, y, z)
            createhugelightning(Root.Position, position, math.random(3, 5) * 2)
        end
        local P = Instance.new("Part")
        P.Size = Vector3.new(4, 0, 4)
        P.CanCollide = false
        P.CastShadow = false
        P.Anchored = true
        P.Material = Enum.Material.Neon
        P.Color = Color3.fromRGB(253, 234, 141)
        local x, y, z =
            math.rad(math.random(1, 12) * 30), math.rad(math.random(1, 12) * 30), math.rad(math.random(1, 12) * 30)
        P.CFrame = CFrame.new(Root.Position) * CFrame.Angles(x, y, z)
        P.Parent = RiceSpiritSlash
        local A3 = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
        TweenService:Create(P, A3, { Size = Vector3.new(0, math.random(2, 7) * 65, 0) }):Play()
        Debris:AddItem(P, 0.2)
        wait(0.01)
    end
end
