-- SERVICES --
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TS = game:GetService("TweenService")

-- FOLDERS --
local Remotes = RS:WaitForChild("Remotes")
local Modules = RS:WaitForChild("Modules")

-- MAIN VARIABLES --
local currentTotalDamage = 0
local currentHitCount = 0
local inCD = false

local Player = Players.LocalPlayer

local function FadeOut(gui, value)
    task.delay(3, function()
        if value == currentHitCount then
            gui.Frame:TweenSize(UDim2.fromScale(0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.3, true)
            currentHitCount = 0
            currentTotalDamage = 0
        end
    end)
end

local function round(n)
    return math.floor(n + 0.5)
end

return function(Damage)
    currentHitCount += 1
    currentTotalDamage += Damage
    local spinner
    if not Player.PlayerGui:FindFirstChild("HitIndicator") then
        local hitIndicator = script.HitIndicator:Clone()
        hitIndicator.Parent = Player.PlayerGui
        hitIndicator.Frame.Size = UDim2.fromScale(0, 0)
        hitIndicator.Frame:TweenSize(
            UDim2.fromScale(0.101, 0.122),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Back,
            0.2,
            true
        )

        hitIndicator.Frame.Hits.Text = currentHitCount .. " HITS!"
        hitIndicator.Frame.Hits:TweenSize(
            UDim2.fromScale(0.813 * 1.1, 0.339 * 1.1),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Back,
            0.06,
            true
        )
        task.delay(0.06, function()
            if hitIndicator.Frame.Hits.Size == UDim2.fromScale(0.813 * 1.1, 0.339 * 1.1) then
                hitIndicator.Frame.Hits:TweenSize(
                    UDim2.fromScale(0.813, 0.339),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Back,
                    0.06,
                    true
                )
            end
        end)

        hitIndicator.Frame.Damage.Text = round(currentTotalDamage)

        --spinner = numberSpinner.fromGuiObject(hitIndicator.Frame.Damage)
        --spinner.Prefix = ""
        --spinner.Decimals = 0
        --spinner.Value = currentTotalDamage

        hitIndicator.Frame.Damage:TweenSize(
            UDim2.fromScale(0.813 * 1.1, 0.339 * 1.1),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Back,
            0.06,
            true
        )
        task.delay(0.06, function()
            if hitIndicator.Frame.Damage.Size == UDim2.fromScale(0.813 * 1.1, 0.339 * 1.1) then
                hitIndicator.Frame.Damage:TweenSize(
                    UDim2.fromScale(0.813, 0.339),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Back,
                    0.06,
                    true
                )
            end
        end)

        FadeOut(hitIndicator, currentHitCount)
    else
        local hitIndicator = Player.PlayerGui.HitIndicator
        hitIndicator.Frame:TweenSize(
            UDim2.fromScale(0.101, 0.122),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Back,
            0.2,
            true
        )
        hitIndicator.Frame.Hits.Text = currentHitCount .. " HITS!"
        hitIndicator.Frame.Hits:TweenSize(
            UDim2.fromScale(0.813 * 1.1, 0.339 * 1.1),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Back,
            0.06,
            true
        )
        task.delay(0.06, function()
            if hitIndicator.Frame.Hits.Size == UDim2.fromScale(0.813 * 1.1, 0.339 * 1.1) then
                hitIndicator.Frame.Hits:TweenSize(
                    UDim2.fromScale(0.813, 0.339),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Back,
                    0.06,
                    true
                )
            end
        end)

        hitIndicator.Frame.Damage.Text = round(currentTotalDamage)
        --spinner.Value = currentTotalDamage
        hitIndicator.Frame.Damage:TweenSize(
            UDim2.fromScale(0.813 * 1.1, 0.339 * 1.1),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Back,
            0.06,
            true
        )
        task.delay(0.06, function()
            if hitIndicator.Frame.Damage.Size == UDim2.fromScale(0.813 * 1.1, 0.339 * 1.1) then
                hitIndicator.Frame.Damage:TweenSize(
                    UDim2.fromScale(0.813, 0.339),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Back,
                    0.06,
                    true
                )
            end
        end)

        FadeOut(hitIndicator, currentHitCount)
    end
end
