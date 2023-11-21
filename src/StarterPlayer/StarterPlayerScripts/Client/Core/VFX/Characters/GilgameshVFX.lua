--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local TweenService = game:GetService("TweenService")

local Debris = game:GetService("Debris")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules
local Assets = ReplicatedStorage.Assets

local Models = ReplicatedStorage.Assets.Models

local Metadata = Modules.Metadata
local Shared = Modules.Shared
local EffectModule = Modules.Effects

local Utility = Modules.Utility

local HitPart2 = Models.Misc.HitPart2

--|| Imports ||--
local LightningModule = require(EffectModule.LightningBolt)
local Explosions = require(EffectModule.Explosions)

local SoundManager = require(Shared.SoundManager)
local RaycastService = require(Shared.RaycastManager)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Effects = ReplicatedStorage.Assets.Effects.Meshes
local Particles = ReplicatedStorage.Assets.Effects.Particles

local Humanoid = Character:WaitForChild("Humanoid")

local function RemoveTrash(Trash)
    for i = 1, #Trash do
        local Item = Trash[i]
        if Item and Item.Parent then
            Item:Destroy()
        end
    end
end

local function GetMouseTarget(Target, Character)
    if Target and Target:IsA("BasePart") and not Target:IsDescendantOf(Character) then
        return true, Target.Parent
    end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { Character, workspace.World.Visuals }
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function RaycastFunction(StartPosition, EndPosition, Distance, Object)
    local Raycast = Ray.new(StartPosition, CFrame.new(StartPosition, EndPosition).LookVector * Distance)
    local Target, Position, Surface = workspace:FindPartOnRayWithIgnoreList(Raycast, {
        workspace.World.Visuals,
        Object,
    })
    return Target, Position, Surface
end

local GilgameshVFX = {

    ["OpenPortal"] = function(PathData)
        local Character = PathData.Character
        local StartPoint = PathData.StartPoint

        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Portal = Particles.PortalParticle:Clone()
        for _, Particle in ipairs(Portal:GetDescendants()) do
            if Particle:IsA("ParticleEmitter") then
                Particle:Emit(1.25)
                delay(1.25, function()
                    Particle.Enabled = false
                end)
            end
        end
        Portal.Anchored = true
        Portal.Position = StartPoint.Position
        Portal.Parent = workspace.World.Visuals

        if Root:FindFirstChild("GigCast") and PathData.Type == "Loop" then
            Root.GigCast:Destroy()
        end

        -- SoundManager:AddSound("GigCast", {Parent = Root, Volume = 2}, "Client")

        Debris:AddItem(Portal, 3)

        for _ = 1, 2 do
            wait(0.2)
            local Attach = Instance.new("Attachment")
            Attach.Position = Vector3.new(-0.5, 5, 0.85)
            Attach.Parent = Portal

            local Attach2 = Instance.new("Attachment")
            Attach2.Position = Vector3.new(1.75, -5, 2.75)
            Attach2.Parent = Portal

            local Bolts = LightningModule.new(Attach, Attach2, 50)
            Bolts.PulseLength = 0.35
            Bolts.Color = Color3.fromRGB(255, 233, 121)

            Debris:AddItem(Attach2, 2)
            Debris:AddItem(Attach, 2)

            if Root:FindFirstChild("LightningSizzle") and PathData.Type == "Loop" then
                Root.LightningSizzle:Destroy()
            end

            -- SoundManager:AddSound("LightningSizzle", {Parent = Root, Volume = 3}, "Client")
            wait(0.225)
        end
    end,

    ["Zashu"] = function(PathData)
        local Character = PathData.Character
        local StartPoint = PathData.StartPoint

        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Velocity = 250
        local Lifetime = 5

        -- SoundManager:AddSound("Woosh",{ Parent = Root, Volume = 2}, "Client")

        local MouseHit = PathData.MouseHit

        local SwordClone = Assets.Models.Swords.GilgameshSpear:Clone()
        SwordClone.CFrame = StartPoint
        SwordClone.CFrame = CFrame.new(StartPoint.Position, MouseHit.Position)
            * CFrame.Angles(math.rad(90), math.rad(90), math.rad(180))
        SwordClone.Parent = workspace.World.Visuals

        Debris:AddItem(SwordClone, 12)

        local Direction = (PathData.MouseHit.Position - SwordClone.Position).Unit

        local Size = SwordClone.Size

        local Points = RaycastService:GetSquarePoints(SwordClone.CFrame, Size.X, Size.X)

        local InitialTween = TweenService:Create(
            SwordClone,
            TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false, 0),
            { ["CFrame"] = SwordClone.CFrame * CFrame.new(0, 5, 0) * CFrame.fromEulerAnglesXYZ(0, 4, 0) }
        )
        InitialTween:Play()
        InitialTween:Destroy()

        --	wait(1)
        local Animate = TweenService:Create(
            SwordClone,
            TweenInfo.new(Lifetime, Enum.EasingStyle.Linear),
            { ["CFrame"] = SwordClone.CFrame * CFrame.new(0, Velocity * Lifetime, 0) }
        )
        Animate:Play()
        Animate:Destroy()
        --SwordClone.CFrame * CFrame.new(0,Lifetime * Velocity * 2,0)

        RaycastService:CastProjectileHitbox({
            Points = Points,
            Direction = Direction,
            Velocity = Velocity,
            Lifetime = Lifetime,
            Iterations = 60,
            Visualize = false,
            Function = function(RaycastResult)
                Explosions.Zashu({
                    Character = Character,
                    RaycastResult = RaycastResult,
                    Spear = SwordClone,
                    Distance = PathData.Distance,
                })

                local Target = RaycastResult.Instance

                if Target:IsA("BasePart") and Target.Anchored and Target.Transparency ~= 1 then
                    Animate:Pause()

                    local Weld = Instance.new("Weld")
                    Weld.Part1 = SwordClone
                    Weld.Part0 = Target
                    Weld.Parent = SwordClone

                    Debris:AddItem(Weld, 2.5)
                    Debris:AddItem(SwordClone, 3)
                end
            end,
            Ignore = { Character, workspace.World.Visuals },
        })
    end,

    ["GatesOfBabylon"] = function(PathData)
        local Character = PathData.Character

        local StartPositionData = PathData.StartPoints

        local Velocity = 235
        local Lifetime = 8

        local MouseHit = PathData.MouseHit

        for Index = 1, 7 do
            local CurrentStartPoint = StartPositionData[Index]

            local SwordClone = Assets.Models.Swords.GilgameshSpear:Clone()
            SwordClone.CFrame = CurrentStartPoint
            SwordClone.CFrame = CFrame.new(CurrentStartPoint.Position, MouseHit.Position)
                * CFrame.Angles(math.rad(90), math.rad(90), math.rad(180))

            SwordClone.Parent = workspace.World.Visuals

            Debris:AddItem(SwordClone, 1)

            local Direction = (PathData.MouseHit.Position - SwordClone.Position).Unit

            local Size = SwordClone.Size

            local Points = RaycastService:GetSquarePoints(SwordClone.CFrame, Size.X, Size.X)

            local InitialTween = TweenService:Create(
                SwordClone,
                TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false, 0),
                { ["CFrame"] = SwordClone.CFrame * CFrame.new(0, 5, 0) * CFrame.fromEulerAnglesXYZ(0, 4, 0) }
            )
            InitialTween:Play()
            InitialTween:Destroy()

            coroutine.resume(coroutine.create(function()
                InitialTween.Completed:Wait()

                local Animate = TweenService:Create(
                    SwordClone,
                    TweenInfo.new(Lifetime, Enum.EasingStyle.Linear),
                    { ["CFrame"] = SwordClone.CFrame * CFrame.new(0, Velocity * Lifetime, 0) }
                )
                Animate:Play()
                Animate:Destroy()

                RaycastService:CastProjectileHitbox({
                    Points = Points,
                    Direction = Direction,
                    Velocity = Velocity + 5,
                    Lifetime = Lifetime,
                    Iterations = 60,
                    Visualize = false,
                    Function = function(RaycastResult)
                        Explosions.GatesOfBabylon({
                            Index = Index,
                            Character = Character,
                            RaycastResult = RaycastResult,
                            Spear = SwordClone,
                            Distance = PathData.Distance,
                        })
                        -- SoundManager:AddSound("Explosion", {Parent = SwordClone, Volume = .5}, "Client")

                        local Target = RaycastResult.Instance

                        if Target:IsA("BasePart") and Target:IsDescendantOf(workspace.World.Live) then
                            Animate:Pause()

                            local WeldConstraint = Instance.new("WeldConstraint")
                            WeldConstraint.Part0 = Target
                            WeldConstraint.Part1 = SwordClone
                            WeldConstraint.Parent = Target

                            Debris:AddItem(WeldConstraint, 2.5)
                            Debris:AddItem(SwordClone, 3)
                        end
                    end,
                    Ignore = { Character, workspace.World.Visuals },
                })
            end))
        end
    end,

    ["Enkidu"] = function(PathData)
        local Character = PathData.Character

        local StartPositionData = PathData.StartPoints

        local Velocity = 200
        local Lifetime = 5

        local MouseHit = PathData.MouseHit

        local Trash = {}

        for Index = 1, 4 do
            local CurrentStartPoint = StartPositionData[Index]

            local SwordClone = Assets.Models.Swords.GilgameshSpear:Clone()
            SwordClone.CFrame = CurrentStartPoint
            SwordClone.CFrame = CFrame.new(CurrentStartPoint.Position, MouseHit.Position)
                * CFrame.Angles(math.rad(90), math.rad(90), math.rad(180))
            SwordClone.Transparency = 1

            SwordClone.Parent = workspace.World.Visuals

            Debris:AddItem(SwordClone, 1)

            local BeamClone = Particles.MainPortal:Clone()
            BeamClone.CFrame = CFrame.lookAt(SwordClone.Position, MouseHit.Position)
            BeamClone.Anchored = true

            BeamClone.Parent = workspace.World.Visuals
            Debris:AddItem(BeamClone, 2)

            local Direction = (PathData.MouseHit.Position - BeamClone.Position).Unit
            local Size = SwordClone.Size

            local BeamMagnitude = (BeamClone.BeamStart.Position - BeamClone.BeamEnd.Position).Magnitude
            local Points = RaycastService:GetSquarePoints(SwordClone.CFrame, Size.X, Size.X)

            local Rate = MouseHit.Position.Magnitude / Lifetime

            local Animate = TweenService:Create(
                BeamClone.BeamEnd,
                TweenInfo.new(Lifetime / 3, Enum.EasingStyle.Linear),
                { ["WorldPosition"] = (SwordClone.CFrame * CFrame.new(0, Velocity * Lifetime, 0)).Position }
            )
            Animate:Play()
            Animate:Destroy()

            RaycastService:CastProjectileHitbox({
                Points = Points,
                Direction = Direction,
                Velocity = Velocity + 5,
                Lifetime = Lifetime,
                Iterations = 60,
                Visualize = false,
                Function = function(RaycastResult)
                    local Target = RaycastResult.Instance
                    if Target and Target:IsA("BasePart") then
                        Animate:Pause()
                    end
                end,
                Ignore = { Character, workspace.World.Visuals },
            })
        end
    end,

    ["Punishment"] = function(PathData)
        local Character = PathData.Character
        local Target = PathData.Target

        local StartPositionData = PathData.StartPoints

        local Velocity = 135
        local Lifetime = 5

        --	local MouseHit = PathData.MouseHit

        local Trash = {}

        for Index = 1, #StartPositionData do
            local CurrentStartPoint = StartPositionData[Index]

            local SwordClone = Assets.Models.Swords.GilgameshSpear:Clone()
            SwordClone.CFrame = CurrentStartPoint
            SwordClone.CFrame = CFrame.new(CurrentStartPoint.Position, Target.PrimaryPart.Position)
                * CFrame.Angles(math.rad(90), math.rad(90), math.rad(180))

            SwordClone.Parent = workspace.World.Visuals

            Debris:AddItem(SwordClone, 1)

            local Direction = (Target.PrimaryPart.Position - SwordClone.Position).Unit

            local Size = SwordClone.Size

            local Points = RaycastService:GetSquarePoints(SwordClone.CFrame, Size.X, Size.X)

            local InitialTween = TweenService:Create(
                SwordClone,
                TweenInfo.new(0.75, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false, 0),
                { ["CFrame"] = SwordClone.CFrame * CFrame.new(0, 5, 0) * CFrame.fromEulerAnglesXYZ(0, 4, 0) }
            )
            InitialTween:Play()
            InitialTween:Destroy()

            coroutine.resume(coroutine.create(function()
                InitialTween.Completed:Wait()

                local Animate = TweenService:Create(
                    SwordClone,
                    TweenInfo.new(Lifetime, Enum.EasingStyle.Linear),
                    { ["CFrame"] = SwordClone.CFrame * CFrame.new(0, Velocity * Lifetime, 0) }
                )
                Animate:Play()
                Animate:Destroy()

                RaycastService:CastProjectileHitbox({
                    Points = Points,
                    Direction = Direction,
                    Velocity = Velocity + 5,
                    Lifetime = Lifetime,
                    Iterations = 60,
                    Visualize = false,
                    Function = function(RaycastResult)
                        Explosions.GatesOfBabylon({
                            Index = Index,
                            Character = Character,
                            RaycastResult = RaycastResult,
                            Spear = SwordClone,
                            Distance = PathData.Distance,
                            Type = "Punishment",
                        })
                        -- SoundManager:AddSound("Explosion", {Parent = SwordClone, Volume = 1}, "Client")

                        local Target = RaycastResult.Instance

                        if Target:IsA("BasePart") and Target:IsDescendantOf(workspace.World.Live) then
                            Animate:Pause()

                            local WeldConstraint = Instance.new("WeldConstraint")
                            WeldConstraint.Part0 = Target
                            WeldConstraint.Part1 = SwordClone
                            WeldConstraint.Parent = Target

                            Debris:AddItem(WeldConstraint, 3)
                            Debris:AddItem(SwordClone, 3)
                        end
                    end,
                    Ignore = { Character, workspace.World.Visuals },
                })
            end))
        end
    end,

    ["ChainEffect"] = function(PathData)
        local Character = PathData.Character
        local Target = PathData.Target

        local IsTarget, ValidTarget = GetMouseTarget(Target, Character)
        ValidTarget = ValidTarget.PrimaryPart or ValidTarget

        if IsTarget and not workspace.World.Visuals:FindFirstChild(ValidTarget.Name .. " - Gilgamesh Chain") then
            local Chains = Particles.PersonChains:Clone()
            Chains.Anchored = true
            Chains.Name = ValidTarget.Name .. " - Gilgamesh Chain"
            Chains.CFrame = ValidTarget.CFrame -- *  CFrame.new((.55),1,-.6) * CFrame.Angles(-4.5, 6.3, 15.17)

            Chains.Parent = workspace.World.Visuals
            Debris:AddItem(Chains, 2)

            local WeldConstraint = Instance.new("WeldConstraint")
            WeldConstraint.Part0 = ValidTarget
            WeldConstraint.Part1 = Chains

            WeldConstraint.Parent = Chains
        end
    end,
}

return GilgameshVFX
