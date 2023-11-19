--|| Services ||--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--|| Variables ||--
local Player = Players.LocalPlayer
local PlrMouse = Player:GetMouse()

local Camera = workspace.CurrentCamera

local Npcs = workspace.World.NPCS
local PlayerGui = Player:WaitForChild("PlayerGui")

local Dialogue = PlayerGui:WaitForChild("Interface"):FindFirstChild("Dialogue")
local HUD = PlayerGui:WaitForChild("HUD")

local Option1 = Dialogue:WaitForChild("Option1")
local Option2 = Dialogue:WaitForChild("Option2")

local Option3 = Dialogue:WaitForChild("Option3")

local Cancel = Dialogue:WaitForChild("Cancel")

--|| Modules ||--
local RichText = require(script.Parent.RichText)

local title = Dialogue.Title
local textFrame = Dialogue.TextFrame

--Dialogue.Visible = false

local DialogueIn = TweenService:Create(
    Dialogue,
    TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    { Size = UDim2.new(1, 0, 0.25, 0), BackgroundTransparency = 0.6 }
)
local DialogueOut = TweenService:Create(
    Dialogue,
    TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    { Size = UDim2.new(0.4, 0, 0.1, 0), BackgroundTransparency = 1 }
)
local TitleIn = TweenService:Create(
    title,
    TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    { TextTransparency = 0, TextStrokeTransparency = 0.6 }
)
local TitleOut = TweenService:Create(
    title,
    TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    { TextTransparency = 1, TextStrokeTransparency = 1.5 }
)

local slideInDialogue = TweenService:Create(
    Dialogue,
    TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    { Position = UDim2.new(0.43, 0, 0.7, 0) }
)
local slideOutDialogue = TweenService:Create(
    Dialogue,
    TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    { Position = UDim2.new(0.5, 0, 0.7, 0) }
)

--ButtonFadeIn--
local ButtonFadeIn1 = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local ButtonFadeIn2 = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

--ButtonFadeOut--
local ButtonFadeOut1 = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local ButtonFadeOut2 = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

--DialogueOut:Play()
--TitleOut:Play()

local NpcDialogueModules = {}
local ButtonData = {}

--[Init]--
for _, Module in pairs(script:GetDescendants()) do
    if Module:IsA("ModuleScript") then
        NpcDialogueModules[Module.Name] = require(Module)
    end
end

local function ButtonFadeIn(TextButton, Info)
    local ButtonFadeInTween = TweenService:Create(
        TextButton,
        ButtonFadeIn1,
        { Size = UDim2.new(0.35, 0, 0.4, 0), BackgroundTransparency = 0.6 }
    )
    local ButtonLabelInTween = TweenService:Create(TextButton.TextLabel, ButtonFadeIn2, { TextTransparency = 0 })

    ButtonFadeInTween:Play()
    ButtonLabelInTween:Play()
end

local function ButtonFadeOut(TextButton, Info)
    local ButtonFadeOutTween =
        TweenService:Create(TextButton, ButtonFadeOut1, { Size = UDim2.new(0, 0, 0.4, 0), BackgroundTransparency = 1 })
    local ButtonLabelOutTween = TweenService:Create(TextButton.TextLabel, ButtonFadeOut2, { TextTransparency = 1 })

    ButtonFadeOutTween:Play()
    ButtonLabelOutTween:Play()
end

local function ClearConnections(Connections)
    for _, Connection in ipairs(Connections) do
        Connection:Disconnect()
        Connection = nil
    end
end

for _, DialogueButton in ipairs(Dialogue:GetChildren()) do
    if DialogueButton:IsA("TextButton") then
        ButtonFadeIn(DialogueButton)
        wait()
    end
end

for _, DialogueButton in ipairs(Dialogue:GetChildren()) do
    if DialogueButton:IsA("TextButton") then
        ButtonFadeOut(DialogueButton)
        wait()
    end
end

local DialogueModule = {}
local Connections = {}

local CurrentNode = ""

function DialogueModule.Start(DialogueData)
    local Npc = DialogueData.Npc
    local NpcDialogueData = NpcDialogueModules[Npc]

    Dialogue.Visible = true
    HUD.Enabled = false

    Dialogue.Title.Text = NpcDialogueData.Title

    DialogueModule.UpdateText(NpcDialogueData, "First")

    for _, DialogueButton in ipairs(Dialogue:GetChildren()) do
        if DialogueButton:IsA("TextButton") then
            ButtonFadeIn(DialogueButton)
            wait()
        end
    end

    CurrentNode = "First"

    local BindExitConnection
    local BindDeathConnection

    local BindOption1Connection
    local BindOption2Connection

    local BindOption3Connection

    BindOption1Connection = Option1.MouseButton1Down:Connect(function()
        local ResultFunction, Output =
            NpcDialogueData[CurrentNode .. "Node"].Option1.PressedOn(Player, CurrentNode, DialogueModule)
        print(ResultFunction, Output)
        CurrentNode = Output or CurrentNode

        if Output then
            ResultFunction(NpcDialogueData, CurrentNode)
        elseif ResultFunction and not Output then
            ResultFunction()
        end
    end)

    BindOption2Connection = Option2.MouseButton1Down:Connect(function()
        local ResultFunction, Output =
            NpcDialogueData[CurrentNode .. "Node"].Option2.PressedOn(Player, CurrentNode, DialogueModule)

        CurrentNode = Output or CurrentNode

        if Output then
            ResultFunction(NpcDialogueData, CurrentNode)
        elseif ResultFunction and not Output then
            ResultFunction()
        end
    end)

    BindOption3Connection = Option3.MouseButton1Down:Connect(function()
        local ResultFunction, Output =
            NpcDialogueData[CurrentNode .. "Node"].Option3.PressedOn(Player, CurrentNode, DialogueModule)

        CurrentNode = Output or CurrentNode

        if Output then
            ResultFunction(NpcDialogueData, CurrentNode)
        elseif ResultFunction and not Output then
            ResultFunction()
        end

        --CurrentNode =
    end)
    BindExitConnection = Cancel.MouseButton1Down:Connect(function()
        ClearConnections(Connections)
        DialogueModule.End()
    end)

    BindDeathConnection = Player.Character.Humanoid.Died:Connect(function()
        ClearConnections(Connections)
        DialogueModule.End()
    end)

    Connections[#Connections + 1] = BindExitConnection
    Connections[#Connections + 1] = BindDeathConnection

    Connections[#Connections + 1] = BindOption1Connection
    Connections[#Connections + 1] = BindOption2Connection

    Connections[#Connections + 1] = BindOption3Connection
end

function DialogueModule.UpdateText(DialogueData, Node)
    local FindNode = DialogueData[Node .. "Node"] or warn("Could not find Dialogue Node")

    local NextOption1 = FindNode.Option1
    local NextOption2 = FindNode.Option2
    local NextOption3 = FindNode.Option3

    Option1.Text = ""
    Option2.Text = ""
    Option3.Text = ""

    Option1.TextLabel.Text = NextOption1.InitialText
    Option2.TextLabel.Text = NextOption2.InitialText
    Option3.TextLabel.Text = NextOption3.InitialText

    print(#Dialogue:GetChildren())
    print(#Connections)
    local RichAnimate = RichText:New(textFrame, FindNode.Text, { ContainerVerticalAlignment = "Top" }, false)
    RichAnimate:Animate(true)
end

function DialogueModule.End()
    for _, DialogueButton in ipairs(Dialogue:GetChildren()) do
        if DialogueButton:IsA("TextButton") then
            ButtonFadeOut(DialogueButton)
            wait()
        end
    end

    wait()
    slideOutDialogue:Play()

    ClearConnections(Connections)

    Dialogue.Visible = false
    HUD.Enabled = true
end

return DialogueModule
