local Players = game:GetService("Players")

local CAMERA_DISTANCE = 2

local player = Players.LocalPlayer
local character: Model
local viewportFrame = script.Parent

local viewportCamera = Instance.new("Camera")
viewportCamera.CFrame = CFrame.new()
viewportFrame.CurrentCamera = viewportCamera
viewportCamera.Parent = viewportFrame

local function clearViewport()
    for _, v in viewportFrame:GetChildren() do
        if v:IsA("Model") then
            v:Destroy()
        end
    end
end

local function setupCharacterPreview(newCharacter: Model)
    clearViewport()

    character = newCharacter
    task.wait(1) -- wait for character descendants to load
    character.Archivable = true

    local characterClone = character:Clone()
    local head = characterClone:WaitForChild("Head", 1)

    if not head then
        return
    end

    characterClone:PivotTo(CFrame.new(0, 0, CAMERA_DISTANCE))
    viewportCamera.CFrame = CFrame.new(Vector3.new(0, head.Position.Y, 0), head.Position)
    characterClone.Parent = viewportFrame
end

player.CharacterAdded:Connect(setupCharacterPreview)

if player.Character then
    setupCharacterPreview(player.Character)
end
