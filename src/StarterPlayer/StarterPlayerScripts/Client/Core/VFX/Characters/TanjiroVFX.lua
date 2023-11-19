--||Services||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

--||Directories||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Effects = Modules.Effects
local Utility = Modules.Utility
local Shared = Modules.Shared

local HitPart2 = Models.Misc.HitPart2

--||Imports||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)
local VfxHandler = require(Effects.VfxHandler)
local SoundManager = require(Shared.SoundManager)

local CameraShaker = require(Effects.CameraShaker)

local CurrentCamera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
    CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
end)

--||Remotes||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GetMouse = ReplicatedStorage.Remotes.GetMouse

--||Variables||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Humanoid = Character:WaitForChild("Humanoid")

local RingTween = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local TweenInf = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local B5 = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.World.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

local TanjiroVFX = {

    ["Striking Tide"] = function(PathData)
        local Character = PathData.Character
        local Victim = PathData.Victim

        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local End = Root.CFrame
        local p1, p2 = End.p, End.upVector * -200

        coroutine.wrap(function()
            for _ = 1, 3 do
                VfxHandler.AfterImage({
                    Character = Character,
                    Duration = 1,
                    StartTransparency = 0.2,
                    Color = Color3.fromRGB(110, 153, 202),
                })
                wait(0.35)
            end
        end)()

        coroutine.resume(coroutine.create(function()
            wait(0.25)
            local SlashEffect = ReplicatedStorage.Assets.Effects.Meshes.ThreeDSlashEffect:Clone()
            SlashEffect.Anchored = true
            SlashEffect.CanCollide = false
            SlashEffect.Massless = true
            SlashEffect.CFrame = Root.CFrame * CFrame.Angles(0, math.pi / 1.75, math.pi / 2)
            SlashEffect.Parent = workspace.World.Visuals
            local RandomSize = math.random(3, 4) * 3
            local SizeAddon = math.random(3, 4) * 5

            local Tween = TweenService:Create(
                SlashEffect,
                B5,
                {
                    Transparency = 1,
                    CFrame = SlashEffect.CFrame * CFrame.Angles(3.36, 0, 0),
                    Size = SlashEffect.Size + Vector3.new(0, SizeAddon, SizeAddon),
                }
            )
            Tween:Play()
            Tween:Destroy()

            Debris:AddItem(SlashEffect, 1)

            wait(0.2)

            local SlashEffect3D = ReplicatedStorage.Assets.Effects.Meshes.ThreeDSlashEffect:Clone()
            SlashEffect3D.Anchored = true
            SlashEffect3D.CanCollide = false
            SlashEffect3D.Massless = true
            SlashEffect3D.CFrame = Root.CFrame * CFrame.Angles(math.pi - 0.2, -math.pi / 2.3, (math.pi / 2) - 0.3)
            SlashEffect3D.Parent = workspace.World.Visuals

            local Tween = TweenService:Create(
                SlashEffect3D,
                B5,
                {
                    Transparency = 1,
                    CFrame = SlashEffect3D.CFrame * CFrame.Angles(3.36, 0, 0),
                    Size = SlashEffect3D.Size + Vector3.new(0, SizeAddon, SizeAddon),
                }
            )
            Tween:Play()
            Tween:Destroy()

            Debris:AddItem(SlashEffect3D, 1)
        end))

        wait(1)
        local Calculation = Root.CFrame - Root.Position

        delay(0.1, function()
            VfxHandler.RockTing(Root.CFrame, 1)
        end)
        VfxHandler.ImpactLines({ Character = Character, Amount = 12 })
        VfxHandler.Orbies({
            Parent = Root,
            Speed = 0.5,
            Size = Vector3.new(1, 1, 12),
            Cframe = CFrame.new(0, 0, 15),
            Amount = 8,
            Sphere = true,
        })

        local Ring = ReplicatedStorage.Assets.Effects.Meshes.RingInnit:Clone()
        Ring.CFrame = Root.CFrame * CFrame.new(0, -16, 0)
        Ring.Size = Vector3.new(15, 0.05, 15)
        Ring.Transparency = 0.25
        Ring.Material = "Neon"
        Ring.BrickColor = BrickColor.new("Institutional white")
        Ring.Parent = workspace.World.Visuals

        Debris:AddItem(Ring, 1)
        GlobalFunctions.TweenFunction(
            {
                ["Instance"] = Ring,
                ["EasingStyle"] = Enum.EasingStyle.Quad,
                ["EasingDirection"] = Enum.EasingDirection.Out,
                ["Duration"] = 0.5,
            },
            { ["Transparency"] = 1, ["Size"] = Vector3.new(25, 0.05, 25), ["CFrame"] = Ring.CFrame
                * CFrame.new(0, 12, 0) }
        )

        local SlashEffect = ReplicatedStorage.Assets.Effects.Meshes["3dSlashEffect"]:Clone()
        SlashEffect.Anchored = true
        SlashEffect.CanCollide = false
        SlashEffect.Massless = true
        SlashEffect.CFrame = Character.HumanoidRootPart.CFrame
            * CFrame.new(0, -1, 0)
            * CFrame.Angles(math.rad(52.12), math.rad(52.68), math.rad(-16.19))
        SlashEffect.Parent = workspace.World.Visuals

        GlobalFunctions.TweenFunction(
            {
                ["Instance"] = SlashEffect,
                ["EasingStyle"] = Enum.EasingStyle.Quad,
                ["EasingDirection"] = Enum.EasingDirection.Out,
                ["Duration"] = 0.4,
            },
            {
                ["Size"] = Vector3.new(4.15, 0.538, 3.075),
                ["CFrame"] = SlashEffect.CFrame * CFrame.fromEulerAnglesYXZ(0, -10, 0),
            }
        )
        GlobalFunctions.TweenFunction(
            {
                ["Instance"] = SlashEffect.Decal,
                ["EasingStyle"] = Enum.EasingStyle.Quad,
                ["EasingDirection"] = Enum.EasingDirection.Out,
                ["Duration"] = 0.4,
            },
            { ["Transparency"] = 1 }
        )

        GlobalFunctions.TweenFunction(
            {
                ["Instance"] = SlashEffect.Mesh,
                ["EasingStyle"] = Enum.EasingStyle.Quad,
                ["EasingDirection"] = Enum.EasingDirection.Out,
                ["Duration"] = 0.75,
            },
            { ["Scale"] = Vector3.new(-14.988, 2.613, 14.988) }
        )

        Debris:AddItem(SlashEffect, 1)

        for _ = 1, 8 do
            local Slash = ReplicatedStorage.Assets.Effects.Meshes.ThreeDSlashEffect:Clone()
            local size = math.random(2, 4) * 3
            local sizeadd = math.random(1, 6) * 17
            local x, y, z =
                math.rad(math.random(8, 12) * 30), math.rad(math.random(8, 12) * 30), math.rad(math.random(8, 12) * 30)
            local add = math.random(1, 2)
            if add == 2 then
                add = -1
            end
            Slash.Transparency = 0.7
            Slash.Size = Vector3.new(2, size, size)
            Slash.CFrame = End * CFrame.Angles(x, y, z)
            Slash.Parent = workspace.World.Visuals

            local Tween = TweenService:Create(
                Slash,
                TweenInf,
                {
                    Transparency = 1,
                    CFrame = Slash.CFrame * CFrame.Angles(math.pi * add, 0, 0),
                    Size = Slash.Size + Vector3.new(0, sizeadd, sizeadd),
                }
            )
            Tween:Play()
            Tween:Destroy()

            Debris:AddItem(Slash, 0.3)
        end

        for _ = 1, 2 do
            local Ring = ReplicatedStorage.Assets.Effects.Meshes.Ring2:Clone()
            Ring.Size = Vector3.new(50, 3, 50)
            Ring.Material = Enum.Material.Neon
            Ring.CanCollide = false
            Ring.CFrame = CFrame.new(Root.Position) * Calculation
            Ring.Anchored = true
            Ring.Parent = workspace.World.Visuals

            Debris:AddItem(Ring, 0.4)

            local Tween = TweenService:Create(
                Ring,
                RingTween,
                { CFrame = Ring.CFrame * CFrame.new(0, 15, 0), Size = Vector3.new(0, 0, 0) }
            )
            Tween:Play()
            Tween:Destroy()

            wait(0.2)
        end
    end,

    ["WaterStuff"] = function(Data)
        local Character = Data.Character
        for Index = 1, Data.Amount or 5 do
            local Cframe, Size = Character:GetBoundingBox()
            local Options = { -5, 5 }

            local Slice = ReplicatedStorage.Assets.Effects.Meshes.Cut:Clone()
            local NormalSize = Slice.Size

            Slice.Water.Enabled = true
            Slice.Transparency = 1
            Slice.CFrame = CFrame.new(
                (Cframe * CFrame.new(Options[math.random(1, #Options)], 5, Options[math.random(1, #Options)])).Position,
                Cframe.Position
            ) * CFrame.Angles(math.rad(math.random(0, 45)), math.rad(-90), 0)
            Slice.Size = Vector3.new(NormalSize.X, 0, 0)
            Slice.Parent = workspace.World.Visuals

            delay(0.1, function()
                Slice.Water.Enabled = false
            end)
            Debris:AddItem(Slice, 0.6)

            GlobalFunctions.TweenFunction(
                {
                    ["Instance"] = Slice,
                    ["EasingStyle"] = Enum.EasingStyle.Quad,
                    ["EasingDirection"] = Enum.EasingDirection.Out,
                    ["Duration"] = 0.6,
                },
                {
                    ["Size"] = Vector3.new(6, 0.2, 10),
                    ["Transparency"] = 1,
                    ["CFrame"] = Slice.CFrame * CFrame.fromEulerAnglesYXZ(0, 10, 0),
                }
            )
            wait(Data.Duration or 0.1)
        end
    end,

    ["Trail"] = function(PathData)
        local Sword = PathData.Sword
        local Character = PathData.Character

        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        Sword.Blade.Clouds.Enabled = true
        Sword.Blade.WaterSlashTrail.Enabled = true
        Sword.Blade.WaterTrail.Enabled = true
        Sword.Blade.WaterTrail2.Enabled = true

        --	Sword.Blade.WaterSlashTrail.TextureLength = PathData.TextureLength or 6
        Sword.Blade.WaterSlashTrail.Rate = PathData.Rate or 145

        if PathData.Duration == 0.9 then
            Sword.Blade.WaterSlashTrail.LightEmission = 0.4
            Sword.Blade.WaterSlashTrail.Rate = 80
        elseif PathData.Duration == 0.5 then
            coroutine.wrap(function()
                wait(0.25)
                local SlashEffect = ReplicatedStorage.Assets.Effects.Meshes.ThreeDSlashEffect:Clone()
                SlashEffect.Anchored = true
                SlashEffect.CanCollide = false
                SlashEffect.Massless = true
                SlashEffect.CFrame = Root.CFrame * CFrame.Angles(0, math.pi / 1.75, math.pi / 2)
                SlashEffect.Parent = workspace.World.Visuals
                local RandomSize = math.random(3, 4) * 3
                local SizeAddon = math.random(3, 4) * 5

                local Tween = TweenService:Create(
                    SlashEffect,
                    B5,
                    {
                        Transparency = 1,
                        CFrame = SlashEffect.CFrame * CFrame.Angles(3.36, 0, 0),
                        Size = SlashEffect.Size + Vector3.new(0, SizeAddon, SizeAddon),
                    }
                )
                Tween:Play()
                Tween:Destroy()

                Debris:AddItem(SlashEffect, 1)
            end)()
        end

        wait(PathData.Duration)

        Sword.Blade.WaterSlashTrail.Rate = 145
        Sword.Blade.Clouds.Enabled = false
        Sword.Blade.WaterSlashTrail.Enabled = false
        Sword.Blade.WaterTrail.Enabled = false
        Sword.Blade.WaterTrail2.Enabled = false
    end,

    ["WaterWheelHit"] = function(BackData)
        local Character = BackData.Character
        local Victim = BackData.Victim

        local End = Character.HumanoidRootPart.CFrame
        local p1, p2 = End.p, End.upVector * -200
        local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

        if GlobalFunctions.CheckDistance(Player, BackData.Distance) then
            CameraShake:Start()
            CameraShake:ShakeOnce(12, 8, 0, 1.5)
        end

        local Calculation = VRoot.CFrame - VRoot.Position

        -- SoundManager:AddSound("Explosion", {Parent = Character.HumanoidRootPart, Looped = false, Volume = 3}, "Client")

        VfxHandler.Orbies({
            Parent = VRoot,
            Speed = 0.5,
            Size = Vector3.new(1, 1, 8),
            Cframe = CFrame.new(0, 0, 11),
            Amount = 8,
            Sphere = true,
        })
        VfxHandler.RockTing(VRoot.CFrame, 1)

        local results = workspace:Raycast(p1, p2, raycastParams)
        if results and results.Instance and (results.Position - p1).Magnitude < 30 then
            for _ = 1, 5 do
                local Block = ReplicatedStorage.Assets.Effects.Meshes.Block:Clone()
                Block.Size = Vector3.new(2.434, 1.32, 2.719)
                Block.Rotation = Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
                Block.BrickColor = results.Instance.BrickColor
                Block.Material = results.Instance.Material
                Block.Position = VRoot.Position
                Block.Velocity = Vector3.new(math.random(-80, 80), math.random(80, 100), math.random(-80, 80))
                Block.Parent = workspace.World.Visuals
                delay(0.25, function()
                    Block.CanCollide = true
                end)

                local BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                BodyVelocity.Velocity = Vector3.new(math.random(-23, 23), math.random(28, 28), math.random(-23, 23))
                BodyVelocity.P = 5
                BodyVelocity.Parent = Block

                Debris:AddItem(BodyVelocity, 0.1)
                Debris:AddItem(Block, 3)
            end

            local CrashSmoke = ReplicatedStorage.Assets.Effects.Particles.CrashSmoke:Clone()
            CrashSmoke.Size = Vector3.new(15, 2, 15)
            CrashSmoke.Position = VRoot.Position
            CrashSmoke.Smoke.Color = ColorSequence.new(results.Instance.Color)
            CrashSmoke.Smoke:Emit(30)
            CrashSmoke.Parent = workspace.World.Visuals
            delay(1, function()
                CrashSmoke.Smoke.Enabled = false
            end)
            Debris:AddItem(CrashSmoke, 3)
        end

        for _ = 1, 2 do
            local Ring = ReplicatedStorage.Assets.Effects.Meshes.Ring2:Clone()
            Ring.Size = Vector3.new(50, 3, 50)
            Ring.Material = Enum.Material.Neon
            Ring.CanCollide = false
            Ring.CFrame = CFrame.new(VRoot.Position) * Calculation
            Ring.Anchored = true
            Ring.Parent = workspace.World.Visuals

            Debris:AddItem(Ring, 0.4)

            local Tween = TweenService:Create(
                Ring,
                RingTween,
                { CFrame = Ring.CFrame * CFrame.new(0, 15, 0), Size = Vector3.new(0, 0, 0) }
            )
            Tween:Play()
            Tween:Destroy()

            wait(0.2)
        end
    end,

    ["WaterWheel"] = function(BackData)
        local Character = BackData.Character

        local End = Character.HumanoidRootPart.CFrame
        local p1, p2 = End.p, End.upVector * -200

        VfxHandler.ImpactLines({ Character = Character, Amount = 15 })

        local results = workspace:Raycast(p1, p2, raycastParams)
        if results and results.Instance and (results.Position - p1).Magnitude < 30 then
            local DirtStep = ReplicatedStorage.Assets.Effects.Particles.DirtStep:Clone()
            DirtStep.ParticleEmitter.Enabled = true
            DirtStep.CFrame = End * CFrame.new(0, -1.85, 0.225)
            DirtStep.ParticleEmitter.Color = ColorSequence.new(results.Instance.Color)
            DirtStep.Parent = workspace.World.Visuals

            local WeldConstraint = Instance.new("WeldConstraint")
            WeldConstraint.Part0 = Character.HumanoidRootPart
            WeldConstraint.Part1 = DirtStep
            WeldConstraint.Parent = DirtStep

            delay(1, function()
                DirtStep.ParticleEmitter.Enabled = false
            end)

            Debris:AddItem(DirtStep, 2.5)
        end
        for _ = 1, 6 do
            VfxHandler.AfterImage({
                Character = Character,
                Duration = 1,
                StartTransparency = 0.2,
                Color = Color3.fromRGB(110, 153, 202),
            })
            wait(0.1)
        end
    end,

    ["Whirlpool"] = function(Data)
        local Character = Data.Character

        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Cframe = Root.CFrame
        local WhirlpoolTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

        if Character and Cframe then
            Cframe = Cframe * CFrame.new(0, -2.5, 0)

            local Swirl = ReplicatedStorage.Assets.Effects.Meshes.Swirl:Clone()
            Swirl.CFrame = Cframe
            Swirl.Anchored = true
            Swirl.CanCollide = false
            Swirl.Material = Enum.Material.Neon
            Swirl.Transparency = 0.5
            Swirl.Color = Color3.fromRGB(95, 140, 189)
            Swirl.Size = Vector3.new(3, 0, 3)
            Swirl.Name = Character.Name .. " tanjiro whirlpool swirl"
            Swirl.Parent = workspace.World.Visuals

            local Part = ReplicatedStorage.Assets.Effects.Particles.WhirlpoolBubbles:Clone()
            Part.CFrame = Cframe
            Part.Bubbles.Enabled = true
            Part.Steam.Enabled = true
            Part.Parent = workspace.World.Visuals

            Debris:AddItem(Part, 1.7)
            coroutine.resume(coroutine.create(function()
                wait(0.6)
                Part.Bubbles.Enabled = false
                Part.Steam.Enabled = false
            end))

            -- SoundManager:AddSound("watersfx1",{Parent = Root}, "Client")

            coroutine.resume(coroutine.create(function()
                for Index = 1, 6 do
                    local Ring = ReplicatedStorage.Assets.Effects.Meshes.Ring:Clone()
                    Ring.CFrame = Cframe * CFrame.new(0, 40, 0)
                    Ring.Size = Vector3.new(50, 3, 50)
                    Ring.Material = Enum.Material.Neon
                    Ring.Name = Character.Name .. " Ringz whirlpool"
                    Ring.Parent = workspace.World.Visuals

                    Debris:AddItem(Ring, 0.3)
                    TweenService:Create(Ring, WhirlpoolTweenInfo, { CFrame = Cframe, Size = Vector3.new(5, 3, 5) })
                        :Play()

                    wait(0.1)
                end
            end))

            TweenService
                :Create(Swirl, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {
                    Size = Vector3.new(30, 48, 30),
                    CFrame = Swirl.CFrame * CFrame.new(0, 26, 0),
                })
                :Play()

            TweenService
                :Create(Swirl, TweenInfo.new(0.475, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 1, true, 0.35), {
                    Color = Color3.fromRGB(189, 189, 189),
                })
                :Play()

            coroutine.resume(coroutine.create(function()
                for _ = 1, 8 do
                    local Cframe, Size = Character:GetBoundingBox()
                    local Options = { -5, 5 }

                    local Slice = ReplicatedStorage.Assets.Effects.Meshes.Cut:Clone()
                    local NormalSize = Slice.Size

                    Slice.Water.Enabled = true
                    Slice.Transparency = 1
                    Slice.CFrame = CFrame.new(
                        (Cframe * CFrame.new(Options[math.random(1, #Options)], 5, Options[math.random(1, #Options)])).Position,
                        Cframe.Position
                    ) * CFrame.Angles(math.rad(math.random(0, 45)), math.rad(-90), 0)
                    Slice.Size = Vector3.new(NormalSize.X, 0, 0)
                    Slice.Parent = workspace.World.Visuals

                    delay(0.1, function()
                        Slice.Water.Enabled = false
                    end)
                    Debris:AddItem(Slice, 0.6)

                    GlobalFunctions.TweenFunction(
                        {
                            ["Instance"] = Slice,
                            ["EasingStyle"] = Enum.EasingStyle.Quad,
                            ["EasingDirection"] = Enum.EasingDirection.Out,
                            ["Duration"] = 0.6,
                        },
                        {
                            ["Size"] = Vector3.new(6, 0.2, 10),
                            ["Transparency"] = 1,
                            ["CFrame"] = Slice.CFrame * CFrame.fromEulerAnglesYXZ(0, 10, 0),
                        }
                    )
                    wait(Data.Duration or 0.35)
                end
            end))

            coroutine.resume(coroutine.create(function()
                wait(0.5)
                TweenService
                    :Create(Swirl, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {
                        Size = Vector3.new(0, 60, 0),
                        Transparency = 1,
                    })
                    :Play()
            end))

            Debris:AddItem(Swirl, 1.6)

            while Swirl do
                Swirl.CFrame = Swirl.CFrame * CFrame.Angles(0, 0.9, 0)
                RunService.RenderStepped:Wait()
                if workspace.World.Visuals:FindFirstChild(Character.Name .. " tanjiro whirlpool swirl") == nil then
                    break
                end
            end
        end
    end,

    ["WaterSurfaceSlash"] = function(PathData)
        local Character = PathData.Character
        local Sword = PathData.Sword

        local End = Character.HumanoidRootPart.CFrame
        local p1, p2 = End.p, End.upVector * -200

        -- SoundManager:AddSound("WaterPlayerSlash", {Parent = Character.HumanoidRootPart, Looped = false}, "Client")

        local WaterEffect = ReplicatedStorage.Assets.Effects.Particles.Water:Clone()
        WaterEffect.Parent = Sword.Blade
        WaterEffect.Enabled = true
        delay(1, function()
            WaterEffect.Enabled = false
        end)

        Debris:AddItem(WaterEffect, 3)

        local results = workspace:Raycast(p1, p2, raycastParams)
        if results and results.Instance and (results.Position - p1).Magnitude < 30 then
            local Dust = ReplicatedStorage.Assets.Effects.Particles.Dust:Clone()
            Dust.CFrame = End * CFrame.Angles(0, 0.3, 0) * CFrame.new(3, 0, 0)
            Dust.ParticleEmitter.Color = ColorSequence.new(results.Instance.Color)
            Dust.ParticleEmitter:Emit(10)
            Dust.Parent = workspace.World.Visuals
            Debris:AddItem(Dust, 3)

            local Dust = ReplicatedStorage.Assets.Effects.Particles.Dust:Clone()
            Dust.CFrame = End * CFrame.Angles(0, -0.3, 0) * CFrame.new(-3, 0, 0)
            Dust.ParticleEmitter.Color = ColorSequence.new(results.Instance.Color)
            Dust.ParticleEmitter:Emit(10)
            Dust.Parent = workspace.World.Visuals

            local DirtStep = ReplicatedStorage.Assets.Effects.Particles.DirtStep:Clone()
            DirtStep.ParticleEmitter.Enabled = true
            DirtStep.CFrame = End * CFrame.new(0, -1.85, 0.225)
            DirtStep.ParticleEmitter.Color = ColorSequence.new(results.Instance.Color)
            DirtStep.Parent = workspace.World.Visuals

            local WeldConstraint = Instance.new("WeldConstraint")
            WeldConstraint.Part0 = Character.HumanoidRootPart
            WeldConstraint.Part1 = DirtStep
            WeldConstraint.Parent = DirtStep

            delay(0.5, function()
                DirtStep.ParticleEmitter.Enabled = false
            end)

            Debris:AddItem(DirtStep, 2)
            Debris:AddItem(Dust, 3)
        end

        for _ = 1, 8 do
            local Slash = ReplicatedStorage.Assets.Effects.Meshes.ThreeDSlashEffect:Clone()
            local size = math.random(2, 4) * 3
            local sizeadd = math.random(1, 6) * 17
            local x, y, z =
                math.rad(math.random(8, 12) * 30), math.rad(math.random(8, 12) * 30), math.rad(math.random(8, 12) * 30)
            local add = math.random(1, 2)
            if add == 2 then
                add = -1
            end
            Slash.Transparency = 0.7
            Slash.Size = Vector3.new(2, size, size)
            Slash.CFrame = End * CFrame.Angles(x, y, z)
            Slash.Parent = workspace.World.Visuals

            local Tween = TweenService:Create(
                Slash,
                TweenInf,
                {
                    Transparency = 1,
                    CFrame = Slash.CFrame * CFrame.Angles(math.pi * add, 0, 0),
                    Size = Slash.Size + Vector3.new(0, sizeadd, sizeadd),
                }
            )
            Tween:Play()
            Tween:Destroy()

            Debris:AddItem(Slash, 0.3)
        end
    end,
}

return TanjiroVFX
