--|| Service ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Lighting = game:GetService("Lighting")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Effects = Modules.Effects
local Shared = Modules.Shared

local EffectMeshes = ReplicatedStorage.Assets.Effects.Meshes
local EffectParticles = ReplicatedStorage.Assets.Effects.Particles
local EffectBeams = ReplicatedStorage.Assets.Effects.Beams

local HitPart2 = Models.Misc.HitPart2

--|| Imports ||--
local SoundManager = require(Shared.SoundManager)
local RaycastManager = require(Shared.RaycastManager)

local RayService = require(Shared.RaycastManager.RayService)

local Explosions = require(Effects.Explosions)
local VfxHandler = require(Effects.VfxHandler)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local World = workspace.World
local Visuals = World.Visuals

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local PlayerMouse = Player:GetMouse()

local Humanoid = Character:WaitForChild("Humanoid")

local NatsuVFX = {

    ["Fire Dragon's Iron Fist"] = function(Data)
        local Character = Data.Character
        local Victim = Data.Victim

        --[[ Play Sound ]]
        --
        -- SoundManager:AddSound("Fire1",{ Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = 0.5}, "Client")

        --[[ Orbs ]]
        --
        coroutine.wrap(function()
            wait(0.35)
            --[[ Orbies come IN ]]
            --
            for j = 1, 10 do
                for i = 1, 5 do
                    local RootPosition = Victim.Torso.CFrame

                    local originalPos = CFrame.new(
                        RootPosition.Position
                            + Vector3.new(math.random(-1, 1) * 10, math.random(-1, 1) * 10, math.random(-1, 1) * 10),
                        RootPosition.Position
                    )
                    local beam = EffectMeshes.Block:Clone()
                    beam.Shape = "Block"
                    local mesh = Instance.new("SpecialMesh")
                    mesh.MeshType = "Sphere"
                    mesh.Parent = beam
                    beam.Size = Vector3.new(1, 1, 10)
                    beam.Material = Enum.Material.Neon
                    beam.BrickColor = BrickColor.new("Royal purple")
                    beam.Transparency = 0
                    beam.Parent = workspace.World.Visuals

                    beam.CFrame = CFrame.new(
                        originalPos.Position + Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)),
                        RootPosition.Position
                    )
                    local tween = TweenService:Create(
                        beam,
                        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {
                            ["Size"] = beam.Size + Vector3.new(0, 0, math.random(1, 2)),
                            ["Position"] = RootPosition.Position,
                        }
                    )
                    local tween2 = TweenService:Create(
                        beam,
                        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                        { ["Size"] = Vector3.new(0, 0, 10) }
                    )
                    tween:Play()
                    tween:Destroy()
                    tween2:Play()
                    tween2:Destroy()
                    Debris:AddItem(beam, 0.15)
                end
                wait(0.15)
            end
        end)()

        --[[ Ring ]]
        --
        coroutine.wrap(function()
            wait(0.35)
            local WaitTime = 0.5
            for j = 1, 2 do
                for i = 1, 2 do
                    local Ring = EffectMeshes.RingInnit:Clone()
                    Ring.CFrame = Victim.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
                    Ring.Size = Vector3.new(10, 0, 10)
                    Ring.Transparency = 0
                    Ring.Parent = workspace.World.Visuals

                    local tween = TweenService:Create(
                        Ring,
                        TweenInfo.new(WaitTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { ["Size"] = Vector3.new(0, 0, 0) }
                    )
                    tween:Play()
                    tween:Destroy()
                    Debris:AddItem(Ring, WaitTime)

                    wait(0.1)
                end
                wait(WaitTime)
                WaitTime = WaitTime - (j / 10)
            end
        end)()

        wait(1.85)
        -- SoundManager:AddSound("FireDragonIronFist",{ Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = 3}, "Client")
        --[[ Play Sound ]]
        --
        wait(0.5)
        -- SoundManager:AddSound("Fire2",{ Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = 0.5}, "Client")

        --[[ Fire P00rticle XD ]]
        --
        local Fire = EffectParticles.FireMagicParticle:Clone()
        local Attachment = Fire.Attachment
        Attachment.Parent = Victim.HumanoidRootPart
        Fire:Destroy()

        Attachment.Fire.Speed = NumberRange.new(150, 200)
        Attachment.Fire.Drag = -5

        Attachment.Fire.Lifetime = NumberRange.new(0.35, 0.45)
        Attachment.Fire.Size =
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 20) })
        Attachment.Fire.Acceleration = Character.HumanoidRootPart.CFrame.LookVector * 5000
        Attachment.Fire.Rate = 200

        Attachment.Fire.SpreadAngle = Vector2.new(-360, 360)
        coroutine.wrap(function()
            Attachment.Fire.Enabled = true
            for i = 1, 2 do
                Attachment.Fire:Emit(50)
                wait(0.1)
            end
            Attachment.Fire.Enabled = false
        end)()
        Debris:AddItem(Attachment, 1)

        --[[ Ring ]]
        --
        coroutine.wrap(function()
            for j = 1, 2 do
                for i = 1, 2 do
                    local Ring = EffectMeshes.RingInnit:Clone()
                    Ring.CFrame = Victim.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
                    Ring.Size = Vector3.new(5, 0, 5)
                    Ring.Transparency = 0
                    Ring.Parent = workspace.World.Visuals

                    local tween = TweenService:Create(
                        Ring,
                        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { ["Transparency"] = 1, ["Size"] = Vector3.new(50, 0, 50) }
                    )
                    tween:Play()
                    tween:Destroy()
                    Debris:AddItem(Ring, 0.25)

                    wait(0.1)
                end
                wait(0.1)
            end
        end)()

        --[[ Expand Lines Out ]]
        --
        coroutine.wrap(function()
            for i = 1, 10 do
                local originalPos = Victim.Torso.Position
                local beam = EffectMeshes.Block:Clone()
                beam.Shape = "Block"
                local mesh = Instance.new("SpecialMesh")
                mesh.MeshType = "Sphere"
                mesh.Parent = beam
                beam.Size = Vector3.new(10, 10, 20)
                beam.Material = Enum.Material.Neon
                beam.BrickColor = BrickColor.new("Royal purple")
                beam.Transparency = 0
                beam.Parent = workspace.World.Visuals

                beam.CFrame = CFrame.new(
                    originalPos + Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)),
                    originalPos
                )
                local tween = TweenService:Create(
                    beam,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {
                        ["Size"] = beam.Size + Vector3.new(0, 0, math.random(1, 2)),
                        ["CFrame"] = beam.CFrame * CFrame.new(0, 0, 50),
                    }
                )
                local tween2 = TweenService:Create(
                    beam,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { ["Size"] = Vector3.new(0, 0, 20) }
                )
                tween:Play()
                tween:Destroy()
                tween2:Play()
                tween2:Destroy()
                Debris:AddItem(beam, 0.15)
            end
        end)()
    end,

    ["CrimsonLotusStart"] = function(Data)
        local Character = Data.Character

        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        --[[ Play Sound ]]
        --
        -- SoundManager:AddSound("Fire1",{ Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = 2}, "Client")

        --[[ Fire P00rticle XD ]]
        --
        coroutine.wrap(function()
            for i = 1, 2 do
                local Offset = 1
                if i == 1 then
                    Offset = Offset * 10
                else
                    Offset = Offset * -10
                end
                local Fire = EffectParticles.FireMagicParticle:Clone()
                local Attachment = Fire.Attachment
                Attachment.Parent = Character.Torso
                Attachment.Position = Attachment.Position + Vector3.new(Offset, 0, 0)
                Fire:Destroy()

                Attachment.Fire.Speed = NumberRange.new(20, 40)
                --Attachment.Fire.Drag = -5

                Attachment.Fire.Lifetime = NumberRange.new(0.5)
                Attachment.Fire.Size =
                    NumberSequence.new({ NumberSequenceKeypoint.new(0, 7), NumberSequenceKeypoint.new(1, 0) })
                Attachment.Fire.Acceleration = Vector3.new(0, -3000, 0)
                Attachment.Fire.Rate = 200

                Attachment.Fire.SpreadAngle = Vector2.new(-360, 360)
                coroutine.wrap(function()
                    Attachment.Fire.Enabled = true
                    for i = 1, 2 do
                        Attachment.Fire:Emit(50)
                        wait(0.25)
                    end
                    Attachment.Fire.Enabled = false
                end)()
                Debris:AddItem(Attachment, 1.75)
            end

            wait(0.5)

            --[[ Fire P00rticle XD ]]
            --
            coroutine.wrap(function()
                local Fire = EffectParticles.FireMagicParticle:Clone()
                local Attachment = Fire.Attachment
                Attachment.Parent = Character.HumanoidRootPart
                Fire:Destroy()

                Attachment.Fire.Speed = NumberRange.new(150, 200)
                Attachment.Fire.Drag = 5

                Attachment.Fire.Lifetime = NumberRange.new(0.5, 0.75)
                Attachment.Fire.Size =
                    NumberSequence.new({ NumberSequenceKeypoint.new(0, 6), NumberSequenceKeypoint.new(1, 10) })
                Attachment.Fire.Acceleration = Vector3.new(0, 0, 0)
                Attachment.Fire.Rate = 200

                Attachment.Fire.SpreadAngle = Vector2.new(-180, 180)
                coroutine.wrap(function()
                    Attachment.Fire.Enabled = true
                    for i = 1, 2 do
                        Attachment.Fire:Emit(50)
                        wait(0.1)
                    end
                    Attachment.Fire.Enabled = false
                end)()
                Debris:AddItem(Attachment, 1)

                --[[ Stars xD ]]
                --
                local Stars = EffectParticles.ParticleAttatchments.Stars:Clone()
                Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
                Stars.Stars.Size =
                    NumberSequence.new({ NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0) })
                Stars.Stars.Drag = 5
                Stars.Stars.Rate = 100
                Stars.Stars.Acceleration = Vector3.new(0, -100, 0)
                Stars.Stars.Lifetime = NumberRange.new(0.5, 0.75)
                Stars.Stars.Speed = NumberRange.new(100, 200)
                Stars.Parent = Character.HumanoidRootPart

                Stars.Stars.Enabled = true
                Stars.Stars:Emit(100)
                Debris:AddItem(Stars, 1)
                wait(0.2)
                Stars.Stars.Enabled = false

                wait(0.75)
                for i = 1, 3 do
                    local Fire = EffectParticles.FireMagicParticle:Clone()
                    local Attachment = Fire.Attachment
                    Attachment.Parent = Character.HumanoidRootPart
                    Fire:Destroy()

                    Attachment.Fire.Speed = NumberRange.new(150, 200)
                    Attachment.Fire.Drag = 5

                    Attachment.Fire.Lifetime = NumberRange.new(0.35, 0.55)
                    Attachment.Fire.Size =
                        NumberSequence.new({ NumberSequenceKeypoint.new(0, 8), NumberSequenceKeypoint.new(1, 12) })
                    Attachment.Fire.Acceleration = Vector3.new(0, 0, 0)
                    Attachment.Fire.Rate = 200

                    Attachment.Fire.SpreadAngle = Vector2.new(-180, 180)
                    coroutine.wrap(function()
                        Attachment.Fire.Enabled = true
                        for i = 1, 2 do
                            Attachment.Fire:Emit(25)
                            wait(0.1)
                        end
                        Attachment.Fire.Enabled = false
                    end)()
                    Debris:AddItem(Attachment, 1)

                    --[[ Stars xD ]]
                    --
                    local Stars = EffectParticles.ParticleAttatchments.Stars:Clone()
                    Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
                    Stars.Stars.Size =
                        NumberSequence.new({ NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0) })
                    Stars.Stars.Drag = 5
                    Stars.Stars.Rate = 100
                    Stars.Stars.Acceleration = Vector3.new(0, -100, 0)
                    Stars.Stars.Lifetime = NumberRange.new(0.5, 0.75)
                    Stars.Stars.Speed = NumberRange.new(100, 200)
                    Stars.Parent = Character.HumanoidRootPart

                    Stars.Stars:Emit(50)
                    Debris:AddItem(Stars, 1)
                    wait(0.25)
                end
            end)()

            --[[ Orbs ]]
            --
            coroutine.wrap(function()
                wait(0.35)
                --[[ Orbies come IN ]]
                --
                for j = 1, 3 do
                    for i = 1, 5 do
                        local RootPosition = Character.Torso.CFrame

                        local originalPos = CFrame.new(
                            RootPosition.Position
                                + Vector3.new(math.random(-3, 3) * 10, math.random(-3, 3) * 10, math.random(-3, 3) * 10),
                            RootPosition.Position
                        )
                        local beam = EffectMeshes.Block:Clone()
                        beam.Shape = "Block"
                        local mesh = Instance.new("SpecialMesh")
                        mesh.MeshType = "Sphere"
                        mesh.Parent = beam
                        beam.Size = Vector3.new(1, 1, 10)
                        beam.Material = Enum.Material.Neon
                        beam.BrickColor = BrickColor.new("Institutional white")
                        beam.Transparency = 0
                        beam.Parent = Visuals

                        beam.CFrame =
                            CFrame.new(
                                originalPos.Position
                                    + Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)),
                                RootPosition.Position
                            )
                        local tween = TweenService:Create(
                            beam,
                            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                            {
                                ["Size"] = beam.Size + Vector3.new(0, 0, math.random(1, 2)),
                                ["Position"] = RootPosition.Position,
                            }
                        )
                        local tween2 = TweenService:Create(
                            beam,
                            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                            { ["Size"] = Vector3.new(0, 0, 10) }
                        )
                        tween:Play()
                        tween:Destroy()
                        tween2:Play()
                        tween2:Destroy()
                        Debris:AddItem(beam, 0.15)
                    end
                    wait(0.1)
                end
            end)()
        end)()
    end,

    ["CrimsonLotusLand"] = function(Data)
        local Character = Data.Character

        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
        local ContactPoint = Data.ContactPoint

        --[[ Play Sound ]]
        --
        -- local Sound = SoundManager:AddSound("Fire2",{ Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = 3, TimePosition = .35}, "Client")

        --[[ Ball Effect ]]
        --
        local Ball = EffectMeshes.ball:Clone()
        Ball.Color = Color3.fromRGB(170, 0, 255)
        Ball.Material = Enum.Material.ForceField
        Ball.Transparency = 0
        Ball.Size = Vector3.new(20, 20, 20)
        Ball.Position = ContactPoint
        Ball.Parent = Visuals

        local tween = TweenService:Create(
            Ball,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Transparency"] = 1, ["Size"] = Ball.Size * 4 }
        )
        tween:Play()
        tween:Destroy()
        Debris:AddItem(Ball, 0.45)

        --[[ Sphere Effect ]]
        --
        local Sphere = EffectMeshes.Sphere:Clone()
        Sphere.Color = Color3.fromRGB(255, 85, 0)
        Sphere.Material = Enum.Material.Neon
        Sphere.Transparency = 0
        Sphere.Mesh.Scale = Vector3.new(25, 100, 25)
        Sphere.Position = ContactPoint
        Sphere.Parent = Visuals

        local tween = TweenService:Create(
            Sphere.Mesh,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Scale"] = Vector3.new(0, Sphere.Mesh.Scale.Y, 0) }
        )
        tween:Play()
        tween:Destroy()

        Debris:AddItem(Sphere, 0.1)

        --[[ Stars xD ]]
        --
        local Stars = EffectParticles.ParticleAttatchments.Stars:Clone()
        Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
        Stars.Stars.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0) })
        Stars.Stars.Drag = 5
        Stars.Stars.Rate = 100
        Stars.Stars.Acceleration = Vector3.new(0, -100, 0)
        Stars.Stars.Lifetime = NumberRange.new(1, 1.5)
        Stars.Stars.Speed = NumberRange.new(150, 200)
        Stars.Parent = Character.HumanoidRootPart

        Stars.Stars.Enabled = true
        Stars.Stars:Emit(100)
        Debris:AddItem(Stars, 2)

        --[[ Fire P00rticle XD ]]
        --
        local Fire = EffectParticles.FireMagicParticle:Clone()
        Fire.CFrame = CFrame.new(ContactPoint) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)

        Fire.Attachment.Fire.Speed = NumberRange.new(200, 250)
        Fire.Attachment.Fire.Drag = 5

        Fire.Attachment.Fire.Lifetime = NumberRange.new(1)
        Fire.Attachment.Fire.Size =
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 20), NumberSequenceKeypoint.new(1, 0) })
        Fire.Attachment.Fire.Acceleration = Vector3.new(0, 100, 0)
        Fire.Attachment.Fire.Rate = 200

        Fire.Attachment.Fire.SpreadAngle = Vector2.new(1, 180)
        coroutine.wrap(function()
            Fire.Attachment.Fire.Enabled = true
            for i = 1, 2 do
                Fire.Attachment.Fire:Emit(25)
                wait(0.05)
            end
            Fire.Attachment.Fire.Enabled = false
            Stars.Stars.Enabled = false
        end)()
        Fire.Parent = Visuals
        Debris:AddItem(Fire, 1)

        --[[ Flying Debris Rock ]]
        --
        for i = 1, 2 do
            for j = 1, 5 do
                --[[ Raycast ]]
                --
                local StartPosition = (
                    Vector3.new(math.sin(360 * i) * 15, 0, math.cos(360 * i) * 15) + Character.HumanoidRootPart.Position
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

                        local X, Y, Z = math.random(2, 5), math.random(2, 5), math.random(2, 5)
                        Block.Size = Vector3.new(X, Y, Z)

                        Block.Position = pos
                        Block.Rotation =
                            Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
                        Block.Transparency = 0
                        Block.Color = partHit.Color
                        Block.Material = partHit.Material
                        Block.Anchored = false
                        Block.Parent = Visuals

                        local BodyVelocity = Instance.new("BodyVelocity")
                        BodyVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
                        BodyVelocity.Velocity = Vector3.new(
                            math.random(-80, 80),
                            math.random(50, 60),
                            math.random(-80, 80)
                        ) * (j * 0.65)
                        BodyVelocity.P = 100000
                        Block.Velocity = Vector3.new(math.random(-80, 80), math.random(50, 60), math.random(-80, 80))
                            * (j * 0.65)
                        BodyVelocity.Parent = Block

                        Debris:AddItem(BodyVelocity, 0.05)
                        Debris:AddItem(Block, 2)
                    end
                end
            end
            wait()
        end

        --[[ RingInnit ]]
        --
        local RingInnit = EffectMeshes.RingInnit:Clone()
        RingInnit.Transparency = 0
        RingInnit.CFrame = Character.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(90), 0)
        RingInnit.Size = Vector3.new(25, 1, 25)
        RingInnit.Parent = Visuals
        Debris:AddItem(RingInnit, 0.35)

        local tween = TweenService:Create(
            RingInnit,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Size"] = Vector3.new(120, 1, 120), ["Transparency"] = 1 }
        )
        tween:Play()
        tween:Destroy()

        --[[ Expand Lines Out ]]
        --
        coroutine.wrap(function()
            for j = 1, 3 do
                for i = 1, 6 do
                    local originalPos = ContactPoint
                    local beam = EffectMeshes.Block:Clone()
                    beam.Shape = "Block"
                    local mesh = Instance.new("SpecialMesh")
                    mesh.MeshType = "Sphere"
                    mesh.Parent = beam
                    beam.Size = Vector3.new(5, 5, 25)
                    beam.Material = Enum.Material.Neon
                    beam.BrickColor = BrickColor.new("Institutional white")
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
                            ["Size"] = beam.Size + Vector3.new(0, 0, math.random(2, 5)),
                            ["CFrame"] = beam.CFrame * CFrame.new(0, 0, 100),
                        }
                    )
                    local tween2 = TweenService:Create(
                        beam,
                        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                        { ["Size"] = Vector3.new(0, 0, 25) }
                    )
                    tween:Play()
                    tween:Destroy()
                    tween2:Play()
                    tween2:Destroy()
                    Debris:AddItem(beam, 0.15)
                end
                --Utilities:Wait(0.15)
            end
        end)()

        --[[ Terrain Rocks on Ground ]]
        --
        local RootPos = Character.HumanoidRootPart.Position
        local GroundRocks = {}
        for i = 1, 20 do
            --[[ Raycast ]]
            --
            local StartPosition = (Vector3.new(math.sin(360 * i) * 35, 0, math.cos(360 * i) * 35) + RootPos)
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

                    local X, Y, Z = math.random(3, 6), math.random(3, 6), math.random(3, 6)
                    Block.Size = Vector3.new(X, Y, Z)

                    Block.Position = pos
                    Block.Anchored = true
                    --local visual = RayService:Visualize(StartPosition, pos, Color3.fromRGB(255, 0, 0))
                    Block.Rotation = Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
                    Block.Transparency = 0
                    Block.Color = partHit.Color
                    Block.Material = partHit.Material
                    Block.Parent = Visuals
                    GroundRocks[i] = Block
                    Debris:AddItem(Block, 2)
                end
            end
        end

        --[[ Delete Rocks ]]
        --
        wait(1.5)
        if #GroundRocks > 0 then
            for i, v in ipairs(GroundRocks) do
                v.Anchored = false
            end
        end
    end,

    ["FireDragonRoar"] = function(Data)
        local Character = Data.Character

        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        --[[ Play Sound ]]
        --
        -- SoundManager:AddSound("Fire1",{ Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = 0.75}, "Client")

        --[[ Play Sound ]]
        --
        -- SoundManager:AddSound("FireDragonRoar",{ Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = 2}, "Client")

        --[[ Small Burst of Fire and Star Particles ]]
        --
        local Fire = EffectParticles.FireMagicParticle:Clone()
        local Attachment = Fire.Attachment
        Attachment.Parent = Character.HumanoidRootPart
        Fire:Destroy()

        Attachment.Fire.Speed = NumberRange.new(100)
        Attachment.Fire.Drag = 5

        Attachment.Fire.Lifetime = NumberRange.new(0.35, 0.55)
        Attachment.Fire.Size =
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 0) })
        Attachment.Fire.Acceleration = Vector3.new(0, -100, 0)
        Attachment.Fire.Rate = 200

        Attachment.Fire.SpreadAngle = Vector2.new(-180, 180)
        Attachment.Fire:Emit(50)
        Debris:AddItem(Attachment, 2)

        --[[ Stars xD ]]
        --
        local Stars = EffectParticles.ParticleAttatchments.Stars:Clone()
        Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(170, 85, 255))
        Stars.Stars.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0) })
        Stars.Stars.Drag = 5
        Stars.Stars.Rate = 100
        Stars.Stars.Acceleration = Vector3.new(0, 0, 0)
        Stars.Stars.Lifetime = NumberRange.new(0.35, 0.45)
        Stars.Stars.Speed = NumberRange.new(120, 150)
        Stars.Parent = Character.HumanoidRootPart

        Stars.Stars:Emit(50)
        Debris:AddItem(Stars, 2)

        --[[ Fancy Wave ]]
        --
        local FancyWave = EffectParticles.ParticleAttatchments.FancyWave:Clone()
        FancyWave.FancyWave.Color = ColorSequence.new(Color3.fromRGB(170, 170, 255))
        FancyWave.FancyWave.Size =
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 0) })
        FancyWave.FancyWave.Transparency =
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
        FancyWave.FancyWave.Rate = 100
        FancyWave.FancyWave.Lifetime = NumberRange.new(0.2)
        FancyWave.FancyWave.Parent = Attachment

        FancyWave:Destroy()

        wait(0.25)

        --[[ Ring ]]
        --
        coroutine.wrap(function()
            local WaitTime = 0.15
            for j = 1, 5 do
                local RingInnit = EffectMeshes.RingInnit:Clone()
                RingInnit.CFrame = Character.HumanoidRootPart.CFrame
                    * CFrame.new(0, 1, -1)
                    * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
                RingInnit.Size = Vector3.new(15, 0.5, 15)
                RingInnit.Transparency = 0
                RingInnit.Parent = Visuals
                local tween = TweenService:Create(
                    RingInnit,
                    TweenInfo.new(WaitTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { ["Size"] = Vector3.new(0, 0.5, 0) }
                )
                tween:Play()
                tween:Destroy()
                Debris:AddItem(RingInnit, WaitTime)

                wait(WaitTime)
                --WaitTime = WaitTime - (j/10)
            end
        end)()

        --[[ Orbies come IN ]]
        --
        for j = 1, 8 do
            for i = 1, 5 do
                local RootPosition = Character.Torso.CFrame

                local originalPos =
                    CFrame.new(
                        RootPosition.Position
                            + Vector3.new(math.random(-3, 3) * 5, math.random(-3, 3) * 5, math.random(-3, 3) * 5),
                        RootPosition.Position
                    )
                local beam = EffectMeshes.Block:Clone()
                beam.Shape = "Block"
                local mesh = Instance.new("SpecialMesh")
                mesh.MeshType = "Sphere"
                mesh.Parent = beam
                beam.Size = Vector3.new(1, 1, 5)
                beam.Material = Enum.Material.Neon
                beam.Color = Color3.fromRGB(170, 85, 255)
                beam.Transparency = 0
                beam.Parent = Visuals
                beam.CFrame = CFrame.new(
                    originalPos.Position + Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)),
                    RootPosition.Position
                )
                local tween = TweenService:Create(
                    beam,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { ["Size"] = beam.Size + Vector3.new(0, 0, math.random(1, 2)), ["Position"] = RootPosition.Position }
                )
                local tween2 = TweenService:Create(
                    beam,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { ["Size"] = Vector3.new(0, 0, 5) }
                )
                tween:Play()
                tween:Destroy()
                tween2:Play()
                tween2:Destroy()
                Debris:AddItem(beam, 0.15)
            end
            Attachment.FancyWave:Emit(5)
            wait(0.1)
        end
        --[[ Expand Lines Out ]]
        --
        coroutine.wrap(function()
            for Index = 1, 15 do
                local originalPos = Character.HumanoidRootPart.Position
                local beam = EffectMeshes.Block:Clone()
                beam.Shape = "Block"
                local mesh = Instance.new("SpecialMesh")
                mesh.MeshType = "Sphere"
                mesh.Parent = beam
                beam.Size = Vector3.new(5, 5, 5)
                beam.Material = Enum.Material.Neon
                beam.Color = Color3.fromRGB(170, 170, 255)
                beam.Transparency = 0
                beam.Parent = Visuals

                beam.CFrame =
                    CFrame.new(originalPos + Vector3.new(math.random(-1, 1), 1, math.random(-1, 1)), originalPos)
                local tween = TweenService:Create(
                    beam,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {
                        ["Size"] = beam.Size + Vector3.new(0, 0, math.random(2, 5)),
                        ["CFrame"] = beam.CFrame * CFrame.new(0, 0, math.random(20, 40)),
                    }
                )
                local tween2 = TweenService:Create(
                    beam,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { ["Size"] = Vector3.new(0, 0, 10) }
                )
                tween:Play()
                tween:Destroy()
                tween2:Play()
                tween2:Destroy()
                Debris:AddItem(beam, 0.2)
            end
        end)()

        --[[ FRONT OF GOING CIRCLE Fire P00rticle XD ]]
        --
        local FrontFire = EffectParticles.FireMagicParticle:Clone()
        local FrontAttachment = FrontFire.Attachment
        FrontFire.CFrame = Character.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(90))

        FrontAttachment.Fire.Speed = NumberRange.new(150, 180)
        FrontAttachment.Fire.Drag = 5

        FrontAttachment.Fire.Lifetime = NumberRange.new(0.5)
        FrontAttachment.Fire.Size =
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 0) })
        FrontAttachment.Fire.Acceleration = Vector3.new(0, 100, 0)
        FrontAttachment.Fire.Rate = 200

        FrontAttachment.Fire.SpreadAngle = Vector2.new(1, 180)
        coroutine.wrap(function()
            FrontAttachment.Fire.Enabled = true
            for i = 1, 2 do
                FrontAttachment.Fire:Emit(25)
                wait(0.05)
            end
            FrontAttachment.Fire.Enabled = false
        end)()
        FrontFire.Parent = Visuals
        Debris:AddItem(FrontFire, 1)

        --[[ Fire P00rticle XD ]]
        --
        local RoarFire = EffectParticles.FireMagicParticle:Clone()
        RoarFire.Shape = "Block"
        RoarFire.Attachment.Fire.Parent = RoarFire

        RoarFire.Size = Vector3.new(10, 10, 100)
        RoarFire.Transparency = 1
        RoarFire.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -45)
        RoarFire.Parent = Visuals

        RoarFire.Fire.Speed = NumberRange.new(100)
        RoarFire.Fire.Drag = 5

        RoarFire.Fire.Lifetime = NumberRange.new(0.5, 0.75)
        RoarFire.Fire.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 15), NumberSequenceKeypoint.new(1, 0) })
        RoarFire.Fire.Acceleration = Character.HumanoidRootPart.CFrame.LookVector * 250
        RoarFire.Fire.Rate = 500

        RoarFire.Fire.SpreadAngle = Vector2.new(-360, 360)

        --[[ Stars xD ]]
        --
        local Stars = EffectParticles.ParticleAttatchments.Stars:Clone()
        Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
        Stars.Stars.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
        Stars.Stars.Drag = 5
        Stars.Stars.Rate = 100
        Stars.Stars.Enabled = true
        Stars.Stars.Acceleration = Character.HumanoidRootPart.CFrame.LookVector * 50
        Stars.Stars.Lifetime = NumberRange.new(1, 1.5)
        Stars.Stars.Speed = NumberRange.new(50, 75)
        Stars.Stars.Parent = RoarFire
        Stars:Destroy()

        coroutine.wrap(function()
            RoarFire.Fire.Enabled = true
            for _ = 1, 2 do
                RoarFire.Fire:Emit(50)
                RoarFire.Stars:Emit(10)
                wait(0.1)
            end
            RoarFire.Fire.Enabled = false
            RoarFire.Stars.Enabled = false
        end)()
        Debris:AddItem(RoarFire, 2)
        --[[ Ring ]]
        --
        for Index = 0, 7 do
            local RingInnit = EffectMeshes.RingInnit:Clone()
            RingInnit.CFrame = Character.HumanoidRootPart.CFrame
                * CFrame.new(0, 0, -(Index * 10))
                * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
            RingInnit.Size = Vector3.new(5, 0, 5)
            RingInnit.Transparency = 0
            RingInnit.Parent = Visuals

            local tween = TweenService:Create(
                RingInnit,
                TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Transparency"] = 1, ["Size"] = Vector3.new(50, 0, 50) }
            )
            tween:Play()
            tween:Destroy()
            Debris:AddItem(RingInnit, 0.15)
            wait(0.025)
        end
    end,

    ["PurgatoryDragonFire"] = function(Data)
        local Character = Data.Character

        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        --[[ Play Sound ]]
        --
        -- SoundManager:AddSound("Fire1",{ Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = 2}, "Client")

        --[[ Fire on Arm ]]
        --
        local Fire = EffectParticles.FireMagicParticle:Clone()
        local Attachment = Fire.Attachment
        Attachment.Parent = Character["Right Arm"]
        Fire:Destroy()
        Attachment.Fire.Speed = NumberRange.new(20, 25)
        Attachment.Fire.Drag = 5
        Attachment.Fire.Lifetime = NumberRange.new(0.25, 0.35)
        Attachment.Fire.Size =
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
        Attachment.Fire.Acceleration = Vector3.new(0, 50, 0)
        Attachment.Fire.Rate = 200
        Attachment.Fire.LockedToPart = false
        Attachment.Fire.SpreadAngle = Vector2.new(-360, 360)
        coroutine.wrap(function()
            Attachment.Fire.Enabled = true
            for _ = 1, 2 do
                Attachment.Fire:Emit(50)
                wait(0.25)
            end
            Attachment.Fire.Enabled = false
        end)()

        Debris:AddItem(Attachment, 1.75)

        --[[ Orbies come IN ]]
        --
        for j = 1, 10 do
            for i = 1, 5 do
                local RootPosition = Character["Right Arm"].CFrame

                local originalPos =
                    CFrame.new(
                        RootPosition.Position
                            + Vector3.new(math.random(-3, 3) * 5, math.random(-3, 3) * 5, math.random(-3, 3) * 5),
                        RootPosition.Position
                    )
                local beam = EffectMeshes.Block:Clone()
                beam.Shape = "Block"
                local mesh = Instance.new("SpecialMesh")
                mesh.MeshType = "Sphere"
                mesh.Parent = beam
                beam.Size = Vector3.new(1, 1, 5)
                beam.Material = Enum.Material.Neon
                beam.Color = Color3.fromRGB(255, 85, 0)
                beam.Transparency = 0
                beam.Parent = Visuals
                beam.CFrame = CFrame.new(
                    originalPos.Position + Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)),
                    RootPosition.Position
                )
                local tween = TweenService:Create(
                    beam,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { ["Size"] = beam.Size + Vector3.new(0, 0, math.random(1, 2)), ["Position"] = RootPosition.Position }
                )
                local tween2 = TweenService:Create(
                    beam,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { ["Size"] = Vector3.new(0, 0, 5) }
                )
                tween:Play()
                tween:Destroy()
                tween2:Play()
                tween2:Destroy()
                Debris:AddItem(beam, 0.15)
            end
            wait(0.1)
        end

        --[[ Smash Ground ]]
        --

        --[[ Ball Effect ]]
        --
        local Ball = EffectMeshes.ball:Clone()
        Ball.Color = Color3.fromRGB(170, 0, 255)
        Ball.Material = Enum.Material.ForceField
        Ball.Transparency = 0
        Ball.Size = Vector3.new(20, 20, 20)
        Ball.Position = Character.HumanoidRootPart.Position
        Ball.Parent = Visuals

        local tween = TweenService:Create(
            Ball,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Transparency"] = 1, ["Size"] = Ball.Size * 4 }
        )
        tween:Play()
        tween:Destroy()
        Debris:AddItem(Ball, 0.45)

        --[[ Sphere Effect ]]
        --
        local Sphere = EffectMeshes.Sphere:Clone()
        Sphere.Color = Color3.fromRGB(170, 85, 255)
        Sphere.Material = Enum.Material.Neon
        Sphere.Transparency = 0
        Sphere.Mesh.Scale = Vector3.new(25, 100, 25)
        Sphere.Position = Character.HumanoidRootPart.Position
        Sphere.Parent = Visuals

        local tween = TweenService:Create(
            Sphere.Mesh,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Scale"] = Vector3.new(0, Sphere.Mesh.Scale.Y, 0) }
        )
        tween:Play()
        tween:Destroy()

        Debris:AddItem(Sphere, 0.1)

        --[[ Stars xD ]]
        --
        local Stars = EffectParticles.ParticleAttatchments.Stars:Clone()
        Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
        Stars.Stars.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0) })
        Stars.Stars.Drag = 5
        Stars.Stars.Rate = 100
        Stars.Stars.Acceleration = Vector3.new(0, -100, 0)
        Stars.Stars.Lifetime = NumberRange.new(1, 1.5)
        Stars.Stars.Speed = NumberRange.new(150, 200)
        Stars.Parent = Character.HumanoidRootPart

        Stars.Stars.Enabled = true
        Stars.Stars:Emit(100)
        Debris:AddItem(Stars, 2)

        --[[ Fire P00rticle XD ]]
        --
        local Fire = EffectParticles.FireMagicParticle:Clone()
        local Attachment = Fire.Attachment
        Fire.CFrame = Character.HumanoidRootPart.CFrame
            * CFrame.new(0, -3, 0)
            * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)

        Attachment.Fire.Speed = NumberRange.new(200, 250)
        Attachment.Fire.Drag = 5

        Attachment.Fire.Lifetime = NumberRange.new(1)
        Attachment.Fire.Size =
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 20), NumberSequenceKeypoint.new(1, 0) })
        Attachment.Fire.Acceleration = Vector3.new(0, 100, 0)
        Attachment.Fire.Rate = 200

        Attachment.Fire.SpreadAngle = Vector2.new(1, 180)
        coroutine.wrap(function()
            Attachment.Fire.Enabled = true
            for i = 1, 2 do
                Attachment.Fire:Emit(25)
                wait(0.05)
            end
            Attachment.Fire.Enabled = false
            Stars.Stars.Enabled = false
        end)()
        Fire.Parent = Visuals
        Debris:AddItem(Fire, 1)

        --[[ Flying Debris Rock ]]
        --
        for i = 1, 2 do
            for j = 1, 5 do
                --[[ Raycast ]]
                --
                local StartPosition = (
                    Vector3.new(math.sin(360 * i) * 15, 0, math.cos(360 * i) * 15) + Character.HumanoidRootPart.Position
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

                        local X, Y, Z = math.random(2, 5), math.random(2, 5), math.random(2, 5)
                        Block.Size = Vector3.new(X, Y, Z)

                        Block.Position = pos
                        Block.Rotation =
                            Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
                        Block.Transparency = 0
                        Block.Color = partHit.Color
                        Block.Material = partHit.Material
                        Block.Anchored = false
                        Block.Parent = Visuals

                        local BodyVelocity = Instance.new("BodyVelocity")
                        BodyVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
                        BodyVelocity.Velocity = Vector3.new(
                            math.random(-80, 80),
                            math.random(50, 60),
                            math.random(-80, 80)
                        ) * (j * 0.65)
                        BodyVelocity.P = 100000
                        Block.Velocity = Vector3.new(math.random(-80, 80), math.random(50, 60), math.random(-80, 80))
                            * (j * 0.65)
                        BodyVelocity.Parent = Block

                        Debris:AddItem(BodyVelocity, 0.05)
                        Debris:AddItem(Block, 2)
                    end
                end
            end
            wait()
        end

        --[[ RingInnit ]]
        --
        local RingInnit = EffectMeshes.RingInnit:Clone()
        RingInnit.Transparency = 0
        RingInnit.CFrame = Character.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(90), 0)
        RingInnit.Size = Vector3.new(25, 1, 25)
        RingInnit.Parent = Visuals
        Debris:AddItem(RingInnit, 0.35)

        local tween = TweenService:Create(
            RingInnit,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Size"] = Vector3.new(120, 1, 120), ["Transparency"] = 1 }
        )
        tween:Play()
        tween:Destroy()

        --[[ Expand Lines Out ]]
        --
        coroutine.wrap(function()
            for i = 1, 15 do
                local originalPos = Character.HumanoidRootPart.Position
                local beam = EffectMeshes.Block:Clone()
                beam.Shape = "Block"
                local mesh = Instance.new("SpecialMesh")
                mesh.MeshType = "Sphere"
                mesh.Parent = beam
                beam.Size = Vector3.new(5, 5, 5)
                beam.Material = Enum.Material.Neon
                beam.Color = Color3.fromRGB(255, 70, 73)
                beam.Transparency = 0
                beam.Parent = Visuals

                beam.CFrame =
                    CFrame.new(originalPos + Vector3.new(math.random(-1, 1), 1, math.random(-1, 1)), originalPos)
                local tween = TweenService:Create(
                    beam,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {
                        ["Size"] = beam.Size + Vector3.new(0, 0, math.random(2, 5)),
                        ["CFrame"] = beam.CFrame * CFrame.new(0, 0, math.random(20, 40)),
                    }
                )
                local tween2 = TweenService:Create(
                    beam,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { ["Size"] = Vector3.new(0, 0, 10) }
                )
                tween:Play()
                tween:Destroy()
                tween2:Play()
                tween2:Destroy()
                Debris:AddItem(beam, 0.2)
            end
        end)()

        --[[ Terrain Rocks on Ground ]]
        --
        local RootPos = Character.HumanoidRootPart.Position
        local GroundRocks = {}
        for i = 1, 20 do
            --[[ Raycast ]]
            --
            local StartPosition = (Vector3.new(math.sin(360 * i) * 35, 0, math.cos(360 * i) * 35) + RootPos)
            local EndPosition = CFrame.new(StartPosition).UpVector * -10

            local RayData = RaycastParams.new()
            RayData.FilterDescendantsInstances = { Character, World.Live, World.Visuals } or World.Visuals
            RayData.FilterType = Enum.RaycastFilterType.Exclude
            RayData.IgnoreWater = true

            local ray = workspace:Raycast(StartPosition, EndPosition, RayData)
            if ray then
                local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
                if partHit then
                    local Block = EffectMeshes.Block:Clone()

                    local X, Y, Z = math.random(3, 6), math.random(3, 6), math.random(3, 6)
                    Block.Size = Vector3.new(X, Y, Z)

                    Block.Position = pos
                    Block.Anchored = true
                    --local visual = RayService:Visualize(StartPosition, pos, Color3.fromRGB(255, 0, 0))
                    Block.Rotation = Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
                    Block.Transparency = 0
                    Block.Color = partHit.Color
                    Block.Material = partHit.Material
                    Block.Parent = Visuals
                    GroundRocks[i] = Block
                    Debris:AddItem(Block, 2)
                end
            end
        end

        --[[ Delete Rocks ]]
        --
        wait(1.5)
        if #GroundRocks > 0 then
            for i, v in ipairs(GroundRocks) do
                v.Anchored = false
            end
        end
    end,

    ["NatsuScreen"] = function(Data)
        local Character = Data.Character or nil
        local EnemyCharacter = Data.EnemyCharacter or nil
        local ContactPoint = Data.ContactPoint

        local Blur = Instance.new("BlurEffect")
        Blur.Size = 24
        Blur.Parent = Lighting

        local ColorCorrection = Instance.new("ColorCorrectionEffect")
        ColorCorrection.Brightness = -0.5
        ColorCorrection.Contrast = 1
        ColorCorrection.Saturation = -1
        ColorCorrection.Parent = Lighting

        local tween = TweenService:Create(
            Blur,
            TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Size"] = 0 }
        )
        tween:Play()
        tween:Destroy()

        local tween2 = TweenService:Create(
            ColorCorrection,
            TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Brightness"] = 0, ["Contrast"] = 0, ["Saturation"] = 0 }
        )
        tween2:Play()
        tween2:Destroy()

        Debris:AddItem(Blur, 1)
        Debris:AddItem(ColorCorrection, 1)
    end,
}

return NatsuVFX
