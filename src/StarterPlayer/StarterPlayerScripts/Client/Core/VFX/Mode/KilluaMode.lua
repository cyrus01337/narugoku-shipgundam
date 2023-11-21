--|| Services ||--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

--|| Variables ||--
local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()

local Camera = workspace.CurrentCamera

local Particles = ReplicatedStorage.Assets.Effects.Particles
local Effects = ReplicatedStorage.Assets.Effects.Meshes

--|| Modules ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(ReplicatedStorage.Modules.Shared.SoundManager)

local LightningModule = require(ReplicatedStorage.Modules.Effects.LightningBolt)
local VfxHandler = require(ReplicatedStorage.Modules.Effects.VfxHandler)

local TaskScheduler = require(ReplicatedStorage.Modules.Utility.TaskScheduler)

--|| Assets ||--
local PlayerHead = Effects["PlayerHead"]
local MB2Effect = ReplicatedStorage.Assets.Models.Misc["FakeBodyPart"]

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { Character, workspace.World.Visuals }
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

--|| Tweens ||--
local Ti = TweenInfo.new(0.4, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)

local function CameraTween(Character, Part1, Part2, c)
    local Humanoid = Character:FindFirstChild("Humanoid")

    local CameraTime = c or 1
    local Tweeninfo = TweenInfo.new(CameraTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)

    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = Part1.CFrame

    local Tween = TweenService:Create(Camera, Tweeninfo, { CFrame = Part2.CFrame })
    Tween:Play()
    Tween:Destroy()

    TaskScheduler:AddTask(CameraTime, function()
        Camera.CameraType = "Custom"
        Camera.CameraSubject = Humanoid
    end)
end

local Godspeed = {

    ["Transformation"] = function(Data)
        local Character = Data.Character
        local Root = Character:FindFirstChild("HumanoidRootPart")

        local StartTime = os.clock()

        VfxHandler.FakeBodyPart({
            Character = Character,
            Object = "Left Leg",
            Material = "Neon",
            Color = Color3.fromRGB(110, 153, 202),
            Transparency = 1,
            Duration = 2,
            Delay = 0.1,
        })
        VfxHandler.FakeBodyPart({
            Character = Character,
            Object = "Left Arm",
            Material = "Neon",
            Color = Color3.fromRGB(110, 153, 202),
            Transparency = 1,
            Duration = 2,
            Delay = 0.1,
        })
        VfxHandler.FakeBodyPart({
            Character = Character,
            Object = "Torso",
            Material = "Neon",
            Color = Color3.fromRGB(110, 153, 202),
            Transparency = 1,
            Duration = 2,
            Delay = 0.1,
        })
        VfxHandler.FakeBodyPart({
            Character = Character,
            Object = "Right Leg",
            Material = "Neon",
            Color = Color3.fromRGB(110, 153, 202),
            Transparency = 1,
            Duration = 2,
            Delay = 0.1,
        })
        VfxHandler.FakeBodyPart({
            Character = Character,
            Object = "Right Arm",
            Material = "Neon",
            Color = Color3.fromRGB(110, 153, 202),
            Transparency = 1,
            Duration = 2,
            Delay = 0.1,
        })

        local MainAttachment = Character["Torso"]:FindFirstChild("BodyFrontAttachment")

        local ModeDebris = GlobalFunctions.NewInstance(
            "Folder",
            { Parent = workspace.World.Visuals.Mode, Name = Character.Name .. " Mode Debris" }
        )

        local MB2Effect = Particles.ParticleAttatchments.GodspeedThing:Clone()
        MB2Effect.Shockwave:Emit(1)
        MB2Effect.Parent = Root

        Debris:AddItem(MB2Effect, 1)

        --CameraTween(Character, Part2, Part1, 2)

        local RaycastResult = workspace:Raycast(Root.Position, Root.CFrame.upVector * -15, raycastParams)
        if RaycastResult and RaycastResult.Instance then
            for Index = 1, 10 do
                local Block = Effects.block:Clone()
                Block.Size = Vector3.new(0.744, 0.7, 0.759)
                Block.Orientation = Vector3.new(math.random(), math.random(), math.random())
                Block.Position = Root.Position + Vector3.new(math.random(-7, 7), -2, math.random(-7, 7))
                Block.Anchored = false
                Block.CanCollide = false
                Block.Color = RaycastResult.Instance.Color
                Block.Material = RaycastResult.Material
                Block.Parent = workspace.World.Visuals
                TaskScheduler:AddTask(0.15, function()
                    Block.CanCollide = true
                end)

                local BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                BodyVelocity.Velocity = Vector3.new(0, 5, 0)
                BodyVelocity.P = 3000
                BodyVelocity.Parent = Block

                Debris:AddItem(BodyVelocity, 1.35)
                Debris:AddItem(Block, 6.25)
            end

            coroutine.resume(coroutine.create(function()
                for Index = 1, 2 do
                    -- SoundManager:AddSound("LightningSizzle", {Parent = Root, Volume = 2}, "Client")

                    local RingTing = ReplicatedStorage.Assets.Effects.Meshes.RingInnit:Clone()
                    RingTing.Material = RaycastResult.Material
                    RingTing.Color = RaycastResult.Instance.Color
                    RingTing.Anchored = true
                    RingTing.CFrame = Root.CFrame * CFrame.new(0, -3, 0)
                    RingTing.Size = Vector3.new(15, 0.05, 15)
                    RingTing.Transparency = 0.25
                    RingTing.Parent = workspace.World.Visuals

                    GlobalFunctions.TweenFunction({
                        ["Instance"] = RingTing,
                        ["EasingStyle"] = Enum.EasingStyle.Quad,
                        ["EasingDirection"] = Enum.EasingDirection.Out,
                        ["Duration"] = 0.5,
                    }, {
                        ["Transparency"] = 1,
                        ["Size"] = Vector3.new(22, 0.05, 22),
                    })

                    Debris:AddItem(RingTing, 1.25)
                    wait(0.8)
                end
            end))
        end

        local LineTing = Particles.LongLineTing:Clone()
        LineTing.Parent = Root

        local X, Y, Z = 5, 5, 5

        for Index = 1, 18 do
            local Attachment2 = Instance.new("Attachment")
            Attachment2.Parent = Root
            Attachment2.Position = Vector3.new(math.random(-X, X), math.random(-Y, Y), math.random(-Z, Z))

            local ColorCalc = Index % 2 == 0 and Color3.fromRGB(110, 153, 202) or Color3.fromRGB(110, 153, 202)

            local LightningBolt = LightningModule.new(MainAttachment, Attachment2, 4)
            LightningBolt.Color = ColorCalc
            Debris:AddItem(Attachment2, 1)
            wait(0.06)
        end

        wait(0.25)

        for _, v in ipairs(Character:GetChildren()) do
            if v.ClassName == "MeshPart" or v.ClassName == "Part" then
                local UIAura = script.UIAura:Clone()
                local light = script.light:Clone()
                local sqres = script.sqres:Clone()
                UIAura.Parent = v
                light.Parent = v
                sqres.Parent = v
            elseif v:IsA("Accessory") and v.Name == "Hair" then
                local Ting = v.Handle:Clone()
                Ting["killua hair"].Color = Color3.fromRGB(183, 230, 255)
                Ting["killua hair"].Material = "Neon"
                Ting["killua hair"].Transparency = 0.5
                Ting["killua hair"].Size = v.Handle["killua hair"].Size + Vector3.new(0.175, 0.175, 0.175)
                Ting["killua hair 2"].Size = v.Handle["killua hair 2"].Size + Vector3.new(0.175, 0.175, 0.175)
                Ting["killua hair 2"].Color = Color3.fromRGB(183, 230, 255)
                Ting["killua hair 2"].Material = "Neon"
                Ting["killua hair 2"].Transparency = 0.5
                Ting.Color = Color3.fromRGB(183, 230, 255)
                Ting.Massless = true
                Ting.CanCollide = false
                Ting.Material = "Neon"
                Ting.Transparency = 0.5
                Ting.Name = Character.Name .. "GodspeedPart"
                Ting.Parent = ModeDebris

                local TextureTing = ReplicatedStorage.Assets.Effects.Decals.Texture:Clone()
                TextureTing.Parent = Ting["killua hair"]

                local TextureTing = ReplicatedStorage.Assets.Effects.Decals.Texture:Clone()
                TextureTing.Parent = Ting["killua hair 2"]

                local WeldConstraint = Instance.new("WeldConstraint")
                WeldConstraint.Part0 = v.Handle
                WeldConstraint.Part1 = Ting
                WeldConstraint.Parent = Ting
            end
        end

        VfxHandler.FakeBodyPart({
            Character = Character,
            Name = Character.Name .. "GodspeedPart",
            Object = "Left Arm",
            Color = Color3.fromRGB(110, 153, 202),
            Transparency = 0.6,
        })
        VfxHandler.FakeBodyPart({
            Character = Character,
            Name = Character.Name .. "GodspeedPart",
            Object = "Right Arm",
            Color = Color3.fromRGB(110, 153, 202),
            Transparency = 0.6,
        })
        VfxHandler.FakeBodyPart({
            Character = Character,
            Name = Character.Name .. "GodspeedPart",
            Object = "Torso",
            Color = Color3.fromRGB(110, 153, 202),
            Transparency = 0.6,
        })
        VfxHandler.FakeBodyPart({
            Character = Character,
            Name = Character.Name .. "GodspeedPart",
            Object = "Left Leg",
            Color = Color3.fromRGB(110, 153, 202),
            Transparency = 0.6,
        })
        VfxHandler.FakeBodyPart({
            Character = Character,
            Name = Character.Name .. "GodspeedPart",
            Object = "Right Leg",
            Color = Color3.fromRGB(110, 153, 202),
            Transparency = 0.6,
        })

        local Clone = PlayerHead:Clone()
        Clone.CFrame = Character["Head"].CFrame
        Clone.Massless = true
        Clone.CanCollide = false
        Clone.Orientation = Character["Head"].Orientation
        Clone.Color = Color3.fromRGB(110, 153, 202)
        Clone.Size = PlayerHead.Size + Vector3.new(0.1, 0.1, 0.1)
        Clone.Transparency = 0.35
        Clone.Name = Character.Name .. "GodspeedPart"

        local WeldConstraint = Instance.new("WeldConstraint")
        WeldConstraint.Part0 = Clone
        WeldConstraint.Part1 = Character["Head"]
        WeldConstraint.Parent = Character["Head"]

        Clone.Parent = Character

        while
            Character
            and Players:GetPlayerFromCharacter(Character)
            and Character.Humanoid.Health >= 1
            and _G.Data.Character == "Killua"
        do
            coroutine.resume(coroutine.create(function()
                local Parents = {
                    Character:FindFirstChild("HumanoidRootPart"),
                    Character:FindFirstChild("Head"),
                    Character:FindFirstChild("Left Arm"),
                    Character:FindFirstChild("Right Leg"),
                }

                local Attachment = Instance.new("Attachment")
                Attachment.Position = Vector3.new(0.5, 0.5, 0.5)
                Attachment.Parent = Parents[math.random(1, #Parents)]

                local AuraBolt = LightningModule.new(MainAttachment, Attachment, 20)
                AuraBolt.PulseLength = 1
                AuraBolt.Color = Color3.fromRGB(110, 153, 202)
                Debris:AddItem(Attachment, 1)

                -- SoundManager:AddSound("LightningSizzle", {Parent = Root, Volume = 2}, "Client")
            end))

            if os.clock() - StartTime >= 58 then
                StartTime = os.clock()
                break
            end
            wait(1)
        end

        if ModeDebris:FindFirstChild(Character.Name .. "GodspeedPart") then
            for _, v in ipairs(ModeDebris:GetChildren()) do
                if v.Name == Character.Name .. "GodspeedPart" then
                    v:Destroy()
                end
            end
        end

        for _, v in ipairs(Character:GetDescendants()) do
            if v.Name == Character.Name .. "GodspeedPart" and v:IsA("BasePart") or v:IsA("ParticleEmitter") then
                v:Destroy()
            end
        end

        ModeDebris:Destroy()
    end,
}

return Godspeed
