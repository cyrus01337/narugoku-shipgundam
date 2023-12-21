local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- local SoundManager = require(Shared:WaitForChild("SoundManager"))
local TweenData = require(script.Tweens)

local player = Players.LocalPlayer
local playerMouse = player:GetMouse()
local modules = ReplicatedStorage:WaitForChild("Modules")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local Shared = modules:WaitForChild("Shared")

script.Parent:WaitForChild("Logo")
script.Parent:WaitForChild("Play")
script.Parent:WaitForChild("Training")
script.Parent:WaitForChild("Private_Servers")
script.Parent.Logo.Size = UDim2.new(0, 0, 0, 0)
script.Parent.Training.Position = UDim2.new(0.5, 0, 1.1, 0)
script.Parent.Play.Position = UDim2.new(0.5, 0, 1.1, 0)
script.Parent.Private_Servers.Position = UDim2.new(0.5, 0, 1.1, 0)
script.Parent:WaitForChild("Close")

local CloseConnection
CloseConnection = script.Parent.Close.Event:Connect(function()
    Debris:AddItem(script.Parent, 1)

    local Tween =
        TweenService:Create(script.Parent.Logo, TweenData.LogoTween, { Position = UDim2.new(0.5, 0, -0.5, 0) })
    Tween:Play()
    Tween:Destroy()

    local Tween =
        TweenService:Create(script.Parent.Training, TweenData.TrainingTween, { Position = UDim2.new(0.5, 0, 1.2, 0) })
    Tween:Play()
    Tween:Destroy()

    wait()
    local Tween = TweenService:Create(script.Parent.Play, TweenData.PlayTween, { Position = UDim2.new(0.5, 0, 1.2, 0) })
    Tween:Play()
    Tween:Destroy()

    local Tween = TweenService:Create(
        script.Parent.Private_Servers,
        TweenData.Private_ServersTween,
        { Position = UDim2.new(0.5, 0, 1.2, 0) }
    )
    Tween:Play()
    Tween:Destroy()
end)

local Tween = TweenService:Create(
    script.Parent.Logo,
    TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false, 0),
    { Size = UDim2.new(0.3, 0, 0.85, 0) }
)
Tween:Play()
Tween:Destroy()

-- SoundManager:AddSound("Pop", {Parent = Player:WaitForChild("PlayerGui"), PlaybackSpeed = .6}, "Client")

wait(0.5)

local Tween = TweenService:Create(
    script.Parent.Play,
    TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, false, 0),
    { Position = UDim2.new(0.5, 0, 0.69, 0) }
)
Tween:Play()
Tween:Destroy()

wait(0.25)

-- SoundManager:AddSound("Pop", {Parent = Player:WaitForChild("PlayerGui"), PlaybackSpeed = 1}, "Client")
wait()

local Tween = TweenService:Create(
    script.Parent.Training,
    TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, false, 0),
    { Position = UDim2.new(0.5, 0, 0.76, 0) }
)
Tween:Play()
Tween:Destroy()

wait(0.25)
-- SoundManager:AddSound("Pop", {Parent = Player:WaitForChild("PlayerGui"), PlaybackSpeed = 1}, "Client")

local Tween = TweenService:Create(
    script.Parent.Private_Servers,
    TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, false, 0),
    { Position = UDim2.new(0.5, 0, 0.828, 0) }
)
Tween:Play()
Tween:Destroy()

wait(0.25)
-- SoundManager:AddSound("Pop", {Parent = Player:WaitForChild("PlayerGui"), PlaybackSpeed = 1}, "Client")
wait()

local Buttons = { script.Parent.Play, script.Parent.Training, script.Parent.Private_Servers }
local In = nil

function UpdateIn()
    for _, v in ipairs(Buttons) do
        if In == v then
            local Tween = TweenService:Create(v, TweenData.ButtonTween, { Size = UDim2.new(0.2, 0, 0.05, 0) })
            Tween:Play()
            Tween:Destroy()
        else
            local Tween = TweenService:Create(v, TweenData.ButtonTween, { Size = UDim2.new(0.14, 0, 0.05, 0) })
            Tween:Play()
            Tween:Destroy()
        end
    end
end

local en = false
for i, v in ipairs(Buttons) do
    local Button = v:WaitForChild("Button")
    local Connection
    Connection = Button.MouseButton1Down:Connect(function()
        if en == false and v and v:FindFirstChild("F1") then
            en = true

            -- SoundManager:AddSound("ClickMenu", {Parent = Player:WaitForChild("PlayerGui")}, "Client")
            if v.Name == "Training" then
                print("clicked Training")
            elseif v.Name == "Play" then
                -- TODO: Refactor
                local Circle = script.Tweens.Circle:Clone()
                Circle.Parent = script.Parent

                coroutine.wrap(function()
                    local Tween = TweenService:Create(
                        script.Parent.Play,
                        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, false, 0),
                        { Position = UDim2.new(-1.5, 0, 0.677, 0) }
                    )
                    Tween:Play()
                    Tween:Destroy()

                    Tween.Completed:Wait()
                    local Tween2 = TweenService:Create(
                        script.Parent.Training,
                        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, false, 0),
                        { Position = UDim2.new(1.2, 0, 0.76, 0) }
                    )
                    Tween2:Play()
                    Tween2:Destroy()

                    Tween2.Completed:Wait()
                    local Tween = TweenService:Create(
                        script.Parent.Private_Servers,
                        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, false, 0),
                        { Position = UDim2.new(-0.075, 0, 0.828, 0) }
                    )
                    Tween:Play()
                    Tween:Destroy()
                end)()

                --{1.2, 0},{0.76, 0}
                --{-0.065, 0},{0.677, 0}

                coroutine.wrap(function()
                    wait(1.65)
                    local Tween = TweenService:Create(
                        Circle,
                        TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0),
                        { Size = UDim2.new(3, 0, 3, 0), ImageColor3 = Color3.fromRGB(0, 0, 0) }
                    )
                    Tween:Play()
                    Tween:Destroy()
                end)()

                --script.Parent:WaitForChild("TextLabel")
                --coroutine.wrap(function()
                --	wait(1.5)
                --	script.Parent.Logo.Size = UDim2.new()
                --	script.Parent.Logo.Rotation = math.random(1,12) * 30

                --	local Tween = TweenService:Create(script.Parent.Logo,TweenInfo.new(2,Enum.EasingStyle.Elastic,Enum.EasingDirection.Out,0,false,0),{ Size = UDim2.new(0.45, 0,0.85, 0), Rotation = 0 })
                --	Tween:Play()
                --	Tween:Destroy()
                --end)()
                wait(1.65 * 2)

                script.Parent.Logo:Destroy()

                local Tween2 = TweenService:Create(
                    Circle,
                    TweenInfo.new(0.35, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0),
                    { ImageTransparency = 1 }
                )
                Tween2:Play()
                Tween2:Destroy()
                player:WaitForChild("PlayerGui").InCamera.Value = false

                CloseConnection:Disconnect()
                CloseConnection = nil
                Connection:Disconnect()
                Connection = nil
                local Connection
                Connection = Tween2.Completed:Connect(function()
                    --Player:WaitForChild("PlayerGui").InCamera.Value = false;
                    script.Parent.Enabled = false

                    Connection:Disconnect()
                    Connection = nil
                end)

                remotes.EnteredGame:FireServer()
            elseif v.Name == "Private_Servers" then
                print("clicked private server")
            end

            local x, y = playerMouse.X - v.F1.AbsolutePosition.X, playerMouse.Y - v.F1.AbsolutePosition.Y
            local Circle = script.Tweens.Circle:Clone()
            Circle.Position = UDim2.new(0, x, 0, y, 0)
            Circle.Parent = v.F1

            local Tween = TweenService:Create(
                Circle,
                TweenData.CircleEffectTween,
                { Size = UDim2.new(9, 0, 9, 0), ImageTransparency = 1 }
            )
            Tween:Play()
            Tween:Destroy()

            Debris:AddItem(Circle, 1)

            wait(2)
            en = false
        end
    end)
    v.MouseEnter:Connect(function()
        In = v
        UpdateIn()
        -- SoundManager:AddSound("HoverTing", {Parent = Player:WaitForChild("PlayerGui")}, "Client")
    end)
    v.MouseLeave:Connect(function()
        if In == v then
            In = nil
            UpdateIn()
        end
    end)
end
