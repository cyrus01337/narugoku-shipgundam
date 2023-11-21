local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local modules = ReplicatedStorage:WaitForChild("Modules")
local cyrus01337Utils = require(modules:WaitForChild("cyrus01337Utils"))
local globalFunctions = require(ReplicatedStorage:WaitForChild("GlobalFunctions"))

local player = Players.LocalPlayer
local playerChar = player.Character or player.CharacterAdded:Wait()
local playerRoot = playerChar:WaitForChild("HumanoidRootPart")
local playerGui = player:WaitForChild("PlayerGui")
local playerHud = playerGui:WaitForChild("HUD")
playerHud.Enabled = false
local instanceValue = script:WaitForChild("Value")
local menu = script:WaitForChild("Menu")
menu.Parent = playerGui
local defaultRotation
local angle = 0
local cameraAngles = {}
local connections: { [string]: RBXScriptConnection } = {}
local cameraValue = globalFunctions.NewInstance("IntValue", {
    Name = "CameraValue",
    Parent = script,
    Value = 1,
})
local Tweeninf2 = TweenInfo.new(15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true, 0)
local Tweeninf3 = TweenInfo.new(2, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)

ReplicatedFirst:RemoveDefaultLoadingScreen()
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
cyrus01337Utils.retryForever("DisableTopbar", function()
    StarterGui:SetCore("TopbarEnabled", false)
end)

for _, angleInstance in workspace.World.Map.CameraAngles:GetChildren() do
    cameraAngles[angleInstance.Name] = angleInstance.CFrame
    angleInstance:Destroy()
end

script.Value.Value = cameraAngles.CameraMenuAngle1
local MenuTween = TweenService:Create(instanceValue, Tweeninf2, {
    Value = cameraAngles.CameraMenuAngle2,
})

local function updateCameraValue()
    if MenuTween.PlaybackState == Enum.PlaybackState.Playing then
        return
    end

    MenuTween:Play()
end

updateCameraValue()
cameraValue.Changed:Connect(updateCameraValue)

while playerGui.InCamera.Value do
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    defaultRotation = playerRoot.CFrame - playerRoot.Position
    local Tween = TweenService:Create(playerRoot, Tweeninf3, {
        CFrame = CFrame.new(playerRoot.Position) * defaultRotation * CFrame.Angles(0, angle, 0),
    })

    Tween:Play()
    Tween:Destroy()

    workspace.CurrentCamera.CFrame = instanceValue.Value
    task.wait()
end

StarterGui:SetCore("TopbarEnabled", true)
workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
playerHud.Enabled = true

for key, connection in connections do
    connection:Disconnect()

    connections[key] = nil
end
