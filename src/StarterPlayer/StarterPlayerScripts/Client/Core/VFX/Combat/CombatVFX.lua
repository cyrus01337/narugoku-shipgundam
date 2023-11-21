--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules
local Assets = ReplicatedStorage.Assets

local Metadata = Modules.Metadata
local Utility = Modules.Utility

local Shared = Modules.Shared

local Effects = Assets.Effects
--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local TaskScheduler = require(Utility.TaskScheduler)

local SoundManager = require(Shared.SoundManager)
local RayService = require(Shared.RaycastManager.RayService)

local VfxHandler = require(Modules.Effects.VfxHandler)
local CameraShaker = require(Modules.Effects.CameraShaker)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
    Camera.CFrame = Camera.CFrame * shakeCFrame
end)

local Humanoid = Character:WaitForChild("Humanoid")

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.World.Live, workspace.World.Visuals }
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local BlockAnimation

local function CreateRock(Result)
    local Size = 2 + 1 * math.random()

    local Rock = Instance.new("Part")
    Rock.Material = Result.Material
    Rock.Size = Vector3.new(1, 1, 1) * Size

    Rock.Anchored = true
    Rock.CanCollide = false
    Rock.Position = Result.Position - Vector3.new(0, Rock.Size.Y, 0)

    Rock.Color = Result.Instance.Color
    Rock.Orientation = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))

    Rock.Parent = workspace.World.Visuals
    Debris:AddItem(Rock, 3)

    local Tween = TweenService:Create(Rock, TweenInfo.new(0.5, Enum.EasingStyle.Linear), { Position = Result.Position })
    Tween:Play()
    Tween:Destroy()

    TaskScheduler:AddTask(1, function()
        local Tween = TweenService:Create(
            Rock,
            TweenInfo.new(0.5, Enum.EasingStyle.Linear),
            {
                Position = Result.Position - Vector3.new(0, Rock.Size.Y, 0),
                Orientation = Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360)),
                Size = Vector3.new(0, 0, 0),
            }
        )
        Tween:Play()
        Tween:Destroy()
    end)
end

local CombatVFX = {

    StartBarrage = function(Data)
        local Character = Data.Character
        local Humanoid, Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")

        local StartTime = os.clock()

        local Dust = ReplicatedStorage.Assets.Effects.Particles.BarrageDust:Clone()
        Dust.Parent = workspace.World.Visuals
        Debris:AddItem(Dust, 10)

        local Weld = Instance.new("Weld")
        Weld.Part0 = Root
        Weld.Part1 = Dust
        Weld.C0 = CFrame.new(0, -Humanoid.HipHeight - 1, 0)
        Weld.Parent = Root

        local Rot = Vector3.new(7, 4, 9) * 1.5
        local HipCalculation = Humanoid.HipHeight - 1

        while true do
            wait(0.05)
            local RayParam = RaycastParams.new()
            RayParam.FilterType = Enum.RaycastFilterType.Exclude
            RayParam.FilterDescendantsInstances = { Character, workspace.World.Visuals, Workspace.World.Live }

            local RaycastResult = workspace:Raycast(Root.Position, Vector3.new(0, -1000, 500), RayParam) or {}
            local Target, Position = RaycastResult.Instance, RaycastResult.Position

            if Target then
                Dust.Attachment.dust1.Enabled = true
                Dust.Attachment.dust1.Color = ColorSequence.new(Target.Color)
            else
                Dust.Attachment.dust1.Enabled = false
            end
            if os.clock() - StartTime >= 1.15 then
                break
            end
        end
        Dust.Attachment.dust1.Enabled = false
        Debris:AddItem(Dust, 1)
    end,

    LastBarrageHit = function(Data)
        local Character = Data.Character

        local Humanoid, Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
        -- SoundManager:AddSound("BarrageSwing", {Parent = Root, Volume = 3, PlaybackSpeed = 1.4}, "Client")

        VfxHandler.Shockwave2(
            Root.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(math.rad(90), 0, 0),
            Root.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(math.rad(90), 0, 0),
            BrickColor.new("White"),
            Vector3.new(8, 1, 8),
            Vector3.new(0, 1, 0),
            0.25,
            0,
            Enum.EasingStyle.Quad,
            Color3.fromRGB(255, 255, 255),
            Enum.Material.Neon,
            "Rings"
        )

        local End = Root.CFrame
        local Position1, Position2 = End.p, End.upVector * -200

        local RaycastResult = workspace:Raycast(Position1, Position2, raycastParams)
        if RaycastResult and RaycastResult.Instance and (RaycastResult.Position - Position1).Magnitude < 30 then
            local Dust = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments["Dust"]:Clone()
            Dust.P1.Color = ColorSequence.new(RaycastResult.Instance.Color)
            Dust.Parent = Root

            VfxHandler.Emit(Dust.P1, 15)
            Debris:AddItem(Dust, 2)
        end
    end,

    LLLLR = function(Data)
        local Character = Data.Character
        local Victim = Data.Victim

        local Humanoid, Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
        local VHum, VRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")

        local PunchedParticle = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments.Punched:Clone()
        PunchedParticle.Parent = VRoot
        for _, Particle in ipairs(PunchedParticle:GetChildren()) do
            if Particle:IsA("ParticleEmitter") then
                Particle.Rate = 0
                Particle:Emit(1)
            end
        end
        Debris:AddItem(PunchedParticle, 1.35)

        -- SoundManager:AddSound("CombatKnockback", {Parent = Character.HumanoidRootPart, Volume = 3.75}, "Client")

        local shockwave5 = ReplicatedStorage.Assets.Effects.Meshes.shockwave5:Clone()
        shockwave5.CFrame = Root.CFrame * CFrame.new(0, 0, -5) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
        shockwave5.Size = Vector3.new(20, 20, 20)
        shockwave5.Transparency = 0
        shockwave5.Material = "Neon"
        shockwave5.BrickColor = BrickColor.new("Institutional white")
        shockwave5.Parent = workspace.World.Visuals

        Debris:AddItem(shockwave5, 0.3)

        GlobalFunctions.TweenFunction({
            ["Instance"] = shockwave5,
            ["EasingStyle"] = Enum.EasingStyle.Quad,
            ["EasingDirection"] = Enum.EasingDirection.Out,
            ["Duration"] = 0.25,
        }, {
            ["Transparency"] = 1,
            ["Size"] = Vector3.new(0, 90, 0),
        })

        local shockwaveOG = ReplicatedStorage.Assets.Effects.Meshes.shockwaveOG:Clone()
        shockwaveOG.CFrame = Root.CFrame * CFrame.new(0, 0, -5) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
        shockwaveOG.Size = Vector3.new(15, 5, 15)
        shockwaveOG.Transparency = 0
        shockwaveOG.Material = "Neon"
        shockwaveOG.BrickColor = BrickColor.new("Institutional white")
        shockwaveOG.Parent = workspace.World.Visuals

        GlobalFunctions.TweenFunction({
            ["Instance"] = shockwaveOG,
            ["EasingStyle"] = Enum.EasingStyle.Quad,
            ["EasingDirection"] = Enum.EasingDirection.Out,
            ["Duration"] = 0.3,
        }, {
            ["Transparency"] = 1,
            ["Size"] = Vector3.new(0, 0, 0),
        })

        Debris:AddItem(shockwaveOG, 0.3)

        -- SoundManager:AddSound("BOOM!",{Parent = Root, Volume = 1.25},"Client")

        local StartTime = os.clock()
        local RockInBetween = 0.1
        local LastRock = os.clock() - RockInBetween

        local End = VRoot.CFrame

        local RaycastResult = workspace:Raycast(Root.Position, Root.CFrame.upVector * -15, raycastParams)
        if RaycastResult and RaycastResult.Instance then
            local Clone = ReplicatedStorage.Assets.Effects.Particles.LightningBeamParticles:Clone()
            Clone.Transparency = 1
            Clone.CFrame = Root.CFrame * CFrame.new(0, 2, 1)

            Clone.Anchored = false
            Clone.CanCollide = true

            Clone.Attachment.Rocks:Emit(2)
            Clone.Smoke:Emit(15)
            Clone.Smoke.Color = ColorSequence.new(RaycastResult.Instance.Color)
            Clone.Parent = workspace.World.Visuals

            Debris:AddItem(Clone, 3)
        end

        local plus = 3
        local args = RaycastParams.new()
        args.FilterType = Enum.RaycastFilterType.Exclude
        args.FilterDescendantsInstances = { workspace.World.Visuals, Character, Victim, workspace.World.Live }

        coroutine.resume(coroutine.create(function()
            for _ = 1, 8 do
                local cf = Character.PrimaryPart.CFrame

                local ray1 = workspace:Raycast(cf * CFrame.new(-3.8, 0, -plus).Position, Vector3.new(0, -35, 0), args)
                local ray2 = workspace:Raycast(cf * CFrame.new(5, 0, -plus).Position, Vector3.new(0, -35, 0), args)
                if ray1 then
                    CreateRock(ray1)
                end

                if ray2 then
                    CreateRock(ray2)
                end

                plus += 4.5
                wait()
            end
        end))

        for _ = 1, math.random(8, 10) do
            local x, y, z =
                math.cos(math.rad(math.random(1, 6) * 60)),
                math.cos(math.rad(math.random(1, 6) * 60)),
                math.sin(math.rad(math.random(1, 6) * 60))
            local Start = Victim.PrimaryPart.Position
            local End = Start + Vector3.new(x, y, z)

            local Orbie = ReplicatedStorage.Assets.Effects.Meshes.MeshOribe:Clone()
            Orbie.CFrame = CFrame.new(Start, End)
            Orbie.Color = Color3.fromRGB(255, 255, 255)
            Orbie.Size = Vector3.new(1, 2, 1)

            local OrbieTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

            local Tween = TweenService:Create(
                Orbie,
                OrbieTweenInfo,
                { CFrame = CFrame.new(Start, End) * CFrame.new(0, 0, -(math.random(2, 5) * 10)), Size = Vector3.new(
                    0,
                    0,
                    24
                ) }
            )
            Tween:Play()
            Tween:Destroy()

            Debris:AddItem(Orbie, 0.2)
            Orbie.Parent = workspace.World.Visuals
        end

        local Position1, Position2 = End.p, End.upVector * -200

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

        for Index = 1, 2 do
            local Cframe = End * CFrame.new(-4.5, 0, 1.25)
            if Index == 2 then
                Cframe = End * CFrame.new(4.5, 0, 1.25)
            end
            local DashMesh = ReplicatedStorage.Assets.Effects.Meshes.DashMesh:Clone()
            DashMesh.Transparency = 0.35
            DashMesh.CFrame = Cframe * CFrame.new(0, -DashMesh.Size.Y / 2, 0)
            DashMesh.Size = Vector3.new(0.54, 6, 29)
            DashMesh.Parent = workspace.World.Visuals

            wait(0.35)
            local tiasdasd = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

            local Tween = TweenService:Create(
                DashMesh,
                tiasdasd,
                { ["Transparency"] = 1, ["CFrame"] = Cframe * CFrame.new(0, -DashMesh.Size.Y / 2, 3) }
            )
            Tween:Play()
            Tween:Destroy()

            Debris:AddItem(DashMesh, 0.5)
        end
    end,

    Parry = function(Data)
        local Character = Data.Character
        local Victim = Data.Victim

        local Humanoid = Character:FindFirstChild("Humanoid")
        local Animator = Humanoid:FindFirstChildOfClass("Animator")

        local DizzyEffect = ReplicatedStorage.Assets.Effects.Particles.Parry:Clone()
        DizzyEffect.CFrame = Character.Head.CFrame * CFrame.new(0, 0, 0)
        DizzyEffect.Parent = workspace.World.Visuals
        DizzyEffect.Stars.stars:Emit(10)
        for _, v in ipairs(DizzyEffect:GetDescendants()) do
            if v:IsA("Beam") then
                delay(0.215, function()
                    v.Enabled = true
                end)
            end
        end

        coroutine.wrap(function()
            local StartTime = os.clock()
            Humanoid.AutoRotate = false

            while os.clock() - StartTime <= 1.15 do
                Humanoid.WalkSpeed = 0
                Humanoid.JumpPower = 0

                RunService.Stepped:Wait()
            end
            Humanoid.WalkSpeed = 14
            Humanoid.JumpPower = 50

            Humanoid.AutoRotate = true
        end)()

        if Animator and Humanoid then
            local Animation = Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Combat.Block.GuardBreak)
            Animation:Play()
            coroutine.resume(coroutine.create(function()
                wait(1.15)
                Animation:Stop()
            end))
        end

        Debris:AddItem(DizzyEffect, 1.75)

        local WeldConstraint = Instance.new("WeldConstraint")
        WeldConstraint.Part0 = Character.Head
        WeldConstraint.Part1 = DizzyEffect
        WeldConstraint.Name = "DizzyWeld"
        WeldConstraint.Parent = DizzyEffect

        -- SoundManager:AddSound("CombatParry", {Parent = Character:FindFirstChild("HumanoidRootPart"), Volume = .75}, "Client")
    end,

    Block = function(Data)
        local Character = Data.Character
        local Victim = Data.Victim

        local WeaponType = Data.WeaponType

        local VHumanoid, VRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")
        local Animator = VHumanoid:FindFirstChildOfClass("Animator")

        if Victim and Animator and Humanoid then
            BlockAnimation = Animator:LoadAnimation(
                ReplicatedStorage.Assets.Animations.Shared.Combat.Block[WeaponType .. "BlockHitReaction"]
            )
            BlockAnimation:Play()
        end

        local BlockEffect = ReplicatedStorage.Assets.Effects.Particles.BlockEffect:Clone()
        BlockEffect:Emit(1)
        BlockEffect.Enabled = true
        BlockEffect.Parent = VRoot

        Debris:AddItem(BlockEffect, 1)

        -- SoundManager:AddSound("BlockSound", {Parent = Character:FindFirstChild("HumanoidRootPart"), Looped = false, Volume = 3},"Client")
    end,

    GuardBreak = function(Data)
        local Character = Data.Character
        local Victim = Data.Victim

        local VHumanoid, VRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")
        local Animator = VHumanoid:FindFirstChildOfClass("Animator")

        coroutine.wrap(function()
            local StartTime = os.clock()
            VHumanoid.AutoRotate = false

            while os.clock() - StartTime <= 1.875 do
                VHumanoid.WalkSpeed = 0
                VHumanoid.JumpPower = 0

                RunService.Stepped:Wait()
            end
            VHumanoid.WalkSpeed = 14
            VHumanoid.JumpPower = 50

            VHumanoid.AutoRotate = true
        end)()

        if Victim and Animator and Humanoid then
            local Animation = Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Combat.Block.GuardBreak)

            for _, animation: AnimationTrack in Animator:GetPlayingAnimationTracks() do
                if animation.Animation.AnimationId == "rbxassetid://13947499839" then
                    animation:Stop()
                    break
                end
            end

            Animation:Play()
            coroutine.resume(coroutine.create(function()
                wait(1.875)
                Animation:Stop()
            end))
        end

        local GuardBreakParticle = Assets.Effects.Particles.GuardBreak:Clone()
        GuardBreakParticle.Parent = VRoot
        GuardBreakParticle:Emit(5)

        Debris:AddItem(GuardBreakParticle, 1)

        -- SoundManager:AddSound("Breaksound", {Parent = Character:FindFirstChild("HumanoidRootPart"), Looped = false, Volume = 1},"Client")
    end,

    Light = function(Data)
        local Character = Data.Character
        local Victim = Data.Victim
        local KeysLogged = Data.KeysLogged

        if Data.SecondType == "Choke" then
            return
        end

        local VHumanoid, VRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")
        local Animator = VHumanoid:FindFirstChildOfClass("Animator")

        if VRoot:FindFirstChild("SnakeAwakenKnockback") == nil then
            VfxHandler.Orbies({ Parent = VRoot, Speed = 0.35, Cframe = CFrame.new(0, 0, 3), Amount = 6, Circle = true })
        end
        local PunchedParticle = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments.Punched:Clone()
        PunchedParticle.Parent = VRoot
        if VRoot:FindFirstChild("SnakeAwakenKnockback") then
            PunchedParticle.Hit2:Destroy()
        end

        for _, Particle in ipairs(PunchedParticle:GetChildren()) do
            if Particle:IsA("ParticleEmitter") then
                Particle.Rate = 0
                Particle:Emit(1)
            end
        end
        Debris:AddItem(PunchedParticle, 1.35)

        -- SoundManager:AddSound("CombatHit", {Parent = Character.HumanoidRootPart, Looped = false, Volume = 1.35}, "Client")

        if Data.SecondType == "SlamDown" then
            return
        end

        if Victim and Animator and Humanoid then
            local Animation = Animator:LoadAnimation(
                ReplicatedStorage.Assets.Animations.Shared.Combat.HitReaction["HitReaction" .. (KeysLogged == 0 and 1 or KeysLogged)]
            ) --KeysLogged == 0 and 1 or KeysLogged
            Animation:Play()
        end
    end,

    LastHit = function(Data)
        local Character = Data.Character
        local Victim = Data.Victim

        local StartTime = os.clock()
        local RockInBetween = 0.1
        local LastRock = os.clock() - RockInBetween

        local VHumanoid, VRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")
        local Animator = VHumanoid:FindFirstChildOfClass("Animator")

        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = { workspace.World.Map }
        raycastParams.FilterType = Enum.RaycastFilterType.Include

        local Result = workspace:Raycast(VRoot.Position, VRoot.CFrame.upVector * -15, raycastParams)
        if Result and Result.Instance then
            local DirtStep = ReplicatedStorage.Assets.Effects.Particles.DirtStep:Clone()
            DirtStep.ParticleEmitter.Enabled = true
            DirtStep.CFrame = VRoot.CFrame * CFrame.new(0, -1.85, 0.225)
            DirtStep.ParticleEmitter.Color = ColorSequence.new(Result.Instance.Color)
            DirtStep.Parent = VRoot

            local WeldConstraint = Instance.new("WeldConstraint")
            WeldConstraint.Part0 = VRoot
            WeldConstraint.Part1 = DirtStep
            WeldConstraint.Parent = DirtStep

            delay(0.5, function()
                DirtStep.ParticleEmitter.Enabled = false
            end)
            Debris:AddItem(DirtStep, 1)
        end

        VfxHandler.Orbies({
            Parent = VRoot,
            Speed = 0.5,
            Size = Vector3.new(0.2, 0.3, 3.79),
            Cframe = CFrame.new(0, 0, 5),
            Amount = 5,
            Circle = true,
            Sphere = true,
        })

        local PunchedParticle = ReplicatedStorage.Assets.Effects.Particles.ParticleAttatchments.Punched:Clone()
        PunchedParticle.Parent = VRoot
        for _, Particle in ipairs(PunchedParticle:GetChildren()) do
            if Particle:IsA("ParticleEmitter") then
                Particle.Rate = 0
                Particle:Emit(1)
            end
        end
        Debris:AddItem(PunchedParticle, 1.35)

        -- SoundManager:AddSound("CombatKnockback", {Parent = Character.HumanoidRootPart, Volume = 3.75}, "Client")

        if Animator then
            local Animation =
                Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Combat.HitReaction.HitReaction5)
            Animation:Play()
        end
    end,

    LastSwing = function(Data)
        local Character = Data.Character
        local OriginalAttatchment = Character["Right Arm"]:FindFirstChild("RightGripAttachment")

        local Attatchment = Instance.new("Attachment")
        Attatchment.Position = Attatchment.Position - Vector3.new(0.086, -0.085, 0.548)
        Attatchment.Visible = false
        Attatchment.Parent = Character["Right Arm"]

        local Trail = ReplicatedStorage.Assets.Effects.Trails.TrailTing:Clone()
        Trail.Color = ColorSequence.new(Color3.fromRGB(157, 255, 241))
        Trail.LightEmission = 1
        Trail.LightInfluence = 1
        Trail.Attachment0 = OriginalAttatchment
        Trail.Attachment1 = Attatchment
        Trail.Lifetime = 0.35
        Trail.Enabled = true
        Trail.Parent = Character["Right Arm"]

        Debris:AddItem(Attatchment, 1)
        Debris:AddItem(Trail, 0.65)

        local Ting = Character["Right Arm"]:Clone()
        Ting.Material = "Neon"
        Ting.Transparency = 0.125
        Ting.Color = Color3.fromRGB(157, 255, 241)
        Ting.Size = Character["Right Arm"].Size + Vector3.new(0.1, 0.1, 0.1)
        Ting.Orientation = Character["Right Arm"].Orientation
        Ting.CFrame = Character["Right Arm"].CFrame
        Ting.Parent = workspace.World.Visuals

        local WeldConstraint = Instance.new("WeldConstraint")
        WeldConstraint.Part0 = Character["Right Arm"]
        WeldConstraint.Part1 = Ting
        WeldConstraint.Parent = Ting

        Debris:AddItem(Ting, 1)

        local Tween = TweenService:Create(
            Ting,
            TweenInfo.new(0.125, Enum.EasingStyle.Cubic, Enum.EasingDirection.In, 0, false),
            { ["Transparency"] = 1 }
        )
        Tween:Play()
        Tween:Destroy()
    end,

    AerialKnockBackEffect = function(Data)
        local Character = Data.Character
        local Victim = Data.Victim

        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = { Character, workspace.World.Visuals }
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude

        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
        local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

        local Direction = CFrame.new(
            Root.Position,
            Root.Position + (Root.CFrame.lookVector * 10) + (Root.CFrame.upVector * -10)
        ).LookVector * 300
        local Start = Root.Position

        local RaycastResult = workspace:Raycast(Start, Direction, raycastParams)
        local Point = CFrame.new(RaycastResult.Position) * CFrame.new(0, 6, 0)

        if RaycastResult and RaycastResult.Instance and (RaycastResult.Position - Start).Magnitude <= 300 then
            CameraShake:Start()
            CameraShake:ShakeOnce(10, 10, 0, 1.5)

            local Clone = ReplicatedStorage.Assets.Effects.Meshes.Ring:Clone()
            Clone.Transparency = 0
            Clone.Color = Color3.fromRGB(255, 255, 255)
            Clone.Size = Vector3.new(1, 1, 1)
            Clone.CFrame = Point
            Clone.Parent = workspace.World.Visuals

            Debris:AddItem(Clone, 1)

            GlobalFunctions.TweenFunction({
                ["Instance"] = Clone,
                ["EasingStyle"] = Enum.EasingStyle.Quad,
                ["EasingDirection"] = Enum.EasingDirection.Out,
                ["Duration"] = 0.5,
            }, {
                ["Size"] = Vector3.new(30, 1, 30),
                ["Transparency"] = 1,
            })

            -- SoundManager:AddSound("KnockbackCrash", {Parent = VRoot, Looped = false, Volume = .65}, "Client")

            VfxHandler.Orbies({
                Parent = VRoot,
                Speed = 0.5,
                Size = Vector3.new(1, 1, 12),
                Cframe = CFrame.new(0, 0, 15),
                Amount = 10,
                Sphere = true,
            })
            VfxHandler.RockTing(Point, 1)
            VfxHandler.GroundSlamEffect(RaycastResult.Instance, RaycastResult.Position)

            local ray = Ray.new(Character.HumanoidRootPart.Position, Vector3.new(0, -1000, 500))
            local partHit, pos =
                workspace:FindPartOnRayWithIgnoreList(ray, { Character, workspace.World.Visuals, Victim }, false, false)
            if partHit then
                for _ = 1, 5 do
                    local Block = ReplicatedStorage.Assets.Effects.Meshes.Block:Clone()
                    Block.Size = Vector3.new(2.434, 1.32, 2.719)
                    Block.Rotation = Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
                    Block.BrickColor = partHit.BrickColor
                    Block.Material = partHit.Material
                    Block.Position = RaycastResult.Position
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

                local Ring = ReplicatedStorage.Assets.Effects.Meshes.RingInnit:Clone()
                Ring.CFrame = Point * CFrame.new(0, -16, 0)
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
                    {
                        ["Transparency"] = 1,
                        ["Size"] = Vector3.new(25, 0.05, 25),
                        ["CFrame"] = Ring.CFrame * CFrame.new(0, 12, 0),
                    }
                )

                local CrashSmoke = ReplicatedStorage.Assets.Effects.Particles.CrashSmoke:Clone()
                CrashSmoke.Size = Vector3.new(15, 2, 15)
                CrashSmoke.CFrame = Point
                CrashSmoke.Smoke.Color = ColorSequence.new(partHit.Color)
                CrashSmoke.Smoke:Emit(20)
                CrashSmoke.Parent = workspace.World.Visuals
                delay(1, function()
                    CrashSmoke.Smoke.Enabled = false
                end)
                Debris:AddItem(CrashSmoke, 3)
            end
        end
    end,
}

return CombatVFX
