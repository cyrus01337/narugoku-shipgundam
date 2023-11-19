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

local CurrentCamera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
    CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
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
        local Color = Index % 2 == 0 and "Cool yellow" or "Cool yellow"

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

        local Ti2 = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
        local Ti3 = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 4, true, 0)

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
        Part.Color = Color3.fromRGB(255, 85, 0)
        Part.TopSurface = Enum.SurfaceType.SmoothNoOutlines
        Part.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
        Part.CanCollide = false
        Part.Anchored = true
        Part.CastShadow = false
        Part.Size = Vector3.new(0.7, 0.7, newdisance)
        Part.CFrame = CFrame.new(lastcf, newcframe.p) * CFrame.new(0, 0, -newdisance / 2)
        Part.Parent = Lightning

        local Ti2 = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

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

--|| Variables ||--
local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local RingTween = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

return function(Data)
    local Character = Data.Character
    local Root = Character:FindFirstChild("HumanoidRootPart")
    local ReachedTarget = false

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = { Character, workspace.World.Visuals }
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

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

    coroutine.resume(coroutine.create(function()
        for _ = 1, math.random(5, 6) do
            for _ = 1, math.random(1, 2) do
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
            P.Parent = workspace.World.Visuals
            local A3 = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
            TweenService:Create(P, A3, { Size = Vector3.new(0, math.random(2, 7) * 65, 0) }):Play()
            Debris:AddItem(P, 0.2)
            wait(0.01)
        end
    end))

    local Calculation = Root.CFrame - Root.Position

    coroutine.resume(coroutine.create(function()
        for Index = 1, 2 do
            local Ring = ReplicatedStorage.Assets.Effects.Meshes.ring:Clone()
            Ring.Size = Vector3.new(12, 0.3, 12)
            Ring.Position = Root.Position
            Ring.Parent = workspace.World.Visuals

            Debris:AddItem(Ring, 0.8)

            local Tween = TweenService:Create(
                Ring,
                TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { ["Transparency"] = 1, ["Size"] = Vector3.new(35, 0.3, 35) }
            )
            Tween:Play()
            Tween:Destroy()
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
        Color = BrickColor.new("Neon orange").Color,
        Amount = 8,
    })

    local Result = workspace:Raycast(Root.Position, Root.CFrame.upVector * -15, raycastParams)
    if Result and Result.Instance then
        for _ = 1, 3 do
            local Rock = Effects.Rock:Clone()
            Rock.Position = Root.Position
            Rock.Material = Result.Material
            Rock.Color = Result.Instance.Color
            Rock.CanCollide = false
            Rock.Size = Vector3.new(2, 2, 2)
            Rock.Orientation = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
            Rock.Velocity = Vector3.new(math.random(-100, 100), math.random(100, 100), math.random(-100, 100))
            Rock.Parent = workspace.World.Visuals

            local BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.Velocity = Vector3.new(math.random(-40, 40), math.random(40, 75), math.random(-40, 40))
            BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
            BodyVelocity.Parent = Rock

            local BlockTrail = Particles.BlockSmoke:Clone()
            BlockTrail.Color = ColorSequence.new(Result.Instance.Color)
            BlockTrail.Enabled = true
            BlockTrail.Parent = Rock

            Debris:AddItem(Rock, 3)
            Debris:AddItem(BodyVelocity, 0.1)
        end
    end

    if GlobalFunctions.CheckDistance(Players:GetPlayerFromCharacter(Character), Data.Distance) then
        CameraShake:Start()
        CameraShake:ShakeOnce(6, 8, 0, 1.5)
    end

    LightningExplosion.new(
        Root.Position,
        0.35,
        12,
        ColorSequence.new(Color3.fromRGB(255, 251, 134)),
        ColorSequence.new(Color3.fromRGB(255, 85, 0), Color3.fromRGB(255, 255, 255)),
        nil
    )

    for Index = 1, 2 do
        local Ring = ReplicatedStorage.Assets.Effects.Meshes.myring:Clone()
        Ring.Size = Vector3.new(50, 3, 50)
        Ring.Material = Enum.Material.Neon
        Ring.BrickColor = BrickColor.new(Index % 2 == 0 and "Daisy orange" or "Yellow")
        Ring.CanCollide = false
        Ring.CFrame = CFrame.new(Root.Position) * Calculation
        Ring.Anchored = true
        Ring.Parent = workspace.World.Visuals

        Debris:AddItem(Ring, 0.4)

        local Tween = TweenService:Create(
            Ring,
            RingTween,
            { ["Transparency"] = 1, ["CFrame"] = Ring.CFrame * CFrame.new(0, 15, 0), ["Size"] = Vector3.new(0, 0, 0) }
        )
        Tween:Play()
        Tween:Destroy()

        wait(0.2)
    end
end
