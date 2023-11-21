--|| Services ||--
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Effects = Modules.Effects
local Utility = Modules.Utility
local Shared = Modules.Shared

local HitPart2 = Models.Misc.HitPart2

local World = workspace.World
local Visuals = World.Visuals

--|| Import ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)
local VfxHandler = require(Effects.VfxHandler)
local SoundManager = require(Shared.SoundManager)

local LightningBolt = require(Modules.Effects.LightningBolt)

local CameraShaker = require(Effects.CameraShaker)

local CurrentCamera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
    CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
end)

local BezierModule = require(Modules.Utility.BezierModule)

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

local EffectMeshes = ReplicatedStorage.Assets.Effects.Meshes
local EffectParticles = ReplicatedStorage.Assets.Effects.Particles
local EffectBeams = ReplicatedStorage.Assets.Effects.Beams
local Particles = ReplicatedStorage.Assets.Effects.Particles
local EffectTrails = ReplicatedStorage.Assets.Effects.Trails

local HieiVFX = {

    ["BezierDash"] = function(PathData)
        local Character = PathData.Character
        local Humanoid, Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")

        local Victim = PathData.Victim
        local VHum, VRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")

        for _, v in ipairs(Character:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("MeshPart") then
                if
                    v.Parent ~= "Katana"
                    and v.Parent ~= "Sheath"
                    and v.Name ~= "HumanoidRootPart"
                    and v.Name ~= "FakeHead"
                then
                    v.Transparency = 1
                    delay(0.75, function()
                        v.Transparency = 0
                    end)
                end
            end
        end

        for Index = 1, 5 do
            local hieifire = EffectParticles.hieifire:Clone()

            local StartPosition = Character.HumanoidRootPart.Position
            local EndPosition = VRoot.Position

            --[[ Setpath Properties ]]
            --
            local Magnitude = (StartPosition - EndPosition).Magnitude
            local Midpoint = (StartPosition - EndPosition) / 2

            local PointA = CFrame.new(CFrame.new(StartPosition) * (Midpoint / -1.5)).Position -- first 25% of the path
            local PointB = CFrame.new(CFrame.new(EndPosition) * (Midpoint / 1.5)).Position -- last 25% of the path

            local Offset = Magnitude / 2
            PointA = PointA
                + Vector3.new(math.random(-Offset, Offset), math.random(5, 15), math.random(-Offset, Offset))
            PointB = PointB
                + Vector3.new(math.random(-Offset, Offset), math.random(5, 15), math.random(-Offset, Offset))

            --[[ Position the Hand ]]
            --
            hieifire.Parent = workspace
            hieifire.Position = StartPosition

            --[[ Lerp the Path ]]
            --
            coroutine.wrap(function()
                for Index = 0, 1, 0.025 do
                    local Coordinate = BezierModule:cubicBezier(Index, StartPosition, PointA, PointB, EndPosition)
                    hieifire.CFrame = hieifire.CFrame:Lerp(CFrame.new(Coordinate, EndPosition), Index)
                    RunService.Heartbeat:Wait()
                end
                hieifire.Attachment.ParticleEmitter.Enabled = false
                hieifire.Attachment.Stars.Enabled = false
                hieifire.Attachment.Waves.Enabled = false
                Debris:AddItem(hieifire, 1)
            end)()
        end
    end,

    ["ShadowHitEffect"] = function(PathData)
        local Character = PathData.Character or nil
        local ContactPoint = PathData.ContactPoint
        local Enemy = PathData.Enemy or warn("no enemy found for ShadowHitEffect (Hiei)")

        local RedStar = EffectParticles.RedStar.Attachment:Clone()
        RedStar.RedStar.Size =
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 20), NumberSequenceKeypoint.new(1, 0) })
        RedStar.RedStar:Emit(1)
        RedStar.Parent = Enemy.HumanoidRootPart
        Debris:AddItem(RedStar, 1)

        --[[ Play Sound ]]
        --
        -- SoundManager:AddSound("SGFlesh", {Parent = Character.HumanoidRootPart, Volume = 5}, "Client")
        wait(0.25)
        --// Blood
        local HitAttachment = EffectParticles.HieiSwordHit.Attachment:Clone()
        for i, v in pairs(HitAttachment:GetChildren()) do
            --v.Color = ColorSequence.new(Color3.fromRGB(170, 0, 0))
            v.Enabled = true
            if v.Name ~= "Blood" then
                v:Emit(1.5)
            else
                v.Lifetime = NumberRange.new(0.25)
                v.Speed = NumberRange.new(50)
                v:Emit(100)
            end
            delay(0.125, function()
                v.Enabled = false
            end)
        end
        HitAttachment.Parent = Enemy.HumanoidRootPart

        Debris:AddItem(HitAttachment, 0.75)
        for i = 1, 5 do
            local originalPos = Enemy.HumanoidRootPart.Position
            local beam = EffectMeshes.Block:Clone()
            beam.Shape = "Block"
            local mesh = Instance.new("SpecialMesh")
            mesh.MeshType = "Sphere"
            mesh.Parent = beam
            beam.Size = Vector3.new(0.5, 0.5, 2)
            beam.Material = Enum.Material.SmoothPlastic
            beam.BrickColor = BrickColor.new("Maroon")
            beam.Transparency = 0
            beam.Parent = Visuals

            beam.CFrame = CFrame.new(
                originalPos + Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)),
                originalPos
            )
            local tween = TweenService:Create(
                beam,
                TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {
                    ["Size"] = beam.Size + Vector3.new(0, 0, math.random(0.5, 1)),
                    ["CFrame"] = beam.CFrame * CFrame.new(0, 0, math.random(9, 13)),
                }
            )
            local tween2 = TweenService:Create(
                beam,
                TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                { ["Size"] = Vector3.new(0, 0, 2) }
            )
            tween:Play()
            tween:Destroy()
            tween2:Play()
            tween2:Destroy()
            Debris:AddItem(beam, 0.25)
        end

        HitAttachment.Parent = Enemy.HumanoidRootPart

        --// double bg slash
        for i = 1, 2 do
            local originalPos = Enemy.HumanoidRootPart.Position
            local beam = EffectMeshes.Block:Clone()
            beam.Shape = "Block"
            local mesh = Instance.new("SpecialMesh")
            mesh.MeshType = "Sphere"
            mesh.Parent = beam
            beam.Size = Vector3.new(2, 2, 30)
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
                TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                { ["Size"] = beam.Size + Vector3.new(0, 0, math.random(0.5, 1)) }
            )
            local tween2 = TweenService:Create(
                beam,
                TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                { ["Size"] = Vector3.new(0, 0, 30) }
            )
            tween:Play()
            tween:Destroy()
            tween2:Play()
            tween2:Destroy()
            Debris:AddItem(beam, 0.1)
        end
        --// Circle Slash
        local circleslash = EffectMeshes.circleslash:Clone()
        local one = circleslash.one
        local two = circleslash.two
        local StartSizeOne = Vector3.new(15, 15, 2)
        local StartSizeTwo = Vector3.new(15, 15, 2)
        local Multiple = 2

        one.Size = StartSizeOne
        two.Size = StartSizeTwo
        circleslash.Parent = Visuals

        local Offset = math.random(30, 50)
        if math.random(1, 2) == 1 then
            Offset *= 1
        else
            Offset *= -1
        end

        one.CFrame = Character.HumanoidRootPart.CFrame
            * CFrame.new(0, 1, 0)
            * CFrame.fromEulerAnglesXYZ(math.rad(Offset), 0, 0)
        two.CFrame = Character.HumanoidRootPart.CFrame
            * CFrame.new(0, 1, 0)
            * CFrame.fromEulerAnglesXYZ(math.rad(Offset), 0, 0)

        Debris:AddItem(circleslash, 0.5)

        --// Tween one
        local TweenOne = TweenService:Create(
            one,
            TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            { ["CFrame"] = one.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(270)), ["Size"] = StartSizeOne
                * Multiple }
        )
        TweenOne:Play()
        TweenOne:Destroy()

        --// Tween two
        local TweenTwo = TweenService:Create(
            two,
            TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            { ["CFrame"] = two.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(270)), ["Size"] = StartSizeTwo
                * Multiple }
        )
        TweenTwo:Play()
        TweenTwo:Destroy()

        wait(0.05)
        --// Tween Decals
        for i, v in ipairs(one:GetChildren()) do
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

        for i, v in ipairs(two:GetChildren()) do
            local tween = TweenService:Create(
                v,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Transparency"] = 1 }
            )
            tween:Play()
            tween:Destroy()
        end
    end,

    ["ShadowGash"] = function(PathData)
        local Character = PathData.Character or nil
        local ContactPoint = PathData.ContactPoint
        local Enemy = PathData.Enemy or warn("no enemy found for ShadowGash (Hiei)")

        --[[ Play Sound ]]
        --
        -- SoundManager:AddSound("SGCast", {Parent = Character.HumanoidRootPart, Volume = 1}, "Client")

        --// Circle Slash
        local circleslash = EffectMeshes.circleslash:Clone()
        local one = circleslash.one
        local two = circleslash.two
        local StartSizeOne = Vector3.new(15, 15, 1)
        local StartSizeTwo = Vector3.new(15, 15, 2)
        local Multiple = 2

        one.Size = StartSizeOne
        two.Size = StartSizeTwo
        circleslash.Parent = Visuals

        one.CFrame = Character.HumanoidRootPart.CFrame
            * CFrame.new(0, 1, 0)
            * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
        two.CFrame = Character.HumanoidRootPart.CFrame
            * CFrame.new(0, 1, 0)
            * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)

        Debris:AddItem(circleslash, 0.5)
        --// PointLight
        local PointLight = Instance.new("PointLight")
        PointLight.Color = Color3.fromRGB(170, 85, 255)
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
            { ["CFrame"] = one.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(270)), ["Size"] = StartSizeOne
                * Multiple }
        )
        TweenOne:Play()
        TweenOne:Destroy()

        --// Tween two
        local TweenTwo = TweenService:Create(
            two,
            TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            { ["CFrame"] = two.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(270)), ["Size"] = StartSizeTwo
                * Multiple }
        )
        TweenTwo:Play()
        TweenTwo:Destroy()

        wait(0.05)
        --// Tween Decals
        for i, v in ipairs(one:GetChildren()) do
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

        for i, v in ipairs(two:GetChildren()) do
            local tween = TweenService:Create(
                v,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Transparency"] = 1 }
            )
            tween:Play()
            tween:Destroy()
        end
        --
        wait(0.15)
        --// Set invisible
        for _, v in ipairs(Character:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("MeshPart") then
                if
                    v.Parent ~= "Katana"
                    and v.Parent ~= "Sheath"
                    and v.Name ~= "HumanoidRootPart"
                    and v.Name ~= "FakeHead"
                then
                    v.Transparency = 1
                end
            end
        end
        --

        --// Fire Bezier Following.
        for i = 1, 5 do
            local hieifire = EffectParticles.hieifire:Clone()

            local StartPosition = Character.HumanoidRootPart.Position
            local EndPosition = Enemy.HumanoidRootPart.Position

            --[[ Setpath Properties ]]
            --
            local Magnitude = (StartPosition - EndPosition).Magnitude
            local Midpoint = (StartPosition - EndPosition) / 2

            local PointA = CFrame.new(CFrame.new(StartPosition) * (Midpoint / -1.5)).Position -- first 25% of the path
            local PointB = CFrame.new(CFrame.new(EndPosition) * (Midpoint / 1.5)).Position -- last 25% of the path

            local Offset = Magnitude / 2
            PointA = PointA
                + Vector3.new(math.random(-Offset, Offset), math.random(5, 15), math.random(-Offset, Offset))
            PointB = PointB
                + Vector3.new(math.random(-Offset, Offset), math.random(5, 15), math.random(-Offset, Offset))

            --[[ Position the Hand ]]
            --
            hieifire.Parent = workspace
            hieifire.Position = StartPosition

            --[[ Lerp the Path ]]
            --
            coroutine.wrap(function()
                for i = 0, 1, 0.025 do
                    local Coordinate = BezierModule:cubicBezier(i, StartPosition, PointA, PointB, EndPosition)
                    hieifire.CFrame = hieifire.CFrame:Lerp(CFrame.new(Coordinate, EndPosition), i)
                    game:GetService("RunService").Heartbeat:Wait()
                end
                hieifire.Attachment.ParticleEmitter.Enabled = false
                hieifire.Attachment.Stars.Enabled = false
                hieifire.Attachment.Waves.Enabled = false
                Debris:AddItem(hieifire, 1)
            end)()
        end

        --// wait for bezier to reach
        wait(0.5)
        --// Teleported to Enemy
        --[[ Play Sound ]]
        --
        -- SoundManager:AddSound("SGTeleport", {Parent = Character.HumanoidRootPart, Volume = 5}, "Client")

        --// Set visible
        for i, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("MeshPart") then
                if
                    v.Parent ~= "Katana"
                    and v.Parent ~= "Sheath"
                    and v.Name ~= "HumanoidRootPart"
                    and v.Name ~= "Handle"
                    and v.Name ~= "FakeHead"
                then
                    v.Transparency = 0
                end
            end
        end
        wait(0.25)
        local RedStar = EffectParticles.RedStar.Attachment:Clone()
        RedStar.RedStar.Size =
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 20), NumberSequenceKeypoint.new(1, 0) })
        RedStar.RedStar:Emit(1)
        RedStar.Parent = Enemy.HumanoidRootPart
        Debris:AddItem(RedStar, 1)

        --[[ Play Sound ]]
        --
        -- SoundManager:AddSound("SGFlesh", {Parent = Character.HumanoidRootPart, Volume = 5}, "Client")
        wait(0.25)
        --// Blood
        local HitAttachment = EffectParticles.HieiSwordHit.Attachment:Clone()
        for i, v in pairs(HitAttachment:GetChildren()) do
            --v.Color = ColorSequence.new(Color3.fromRGB(170, 0, 0))
            v.Enabled = true
            if v.Name ~= "Blood" then
                v:Emit(1.5)
            else
                v.Lifetime = NumberRange.new(0.25)
                v.Speed = NumberRange.new(50)
                v:Emit(100)
            end
            delay(0.125, function()
                v.Enabled = false
            end)
        end
        HitAttachment.Parent = Enemy.HumanoidRootPart

        Debris:AddItem(HitAttachment, 0.75)
        for i = 1, 5 do
            local originalPos = Enemy.HumanoidRootPart.Position
            local beam = EffectMeshes.Block:Clone()
            beam.Shape = "Block"
            local mesh = Instance.new("SpecialMesh")
            mesh.MeshType = "Sphere"
            mesh.Parent = beam
            beam.Size = Vector3.new(0.5, 0.5, 2)
            beam.Material = Enum.Material.SmoothPlastic
            beam.BrickColor = BrickColor.new("Maroon")
            beam.Transparency = 0
            beam.Parent = Visuals

            beam.CFrame = CFrame.new(
                originalPos + Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)),
                originalPos
            )
            local tween = TweenService:Create(
                beam,
                TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {
                    ["Size"] = beam.Size + Vector3.new(0, 0, math.random(0.5, 1)),
                    ["CFrame"] = beam.CFrame * CFrame.new(0, 0, math.random(9, 13)),
                }
            )
            local tween2 = TweenService:Create(
                beam,
                TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                { ["Size"] = Vector3.new(0, 0, 2) }
            )
            tween:Play()
            tween:Destroy()
            tween2:Play()
            tween2:Destroy()
            Debris:AddItem(beam, 0.25)
        end

        HitAttachment.Parent = Enemy.HumanoidRootPart

        --[[ Side Shockwaves ]]
        --
        for j = 1, 2 do
            local Offset = 5
            local Rot = 288
            local GoalSize = Vector3.new(50, 0.5, 10)
            if j == 1 then
            else
                Offset = Offset * -1
                Rot = 252
            end

            local SideWind = EffectMeshes.SideWind:Clone()
            SideWind.Size = Vector3.new(8, 0.05, 2)
            SideWind.Color = Color3.fromRGB(255, 255, 255)
            SideWind.Material = Enum.Material.SmoothPlastic
            SideWind.Transparency = -1
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

        --// double bg slash
        for i = 1, 2 do
            local originalPos = Enemy.HumanoidRootPart.Position
            local beam = EffectMeshes.Block:Clone()
            beam.Shape = "Block"
            local mesh = Instance.new("SpecialMesh")
            mesh.MeshType = "Sphere"
            mesh.Parent = beam
            beam.Size = Vector3.new(2, 2, 30)
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
                TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                { ["Size"] = beam.Size + Vector3.new(0, 0, math.random(0.5, 1)) }
            )
            local tween2 = TweenService:Create(
                beam,
                TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                { ["Size"] = Vector3.new(0, 0, 30) }
            )
            tween:Play()
            tween:Destroy()
            tween2:Play()
            tween2:Destroy()
            Debris:AddItem(beam, 0.1)
        end
        --// Circle Slash
        local circleslash = EffectMeshes.circleslash:Clone()
        local one = circleslash.one
        local two = circleslash.two
        local StartSizeOne = Vector3.new(30, 30, 2)
        local StartSizeTwo = Vector3.new(30, 30, 2)
        local Multiple = 2

        one.Size = StartSizeOne
        two.Size = StartSizeTwo
        circleslash.Parent = Visuals

        local Offset = math.random(30, 50)
        if math.random(1, 2) == 1 then
            Offset *= 1
        else
            Offset *= -1
        end

        one.CFrame = Character.HumanoidRootPart.CFrame
            * CFrame.new(0, 1, 0)
            * CFrame.fromEulerAnglesXYZ(math.rad(Offset), 0, 0)
        two.CFrame = Character.HumanoidRootPart.CFrame
            * CFrame.new(0, 1, 0)
            * CFrame.fromEulerAnglesXYZ(math.rad(Offset), 0, 0)

        Debris:AddItem(circleslash, 0.5)

        --// Tween one
        local TweenOne = TweenService:Create(
            one,
            TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            { ["CFrame"] = one.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(270)), ["Size"] = StartSizeOne
                * Multiple }
        )
        TweenOne:Play()
        TweenOne:Destroy()

        --// Tween two
        local TweenTwo = TweenService:Create(
            two,
            TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            { ["CFrame"] = two.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(270)), ["Size"] = StartSizeTwo
                * Multiple }
        )
        TweenTwo:Play()
        TweenTwo:Destroy()

        wait(0.05)
        --// Tween Decals
        for i, v in ipairs(one:GetChildren()) do
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

        for i, v in ipairs(two:GetChildren()) do
            local tween = TweenService:Create(
                v,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Transparency"] = 1 }
            )
            tween:Play()
            tween:Destroy()
        end
    end,

    ["CounterStab"] = function(PathData)
        local Character = PathData.Character or nil
        local ContactPoint = PathData.ContactPoint
        local Enemy = PathData.Enemy or warn("no enemy found for CounterStab (Hiei)")

        --[[ Play Sound ]]
        --
        -- SoundManager:AddSound("SGTeleport", {Parent = Character.HumanoidRootPart, Volume = 3}, "Client")

        --// Set invisible
        for i, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("MeshPart") then
                if
                    v.Parent ~= "Katana"
                    and v.Parent ~= "Sheath"
                    and v.Name ~= "HumanoidRootPart"
                    and v.Name ~= "FakeHead"
                then
                    v.Transparency = 1
                end
            end
        end

        --[[ Side Shockwaves ]]
        --
        for j = 1, 2 do
            local Offset = 5
            local Rot = 288
            local GoalSize = Vector3.new(50, 0.5, 10)
            if j == 1 then
            else
                Offset = Offset * -1
                Rot = 252
            end

            local SideWind = EffectMeshes.SideWind:Clone()
            SideWind.Size = Vector3.new(8, 0.05, 2)
            SideWind.Color = Color3.fromRGB(255, 255, 255)
            SideWind.Material = Enum.Material.SmoothPlastic
            SideWind.Transparency = -1
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

        --	if Character:FindFirstChild("HieiHit") == nil then return end

        -- LINES TEST
        coroutine.wrap(function()
            local Trail = EffectTrails.GroundTrail:Clone()
            Trail.Position = Character.HumanoidRootPart.Position
            Trail.Transparency = 1
            Trail.Parent = Visuals

            --// tween the attachments
            local tween = TweenService:Create(
                Trail.Start,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Position"] = Vector3.new(0, 0, 0.25) }
            )
            tween:Play()
            tween:Destroy()

            local tween = TweenService:Create(
                Trail.End,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Position"] = Vector3.new(0, 0, -0.25) }
            )
            tween:Play()
            tween:Destroy()

            for i = 1, 15 do
                --[[ Raycast ]]
                --
                local StartPosition = (Character.HumanoidRootPart.CFrame * CFrame.new(2, 0, 0)).Position
                local EndPosition = CFrame.new(StartPosition).UpVector * -10

                local RayData = RaycastParams.new()
                RayData.FilterDescendantsInstances = { Character, World.Live, World.Visuals } or World.Visuals
                RayData.FilterType = Enum.RaycastFilterType.Exclude
                RayData.IgnoreWater = true

                local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
                if ray then
                    local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
                    if partHit then
                        Trail.Position = pos
                    end
                end
                game:GetService("RunService").Heartbeat:Wait()
            end
            Debris:AddItem(Trail, 2)
        end)()

        --[[ Terrain Rocks on Ground ]]
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
                local i = 0
                for j = 1, 15 do
                    i += 1
                    --[[ Raycast ]]
                    --
                    local StartPosition = (Character.HumanoidRootPart.CFrame * CFrame.new(2, 0, 0) * CFrame.new(
                        OffsetX,
                        0,
                        -i / 100
                    )).Position
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

                            local X, Y, Z = 0.5, 0.5, 0.5
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
                            Debris:AddItem(Block, 2)
                        end
                    end
                    game:GetService("RunService").Heartbeat:Wait()
                end
            end)()
        end

        --- END TEST

        wait(0.4)
        --// Set visible
        for i, v in ipairs(Character:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("MeshPart") then
                if
                    v.Parent ~= "Katana"
                    and v.Parent ~= "Sheath"
                    and v.Name ~= "HumanoidRootPart"
                    and v.Name ~= "Handle"
                    and v.Name ~= "FakeHead"
                then
                    v.Transparency = 0
                end
            end
        end

        wait(0.5)
        if Character:FindFirstChild("HieiHit") == nil then
            return
        end

        coroutine.wrap(function()
            for i = 1, 2 do
                local RedStar = EffectParticles.RedStar.Attachment:Clone()
                RedStar.RedStar.Size =
                    NumberSequence.new({ NumberSequenceKeypoint.new(0, 20), NumberSequenceKeypoint.new(1, 0) })
                RedStar.RedStar:Emit(1)
                RedStar.Parent = Enemy.HumanoidRootPart
                Debris:AddItem(RedStar, 1)

                --[[ Play Sound ]]
                --
                -- SoundManager:AddSound("SGFlesh", {Parent = Character.HumanoidRootPart, Volume = 5}, "Client")
                --// Blood
                local HitAttachment = EffectParticles.HieiSwordHit.Attachment:Clone()
                for i, v in pairs(HitAttachment:GetChildren()) do
                    --v.Color = ColorSequence.new(Color3.fromRGB(170, 0, 0))
                    v.Enabled = true
                    if v.Name ~= "Blood" then
                        v:Emit(1.5)
                    else
                        v.Lifetime = NumberRange.new(0.15)
                        v.Speed = NumberRange.new(75)
                        v:Emit(100)
                    end
                    delay(0.1, function()
                        v.Enabled = false
                    end)
                end
                HitAttachment.Parent = Enemy.HumanoidRootPart

                Debris:AddItem(HitAttachment, 0.75)
                for i = 1, 5 do
                    local originalPos = Enemy.HumanoidRootPart.Position
                    local beam = EffectMeshes.Block:Clone()
                    beam.Shape = "Block"
                    local mesh = Instance.new("SpecialMesh")
                    mesh.MeshType = "Sphere"
                    mesh.Parent = beam
                    beam.Size = Vector3.new(0.5, 0.5, 2)
                    beam.Material = Enum.Material.SmoothPlastic
                    beam.BrickColor = BrickColor.new("Maroon")
                    beam.Transparency = 0
                    beam.Parent = Visuals

                    beam.CFrame = CFrame.new(
                        originalPos + Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)),
                        originalPos
                    )
                    local tween = TweenService:Create(
                        beam,
                        TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                        {
                            ["Size"] = beam.Size + Vector3.new(0, 0, math.random(0.5, 1)),
                            ["CFrame"] = beam.CFrame * CFrame.new(0, 0, math.random(9, 13)),
                        }
                    )
                    local tween2 = TweenService:Create(
                        beam,
                        TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                        { ["Size"] = Vector3.new(0, 0, 2) }
                    )
                    tween:Play()
                    tween:Destroy()
                    tween2:Play()
                    tween2:Destroy()
                    Debris:AddItem(beam, 0.1)
                end

                HitAttachment.Parent = Enemy.HumanoidRootPart

                --// double bg slash
                for j = 1, 2 do
                    local originalPos = Enemy.HumanoidRootPart.Position
                    local beam = EffectMeshes.Block:Clone()
                    beam.Shape = "Block"
                    local mesh = Instance.new("SpecialMesh")
                    mesh.MeshType = "Sphere"
                    mesh.Parent = beam
                    beam.Size = Vector3.new(1, 1, 30) * i
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
                        TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                        { ["Size"] = beam.Size + Vector3.new(0, 0, math.random(0.5, 1)) }
                    )
                    local tween2 = TweenService:Create(
                        beam,
                        TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                        { ["Size"] = Vector3.new(0, 0, 30 * i) }
                    )
                    tween:Play()
                    tween:Destroy()
                    tween2:Play()
                    tween2:Destroy()
                    Debris:AddItem(beam, 0.1)
                end
                wait(1)
            end
        end)()
        if Character:FindFirstChild("HieiHit") == nil then
            return
        end

        --// Circle Slash
        local circleslash = EffectMeshes.circleslash:Clone()
        local one = circleslash.one
        local two = circleslash.two
        local StartSizeOne = Vector3.new(15, 15, 1)
        local StartSizeTwo = Vector3.new(15, 15, 2)
        local Multiple = 2

        one.Size = StartSizeOne
        two.Size = StartSizeTwo
        circleslash.Parent = Visuals

        one.CFrame = Character.HumanoidRootPart.CFrame
            * CFrame.new(0, 1, 0)
            * CFrame.fromEulerAnglesXYZ(math.rad(90), math.rad(45), 0)
        two.CFrame = Character.HumanoidRootPart.CFrame
            * CFrame.new(0, 1, 0)
            * CFrame.fromEulerAnglesXYZ(math.rad(90), math.rad(45), 0)

        Debris:AddItem(circleslash, 0.5)
        --// PointLight
        local PointLight = Instance.new("PointLight")
        PointLight.Color = Color3.fromRGB(170, 85, 255)
        PointLight.Range = 50
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
            { ["CFrame"] = one.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(270)), ["Size"] = StartSizeOne
                * Multiple }
        )
        TweenOne:Play()
        TweenOne:Destroy()

        --// Tween two
        local TweenTwo = TweenService:Create(
            two,
            TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            { ["CFrame"] = two.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(270)), ["Size"] = StartSizeTwo
                * Multiple }
        )
        TweenTwo:Play()
        TweenTwo:Destroy()

        wait(0.05)

        --// Tween Decals
        for i, v in ipairs(one:GetChildren()) do
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

        for i, v in ipairs(two:GetChildren()) do
            local tween = TweenService:Create(
                v,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Transparency"] = 1 }
            )
            tween:Play()
            tween:Destroy()
        end
        --

        wait(0.8)
        if Character:FindFirstChild("HieiHit") == nil then
            return
        end

        --[[ Play Sound ]]
        --
        -- SoundManager:AddSound("DragonExplosion", {Parent = Character.HumanoidRootPart, Volume = 4}, "Client")
        wait(0.2)

        for i = 1, 10 do
            game:GetService("RunService").Heartbeat:Wait()
            --// Circle Slash
            local circleslash = EffectMeshes.circleslash:Clone()
            local one = circleslash.one
            local two = circleslash.two
            local StartSizeOne = Vector3.new(15, 15, 1)
            local StartSizeTwo = Vector3.new(15, 15, 2)
            local Multiple = math.random(3, 7)

            one.Size = StartSizeOne
            two.Size = StartSizeTwo
            circleslash.Parent = Visuals

            one.CFrame = Character.HumanoidRootPart.CFrame
                * CFrame.new(0, 1, 0)
                * CFrame.fromEulerAnglesXYZ(math.rad(math.random(0, 360)), math.rad(math.random(0, 360)), 0)
            two.CFrame = Character.HumanoidRootPart.CFrame
                * CFrame.new(0, 1, 0)
                * CFrame.fromEulerAnglesXYZ(math.rad(math.random(0, 360)), math.rad(math.random(0, 360)), 0)

            Debris:AddItem(circleslash, 0.5)
            --// PointLight
            local PointLight = Instance.new("PointLight")
            PointLight.Color = Color3.fromRGB(170, 85, 255)
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
                    ["CFrame"] = one.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(270)),
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
                    ["CFrame"] = two.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(270)),
                    ["Size"] = StartSizeTwo * Multiple,
                }
            )
            TweenTwo:Play()
            TweenTwo:Destroy()
            --// Tween Decals
            for i, v in ipairs(one:GetChildren()) do
                if v:IsA("Decal") then
                    local tween = TweenService:Create(
                        v,
                        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { ["Transparency"] = 1 }
                    )
                    tween:Play()
                    tween:Destroy()
                end
            end

            for i, v in ipairs(two:GetChildren()) do
                local tween = TweenService:Create(
                    v,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { ["Transparency"] = 1 }
                )
                tween:Play()
                tween:Destroy()
            end
        end
        wait(0.2)
        --
        if Character:FindFirstChild("HieiHit") == nil then
            return
        end

        for i = 1, 5 do
            --[[ Setpath Properties ]]
            --
            local StartPosition = Character.HumanoidRootPart.Position
            local EndPosition = Enemy.HumanoidRootPart.Position

            local Magnitude = (StartPosition - EndPosition).Magnitude
            local Midpoint = (StartPosition - EndPosition) / 2

            local PointA = CFrame.new(CFrame.new(StartPosition) * (Midpoint / -1.5)).Position -- first 25% of the path
            local PointB = CFrame.new(CFrame.new(EndPosition) * (Midpoint / 1.5)).Position -- last 25% of the path

            local Offset = Magnitude
            PointA = PointA
                + Vector3.new(
                    math.random(-Offset, Offset),
                    math.random(Offset / 2, Offset),
                    math.random(-Offset, Offset)
                )
            PointB = PointB
                + Vector3.new(
                    math.random(-Offset, Offset),
                    math.random(Offset / 2, Offset),
                    math.random(-Offset, Offset)
                )

            coroutine.wrap(function()
                --[[ Lerp to Path ]]
                --
                local Speed = 1
                for i = 1, Magnitude, Speed do
                    local Percent = i / Magnitude
                    local Coordinate = BezierModule:cubicBezier(Percent, StartPosition, PointA, PointB, EndPosition)

                    local nextPoint = (
                        (i + 1) < Magnitude
                            and BezierModule:cubicBezier(
                                (i + 1) / Magnitude,
                                StartPosition,
                                PointA,
                                PointB,
                                EndPosition
                            )
                        or BezierModule:cubicBezier(1, StartPosition, PointA, PointB, EndPosition)
                    )

                    -- trail test --
                    local trail = EffectMeshes.cylinder:Clone()
                    trail.Color = Color3.fromRGB(0, 0, 0)
                    trail.Size = Vector3.new(2, (Coordinate - nextPoint).magnitude * Speed, 2)
                    trail.CFrame = CFrame.lookAt(Coordinate, nextPoint) * CFrame.Angles(math.rad(90), 0, 0)
                    local tween = TweenService:Create(
                        trail,
                        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { Size = Vector3.new(0, trail.Size.Y + 3, 0), Color = Color3.fromRGB(111, 111, 168) }
                    )
                    tween:Play()
                    tween:Destroy()
                    game.Debris:AddItem(trail, 0.25)
                    trail.Parent = Visuals

                    game:GetService("RunService").Heartbeat:Wait()
                end
            end)()
        end
        --
        --[[ Stars xD ]]
        --
        local Stars = EffectParticles.ParticleAttatchments.Stars:Clone()
        Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
        Stars.Stars.LightEmission = 0
        Stars.Stars.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
        Stars.Stars.Drag = 5
        Stars.Stars.Rate = 100
        Stars.Stars.Acceleration = Vector3.new(0, -50, 0)
        Stars.Stars.Lifetime = NumberRange.new(0.75)
        Stars.Stars.Speed = NumberRange.new(50, 70)

        Stars.Stars.Enabled = true
        Stars.Stars:Emit(50)
        Debris:AddItem(Stars, 1)

        --[[ Fire P00rticle XD ]]
        --
        local Fire = EffectParticles.Hiei:Clone()
        Fire.CFrame = Enemy.HumanoidRootPart.CFrame

        Fire.Cremation.Speed = NumberRange.new(50)
        Fire.Cremation.Drag = 5

        Fire.Cremation.Lifetime = NumberRange.new(0.5)
        Fire.Cremation.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 5), NumberSequenceKeypoint.new(1, 0) })
        Fire.Cremation.Acceleration = Vector3.new(0, -5, 0)
        Fire.Cremation.Rate = 200

        Stars.Parent = Fire
        coroutine.wrap(function()
            Fire.Cremation.Enabled = true
            for i = 1, 2 do
                Fire.Cremation:Emit(25)
                wait(0.05)
            end
            Fire.Cremation.Enabled = false
            Stars.Stars.Enabled = false
        end)()
        Fire.Parent = Visuals
        Debris:AddItem(Fire, 0.75)
    end,

    ["SwordOfDarkness"] = function(PathData)
        local Character = PathData.Character or nil
        local ContactPoint = PathData.ContactPoint
        local RootStartPosition = Character.HumanoidRootPart.CFrame
        --[[ Play Sound ]]
        --
        -- SoundManager:AddSound("SODTeleport", {Parent = Character.HumanoidRootPart, Volume = 3}, "Client")

        --// Set invisible
        for i, v in ipairs(Character:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("MeshPart") then
                if
                    v.Parent ~= "Katana"
                    and v.Parent ~= "Sheath"
                    and v.Name ~= "HumanoidRootPart"
                    and v.Name ~= "FakeHead"
                then
                    v.Transparency = 1
                end
            end
        end

        VfxHandler.Rockszsz({
            Cframe = RootStartPosition, -- Position
            Amount = 15, -- How manay rocks
            Iteration = 5, -- Expand
            Max = 1, -- Length upwards
            FirstDuration = 0.25, -- Rock tween outward start duration
            RocksLength = 3, -- How long the rocks stay for
        })

        --[[ Side Shockwaves ]]
        --
        for j = 1, 2 do
            local Offset = 5
            local Rot = 288
            local GoalSize = Vector3.new(50, 0.5, 10)
            if j == 1 then
            else
                Offset = Offset * -1
                Rot = 252
            end

            local SideWind = EffectMeshes.SideWind:Clone()
            SideWind.Size = Vector3.new(8, 0.05, 2)
            SideWind.Color = Color3.fromRGB(255, 255, 255)
            SideWind.Material = Enum.Material.SmoothPlastic
            SideWind.Transparency = -1
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

        -- LINES TEST
        coroutine.wrap(function()
            local Trail = EffectTrails.GroundTrail:Clone()
            Trail.Trail.Lifetime = 3
            Trail.Position = Character.HumanoidRootPart.Position
            Trail.Transparency = 1
            Trail.Parent = Visuals

            --// tween the attachments
            local tween = TweenService:Create(
                Trail.Start,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Position"] = Vector3.new(0, 0, 0.25) }
            )
            tween:Play()
            tween:Destroy()

            local tween = TweenService:Create(
                Trail.End,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Position"] = Vector3.new(0, 0, -0.25) }
            )
            tween:Play()
            tween:Destroy()

            local i = 0
            for j = 1, 15 do
                i += 1.5
                --[[ Raycast ]]
                --
                local StartPosition = (Character.HumanoidRootPart.CFrame).Position
                local EndPosition = CFrame.new(StartPosition).UpVector * -10

                local RayData = RaycastParams.new()
                RayData.FilterDescendantsInstances = { Character, World.Live, World.Visuals } or World.Visuals
                RayData.FilterType = Enum.RaycastFilterType.Exclude
                RayData.IgnoreWater = true

                local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
                if ray then
                    local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
                    if partHit then
                        Trail.Position = pos
                    end
                end
                game:GetService("RunService").Heartbeat:Wait()

                --// Circle Slash
                local circleslash = EffectMeshes.circleslash:Clone()
                local one = circleslash.one
                local two = circleslash.two
                local StartSizeOne = Vector3.new(15, 15, 1)
                local StartSizeTwo = Vector3.new(15, 15, 2)
                local Multiple = math.random(2, 3)

                one.Size = StartSizeOne
                two.Size = StartSizeTwo
                circleslash.Parent = Visuals

                one.CFrame = RootStartPosition
                    * CFrame.new(0, 1, -i)
                    * CFrame.fromEulerAnglesXYZ(math.rad(math.random(0, 360)), math.rad(math.random(0, 360)), 0)
                two.CFrame = RootStartPosition
                    * CFrame.new(0, 1, -i)
                    * CFrame.fromEulerAnglesXYZ(math.rad(math.random(0, 360)), math.rad(math.random(0, 360)), 0)

                Debris:AddItem(circleslash, 0.5)
                --// PointLight
                local PointLight = Instance.new("PointLight")
                PointLight.Color = Color3.fromRGB(170, 85, 255)
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
                        ["CFrame"] = one.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(270)),
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
                        ["CFrame"] = two.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(270)),
                        ["Size"] = StartSizeTwo * Multiple,
                    }
                )
                TweenTwo:Play()
                TweenTwo:Destroy()
                --// Tween Decals
                for i, v in ipairs(one:GetChildren()) do
                    if v:IsA("Decal") then
                        local tween = TweenService:Create(
                            v,
                            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                            { ["Transparency"] = 1 }
                        )
                        tween:Play()
                        tween:Destroy()
                    end
                end

                for i, v in ipairs(two:GetChildren()) do
                    local tween = TweenService:Create(
                        v,
                        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { ["Transparency"] = 1 }
                    )
                    tween:Play()
                    tween:Destroy()
                end
            end
            game.Debris:AddItem(Trail, 3)
        end)()

        --[[ Terrain Rocks on Ground ]]
        --
        for loops = 1, 2 do
            coroutine.wrap(function()
                local OffsetX = 2
                --[[ Change Offset. Two Rocks on Both Sides. ]]
                --
                if loops == 2 then
                    OffsetX = OffsetX * -1
                end

                local GroundRocks = {}
                local i = 0
                for j = 1, 15 do
                    i += 1
                    --[[ Raycast ]]
                    --
                    local StartPosition = (Character.HumanoidRootPart.CFrame * CFrame.new(OffsetX, 0, -i / 100)).Position
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

                            local X, Y, Z = 1, 1, 1
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
                            Debris:AddItem(Block, 3)
                        end
                    end
                    game:GetService("RunService").Heartbeat:Wait()
                end
            end)()
        end
        --- END TEST
        local cylinder = EffectMeshes.hieicylinder:Clone()
        cylinder.CFrame = Character.HumanoidRootPart.CFrame
            * CFrame.new(0, 0, -25)
            * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
        cylinder.Parent = Visuals

        local Tween = TweenService:Create(
            cylinder,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["Size"] = Vector3.new(0, cylinder.Size.Y, 0) }
        )
        Tween:Play()
        Tween:Destroy()

        coroutine.wrap(function()
            cylinder.Slash.Enabled = true
            for i = 1, 2 do
                cylinder.Slash:Emit(2)
                cylinder.RedStar:Emit(2)
                wait(0.05)
            end
            cylinder.Slash.Enabled = false
            wait(0.2)
            cylinder.RedStar:Emit(2)
            cylinder.Transparency = 1
        end)()

        Debris:AddItem(cylinder, 1)
        --[[ Play Sound ]]
        --
        -- SoundManager:AddSound("SODExplosion", {Parent = Character.HumanoidRootPart, Volume = 2}, "Client")
        wait(0.4)
        --// Set visible
        for i, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("MeshPart") then
                if
                    v.Parent ~= "Katana"
                    and v.Parent ~= "Sheath"
                    and v.Name ~= "HumanoidRootPart"
                    and v.Name ~= "Handle"
                    and v.Name ~= "FakeHead"
                then
                    v.Transparency = 0
                end
            end
        end
    end,

    ["BlackDragonHellfire"] = function(PathData)
        local Character = PathData.Character or nil
        local ContactPoint = PathData.ContactPoint

        --[[ Play Sound ]]
        --

        local function DragonImpact(Dragon)
            --// play dragon roar
            -- SoundManager:AddSound("DragonExplosion", {Parent = Character.HumanoidRootPart, Volume = 2}, "Client")

            --// PointLight
            local PointLight = Instance.new("PointLight")
            PointLight.Color = Color3.fromRGB(170, 170, 255)
            PointLight.Range = 300
            PointLight.Brightness = 5
            PointLight.Parent = Dragon

            local LightTween = TweenService:Create(
                PointLight,
                TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Range"] = 0, ["Brightness"] = 0 }
            )
            LightTween:Play()
            LightTween:Destroy()

            --[[ Ball Effect ]]
            --
            local Ball = EffectMeshes.ball:Clone()
            Ball.Color = Color3.fromRGB(170, 85, 255)
            Ball.Material = Enum.Material.ForceField
            Ball.Transparency = 0
            Ball.Size = Vector3.new(30, 30, 30)
            Ball.Position = Dragon.Position
            Ball.Parent = Visuals

            local tween = TweenService:Create(
                Ball,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ["Transparency"] = 1, ["Size"] = Ball.Size * 4 }
            )
            tween:Play()
            tween:Destroy()
            Debris:AddItem(Ball, 0.25)

            --[[ Stars xD ]]
            --
            local Stars = EffectParticles.ParticleAttatchments.Stars:Clone()
            Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
            Stars.Stars.LightEmission = 0
            Stars.Stars.Size =
                NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
            Stars.Stars.Drag = 5
            Stars.Stars.Rate = 100
            Stars.Stars.Acceleration = Vector3.new(0, -100, 0)
            Stars.Stars.Lifetime = NumberRange.new(1, 1.5)
            Stars.Stars.Speed = NumberRange.new(150, 200)

            Stars.Stars.Enabled = true
            Stars.Stars:Emit(100)
            Debris:AddItem(Stars, 2)

            --[[ Fire P00rticle XD ]]
            --
            local Fire = EffectParticles.Hiei:Clone()
            Fire.CFrame = CFrame.new(ContactPoint)

            Fire.Cremation.Speed = NumberRange.new(200)
            Fire.Cremation.Drag = 5

            Fire.Cremation.Lifetime = NumberRange.new(0.5)
            Fire.Cremation.Size =
                NumberSequence.new({ NumberSequenceKeypoint.new(0, 20), NumberSequenceKeypoint.new(1, 0) })
            Fire.Cremation.Acceleration = Vector3.new(0, -5, 0)
            Fire.Cremation.Rate = 200

            Stars.Parent = Fire
            coroutine.wrap(function()
                Fire.Cremation.Enabled = true
                for i = 1, 2 do
                    Fire.Cremation:Emit(25)
                    wait(0.05)
                end
                Fire.Cremation.Enabled = false
                Stars.Stars.Enabled = false
            end)()
            Fire.Parent = Visuals
            Debris:AddItem(Fire, 2)
            --
            for i, v in pairs(Dragon.Parent:GetChildren()) do
                local Tween = TweenService:Create(
                    v,
                    TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { ["Transparency"] = 1 }
                )
                Tween:Play()
                Tween:Destroy()
            end

            Debris:AddItem(Dragon.Parent, 0.5)

            local shock = EffectMeshes.upwardShock:Clone()
            shock.CFrame = Dragon.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(90), 0)
            shock.Color = Color3.fromRGB(57, 57, 86)
            shock.Size = Vector3.new(0, 0, 0)
            local tween = TweenService:Create(
                shock,
                TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = Vector3.new(75, 105, 75), CFrame = shock.CFrame
                    * CFrame.new(0, 35, 0)
                    * CFrame.Angles(0, math.pi / 2, 0) }
            )
            tween:Play()
            tween:Destroy()
            coroutine.wrap(function()
                wait(0.2)
                local tween = TweenService:Create(
                    shock,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { Size = Vector3.new(0, 80, 0), Color = Color3.fromRGB(111, 111, 168) }
                )
                tween:Play()
                tween:Destroy()
                game.Debris:AddItem(shock, 0.2)
            end)()
            shock.Parent = Visuals

            --[[ New Shockwave ]]
            --
            local Shockwave = EffectParticles.ParticleAttatchments.Shockwave:Clone()
            Shockwave.Shockwave.Size =
                NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 120) })
            Shockwave.Shockwave.Parent = Fire
            Fire.Shockwave:Emit(2)

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
                        if i % 2 == 0 then
                            beam.Color = Color3.fromRGB(0, 0, 0)
                        else
                            beam.Color = Color3.fromRGB(47, 0, 71)
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
                                ["Size"] = beam.Size + Vector3.new(0, 0, math.random(2, 5)),
                                ["CFrame"] = beam.CFrame * CFrame.new(0, 0, 50),
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

            --[[ Flying Debris Rock ]]
            --
            local Offset = 20
            local RootPos = Dragon.Position + Vector3.new(0, 5, 0)
            for i = 1, 2 do
                for j = 1, 5 do
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
                            Block.Velocity = Vector3.new(
                                math.random(-80, 80),
                                math.random(50, 60),
                                math.random(-80, 80)
                            ) * (j * 0.65)
                            BodyVelocity.Parent = Block

                            Debris:AddItem(BodyVelocity, 0.05)
                            Debris:AddItem(Block, 2)
                        end
                    end
                end
                wait()
            end

            --// Lightning
            Offset = 60
            local StartPosition = (
                Vector3.new(math.sin(360) * Offset, 0, math.cos(360) * Offset) + (
                    Dragon.Position + Vector3.new(0, 5, 0)
                )
            )
            local EndPosition = CFrame.new(StartPosition).UpVector * -10

            local RayData = RaycastParams.new()
            RayData.FilterDescendantsInstances = { Character, World.Live, World.Visuals } or World.Visuals
            RayData.FilterType = Enum.RaycastFilterType.Exclude
            RayData.IgnoreWater = true

            local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
            if ray then
                local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
                if pos then
                    local Smoke = Particles.Smoke:Clone()
                    Smoke.Smoke.Size =
                        NumberSequence.new({ NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 0) })
                    Smoke.Smoke.Color = ColorSequence.new(partHit.Color)
                    Smoke.Smoke.Acceleration = Vector3.new(0, 5, 0)
                    Smoke.Smoke.Drag = 5
                    Smoke.Smoke.Lifetime = NumberRange.new(3)
                    Smoke.Smoke.Rate = 500
                    Smoke.Transparency = 1
                    Smoke.Smoke.Speed = NumberRange.new(100)
                    Smoke.Position = Dragon.Position
                    Smoke.Size = Vector3.new(50, 0, 50)
                    Smoke.Parent = Visuals
                    coroutine.wrap(function()
                        Smoke.Smoke.Enabled = true
                        for i = 1, 2 do
                            Smoke.Smoke:Emit(25)
                            wait(0.05)
                        end
                        Smoke.Smoke.Enabled = false
                    end)()
                    Debris:AddItem(Smoke, 4)

                    for i = 1, 20 do
                        --// lightning contact ripple \\--
                        local newStartPosition = Dragon.Position
                        local newEndPosition = (
                            Vector3.new(math.sin(360 * i) * Offset, 0, math.cos(360 * i) * Offset) + Dragon.Position
                        )

                        local baseBall = EffectMeshes.Block:Clone()
                        baseBall.Transparency = 1
                        baseBall.Size = Vector3.new(0, 0, 0)
                        baseBall.Anchored = true
                        baseBall.CanCollide = false
                        baseBall.Position = newStartPosition
                        baseBall.Parent = Visuals

                        local ball = EffectMeshes.Block:Clone()
                        ball.Transparency = 1
                        ball.Size = Vector3.new(0, 0, 0)
                        ball.Anchored = true
                        ball.CanCollide = false
                        ball.Position = newEndPosition
                        ball.Parent = Visuals

                        local Attachment = Instance.new("Attachment")
                        Attachment.Parent = baseBall

                        local Attachment2 = Instance.new("Attachment")
                        Attachment2.Parent = ball

                        local a1, a2 = Attachment, Attachment2
                        for i = 1, 2 do
                            local ranCF = CFrame.fromAxisAngle(
                                (newEndPosition - newStartPosition).Unit,
                                2 * math.random() * math.pi
                            )

                            local A1, A2 = {}, {}
                            A1.WorldPosition, A1.WorldAxis = a1.WorldPosition, ranCF * a1.WorldAxis
                            A2.WorldPosition, A2.WorldAxis = a2.WorldPosition, ranCF * a2.WorldAxis
                            local NewBolt = LightningBolt.new(A1, A2, 10)
                            NewBolt.CurveSize0, NewBolt.CurveSize1 = 0, 0
                            NewBolt.MinRadius, NewBolt.MaxRadius = 0, 15
                            NewBolt.Frequency = 1
                            NewBolt.AnimationSpeed = 7
                            NewBolt.Thickness = 1
                            NewBolt.MinThicknessMultiplier, NewBolt.MaxThicknessMultiplier = 0.2, 1

                            NewBolt.MinTransparency, NewBolt.MaxTransparency = 0, 1
                            NewBolt.PulseSpeed = 5
                            NewBolt.PulseLength = 1
                            NewBolt.FadeLength = 0.2
                            NewBolt.ContractFrom = 0.5

                            --Bolt Color Properties--
                            if i == 1 then
                                NewBolt.Color = Color3.fromRGB(0, 0, 0)
                            else
                                NewBolt.Color = Color3.fromRGB(170, 170, 255)
                            end
                            NewBolt.ColorOffsetSpeed = 5
                        end
                        Debris:AddItem(Attachment, 0.5)
                        Debris:AddItem(ball, 0.5)
                        Debris:AddItem(baseBall, 0.5)
                    end
                end
            end

            VfxHandler.Rockszsz({
                Cframe = CFrame.new(Dragon.Position), -- Position
                Amount = 25, -- How manay rocks
                Iteration = 30, -- Expand
                Max = 5, -- Length upwards
                FirstDuration = 0.25, -- Rock tween outward start duration
                RocksLength = 3, -- How long the rocks stay for
            })
        end

        --// play dragon roar
        -- SoundManager:AddSound("DragonRoar", {Parent = Character.HumanoidRootPart, Volume = 2}, "Client")

        --// Set up Dragon Head
        local Dragon = Models.Misc.Dragon:Clone()
        --Dragon.Head.CFrame = Character.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)
        for i, v in pairs(Dragon:GetChildren()) do
            v.CFrame = Character.HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(270), 0, math.rad(90))
        end
        Dragon.Parent = Visuals

        --[[ Setpath Properties ]]
        --
        local StartPosition = Character.HumanoidRootPart.Position
        local EndPosition = ContactPoint

        local Magnitude = (StartPosition - EndPosition).Magnitude
        local Midpoint = (StartPosition - EndPosition) / 2

        local PointA = CFrame.new(CFrame.new(StartPosition) * (Midpoint / -1.5)).Position -- first 25% of the path
        local PointB = CFrame.new(CFrame.new(EndPosition) * (Midpoint / 1.5)).Position -- last 25% of the path

        local Offset = Magnitude / 2
        PointA = PointA + Vector3.new(math.random(-Offset, Offset), math.random(10, 25), math.random(-Offset, Offset))
        PointB = PointB + Vector3.new(math.random(-Offset, Offset), math.random(10, 25), math.random(-Offset, Offset))

        --[[ Lerp to Path ]]
        --
        local Speed = 4
        for i = 1, Magnitude, Speed do
            local Percent = i / Magnitude
            local Coordinate = BezierModule:cubicBezier(Percent, StartPosition, PointA, PointB, EndPosition)
            Dragon.Head.CFrame = Dragon.Head.CFrame:Lerp(
                CFrame.new(Coordinate, EndPosition) * CFrame.fromEulerAnglesXYZ(math.rad(270), 0, math.rad(90)),
                Percent
            )

            local nextPoint = (
                (i + 1) < Magnitude
                    and BezierModule:cubicBezier((i + 1) / Magnitude, StartPosition, PointA, PointB, EndPosition)
                or BezierModule:cubicBezier(1, StartPosition, PointA, PointB, EndPosition)
            )

            -- trail test --
            local trail = EffectMeshes.cylinder:Clone()
            trail.Color = Color3.fromRGB(0, 0, 0)
            trail.Size = Vector3.new(15, (Coordinate - nextPoint).Magnitude * Speed / 2, 15)
            trail.CFrame = CFrame.lookAt(Coordinate, nextPoint) * CFrame.Angles(math.rad(90), 0, 0)
            local tween = TweenService:Create(
                trail,
                TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = Vector3.new(0, trail.Size.Y + 8, 0), Color = Color3.fromRGB(111, 111, 168) }
            )
            tween:Play()
            tween:Destroy()
            game.Debris:AddItem(trail, 0.5)
            trail.Parent = Visuals

            game:GetService("RunService").Heartbeat:Wait()

            Speed = math.random(2, 4)
        end
        DragonImpact(Dragon.Head)
    end,

    ["Charge"] = function(Data)
        Character = Data.Character
        --[[ Lines in Front/Gravity Force ]]
        --
        coroutine.wrap(function()
            local WIDTH, LENGTH = 0.2, 4
            for j = 1, 60 do
                for i = 1, 1 do
                    local Sphere = EffectMeshes.Sphere:Clone()
                    Sphere.Transparency = 0
                    Sphere.Mesh.Scale = Vector3.new(WIDTH, LENGTH, WIDTH)
                    Sphere.Material = Enum.Material.Neon
                    if j % 2 == 0 then
                        Sphere.Color = Color3.fromRGB(0, 0, 0)
                    else
                        Sphere.Color = Color3.fromRGB(85, 85, 127)
                    end
                    Sphere.CFrame = Character.HumanoidRootPart.CFrame
                        * CFrame.new(math.random(-4, 4) * i, -5, math.random(-2, 2) * i)
                    Sphere.Parent = Visuals

                    local tween = TweenService:Create(
                        Sphere,
                        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { ["Transparency"] = 1, ["Position"] = Sphere.Position + Vector3.new(0, math.random(7.5, 10), 0) }
                    )
                    tween:Play()
                    tween:Destroy()
                    Debris:AddItem(Sphere, 0.1)
                end
                wait()
            end
        end)()

        --[[ Smoke Effect on Ground ]]
        --
        local Smoke = Particles.Smoke:Clone()
        Smoke.Smoke.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 5) })
        Smoke.Smoke.Drag = 5
        Smoke.Smoke.Lifetime = NumberRange.new(0.35)
        Smoke.Smoke.Rate = 250
        Smoke.Smoke:Emit(5)
        Smoke.Smoke.Speed = NumberRange.new(75)
        Smoke.Smoke.SpreadAngle = Vector2.new(1, 180)
        Smoke.Smoke.Enabled = true
        Smoke.CFrame = Character.HumanoidRootPart.CFrame
            * CFrame.new(0, -2.5, 0)
            * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
        Smoke.Parent = Visuals

        Debris:AddItem(Smoke, 2.5)

        --[[ Small Rock Debris Fly Up ]]
        --
        for j = 1, 40 do
            for i = 1, math.random(1, 2) do
                --[[ Raycast ]]
                --
                local StartPosition = (
                    Vector3.new(math.sin(360 * j) * math.random(5, 10), 0, math.cos(360 * j) * math.random(5, 10))
                    + Character.HumanoidRootPart.Position
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

                        local X, Y, Z = math.random(20, 50) / 100, math.random(20, 50) / 100, math.random(20, 50) / 100
                        Block.Size = Vector3.new(X, Y, Z)

                        Block.Position = pos
                        Block.Rotation =
                            Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
                        Block.Transparency = 0
                        Block.Color = partHit.Color
                        Block.Material = partHit.Material
                        Block.Parent = Visuals

                        local tween = TweenService:Create(
                            Block,
                            TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                            {
                                ["Transparency"] = 1,
                                ["Orientation"] = Block.Orientation
                                    + Vector3.new(
                                        math.random(-360, 360),
                                        math.random(-360, 360),
                                        math.random(-360, 360)
                                    ),
                                ["Position"] = Block.Position + Vector3.new(0, math.random(5, 10), 0),
                            }
                        )
                        tween:Play()
                        tween:Destroy()
                        Debris:AddItem(Block, 0.25)

                        --[[ Set Smoke Properties ]]
                        --
                        Smoke.Smoke.Color = ColorSequence.new(partHit.Color)
                    end
                else
                    Smoke:Destroy()
                end
            end
            wait()
        end
    end,

    ["HieiScreen"] = function(Data)
        local Character = Data.Character or nil
        local ContactPoint = Data.ContactPoint

        local ColorCorrection = Instance.new("ColorCorrectionEffect")
        ColorCorrection.Parent = Lighting

        local tween2 = TweenService:Create(
            ColorCorrection,
            TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["TintColor"] = Color3.fromRGB(0, 0, 0), ["Brightness"] = 0, ["Contrast"] = 0, ["Saturation"] = -1 }
        )
        tween2:Play()
        tween2:Destroy()

        wait(0.075)
        local tween2 = TweenService:Create(
            ColorCorrection,
            TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["TintColor"] = Color3.fromRGB(85, 0, 0), ["Brightness"] = 0, ["Contrast"] = 0, ["Saturation"] = 0 }
        )
        tween2:Play()
        tween2:Destroy()

        wait(0.1)
        local tween2 = TweenService:Create(
            ColorCorrection,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["TintColor"] = Color3.fromRGB(255, 255, 255), ["Brightness"] = 0, ["Contrast"] = 0, ["Saturation"] = 0 }
        )
        tween2:Play()
        tween2:Destroy()

        Debris:AddItem(ColorCorrection, 0.1)
    end,

    ["Slam"] = function(Data)
        local Character = Data.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        if GlobalFunctions.CheckDistance(Player, 45) then
            GlobalFunctions.FreshShake(100, 30, 1, 0.2, 0)
        end

        local RayParam = RaycastParams.new()
        RayParam.FilterType = Enum.RaycastFilterType.Exclude
        RayParam.FilterDescendantsInstances = { Character, workspace.World.Visuals }

        local RaycastResult = workspace:Raycast(Root.Position, Vector3.new(0, -1000, 500), RayParam) or {}
        local Target, Position = RaycastResult.Instance, RaycastResult.Position

        if Target then
            for Index = 1, math.random(6, 10) do
                local x, y, z =
                    math.cos(math.rad(math.random(1, 6) * 60)),
                    math.cos(math.rad(math.random(1, 6) * 60)),
                    math.sin(math.rad(math.random(1, 6) * 60))
                local Start = Position
                local End = Start + Vector3.new(x, y, z)

                local Orbie = ReplicatedStorage.Assets.Effects.Meshes.MeshOribe:Clone()
                Orbie.Color = Color3.fromRGB(170, 85, 255)
                Orbie.CFrame = CFrame.new(Start, End)
                Orbie.Size = Vector3.new(1, 2, 1)

                local OrbieTweenInfo =
                    TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

                local Tween = TweenService:Create(
                    Orbie,
                    OrbieTweenInfo,
                    {
                        CFrame = CFrame.new(Start, End) * CFrame.new(0, 0, -(math.random(2, 5) * 10)),
                        Size = Vector3.new(0, 0, 24),
                    }
                )
                Tween:Play()
                Tween:Destroy()

                Debris:AddItem(Orbie, 0.2)
                Orbie.Parent = workspace.World.Visuals
            end

            local CrashSmoke = ReplicatedStorage.Assets.Effects.Particles.CrashSmoke:Clone()
            CrashSmoke.Size = Vector3.new(12, 1, 12)
            CrashSmoke.Position = Position
            CrashSmoke.Smoke.Color = ColorSequence.new(Target.Color)
            VfxHandler.Emit(CrashSmoke.Smoke, 15)
            CrashSmoke.Parent = workspace.World.Visuals
            delay(1, function()
                CrashSmoke.Smoke.Enabled = false
            end)
            Debris:AddItem(CrashSmoke, 3)

            VfxHandler.RockExplosion({
                Pos = Position,
                Quantity = 8,
                Radius = 15,
                Size = Vector3.new(2.5, 2.5, 2.5),
                Duration = 2,
            })

            for _ = 1, 10 do
                local Rock = ReplicatedStorage.Assets.Effects.Meshes.Rock:Clone()
                Rock.Position = Root.Position
                Rock.Material = Target.Material
                Rock.Color = Target.Color
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
                BlockTrail.Color = ColorSequence.new(Target.Color)
                BlockTrail.Enabled = true
                BlockTrail.Parent = Rock

                Debris:AddItem(Rock, 3)
                Debris:AddItem(BodyVelocity, 0.1)
            end
        end
        local Result = workspace:Raycast(Root.Position, Root.CFrame.upVector * -100, raycastParams)
        if Result and Result.Instance then
        end
    end,
}

return HieiVFX
