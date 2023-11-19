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
local Shared = Modules.Shared
local Utility = Modules.Utility

local HitPart2 = Models.Misc.HitPart2

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(Shared.SoundManager)

local TaskScheduler = require(Utility.TaskScheduler)

local Explosions = require(Modules.Effects.Explosions)
local VfxHandler = require(Modules.Effects.VfxHandler)

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

local function Lerp(Start, End, Alpha)
    return Start + (End - Start) * Alpha
end

local function BezierCurve(Start, Offset, End, Alpha)
    local FirstLerp = Lerp(Start, Offset, Alpha)
    local SecondLerp = Lerp(Offset, End, Alpha)

    local BezierLerp = Lerp(FirstLerp, SecondLerp, Alpha)

    return BezierLerp
end

local Killer_QueenVFX = {
    ["Traced Steps Explode"] = function(Data)
        local Character, Victim = Data.Character, Data.Victim
        local Root, VRoot = Character:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("HumanoidRootPart")

        -- SoundManager:AddSound("Explosion", {Parent = Root, Volume = 1}, "Client")
        Explosions.TracingStep({ Character = Character, ContactPointCFrame = VRoot.CFrame, Distance = Data.Distance })
    end,

    ["Traced Steps"] = function(Data)
        local Character = Data.Character
        local Root = Character:FindFirstChild("HumanoidRootPart")

        -- local Sound = SoundManager:AddSound("nil",{Parent = Root, Volume = 1}, "Client")

        for Index = 1, 5 do
            VfxHandler.AfterImage({
                Character = Character,
                Duration = 1,
                StartTransparency = 0.35,
                Color = Color3.fromRGB(0, 0, 0),
            })
            wait(0.045)
        end

        -- if Sound then
        -- 	Sound:Destroy()
        -- end
    end,

    ["Add Bomb"] = function(Data)
        local Character, Victim = Data.Character, Data.Victim
        local Root, VRoot = Character:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("HumanoidRootPart")

        VfxHandler.Orbies({
            Parent = VRoot,
            Speed = 0.5,
            Size = Vector3.new(0.2, 0.3, 4.79),
            Cframe = CFrame.new(0, 0, 5),
            Amount = 5,
            Circle = true,
            Sphere = true,
        })

        local TimerUI = ReplicatedStorage.Assets.Gui.SwitchOn:Clone()
        TimerUI.Parent = VRoot
    end,

    ["RemoveBomb"] = function(Data)
        local Character = Data.Character
        local Root = Character:FindFirstChild("HumanoidRootPart")

        Data.Victim:FindFirstChild("HumanoidRootPart").SwitchOn:Destroy()
    end,

    ["Switch Bomb"] = function(Data)
        local Character = Data.Character
        local Root = Character:FindFirstChild("HumanoidRootPart")

        -- SoundManager:AddSound("Explosion", {Parent = Root, Volume = 1}, "Client")
        Explosions.CoinExplosion({
            Character = Character,
            ContactPointCFrame = Data.Victim:FindFirstChild("HumanoidRootPart").CFrame,
            Coin = Data.Victim:FindFirstChild("HumanoidRootPart"),
            Distance = Data.Distance,
        })
    end,

    ["Coin Flip"] = function(Data)
        local Coin = Data.Coin
        for _ = 1, 25 do
            local Tweeninfo = TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 1, true, 0)

            local TweenTurn = TweenService:Create(Coin, Tweeninfo, { Orientation = Vector3.new(0, 360, 0) })
            TweenTurn:Play()
            TweenTurn:Destroy()
            RunService.Heartbeat:Wait()
        end
        Coin.Orientation = Vector3.new(-0.04, 0.01, -88.66)

        wait(0.125)
        -- SoundManager:AddSound("Tenkai",{Volume = 10, Parent = Coin}, "Client")
    end,

    ["Coin Toss"] = function(Data)
        local Character = Data.Character
        local Root = Character:FindFirstChild("HumanoidRootPart")

        local Coin = Data.Coin

        local Tween = TweenService:Create(
            Coin,
            TweenInfo.new(0.475, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Color = Color3.fromRGB(255, 62, 62) }
        )
        Tween:Play()
        Tween:Destroy()

        Coin.Material = "Neon"

        wait(0.35)
        -- SoundManager:AddSound("Explosion", {Parent = Root, Volume = 1}, "Client")
        Explosions.CoinExplosion({
            Character = Character,
            ContactPointCFrame = Coin.CFrame,
            Coin = Coin,
            Distance = Data.Distance,
        })
    end,

    ["Barrage"] = function(PathData)
        local Character = PathData.Character
        local Target = PathData.Target

        local Root, Hum = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
        -- SoundManager:AddSound("Shubababababa",{Parent = Root, Volume = 1, TimePosition = 1.115}, "Client")

        for _ = 1, 80 do
            local ToCFrame = Root.CFrame * CFrame.new(0, 0, -10)

            local CFrameConfig = CFrame.new(
                (Root.CFrame * CFrame.new(math.random(-3, 3), math.random(-2, 2), math.random(-4, -3))).p,
                ToCFrame.p
            ) * CFrame.Angles(math.rad(90), 0, 0)

            local JojoArm = Effects.Stands.KillerQueenArm:Clone()
            JojoArm.Color = Color3.fromRGB(232, 186, 200)
            JojoArm.Anchored = true
            JojoArm.Massless = true
            JojoArm.CFrame = CFrameConfig
            JojoArm.Parent = workspace.World.Visuals

            local Tween = TweenService:Create(
                JojoArm,
                TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
                { CFrame = JojoArm.CFrame * CFrame.new(0, -math.random(3, 5), 0) }
            )
            Tween:Play()
            Tween:Destroy()

            wait()

            local Tween = TweenService:Create(JojoArm, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Transparency = 1 })
            Tween:Play()
            Tween:Destroy()

            for _, v in ipairs(JojoArm:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("UnionOperation") then
                    local Animate =
                        TweenService:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Transparency = 1 })
                    Animate:Play()
                    Animate:Destroy()
                end
            end
            Debris:AddItem(JojoArm, 0.75)
        end
    end,
}

return Killer_QueenVFX
