--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models
local Effects = ReplicatedStorage.Assets.Effects

local Metadata = Modules.Metadata
local Shared = Modules.Shared
local Utility = Modules.Utility

local HitPart2 = Models.Misc.HitPart2

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(Shared.SoundManager)
local RaycastService = require(Shared.RaycastManager)

local TaskScheduler = require(Utility.TaskScheduler)

local Explosions = require(Modules.Effects.Explosions)
local VfxHandler = require(Modules.Effects.VfxHandler)
local CameraShaker = require(Modules.Effects.CameraShaker)

local EffectMeshes = ReplicatedStorage.Assets.Effects.Meshes
local EffectParticles = ReplicatedStorage.Assets.Effects.Particles
local EffectBeams = ReplicatedStorage.Assets.Effects.Beams
local Particles = ReplicatedStorage.Assets.Effects.Particles

local World = workspace.World
local Visuals = World.Visuals

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--||Assets||--
local ShortFlashStep = Effects.Particles.skinnyflashstep
local FatFlashStep = Effects.Particles.fatflashstep

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

local Humanoid = Character:WaitForChild("Humanoid")

local function RemoveTrash(Trash)
    for i = 1, #Trash do
        local Item = Trash[i]
        if Item and Item.Parent then
            Item:Destroy()
        end
    end
end

local WhitebeardVFX = {
    ["QuakePunch"] = function(PathData)
        local Character = PathData.Character
        local Root = Character:FindFirstChild("HumanoidRootPart")

        local RootPos = Character.HumanoidRootPart.CFrame
        --[[ Play Sound ]]
        --
        -- SoundManager:AddSound("GomuSFX", {Parent = Root, TimePosition = .5, Volume = 3}, "Client")

        --[[ Weld GuraHand  to Hand ]]
        --
        local GuraHand = workspace.GuraHand:Clone()
        GuraHand.Anchored = false
        GuraHand.Parent = Visuals

        local Motor6D = Instance.new("Motor6D")
        Motor6D.Part0 = Character["Left Arm"]
        Motor6D.Part1 = GuraHand
        Motor6D.C1 = CFrame.new(0, 1, 0)
        Motor6D.Parent = Character

        for i = 1, 4 do
            GuraHand.Hold.Shockwave:Emit(1)
            wait(0.2)
        end
        GuraHand.Hold.Star.Enabled = false
        local tween = TweenService:Create(
            GuraHand,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Transparency"] = 1 }
        )
        tween:Play()
        tween:Destroy()

        game.Debris:AddItem(GuraHand, 0.5)

        --[[ Gura Crack ]]
        --
        local GuraCrack = workspace.GuraCrack:Clone()
        GuraCrack.CFrame = RootPos * CFrame.new(0, 0, -2) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
        GuraCrack.Parent = Visuals

        local tween = TweenService:Create(
            GuraCrack,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Size"] = Vector3.new(20, 0.1, 20) }
        )
        tween:Play()
        tween:Destroy()
        coroutine.wrap(function()
            wait(1)
            local tween = TweenService:Create(
                GuraCrack,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Transparency"] = 1 }
            )
            tween:Play()
            tween:Destroy()
        end)()
        game.Debris:AddItem(GuraCrack, 2)
        --[[ Gura Ball ]]
        --
        local GuraBall = workspace.GuraBall:Clone()
        GuraBall.Massless = true
        GuraBall.Anchored = true
        GuraBall.Parent = Visuals

        coroutine.wrap(function()
            while GuraBall.Parent do
                --[[ Ring Behind Player ]]
                --
                local cs = ReplicatedStorage.Assets.Effects.Meshes.Ring2:Clone()
                cs.Size = Vector3.new(5, 2, 5)
                local c1, c2 =
                    GuraBall.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(math.pi / 2, 0, 0),
                    GuraBall.CFrame * CFrame.new(0, 0, 10) * CFrame.Angles(math.pi / 2, 0, 0)
                cs.CFrame = c1
                cs.Material = Enum.Material.Neon
                cs.Parent = workspace.World.Visuals

                local Tween = TweenService:Create(
                    cs,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
                    { Transparency = 1, Size = Vector3.new(25, 0, 25), CFrame = c2 }
                )
                Tween:Play()
                Tween:Destroy()

                Debris:AddItem(cs, 0.15)
                wait(0.15)
            end
        end)()
        coroutine.wrap(function()
            while GuraBall.Parent do
                --[[ Classic Shockwave ]]
                --
                local GoalCFrame = GuraBall.CFrame * CFrame.new(0, 0, 10) * CFrame.Angles(math.pi / 2, 0, 0)
                local classicshockwave = ReplicatedStorage.Assets.Effects.Meshes.classicshockwave:Clone()
                classicshockwave.CFrame = GuraBall.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(math.pi / 2, 0, 0)
                classicshockwave.Parent = Visuals

                local Tween = TweenService:Create(
                    classicshockwave,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
                    { Transparency = 1, Size = Vector3.new(50, 2, 50) }
                )
                Tween:Play()
                Tween:Destroy()

                Debris:AddItem(classicshockwave, 0.15)
                wait(0.1)
            end
        end)()

        --[[ Side Shockwaves ]]
        --
        for j = 1, 2 do
            local Offset = 5
            local Rot = 288
            local GoalSize = Vector3.new(35, 0.05, 7.5)
            if j == 1 then
            else
                Offset = Offset * -1
                Rot = 252
            end

            local SideWind = EffectMeshes.SideWind:Clone()
            SideWind.Size = Vector3.new(8, 0.05, 2)
            SideWind.Transparency = 0.5
            SideWind.CFrame = Character.HumanoidRootPart.CFrame
                * CFrame.new(Offset, -0.5, 0)
                * CFrame.fromEulerAnglesXYZ(math.rad(90), math.rad(180), math.rad(Rot))
            SideWind.Parent = Visuals

            --[[ Tween the Side Shockwaves ]]
            --
            local tween = TweenService:Create(
                SideWind,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["CFrame"] = SideWind.CFrame * CFrame.new(-10, 0, 0), ["Size"] = GoalSize, ["Transparency"] = 1 }
            )
            tween:Play()
            tween:Destroy()

            Debris:AddItem(SideWind, 0.2)
        end
        --[[ Rocks Following Trail ]]
        --
        for loops = 1, 2 do
            coroutine.wrap(function()
                local OffsetX = 1
                --[[ Change Offset. Two Rocks on Both Sides. ]]
                --
                if loops == 2 then
                    OffsetX = -1
                end

                local GroundRocks = {}
                for i = 1, 10 do
                    --[[ Raycast ]]
                    --
                    local StartPosition = (RootPos * CFrame.new(OffsetX * (i + 1.5), 0, -i * 5)).Position
                    local EndPosition = CFrame.new(StartPosition).UpVector * -10

                    local RayData = RaycastParams.new()
                    RayData.FilterDescendantsInstances = { Character, World.Live, World.Visuals } or World.Visuals
                    RayData.FilterType = Enum.RaycastFilterType.Exclude
                    RayData.IgnoreWater = true

                    local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
                    if ray then
                        local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
                        if partHit then
                            local Block = EffectMeshes.Block:Clone()

                            local RATE = 2
                            local X, Y, Z = 1 + (i / RATE), 1 + (i / RATE), 1 + (i / RATE)
                            Block.Size = Vector3.new(X, Y, Z)

                            Block.Position = pos
                            Block.Anchored = true
                            Block.Rotation =
                                Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
                            Block.Transparency = 0
                            Block.Color = partHit.Color --Color3.fromRGB(152, 194, 219)--partHit.Color
                            Block.Material = partHit.Material
                            Block.Parent = Visuals
                            GroundRocks[i] = Block
                        end
                    end
                    wait(0.01)
                end
                --[[ Delete Rocks ]]
                --
                wait(2.5)
                if #GroundRocks > 0 then
                    for i, v in ipairs(GroundRocks) do
                        local Tween = TweenService:Create(
                            v,
                            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
                            { ["Color"] = Color3.fromRGB(152, 194, 219) }
                        )
                        Tween:Play()
                        Tween:Destroy()
                        v.Anchored = false
                        wait()
                    end
                end
            end)()
        end

        --[[ Expand Lines Out ]]
        --
        coroutine.wrap(function()
            for j = 1, 10 do
                for i = 1, 2 do
                    local originalPos = RootPos.Position
                    local beam = EffectMeshes.Block:Clone()
                    beam.Shape = "Block"
                    local mesh = Instance.new("SpecialMesh")
                    mesh.MeshType = "Sphere"
                    mesh.Parent = beam
                    beam.Size = Vector3.new(2, 2, 5)
                    beam.Material = Enum.Material.Neon
                    if i % 2 == 0 then
                        beam.Color = Color3.fromRGB(129, 169, 255)
                    else
                        beam.Color = Color3.fromRGB(255, 255, 255)
                    end
                    beam.Transparency = 0
                    beam.Parent = Visuals

                    beam.CFrame = CFrame.new(
                        originalPos + Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)),
                        originalPos
                    )
                    local tween = TweenService:Create(
                        beam,
                        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {
                            ["Size"] = beam.Size + Vector3.new(0, 0, math.random(1, 2)),
                            ["CFrame"] = beam.CFrame * CFrame.new(0, 0, math.random(20, 25)),
                        }
                    )
                    local tween2 = TweenService:Create(
                        beam,
                        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                        { ["Size"] = Vector3.new(0, 0, math.random(3, 6)) }
                    )
                    tween:Play()
                    tween:Destroy()
                    tween2:Play()
                    tween2:Destroy()
                    Debris:AddItem(beam, 0.15)
                end
            end
        end)()
        --[[ Quickly Tween Size ]]
        --
        coroutine.wrap(function()
            local Size = Vector3.new(5, 5, 5)
            local tween = TweenService:Create(
                GuraBall,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Size"] = GuraBall.Size + Size }
            )
            tween:Play()
            tween:Destroy()

            local tween = TweenService:Create(
                GuraBall.Core,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Size"] = GuraBall.Core.Size + Size }
            )
            tween:Play()
            tween:Destroy()

            wait(0.15)
            local tween = TweenService:Create(
                GuraBall,
                TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Size"] = GuraBall.Size - Size }
            )
            tween:Play()
            tween:Destroy()

            local tween = TweenService:Create(
                GuraBall.Core,
                TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Size"] = GuraBall.Core.Size - Size }
            )
            tween:Play()
            tween:Destroy()
        end)()
        --[[ Tween Slash ]]
        --
        local Lifetime = 0.5

        local Distance = 50
        local RootCFrame = Root.CFrame * CFrame.new(0, 0, -Distance)

        local Dir = (RootCFrame.Position - Root.Position).Unit
        local StartPoint = Root.CFrame * CFrame.new(0, 0, -2)
        GuraBall.CFrame = CFrame.lookAt(StartPoint.Position, StartPoint.Position + Dir)
        GuraBall.Core.CFrame = GuraBall.CFrame

        local tween = TweenService:Create(
            GuraBall,
            TweenInfo.new(Lifetime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            { ["CFrame"] = GuraBall.CFrame * CFrame.new(0, 0, -Distance) }
        )
        tween:Play()
        tween:Destroy()

        local tween = TweenService:Create(
            GuraBall.Core,
            TweenInfo.new(Lifetime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            { ["CFrame"] = GuraBall.Core.CFrame * CFrame.new(0, 0, -Distance) }
        )
        tween:Play()
        tween:Destroy()

        Debris:AddItem(GuraBall, Lifetime + 0.25)

        wait(Lifetime)
        local tween = TweenService:Create(
            GuraBall,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Size"] = Vector3.new(0, 0, 0) }
        )
        tween:Play()
        tween:Destroy()

        local tween = TweenService:Create(
            GuraBall.Core,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Size"] = Vector3.new(0, 0, 0) }
        )
        tween:Play()
        tween:Destroy()
    end,

    ["HelmetSplitter"] = function(PathData)
        local Character = PathData.Character
        local Root = Character:FindFirstChild("HumanoidRootPart")

        local RootPos = Character.HumanoidRootPart.Position
        --[[ Play Sound ]]
        --
        -- SoundManager:AddSound("GomuSFX", {Parent = Root, TimePosition = .5, Volume = 3}, "Client")

        --[[ Weld GuraHand  to Hand ]]
        --
        local GuraHand = workspace.GuraHand:Clone()
        GuraHand.Anchored = false
        GuraHand.Parent = Visuals

        local Motor6D = Instance.new("Motor6D")
        Motor6D.Part0 = Character["Left Arm"]
        Motor6D.Part1 = GuraHand
        Motor6D.C1 = CFrame.new(0, 1, 0)
        Motor6D.Parent = Character
        coroutine.wrap(function()
            for i = 1, 20 do
                GuraHand.Hold.Shockwave:Emit(1)
                wait(0.2)
            end
            GuraHand.Hold.Star.Enabled = false
            local tween = TweenService:Create(
                GuraHand,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Transparency"] = 1 }
            )
            tween:Play()
            tween:Destroy()

            game.Debris:AddItem(GuraHand, 0.5)
        end)()
        wait(2.15)
        --[[ Effect When Ball Hit Ground ]]
        --
        local function GroundTouched(RootPos, PartHit)
            --[[ Rocks xD ]]
            --
            local Rocks = EffectParticles.ParticleAttatchments.Rocks:Clone()
            Rocks.Rocks.Color = ColorSequence.new(PartHit.Color)
            Rocks.Rocks.Size =
                NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0) })
            Rocks.Rocks.Drag = 5
            Rocks.Rocks.Rate = 100
            Rocks.Rocks.Acceleration = Vector3.new(0, -100, 0)
            Rocks.Rocks.Lifetime = NumberRange.new(3)
            Rocks.Rocks.Speed = NumberRange.new(100, 200)
            Rocks.Parent = Character.HumanoidRootPart
            Rocks.Rocks:Emit(200)
            Debris:AddItem(Rocks, 4)

            local Smoke = Particles.Smoke:Clone()
            Smoke.Smoke.Size =
                NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
            Smoke.Smoke.Color = ColorSequence.new(PartHit.Color)
            Smoke.Smoke.Acceleration = Vector3.new(0, -15, 0)
            Smoke.Smoke.Drag = 5
            Smoke.Smoke.Lifetime = NumberRange.new(3)
            Smoke.Smoke:Emit(150)
            Smoke.Smoke.Speed = NumberRange.new(100)
            Smoke.Position = RootPos
            Smoke.Parent = Visuals
            Debris:AddItem(Smoke, 4)

            RootPos = Character.HumanoidRootPart.Position
            local Offset = 20
            --[[ Flying Debris Rock ]]
            --
            for i = 1, 10 do
                local StartPosition = (Vector3.new(math.sin(360 * i) * Offset, 0, math.cos(360 * i) * Offset) + RootPos)
                local EndPosition = CFrame.new(StartPosition).UpVector * -10

                local RayData = RaycastParams.new()
                RayData.FilterDescendantsInstances = { Character, World.Live, World.Visuals } or World.Visuals
                RayData.FilterType = Enum.RaycastFilterType.Exclude
                RayData.IgnoreWater = true

                local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
                if ray then
                    local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
                    if partHit then
                        local Block = EffectMeshes.Block:Clone()

                        local X, Y, Z = math.random(1, 3), math.random(1, 3), math.random(1, 3)
                        Block.Size = Vector3.new(X, Y, Z)

                        Block.Position = pos
                        Block.Rotation =
                            Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
                        Block.Transparency = 0
                        Block.Color = partHit.Color
                        Block.Material = partHit.Material
                        Block.Anchored = false
                        Block.CanCollide = true
                        Block.Parent = Visuals

                        local BodyVelocity = Instance.new("BodyVelocity")
                        BodyVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
                        BodyVelocity.Velocity = Vector3.new(
                            math.random(-80, 80),
                            math.random(50, 60),
                            math.random(-80, 80)
                        ) * (i * 1)
                        BodyVelocity.P = 100000
                        Block.Velocity = Vector3.new(math.random(-80, 80), math.random(50, 60), math.random(-80, 80))
                            * (i * 1)
                        BodyVelocity.Parent = Block

                        Debris:AddItem(BodyVelocity, 0.05)
                        Debris:AddItem(Block, 2)
                    end
                end
                wait()
            end

            --[[ Smoke Effect on Ground ]]
            --
            local Smoke = Particles.Smoke:Clone()
            Smoke.Smoke.Size =
                NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 2) })
            Smoke.Smoke.Drag = 5
            Smoke.Smoke.Lifetime = NumberRange.new(3)
            Smoke.Smoke.Rate = 250
            Smoke.Smoke.Speed = NumberRange.new(75)
            Smoke.Smoke.SpreadAngle = Vector2.new(1, 180)
            Smoke.Smoke.Enabled = true
            Smoke.CFrame = Character.HumanoidRootPart.CFrame
                * CFrame.new(0, -2.5, 0)
                * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
            Smoke.Parent = Visuals
            --[[ Set Smoke Properties ]]
            --
            Smoke.Smoke.Color = ColorSequence.new(PartHit.Color)
            if PartHit == nil then
                Smoke:Destroy()
            end
            coroutine.wrap(function()
                for i = 1, 2 do
                    Smoke.Smoke:Emit(100)
                    wait(0.1)
                end
                Smoke.Smoke.Enabled = false
            end)()
            Debris:AddItem(Smoke, 4)
        end

        --[[ Double Gura Ground Punches ]]
        --
        for q = 1, 2 do
            coroutine.wrap(function()
                local Offset = 10 * q

                --[[ Terrain Rocks on Ground ]]
                --
                local GroundRocks = {}
                for i = 1, 15 + Offset do
                    --[[ Raycast ]]
                    --
                    local StartPosition = (
                        Vector3.new(math.sin(360 * i) * Offset, 0, math.cos(360 * i) * Offset) + RootPos
                    )
                    local EndPosition = CFrame.new(StartPosition).UpVector * -10

                    local RayData = RaycastParams.new()
                    RayData.FilterDescendantsInstances = { Character, World.Live, World.Visuals } or World.Visuals
                    RayData.FilterType = Enum.RaycastFilterType.Exclude
                    RayData.IgnoreWater = true

                    local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
                    if ray then
                        local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
                        if partHit then
                            local Block = EffectMeshes.Block:Clone()

                            local X, Y, Z = 2 + (Offset / 15), 2 + (Offset / 15), 2 + (Offset / 15)
                            Block.Size = Vector3.new(X, Y, Z)

                            Block.Position = pos
                            Block.Anchored = true
                            Block.Rotation =
                                Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
                            Block.Transparency = 0
                            Block.Color = partHit.Color
                            Block.Material = partHit.Material
                            Block.Parent = Visuals
                            GroundRocks[i] = Block
                            Debris:AddItem(Block, 5)
                        end
                    end
                end

                --[[ Delete Rocks ]]
                --
                wait(4)
                if #GroundRocks > 0 then
                    for i, v in ipairs(GroundRocks) do
                        local Tween = TweenService:Create(
                            v,
                            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
                            { ["Color"] = Color3.fromRGB(152, 194, 219) }
                        )
                        Tween:Play()
                        Tween:Destroy()
                        v.Anchored = false
                        wait()
                    end
                end
            end)()
            --[[ Expand Lines Out ]]
            --
            coroutine.wrap(function()
                for j = 1, 10 do
                    for i = 1, 3 do
                        local originalPos = RootPos
                        local beam = EffectMeshes.Block:Clone()
                        beam.Shape = "Block"
                        local mesh = Instance.new("SpecialMesh")
                        mesh.MeshType = "Sphere"
                        mesh.Parent = beam
                        beam.Size = Vector3.new(2, 2, 5)
                        beam.Material = Enum.Material.Neon
                        if i % 2 == 0 then
                            beam.Color = Color3.fromRGB(129, 169, 255)
                        else
                            beam.Color = Color3.fromRGB(255, 255, 255)
                        end
                        beam.Transparency = 0
                        beam.Parent = Visuals

                        beam.CFrame = CFrame.new(
                            originalPos + Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)),
                            originalPos
                        )
                        local tween = TweenService:Create(
                            beam,
                            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                            {
                                ["Size"] = beam.Size + Vector3.new(0, 0, math.random(1, 2)),
                                ["CFrame"] = beam.CFrame * CFrame.new(0, 0, math.random(20, 25)),
                            }
                        )
                        local tween2 = TweenService:Create(
                            beam,
                            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                            { ["Size"] = Vector3.new(0, 0, math.random(3, 6)) }
                        )
                        tween:Play()
                        tween:Destroy()
                        tween2:Play()
                        tween2:Destroy()
                        Debris:AddItem(beam, 0.15)
                    end
                end
            end)()
            --[[ Ball Effect ]]
            --
            local Ball = EffectMeshes.ball:Clone()
            Ball.Color = Color3.fromRGB(255, 255, 255)
            Ball.Material = Enum.Material.Neon
            Ball.Transparency = 0.5
            Ball.Size = Vector3.new(10, 10, 10)
            Ball.Position = RootPos
            Ball.Parent = Visuals

            local tween = TweenService:Create(
                Ball,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Transparency"] = 1, ["Size"] = Ball.Size * 5 }
            )
            tween:Play()
            tween:Destroy()
            Debris:AddItem(Ball, 0.2)

            --[[ Gura Crack ]]
            --
            local GuraCrack = workspace.GuraCrack:Clone()
            GuraCrack.CFrame = CFrame.new(RootPos)
                * CFrame.new(0, -2.5, 0)
                * CFrame.fromEulerAnglesXYZ(math.rad(180), 0, 0)
            GuraCrack.Parent = Visuals

            local tween = TweenService:Create(
                GuraCrack,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Size"] = Vector3.new(20 * q, 0.1, 20 * q) }
            )
            tween:Play()
            tween:Destroy()
            coroutine.wrap(function()
                wait(1)
                local tween = TweenService:Create(
                    GuraCrack,
                    TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { ["Transparency"] = 1 }
                )
                tween:Play()
                tween:Destroy()
            end)()
            game.Debris:AddItem(GuraCrack, 1.5)

            --[[ Raycast Directly Below by x Studs Away ]]
            --
            local StartPosition = Character.HumanoidRootPart.Position
            local EndPosition = CFrame.new(StartPosition).UpVector * -10

            local RayData = RaycastParams.new()
            RayData.FilterDescendantsInstances = { Character, World.Live, World.Visuals } or World.Visuals
            RayData.FilterType = Enum.RaycastFilterType.Exclude
            RayData.IgnoreWater = true

            local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
            if ray then
                local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
                if partHit then
                    --[[ Rocks Fall Down ]]
                    --
                    coroutine.wrap(function()
                        GroundTouched(pos, partHit)
                    end)()
                end
            end
            wait(0.75)
        end
    end,
}

return WhitebeardVFX
