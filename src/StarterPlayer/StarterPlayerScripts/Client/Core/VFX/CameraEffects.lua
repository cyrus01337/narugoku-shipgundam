--|| Services ||--
local Players = game:GetService("Players")

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local UserGameSettings = UserSettings():GetService("UserGameSettings")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Metadata = Modules.Metadata
local Utility = Modules.Utility
local Shared = Modules.Shared
local Effects = Modules.Effects

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local SoundManager = require(Shared.SoundManager)

local CameraShaker = require(Effects.CameraShaker)
local VfxHandler = require(Effects.VfxHandler)

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local PlayerGui = Player:WaitForChild("PlayerGui")

local CurrentCamera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
    CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
end)

local function GetRadialPoints(CF, points, distance)
    local list = {}
    for i = 1, points do
        local degree = ((2 * math.pi) / points) * i
        local z = math.sin(degree) * distance
        local x = math.cos(degree) * distance
        local cf = CF * CFrame.new(x, 0, z)
        list[i] = cf
    end
    return list
end

--|| Debounces ||--
local Break = false

local CameraEffects = {

    ChangeCameraType = function(Data)
        local Character = Player.Character or Player.CharacterAdded:Wait()

        if _G.CameraLock == false then
            return
        end
        if Data == true then
            UserGameSettings.RotationType = Enum.RotationType.MovementRelative
        else
            UserGameSettings.RotationType = Enum.RotationType.CameraRelative
        end
    end,

    HideCharacterBar = function(Data)
        local PlayerGui = Player:WaitForChild("PlayerGui")
        local BarScreenGui = PlayerGui:FindFirstChild(Data.Character .. "Bar")

        if BarScreenGui then
            BarScreenGui.Enabled = false
        end
    end,

    EnableCharacterBar = function(Data)
        local PlayerGui = Player:WaitForChild("PlayerGui")
        local BarScreenGui = PlayerGui:FindFirstChild(Data.Character .. "Bar")

        if BarScreenGui then
            BarScreenGui.Enabled = true
        end
    end,

    CustomBarToValue = function(Data)
        local PlayerGui = Player:WaitForChild("PlayerGui")
        local BarScreenGui = PlayerGui:FindFirstChild(Data.Character .. "Bar")

        if Player[Data.WhichValue].Value >= 295 then
            return
        end

        if BarScreenGui then
            BarScreenGui.Frame.Bar:TweenSize(
                UDim2.new(Player[Data.WhichValue].Value / 300, 0, 0.588, 0),
                "Out",
                "Quad",
                0.25
            )
        end
    end,

    SlashScreen = function(Data)
        VfxHandler.SlashScreen({ Character = Player.Character or Player.CharacterAdded:Wait() })
    end,

    MENBEREEEEE = function(Data)
        local PlayerGui = Player:WaitForChild("PlayerGui")

        local StartTime = os.clock()

        -- SoundManager:AddSound("Woosh",{Parent = PlayerGui, Volume = 5}, "Client")
        wait(0.15)
        PlayerGui.Ultimates.Enabled = true

        local TI = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

        local Colours = {
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(207, 255, 242),
            Color3.fromRGB(237, 222, 255),
            Color3.fromRGB(255, 208, 211),
            Color3.fromRGB(255, 255, 255),
        }

        wait(0.85)
        -- SoundManager:AddSound("Woosh",{Parent = PlayerGui, Volume = 5}, "Client")

        for _, v in ipairs(PlayerGui.Ultimates:GetDescendants()) do
            if v:IsA("ImageLabel") then
                local Tween = TweenService:Create(v, TweenInfo.new(0.15), { ImageTransparency = 1 })
                Tween:Play()
                Tween:Destroy()

                coroutine.wrap(function()
                    Tween.Completed:Wait()
                    v.ImageTransparency = 0
                end)()
            elseif v:IsA("TextLabel") then
                local Tween = TweenService:Create(v, TweenInfo.new(0.15), { TextTransparency = 1 })
                Tween:Play()
                Tween:Destroy()
                coroutine.wrap(function()
                    Tween.Completed:Wait()
                    v.TextTransparency = 0
                end)()
            end
        end
        wait(0.15)
        PlayerGui.Ultimates.Enabled = false
    end,

    Sharingan = function(Data)
        local PlayerGui = Player:WaitForChild("PlayerGui")
        PlayerGui.Sharingan.Enabled = true

        local SharinganColor = Instance.new("ColorCorrectionEffect")
        SharinganColor.TintColor = Color3.fromRGB(197, 31, 31)
        SharinganColor.Parent = Lighting

        Debris:AddItem(SharinganColor, 2)

        local Tween = TweenService:Create(
            PlayerGui.Sharingan.Frame.ImageLabel,
            TweenInfo.new(0.75, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
            { ["Rotation"] = math.random(800), ["ImageTransparency"] = 1 }
        )
        Tween:Play()
        Tween:Destroy()

        Tween.Completed:Wait()

        local Tween = TweenService:Create(
            SharinganColor,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ["TintColor"] = Color3.fromRGB(255, 255, 255) }
        )
        Tween:Play()
        Tween:Destroy()

        PlayerGui.Sharingan.Enabled = false
        PlayerGui.Sharingan.Frame.ImageLabel.ImageTransparency = 0
    end,

    SanjiCutscene = function(Data)
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Root = Character:FindFirstChild("HumanoidRootPart")

        CurrentCamera.CameraType = Enum.CameraType.Scriptable

        local InitialCFrame = CurrentCamera.CFrame

        local Cutscene = TweenService:Create(
            CurrentCamera,
            TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { CFrame = Root.CFrame * CFrame.Angles(0, math.rad(180), 0) * CFrame.new(0, 2.35, 15) }
        )
        Cutscene:Play()

        wait(1.5)
        local FOV = workspace.CurrentCamera.FieldOfView

        local Zoom = TweenService:Create(
            CurrentCamera,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { FieldOfView = 100 }
        )
        Zoom:Play()
        Zoom:Destroy()
        Zoom.Completed:Wait()

        local EndZoom = TweenService:Create(
            CurrentCamera,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { FieldOfView = FOV }
        )
        EndZoom:Play()
        EndZoom:Destroy()

        EndZoom.Completed:Wait()

        local EndTween = TweenService:Create(
            CurrentCamera,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { CFrame = InitialCFrame }
        )
        EndTween:Play()
        EndTween:Destroy()

        EndTween.Completed:Wait()
        CurrentCamera.CameraType = Enum.CameraType.Custom
    end,

    LuffyCutscene = function(Data)
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Root = Character:FindFirstChild("HumanoidRootPart")

        CurrentCamera.CameraType = Enum.CameraType.Scriptable

        local InitialCFrame = CurrentCamera.CFrame

        local BodyPosition = Instance.new("BodyPosition")
        BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BodyPosition.Position = Root.Position
        BodyPosition.Parent = Root

        local BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        BodyGyro.CFrame = Root.CFrame
        BodyGyro.Parent = Root

        local Cutscene = TweenService:Create(
            CurrentCamera,
            TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { CFrame = Root.CFrame * CFrame.Angles(0, math.rad(180), 0) * CFrame.new(0, -1, 10) }
        )
        Cutscene:Play()

        wait(1)
        local FOV = workspace.CurrentCamera.FieldOfView

        local Zoom = TweenService:Create(
            CurrentCamera,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { FieldOfView = 100 }
        )
        Zoom:Play()
        Zoom:Destroy()
        Zoom.Completed:Wait()

        local EndZoom = TweenService:Create(
            CurrentCamera,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { FieldOfView = FOV }
        )
        EndZoom:Play()
        EndZoom:Destroy()

        EndZoom.Completed:Wait()

        local EndTween = TweenService:Create(
            CurrentCamera,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { CFrame = InitialCFrame }
        )
        EndTween:Play()
        EndTween:Destroy()

        EndTween.Completed:Wait()

        BodyPosition:Destroy()
        BodyGyro:Destroy()

        CurrentCamera.CameraType = Enum.CameraType.Custom
    end,

    ModeCamera = function(Data)
        local Character = Data.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local InitialCFrame = CurrentCamera.CFrame
        CurrentCamera.CameraType = Enum.CameraType.Scriptable

        --[[local Cutscene = TweenService:Create(CurrentCamera,TweenInfo.new(.35,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{CFrame = Root.CFrame * CFrame.Angles(0,math.rad(180),0) * CFrame.new(0,-1,10)})
		Cutscene:Play()
		Cutscene:Destroy()
			
		Cutscene.Completed:Wait() ]]

        local Subject = ReplicatedStorage.Assets.Models.Misc.ModeCameraAngle:Clone()
        Subject.CFrame = Root.CFrame * CFrame.new(0, 0, 10)
        Subject.Orientation = Vector3.new(0, 0, 0)
        Subject.Transparency = 1
        Subject.Parent = workspace.World.Visuals

        Debris:AddItem(Subject, 3)

        local StartTime = os.clock()

        local Points = GetRadialPoints(Data.StartingCFrame, 150, 10)

        local DurationBetweenLerp = Data.Duration / #Points -- adjust this to make it smoother >.<

        for Index = 1, #Points do
            local CurrentPoint = Points[Index]

            CurrentCamera.CameraType = Enum.CameraType.Scriptable
            CurrentCamera.CFrame = CFrame.lookAt(CurrentPoint.Position, Character.PrimaryPart.Position)

            RunService.Stepped:Wait()

            if os.clock() - StartTime >= 1 then
                StartTime = os.clock()
                break
            end
        end
        CurrentCamera.CameraType = Enum.CameraType.Custom
        wait(0.1)
        local Tween = TweenService:Create(
            CurrentCamera,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { CFrame = InitialCFrame }
        )
        Tween:Play()
        Tween:Destroy()

        local FOV = CurrentCamera.FieldOfView

        local Zoom = TweenService:Create(
            CurrentCamera,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { FieldOfView = 180 }
        )
        Zoom:Play()
        Zoom:Destroy()

        Zoom.Completed:Wait()

        local Zoom = TweenService:Create(
            CurrentCamera,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { FieldOfView = FOV }
        )
        Zoom:Play()
        Zoom:Destroy()

        Zoom.Completed:Wait()
    end,

    ChangeUICooldown = function(Data)
        local Slots = Player.PlayerGui.HUD:FindFirstChild("SkillUI")

        local CooldownText = Slots[Data.Key .. "Slot"]:FindFirstChild("CooldownText")
        local SkillNameText = Slots[Data.Key .. "Slot"]:FindFirstChild("Skill")
        local Gradient = Slots[Data.Key .. "Slot"]:FindFirstChild("CooldownGradient")

        local Cooldown = Data.Cooldown

        Gradient.Offset = Vector2.new(1, 0)

        local Tween = TweenService:Create(
            Gradient,
            TweenInfo.new(Cooldown, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            { Offset = Vector2.new(-1, 0) }
        )
        Tween:Play()
        Tween:Destroy()

        local Tween = TweenService:Create(
            SkillNameText,
            TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            { TextColor3 = Color3.fromRGB(255, 61, 61) }
        )
        Tween:Play()
        Tween:Destroy()

        local StartTime = os.clock()
        local CachedCharacter = _G.Data.Character
        while os.clock() - StartTime < Cooldown and CachedCharacter == _G.Data.Character and not Break do
            CooldownText.Text = math.floor(((Cooldown - (os.clock() - StartTime)) * 10)) / 10
            RunService.RenderStepped:Wait()
        end
        Gradient.Offset = Vector2.new(-1, 0)
        CooldownText.Text = ""

        local Tween = TweenService:Create(
            SkillNameText,
            TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            { TextColor3 = Color3.fromRGB(255, 255, 255) }
        )
        Tween:Play()
        Tween:Destroy()
    end,

    ChangeCamera = function(Data)
        local Subject = Data.Subject

        CurrentCamera.CameraType = Enum.CameraType.Scriptable --"Enum.CameraType.Track"
        CurrentCamera.CameraSubject = Subject
        CurrentCamera.CFrame = Subject.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(-90), 0, 0)

        local StartTime = os.clock()

        while os.clock() - StartTime <= Data.Duration and Data.Humanoid.Health > 0 and Subject do
            RunService.Stepped:Wait()
        end
        CurrentCamera.CameraType = "Custom"
        CurrentCamera.CameraSubject = Data.Humanoid
        Subject:Destroy()
    end,

    CameraShake = function(Data)
        local Type = Data.Type
        local Time = Data.Time

        if not Type then
            CameraShake:Start()
            CameraShake:ShakeOnce(Data.FirstText, Data.SecondText, Data.ThirdText or 0, Data.FourthText or 1.5)
        elseif Type == "Loop" then
            for _ = 1, Data.Amount do
                CameraShake:Start()
                CameraShake:ShakeOnce(Data.FirstText, Data.SecondText, Data.ThirdText or 0, Data.FourthText or 1.5)
                wait(Time)
            end
        end
    end,

    CreateFlashUI = function(Data)
        local ScreenGUI = Instance.new("ScreenGui")
        ScreenGUI.Name = "Flash"
        ScreenGUI.Parent = Player.PlayerGui

        local Frame = Instance.new("Frame")
        Frame.Parent = ScreenGUI
        Frame.BorderSizePixel = 0
        Frame.BackgroundColor3 = Data.Color
        Frame.Position = Data.Position
        Frame.Size = Data.Size

        local TweenInf = TweenInfo.new(Data.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

        local Tween = TweenService:Create(Frame, TweenInf, { BackgroundTransparency = 1 })
        Tween:Play()
        Tween:Destroy()

        Debris:AddItem(ScreenGUI, Data.Duration * 1.15)
    end,

    ColorCorrection = function(Data)
        if Data.Type == "Create" then
            local ColorCorrection = Instance.new("ColorCorrectionEffect")
            ColorCorrection.TintColor = Data.Color or Color3.fromRGB(255, 255, 255)
            ColorCorrection.Name = Data.Name or "ColorCorrection"

            ColorCorrection.Parent = Lighting

            local Tween = TweenService:Create(
                ColorCorrection,
                TweenInfo.new(Data.Length, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                { TintColor = Data.TweenColor }
            )
            Tween:Play()
            Tween:Destroy()

            coroutine.resume(coroutine.create(function()
                if Data.TimeBeforeRemove then
                    wait(Data.TimeBeforeRemove)
                    local ColorCorrection = Lighting:FindFirstChild(Data.Name)

                    local Tween = TweenService:Create(
                        ColorCorrection,
                        TweenInfo.new(Data.Length, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                        { TintColor = Data.TweenColor }
                    )
                    Tween:Play()
                    Tween:Destroy()

                    Debris:AddItem(ColorCorrection, Data.Length)
                end
            end))

            if Data.Duration then
                Debris:AddItem(ColorCorrection, Data.Length)
            end
        elseif Data.Type == "Remove" then
            local ColorCorrection = Lighting[Data.Name]

            local Tween = TweenService:Create(
                ColorCorrection,
                TweenInfo.new(Data.Length, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                { TintColor = Data.TweenColor }
            )
            Tween:Play()
            Tween:Destroy()

            Tween.Completed:Wait()
            ColorCorrection:Destroy()
        end
    end,

    CreateBlur = function(Data)
        local Blur = Instance.new("BlurEffect")
        Blur.Size = 0
        Blur.Parent = Lighting

        local TweenInf = TweenInfo.new(Data.Length, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)

        local Tween = TweenService:Create(Blur, TweenInf, { Size = Data.Size })
        Tween:Play()
        Tween:Destroy()

        Debris:AddItem(Blur, Data.Length * 2)
    end,

    HideMenu = function(Data)
        local PlayerHUD = PlayerGui:WaitForChild("HUD")
        local Gradient = PlayerHUD.Gradient

        if Data.Value == "Hide" then
            PlayerHUD:WaitForChild("Menu").Visible = false
        elseif Data.Value == "RePeek" then
            PlayerHUD:WaitForChild("Menu").Visible = true
        end
    end,

    HideUI = function(Data)
        local PlayerHUD = PlayerGui:WaitForChild("HUD")

        if Data.Value == "Hide" then
            PlayerHUD:WaitForChild("HealthFrame").Visible = false
            PlayerHUD:WaitForChild("RageFrame").Visible = false
            PlayerHUD:WaitForChild("SkillUI").Visible = false
        elseif Data.Value == "RePeek" then
            PlayerHUD:WaitForChild("HealthFrame").Visible = true
            PlayerHUD:WaitForChild("RageFrame").Visible = true
            PlayerHUD:WaitForChild("SkillUI").Visible = true
        end
    end,

    AddGradient = function(Data)
        local PlayerHUD = PlayerGui.HUD
        local Gradient = PlayerHUD.Gradient

        if Data.Type == "Add" then
            local Tween = TweenService:Create(
                Gradient,
                TweenInfo.new(Data.Length, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                { ImageTransparency = 0.35 }
            )
            Tween:Play()
            Tween:Destroy()

            PlayerHUD.HealthFrame.Visible = false
            PlayerHUD.RageFrame.Visible = false
            PlayerHUD.Menu.Visible = false
            PlayerHUD.SkillUI.Visible = false
        elseif Data.Type == "Remove" then
            local Tween = TweenService:Create(
                Gradient,
                TweenInfo.new(Data.Length, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                { ImageTransparency = 1 }
            )
            Tween:Play()
            Tween:Destroy()

            PlayerHUD.HealthFrame.Visible = true
            PlayerHUD.RageFrame.Visible = true
            PlayerHUD.Menu.Visible = true
            PlayerHUD.SkillUI.Visible = true
        end
    end,

    TweenObject = function(Data)
        local Tween = TweenService:Create(
            Data.Object or workspace.CurrentCamera,
            TweenInfo.new(Data.LifeTime, Data.EasingStyle, Data.EasingDirection, 0, Data.Return, 0),
            Data.Properties
        )
        Tween:Play()
        Tween:Destroy()
    end,

    BreakCooldown = function(Data)
        local Slots = Player.PlayerGui.HUD:FindFirstChild("SkillUI")
        local CooldownTable, GradientTable = {}, {}

        for _, v in ipairs(Slots:GetDescendants()) do
            if v:FindFirstChild("CooldownGradient") then
                repeat
                    RunService.RenderStepped:Wait()
                    v.CooldownGradient.Offset = Vector2.new(-1, 0)
                until v.CooldownGradient.Offset == Vector2.new(-1, 0)
            elseif v:FindFirstChild("CooldownText") then
                v.Text = ""
            end
        end

        Break = true
        wait()
        Break = false
    end,
}

return CameraEffects
