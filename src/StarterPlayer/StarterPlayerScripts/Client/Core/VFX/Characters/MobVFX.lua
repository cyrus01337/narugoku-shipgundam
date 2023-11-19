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

local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Effects = Modules.Effects
local Shared = Modules.Shared

local EffectMeshes = ReplicatedStorage.Assets.Effects.Meshes

local HitPart2 = Models.Misc.HitPart2

--|| Imports ||--
local SoundManager = require(Shared.SoundManager)
local RaycastManager = require(Shared.RaycastManager)

local RayService = require(Shared.RaycastManager.RayService)

local Explosions = require(Effects.Explosions)
local VfxHandler = require(Effects.VfxHandler)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variable ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local PlayerMouse = Player:GetMouse()

local Humanoid = Character:WaitForChild("Humanoid")

local MobVFX = {

    ["Physco Rocks"] = function(Data)
        local Character = Data.Character
        local Rocks = Data.Rocks
        local AnimationDuration = Data.AnimationDuration
        local RockVelocity = Data.RockVelocity
        local RockLifetime = Data.RockLifetime

        local NewRocks = {}
        local Timestamp = os.clock()

        local AvailableRockModels = ReplicatedStorage.Assets.Effects.Meshes.Mob2:GetChildren()
        for Index = 1, #Rocks do
            local RandomRockModel = AvailableRockModels[math.random(1, #AvailableRockModels)]:Clone()
            NewRocks[#NewRocks + 1] = RandomRockModel

            local RockData = Rocks[Index]
            RandomRockModel.Size = Vector3.new(0, 0, 0)
            RandomRockModel.Position = RockData.Position
            RandomRockModel.Parent = workspace.World.Visuals
            RandomRockModel.Orientation =
                Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))

            delay(RockData.Delay, function()
                local Animation = TweenService:Create(
                    RandomRockModel,
                    TweenInfo.new(AnimationDuration / 3 - (os.clock() - Timestamp)),
                    { Size = Vector3.new(1, 1, 1) * RockData.Size }
                )
                Animation:Play()
                Animation:Destroy()
            end)
            Debris:AddItem(RandomRockModel, RockLifetime)
        end

        wait(AnimationDuration)

        local MouseHit = PlayerMouse.Hit

        for Index = 1, #NewRocks do
            local Rock = NewRocks[Index]
            local Points = RaycastManager:GetSquarePoints(CFrame.new(Rock.Position), Rock.Size.X, Rock.Size.X)
            local Direction = (MouseHit.Position - Rock.Position).Unit

            local Size = ReplicatedStorage.Assets.Effects.Meshes.Meteor.Size.X

            -- SoundManager:AddSound("Woosh",{ Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = 2}, "Client")

            RaycastManager:CastProjectileHitbox({
                Points = Points,
                Direction = Direction,
                Velocity = RockVelocity,
                Lifetime = RockLifetime,
                Iterations = 50,
                Visualize = false,
                Function = function(RaycastResult)
                    Explosions.PhyscoRocks({
                        Index = Index,
                        Rock = Rock,
                        Character = Character,
                        RaycastResult = RaycastResult,
                        Distance = Data.Distance,
                        Size = Size,
                    })
                    -- SoundManager:AddSound("Explosionbzz", {Volume = .5, Parent = Character:FindFirstChild("HumanoidRootPart")}, "Client")
                    Rock:Destroy()
                end,
                Ignore = { Character, workspace.World.Visuals, workspace.World.Live },
            })

            local Animate = TweenService:Create(
                Rock,
                TweenInfo.new(RockLifetime, Enum.EasingStyle.Linear),
                { CFrame = CFrame.new(Rock.Position + Direction * RockVelocity * RockLifetime) }
            )
            Animate:Play()
            Animate:Destroy()
            wait(0.05)
        end
    end,

    ["PhyscoChoke"] = function(Data)
        local Character = Data.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Victim = Data.Victim
        local VRoot, VHum = Victim:FindFirstChild("Torso"), Victim:FindFirstChild("Humanoid")

        wait(0.225)

        VfxHandler.Orbies({ Parent = VRoot, Speed = 0.35, Cframe = CFrame.new(0, 0, 3), Amount = 3, Circle = true })
        local PunchedParticle = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments.Punched:Clone()
        PunchedParticle.Parent = VRoot
        for _, v in ipairs(PunchedParticle:GetChildren()) do
            if v:IsA("ParticleEmitter") then
                v.Rate = 0
                v:Emit(1)
            end
        end
        Debris:AddItem(PunchedParticle, 1.35)

        -- SoundManager:AddSound("CombatHit", {Parent = Character.HumanoidRootPart, Looped = false, Volume = 1.35}, "Client")

        wait(2.435)
        Explosions.PhyscoChoke({
            Character = Character,
            Victim = Victim,
            Distance = Data.Distance,
        })
    end,

    ["PhyscoMeteor"] = function(PathData)
        local Character = PathData.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local SpawnCFrame = PathData.SpawnPoint
        local LifeTime = PathData.Lifetime / 4
        local Velocity = PathData.Velocity

        local Projectile = ReplicatedStorage.Assets.Effects.Meshes.Meteor:Clone()
        Projectile.CFrame = SpawnCFrame
        Projectile.Parent = workspace.World.Visuals

        local Calculation = PathData.MouseHit - PathData.MouseHit.Position

        coroutine.resume(coroutine.create(function()
            for Index = 1, 2 do
                local Ring = ReplicatedStorage.Assets.Effects.Meshes.Ring2:Clone()
                Ring.Size = Vector3.new(50, 3, 50)
                Ring.Material = Enum.Material.Neon

                if Index == 2 then
                    Ring.Color = Color3.fromRGB(255, 96, 33)
                end

                Ring.CanCollide = false
                Ring.CFrame = CFrame.new(PathData.MouseHit.Position) * Calculation
                Ring.Anchored = true

                Ring.Parent = workspace.World.Visuals

                Debris:AddItem(Ring, 0.4)

                local Tween = TweenService:Create(
                    Ring,
                    TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
                    { CFrame = Ring.CFrame * CFrame.new(0, 15, 0), Size = Vector3.new(0, 0, 0) }
                )
                Tween:Play()
                Tween:Destroy()

                wait(0.2)
            end
        end))

        -- SoundManager:AddSound("Woosh",{ Parent = Root, Volume = 2}, "Client")

        local Size = ReplicatedStorage.Assets.Effects.Meshes.Meteor.Size.X
        local Points = RaycastManager:GetSquarePoints(SpawnCFrame, Size, Size)
        RaycastManager:CastProjectileHitbox({
            Points = Points,
            Direction = (PathData.MouseHit.Position - SpawnCFrame.Position).Unit,
            Velocity = Velocity,
            Lifetime = LifeTime,
            Iterations = 50,
            Visualize = false,
            Function = function(RaycastResult)
                Explosions.PhyscoMeteor({
                    Character = Character,
                    Distance = PathData.Distance,
                    RaycastResult = RaycastResult,
                    Size = Size,
                })
                Projectile:Destroy()
            end,
            Ignore = { Character, workspace.World.Visuals, workspace.World.Live },
        })

        local Animate = TweenService:Create(
            Projectile,
            TweenInfo.new(LifeTime, Enum.EasingStyle.Linear),
            { CFrame = Projectile.CFrame * CFrame.new(0, 0, -Velocity * LifeTime) }
        )
        Animate:Play()
        Animate:Destroy()

        Debris:AddItem(Projectile, LifeTime)
    end,

    ["PhyscoSlamUp"] = function(PathData)
        local Character, Victim = PathData.Character, PathData.Victim

        local Result = RayService:Cast(
            Victim.HumanoidRootPart.Position + Vector3.new(0, 50, 0),
            Victim.HumanoidRootPart.Position - Vector3.new(0, 1000, 0),
            { workspace.World.Live, workspace.World.Visuals },
            Enum.RaycastFilterType.Exclude
        )

        for _ = 1, 10 do
            VfxHandler.UpwardOrbies({
                Quantity = math.random(5, 7),
                Pos = Result.Position,
                Properties = {
                    Material = Enum.Material.Neon,
                    Transparency = 0.5,
                    Color = math.random(1, 2) == 1 and Color3.fromRGB(70, 14, 255) or Color3.fromRGB(0, 0, 0),
                    Size = Vector3.new(0.2, 0.2, math.random(5, 8)),
                },
                Offsets = {
                    X = { -30 / 1.5, 30 / 1.5 },
                    Y = { 0, 10 },
                    Z = { -30 / 1.5, 30 / 1.5 },
                    Offset = { 40, 75 },
                },
                TweenInfo = TweenInfo.new(2 + 2 * math.random(), Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                Goal = { Transparency = 1 },
            })
        end

        coroutine.resume(coroutine.create(function()
            for _ = 1, 5 do
                VfxHandler.AfterImage({
                    Character = Victim,
                    Duration = 1,
                    StartTransparency = 0.2,
                    Color = Color3.fromRGB(84, 42, 135),
                })
                wait()
            end
        end))

        for _, VictimParts in ipairs(Victim:GetChildren()) do
            if VictimParts.ClassName == "MeshPart" or VictimParts.ClassName == "Part" then
                for _, Particles in ipairs(script:GetChildren()) do
                    if Particles:IsA("ParticleEmitter") then
                        local Aura = Particles:Clone()
                        Aura.Name = "mobauratehe"
                        Aura.Parent = VictimParts
                    end
                end
            end
        end

        wait(0.15)
        -- SoundManager:AddSound("Woosh",{Parent = Character.HumanoidRootPart, Volume = 2},"Client")
    end,

    ["CancelSlam"] = function(PathData)
        local Character, Victim = PathData.Character, PathData.Victim

        for _, v in ipairs(Victim:GetDescendants()) do
            if v.Name == "mobauratehe" then
                v.Enabled = false
                Debris:AddItem(v, 2)
            end
        end
    end,

    ["PhyscoSlamDown"] = function(PathData)
        local Character, Victim = PathData.Character, PathData.Victim

        -- SoundManager:AddSound("Woosh",{Parent = Character.HumanoidRootPart, Volume = 2},"Client")

        local Result = RayService:Cast(
            Victim.HumanoidRootPart.Position + Vector3.new(0, 50, 0),
            Victim.HumanoidRootPart.Position - Vector3.new(0, 1000, 0),
            { workspace.World.Live, workspace.World.Visuals },
            Enum.RaycastFilterType.Exclude
        )

        for _ = 1, 10 do
            VfxHandler.UpwardOrbies({
                Quantity = math.random(5, 7),
                Pos = Result.Position,
                Properties = {
                    Material = Enum.Material.Neon,
                    Transparency = 0.5,
                    Color = math.random(1, 2) == 1 and Color3.fromRGB(70, 14, 255) or Color3.fromRGB(0, 0, 0),
                    Size = Vector3.new(0.5, 0.5, math.random(15, 20)),
                },
                Offsets = {
                    X = { -30 / 1.5, 30 / 1.5 }, -- range
                    Y = { 30, 60 },
                    Z = { -30 / 1.5, 30 / 1.5 }, -- range
                    Offset = { -150, -100 },
                },
                TweenInfo = TweenInfo.new(2 + 2 * math.random(), Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                Goal = { Transparency = 1 },
            })
        end

        for _, v in ipairs(Victim:GetDescendants()) do
            if v.Name == "mobauratehe" then
                v.Enabled = false
                Debris:AddItem(v, 2)
            end
        end

        for _ = 1, 2 do
            VfxHandler.AfterImage({
                Character = Victim,
                Duration = 1,
                StartTransparency = 0.2,
                Color = Color3.fromRGB(100, 49, 150),
            })
            wait()
        end
        Explosions.PhyscoSlam({ Character = Character, Victim = Victim, Distance = PathData.Distance })
    end,

    ["ChokeHoldTehe?"] = function(Data)
        local Character = Data.Character
        local Victim = Data.Victim

        local Root = Character:FindFirstChild("HumanoidRootPart")

        local Result = RayService:Cast(
            Victim.HumanoidRootPart.Position + Vector3.new(0, 50, 0),
            Victim.HumanoidRootPart.Position - Vector3.new(0, 1000, 0),
            { workspace.World.Live, workspace.World.Visuals },
            Enum.RaycastFilterType.Exclude
        )

        coroutine.resume(coroutine.create(function()
            repeat
                wait(0.135)
                coroutine.wrap(function()
                    for _ = 1, 12 do
                        VfxHandler.UpwardOrbies({
                            Quantity = math.random(1.5, 2.75),
                            Pos = Result.Position,
                            Properties = {
                                Material = Enum.Material.Neon,
                                Transparency = 0,
                                Color = math.random(1, 2) == 1 and Color3.fromRGB(70, 14, 255)
                                    or Color3.fromRGB(0, 0, 0),
                                Size = Vector3.new(0.3, 0.3, math.random(2.5, 7.85)),
                            },
                            Offsets = {
                                X = { -30 / 1.5, 30 / 1.5 },
                                Y = { 10, 15 },
                                Z = { -30 / 1.5, 30 / 1.5 },
                                Offset = { -150, -100 },
                            },
                            TweenInfo = TweenInfo.new(4.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                            Goal = { Transparency = 1 },
                            0.5,
                        })
                    end
                    wait(1.75)
                end)()
            until Victim.HumanoidRootPart:FindFirstChild("mobauratehe") == nil
        end))

        for _, VictimParts in ipairs(Victim:GetChildren()) do
            if VictimParts.ClassName == "MeshPart" or VictimParts.ClassName == "Part" then
                for _, Particles in ipairs(script:GetChildren()) do
                    if Particles:IsA("ParticleEmitter") then
                        local Aura = Particles:Clone()
                        Aura.Name = "mobauratehe"
                        Aura.Parent = VictimParts
                    end
                end
            end
        end

        wait(0.15)
        -- SoundManager:AddSound("BlackHole",{Parent = Root, Volume = 3},"Client")

        for _, v in ipairs(Victim:GetDescendants()) do
            if v.Name == "mobauratehe" then
                v.Enabled = false
                Debris:AddItem(v, 2)
            end
        end
    end,
}

return MobVFX
