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

local EffectMeshes = ReplicatedStorage.Assets.Effects.Meshes

local Metadata = Modules.Metadata
local Effects = Modules.Effects
local Utility = Modules.Utility
local Shared = Modules.Shared

local HitPart2 = Models.Misc.HitPart2

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)
local VfxHandler = require(Effects.VfxHandler)
local SoundManager = require(Shared.SoundManager)

local CameraShaker = require(Effects.CameraShaker)

local CurrentCamera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
    CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
end)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

local GetMouse = ReplicatedStorage.Remotes.GetMouse

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Humanoid = Character:WaitForChild("Humanoid")

local RingTween = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local TweenInf = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local B5 = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.World.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Visuals = workspace.World.Visuals

local RengokuVFX = {
    ["secondform"] = function(Data)
        local Character = Data.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local End = Root.CFrame
        local Position1, Position2 = End.p, End.upVector * -200

        local circleslash = script.circleslash:Clone()
        local one = circleslash.one
        local two = circleslash.two
        local StartSizeOne = Vector3.new(15, 15, 1)
        local StartSizeTwo = Vector3.new(15, 15, 2)
        local Multiple = math.random(2, 2.5)

        one.Size = StartSizeOne
        two.Size = StartSizeTwo
        circleslash.Parent = Visuals

        one.CFrame = Root.CFrame * CFrame.new(0, 1, 0) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
        two.CFrame = Root.CFrame * CFrame.new(0, 1, 0) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)

        Debris:AddItem(circleslash, 0.5)
        --// PointLight
        local PointLight = Instance.new("PointLight")
        PointLight.Color = Color3.fromRGB(120, 201, 255)
        PointLight.Range = 25
        PointLight.Brightness = 1
        PointLight.Parent = one

        local LightTween = TweenService:Create(
            PointLight,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Range"] = 0, ["Brightness"] = 0 }
        )
        LightTween:Play()
        LightTween:Destroy()

        --// Tween one
        local TweenOne = TweenService:Create(
            one,
            TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            {
                ["CFrame"] = one.CFrame * CFrame.Angles(math.rad(3.36), math.rad(-80.51), math.rad(-12.76)),
                ["Size"] = StartSizeOne * Multiple,
            }
        )
        TweenOne:Play()
        TweenOne:Destroy()

        --// Tween two
        local TweenTwo = TweenService:Create(
            two,
            TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            {
                ["CFrame"] = two.CFrame * CFrame.Angles(math.rad(3.36), math.rad(-80.51), math.rad(-12.76)),
                ["Size"] = StartSizeTwo * Multiple,
            }
        )
        TweenTwo:Play()
        TweenTwo:Destroy()

        wait(0.05)

        --// Tween Decals
        for _, v in ipairs(one:GetChildren()) do
            if v:IsA("Decal") then
                local tween = TweenService:Create(
                    v,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { ["Transparency"] = 1 }
                )
                tween:Play()
                tween:Destroy()
            end
        end

        for _, v in ipairs(two:GetChildren()) do
            local tween = TweenService:Create(
                v,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Transparency"] = 1 }
            )
            tween:Play()
            tween:Destroy()
        end

        VfxHandler.Spherezsz({
            Cframe = End,
            TweenDuration1 = 0.3,
            TweenDuration2 = 0.35,
            Range = 8,
            MinThick = 12,
            MaxThick = 25,
            Part = nil,
            Color = Color3.fromRGB(255, 139, 61),
            Amount = 8,
        })

        local RaycastResult = workspace:Raycast(Position1, Position2, raycastParams)
        if RaycastResult and RaycastResult.Instance and (RaycastResult.Position - Position1).Magnitude < 30 then
            for Index = 1, 10 do
                local Slash = ReplicatedStorage.Assets.Effects.Meshes.ThreeDSlashEffect:Clone()
                local Size = math.random(2, 4) * 3
                local SizeAdd = math.random(1, 6) * 17
                local X, Y, Z =
                    math.rad(math.random(8, 12) * 30),
                    math.rad(math.random(8, 12) * 30),
                    math.rad(math.random(8, 12) * 30)
                local Add = math.random(1, 2)
                if Add == 2 then
                    Add = -1
                end
                Slash.Transparency = 0.7
                Slash.Size = Vector3.new(2, Size, Size)
                Slash.CFrame = Root.CFrame * CFrame.Angles(X, Y, Z)
                Slash.Parent = workspace.World.Visuals

                local Ti = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

                local Tween = TweenService:Create(
                    Slash,
                    Ti,
                    {
                        Transparency = 1,
                        CFrame = Slash.CFrame * CFrame.Angles(math.pi * Add, 0, 0),
                        Size = Slash.Size + Vector3.new(0, SizeAdd, SizeAdd),
                    }
                )
                Tween:Play()
                Tween:Destroy()

                Debris:AddItem(Slash, 0.3)

                local Dust = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments["Dust"]:Clone()
                Dust.P1.Color = ColorSequence.new(RaycastResult.Instance.Color)
                Dust.Parent = Root

                VfxHandler.Emit(Dust.P1, 3)
                Debris:AddItem(Dust, 2)
            end
        end
    end,

    ["WaterStuff"] = function(Data)
        local Character = Data.Character
        for Index = 1, Data.Amount or 5 do
            local Cframe, Size = Character:GetBoundingBox()
            local Options = { -5, 5 }

            local Slice = ReplicatedStorage.Assets.Effects.Meshes.Cut:Clone()
            local NormalSize = Slice.Size

            Slice.Water.Color = ColorSequence.new(Color3.fromRGB(255, 92, 52))

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

        for Index = 1, 2 do
            local Offset = 5
            local Rot = 288
            local GoalSize = Vector3.new(35, 0.05, 7.5)
            if Index == 1 then
            else
                Offset = Offset * -1
                Rot = 252
            end

            local SideWind = EffectMeshes.SideWind:Clone()
            SideWind.Size = Vector3.new(8, 0.05, 2)
            SideWind.Transparency = 0
            SideWind.Color = Color3.fromRGB(255, 127, 42)
            SideWind.CFrame = Root.CFrame
                * CFrame.new(Offset, -0.5, 0)
                * CFrame.fromEulerAnglesXYZ(math.rad(90), math.rad(180), math.rad(Rot))
            SideWind.Parent = Visuals

            local Tween = TweenService:Create(
                SideWind,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["CFrame"] = SideWind.CFrame * CFrame.new(-10, 0, 0), ["Size"] = GoalSize, ["Transparency"] = 1 }
            )
            Tween:Play()
            Tween:Destroy()

            Debris:AddItem(SideWind, 0.25)

            local DeepRing = EffectMeshes.DeepRing:Clone()
            DeepRing.Size = Vector3.new(5, 0.1, 5)
            DeepRing.Transparency = 0.15
            DeepRing.Color = Color3.fromRGB(255, 127, 42)
            DeepRing.CFrame = Root.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(90), 0)
            DeepRing.Parent = Visuals

            local Tween = TweenService:Create(
                DeepRing,
                TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {
                    ["CFrame"] = DeepRing.CFrame
                        * CFrame.fromEulerAnglesXYZ(math.rad(math.random(45)) * math.sign(Offset), math.rad(270), 0),
                    ["Size"] = Vector3.new(30, 0.1, 30),
                    ["Transparency"] = 1,
                }
            )
            Tween:Play()
            Tween:Destroy()

            Debris:AddItem(DeepRing, 0.35)
        end

        coroutine.resume(coroutine.create(function()
            if PathData.TrailFloor ~= nil then
                return
            end

            local Trail = ReplicatedStorage.Assets.Effects.Trails.GroundTrail:Clone()
            Trail.Trail.Lifetime = 3
            Trail.Position = Root.Position
            Trail.Transparency = 1
            Trail.Parent = Visuals

            Debris:AddItem(Trail, 5)

            local FireParticle = ReplicatedStorage.Assets.Effects.Particles.FireProc:Clone()
            FireParticle.Rate = 50
            FireParticle.Enabled = true
            FireParticle.LockedToPart = false
            FireParticle.Parent = Trail

            delay(0.45, function()
                FireParticle.Enabled = false
            end)

            local Tween = TweenService:Create(
                Trail.Start,
                TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Position"] = Vector3.new(0, 0, 0.25) }
            )
            Tween:Play()
            Tween:Destroy()

            local Connection
            Connection = Tween.Completed:Connect(function()
                local EndTween = TweenService:Create(
                    Trail.End,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { ["Position"] = Vector3.new(0, 0, -0.25) }
                )
                EndTween:Play()
                EndTween:Destroy()

                Connection:Disconnect()
                Connection = nil
            end)

            for Index = 1, 50 do
                --[[ Raycast ]]
                --
                local StartPosition = (Root.CFrame).Position
                local EndPosition = CFrame.new(StartPosition).UpVector * -10

                local RayData = RaycastParams.new()
                RayData.FilterDescendantsInstances = { Character, workspace.World.Live, Visuals } or Visuals
                RayData.FilterType = Enum.RaycastFilterType.Exclude
                RayData.IgnoreWater = true

                local RaycastResult = workspace:Raycast(StartPosition, EndPosition, RayData)
                if RaycastResult then
                    local Part, Position, Normal = RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal
                    if Part then
                        Trail.Position = Position
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end))

        for _, v in ipairs(Sword.Blade:GetChildren()) do
            if v:IsA("Trail") then
                v.Enabled = true
            end
        end

        Sword.Blade.Lines.Enabled = true
        Sword.Blade.ParticleEmitter2.Enabled = true
        if PathData.Bubbles == nil then
            Sword.Blade.WaterSlashTrail.Enabled = true
        end

        --[[Sword.Blade.Clouds.Enabled = true
		Sword.Blade.WaterSlashTrail.Enabled = true
		Sword.Blade.WaterTrail.Enabled = true
		Sword.Blade.WaterTrail2.Enabled = true]]

        --	Sword.Blade.WaterSlashTrail.TextureLength = PathData.TextureLength or 6
        Sword.Blade.WaterSlashTrail.Rate = PathData.Rate or 35

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

                Debris:AddItem(SlashEffect, 2)

                local circleslash = script.circleslash:Clone()
                local one = circleslash.one
                local two = circleslash.two
                local StartSizeOne = Vector3.new(15, 15, 1)
                local StartSizeTwo = Vector3.new(15, 15, 2)
                local Multiple = 2

                one.Size = StartSizeOne
                two.Size = StartSizeTwo
                circleslash.Parent = Visuals

                one.CFrame = Root.CFrame * CFrame.new(0, 1, 0) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
                two.CFrame = Root.CFrame * CFrame.new(0, 1, 0) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)

                for _, v in ipairs(circleslash:GetDescendants()) do
                    if v:IsA("ParticleEmitter") then
                        v.Enabled = false
                    end
                end
                Debris:AddItem(circleslash, 2)

                local PointLight = Instance.new("PointLight")
                PointLight.Color = Color3.fromRGB(120, 201, 255)
                PointLight.Range = 25
                PointLight.Brightness = 1
                PointLight.Parent = one

                local LightTween = TweenService:Create(
                    PointLight,
                    TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { ["Range"] = 0, ["Brightness"] = 0 }
                )
                LightTween:Play()
                LightTween:Destroy()

                --// Tween one
                local TweenOne = TweenService:Create(
                    one,
                    TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                    {
                        ["CFrame"] = one.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(270)),
                        ["Size"] = StartSizeOne * Multiple,
                    }
                )
                TweenOne:Play()
                TweenOne:Destroy()

                --// Tween two
                local TweenTwo = TweenService:Create(
                    two,
                    TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                    {
                        ["CFrame"] = two.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(270)),
                        ["Size"] = StartSizeTwo * Multiple,
                    }
                )
                TweenTwo:Play()
                TweenTwo:Destroy()

                --local C; C = TweenOne.Completed:Connect(function()
                --end)

                wait(0.1)

                --// Tween Decals
                for _, v in ipairs(one:GetChildren()) do
                    if v:IsA("Decal") then
                        local Tween = TweenService:Create(
                            v,
                            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                            { ["Transparency"] = 1 }
                        )
                        Tween:Play()
                        Tween:Destroy()
                    end
                end

                for _, v in ipairs(two:GetChildren()) do
                    local Tween = TweenService:Create(
                        v,
                        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { ["Transparency"] = 1 }
                    )
                    Tween:Play()
                    Tween:Destroy()
                end
            end)()
        end

        wait(PathData.Duration)

        for _, v in ipairs(Sword.Blade:GetChildren()) do
            if v:IsA("Trail") then
                v.Enabled = false
            end
        end

        Sword.Blade.WaterSlashTrail.Rate = 145
        Sword.Blade.WaterSlashTrail.Enabled = false
        Sword.Blade.Lines.Enabled = false
        Sword.Blade.ParticleEmitter2.Enabled = false

        --[[	Sword.Blade.Clouds.Enabled = false
		Sword.Blade.WaterTrail.Enabled = false
		Sword.Blade.WaterTrail2.Enabled = false	 ]]
    end,

    ["WaterSurfaceSlash"] = function(PathData)
        local Character = PathData.Character
        local Sword = PathData.Sword

        local End = Character.HumanoidRootPart.CFrame
        local p1, p2 = End.p, End.upVector * -200

        -- SoundManager:AddSound("WaterPlayerSlash", {Parent = Character.HumanoidRootPart, Looped = false}, "Client")

        local WaterEffect = ReplicatedStorage.Assets.Effects.Particles.Water:Clone()
        WaterEffect.Color = ColorSequence.new(Color3.fromRGB(255, 92, 52))
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

        for Index = 1, 12 do
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
                    ["Transparency"] = 1,
                    ["CFrame"] = Slash.CFrame * CFrame.Angles(math.pi * add, 0, 0),
                    ["Size"] = Slash.Size + Vector3.new(0, sizeadd, sizeadd),
                }
            )
            Tween:Play()
            Tween:Destroy()

            Debris:AddItem(Slash, 0.3)
        end
    end,
}

return RengokuVFX
