-- SERVICES --
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

-- FOLDERS --
local Modules = RS.Modules

-- MODULES --
local debrisModule = require(Modules.Debris)

-- FUNCTIONS --
local function RoundNumber(num)
    return (math.floor(num + 0.5))
end

return function(Action, Variable2, Variable3, Variable4, Variable5)
    if Action == "AirDown" then
        local TargetPosition = Variable2
        local Character = Variable3
        debrisModule.Ground(TargetPosition, 10, Vector3.new(2, 2, 2), { workspace.Debris, Character }, 14, false, 2.5)
        debrisModule.BlockExplosion(CFrame.new(TargetPosition) * CFrame.new(0, 1, 0), 0.5, 1.5, 3, 7, false)
        debrisModule.Shockwave(TargetPosition, 3, 25)
        debrisModule.sphereExp(TargetPosition, 10, 20, Color3.fromRGB(255, 255, 255))

        local sfx = script.Sounds.Slam:Clone()
        sfx.Parent = Character.HumanoidRootPart
        sfx:Play()
        game.Debris:AddItem(sfx, 1)
    elseif Action == "HitFX" then
        local Target = Variable2
        local Type = Variable3

        if Target ~= nil then
            if Type == "Blade Hit" then
                local hitFX = script.FX["Blade Hit"].Attachment:Clone()
                hitFX.Parent = Target

                local sfx = script.Sounds.BladeHit:Clone()
                sfx.Parent = hitFX
                sfx:Play()

                coroutine.wrap(function()
                    local highlight = script.FX[Type].Highlight:Clone()
                    highlight.Parent = Target.Parent
                    TS:Create(highlight, TweenInfo.new(0.35), { OutlineTransparency = 1, FillTransparency = 1 }):Play()
                    game.Debris:AddItem(highlight, 0.35)
                end)()

                for i, v in pairs(hitFX:GetChildren()) do
                    if v:IsA("ParticleEmitter") then
                        v:Emit(v:GetAttribute("EmitCount"))
                    elseif v:IsA("PointLight") then
                        v.Brightness = 0
                        v.Range = 0
                        TS:Create(v, TweenInfo.new(0.1), { Brightness = 1, Range = 10 }):Play()
                        task.delay(0.15, function()
                            TS:Create(v, TweenInfo.new(0.1), { Brightness = 0, Range = 0 }):Play()
                        end)
                    end
                end

                game.Debris:AddItem(hitFX, 2)
            elseif Type == "Basic Hit" then
                local hitFX = script.FX["Basic Hit"].Attachment:Clone()
                hitFX.Parent = Target

                local sfx = script.Sounds.BasicHit:Clone()
                sfx.Parent = hitFX
                sfx:Play()

                coroutine.wrap(function()
                    local highlight = script.FX[Type].Highlight:Clone()
                    highlight.Parent = Target.Parent
                    TS:Create(highlight, TweenInfo.new(0.35), { OutlineTransparency = 1, FillTransparency = 1 }):Play()
                    game.Debris:AddItem(highlight, 0.35)
                end)()

                for i, v in pairs(hitFX:GetChildren()) do
                    if v:IsA("ParticleEmitter") then
                        v:Emit(v:GetAttribute("EmitCount"))
                    elseif v:IsA("PointLight") then
                        v.Brightness = 0
                        v.Range = 0
                        TS:Create(v, TweenInfo.new(0.1), { Brightness = 1, Range = 10 }):Play()
                        task.delay(0.15, function()
                            TS:Create(v, TweenInfo.new(0.1), { Brightness = 0, Range = 0 }):Play()
                        end)
                    end
                end

                game.Debris:AddItem(hitFX, 2)
            elseif Type == "Block Break" then
                local fx = script.FX["Block Break"].Attachment:Clone()
                fx.Parent = Target

                local sfx = script.Sounds.BlockBreak:Clone()
                sfx.Parent = fx
                sfx:Play()

                coroutine.wrap(function()
                    local highlight = script.FX[Type].Highlight:Clone()
                    highlight.Parent = Target.Parent
                    TS:Create(highlight, TweenInfo.new(0.35), { OutlineTransparency = 1, FillTransparency = 1 }):Play()
                    game.Debris:AddItem(highlight, 0.35)
                end)()

                for i, v in pairs(fx:GetChildren()) do
                    if v:IsA("ParticleEmitter") then
                        v:Emit(v:GetAttribute("EmitCount"))
                    elseif v:IsA("PointLight") then
                        v.Brightness = 0
                        v.Range = 0
                        TS:Create(v, TweenInfo.new(0.1), { Brightness = 1, Range = 10 }):Play()
                        task.delay(0.15, function()
                            TS:Create(v, TweenInfo.new(0.1), { Brightness = 0, Range = 0 }):Play()
                        end)
                    end
                end
            elseif Type == "Perfect Block" then
                local fx = script.FX["Perfect Block"].Attachment:Clone()
                fx.Parent = Target

                local sfx = script.Sounds.PerfectBlock1:Clone()
                sfx.Parent = fx
                sfx:Play()

                local sfx2 = script.Sounds.PerfectBlock2:Clone()
                sfx2.Parent = fx
                sfx2:Play()

                coroutine.wrap(function()
                    local highlight = script.FX[Type].Highlight:Clone()
                    highlight.Parent = Target.Parent
                    TS:Create(highlight, TweenInfo.new(0.35), { OutlineTransparency = 1, FillTransparency = 1 }):Play()
                    game.Debris:AddItem(highlight, 0.35)
                end)()

                for i, v in pairs(fx:GetChildren()) do
                    if v:IsA("ParticleEmitter") then
                        v:Emit(v:GetAttribute("EmitCount"))
                    elseif v:IsA("PointLight") then
                        v.Brightness = 0
                        v.Range = 0
                        TS:Create(v, TweenInfo.new(0.1), { Brightness = 1, Range = 10 }):Play()
                        task.delay(0.15, function()
                            TS:Create(v, TweenInfo.new(0.1), { Brightness = 0, Range = 0 }):Play()
                        end)
                    end
                end
            elseif Type == "Block Hit" then
                local fx = script.FX["Block Hit"].Attachment:Clone()
                fx.Parent = Target

                local sfx = script.Sounds.BlockHit:Clone()
                sfx.Parent = fx
                sfx:Play()

                for i, v in pairs(fx:GetChildren()) do
                    if v:IsA("ParticleEmitter") then
                        v:Emit(v:GetAttribute("EmitCount"))
                    elseif v:IsA("PointLight") then
                        v.Brightness = 0
                        v.Range = 0
                        TS:Create(v, TweenInfo.new(0.1), { Brightness = 1, Range = 10 }):Play()
                        task.delay(0.15, function()
                            TS:Create(v, TweenInfo.new(0.1), { Brightness = 0, Range = 0 }):Play()
                        end)
                    end
                end
            end
        end
    elseif Action == "Indicator" then
        local Character = Variable3
        local Damage = Variable2
        local random = Random.new()

        -- DAMAGE INDICATOR GUI --
        local gui = script.DamageIndicator:Clone()
        gui.Damage.Size = UDim2.fromScale(0, 0)
        gui.Damage.TextColor3 = Color3.fromRGB(255, 255, 255) -- TEXT COLOR
        gui.StudsOffset =
            Vector3.new(random:NextNumber(-1.5, 1.5), random:NextNumber(-1, 1), random:NextNumber(-0.5, 0.5)) -- RANDOM POS
        gui.Damage.Text = tostring(RoundNumber(Damage))
        gui.Parent = workspace.Debris
        gui.Adornee = Character.HumanoidRootPart

        -- TWEENS --
        gui.Damage:TweenSize(UDim2.fromScale(0.9, 0.9), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.1, true)
        task.delay(0.1, function()
            gui.Damage:TweenSize(
                UDim2.fromScale(0.75, 0.75),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.1,
                true
            )
            task.delay(0.75, function()
                gui.Damage:TweenSize(UDim2.fromScale(0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.2, true)
                game.Debris:AddItem(gui, 0.2)
            end)
        end)
    elseif Action == "SlashFX" then
        local Character = Variable3
        local SlashMesh = script.FX.SlashMesh:Clone()

        local textures = { -- Slash
            "rbxassetid://8821193347", --1
            "rbxassetid://8821230983", --2
            "rbxassetid://8821246947", --3
            "rbxassetid://8821254467", --4
            "rbxassetid://8821272181", --5
            "rbxassetid://8821280832", --6
            "rbxassetid://8821300395", --7
            "rbxassetid://8821311218", --8
            "rbxassetid://8896641723", --9
        }

        local hrp = Character.HumanoidRootPart
        local CFs = Variable4
        local slashColor = Variable5

        SlashMesh.Mesh.VertexColor = slashColor

        --{
        --	hrp.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(30), math.rad(180)),
        --	hrp.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(30), math.rad(0)),
        --	hrp.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(30), math.rad(180)),
        --	hrp.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(30), math.rad(180)),
        --	hrp.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(0), math.rad(-70)),
        --	hrp.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(0), math.rad(110)),
        --	hrp.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(0), math.rad(-70)),
        --}

        local function slashSpritesheet()
            local count = 1

            local connection
            connection = game["Run Service"].RenderStepped:Connect(function()
                SlashMesh.Mesh.TextureId = textures[count]
                count = count + 1
                if count > #textures then
                    count = 1
                    SlashMesh:Destroy()
                    connection:Disconnect()
                end
            end)

            SlashMesh.Parent = workspace.Debris
            TS:Create(
                SlashMesh,
                TweenInfo.new(0.5),
                { CFrame = SlashMesh.CFrame * CFrame.Angles(0, math.rad(-100), 0), Transparency = 1 }
            ):Play()
            TS:Create(SlashMesh.PointLight, TweenInfo.new(0.5), { Brightness = 0 }):Play()
        end

        local currentCombo = Variable2

        SlashMesh.CFrame = CFs[currentCombo]
        slashSpritesheet()
    elseif Action == "UI" then
        local combatState = Variable2
        local combatDuration = Variable3
        local UI = game.Players.LocalPlayer.PlayerGui.Combat

        if combatState == true then
            UI.Enabled = true
            UI.TimeRemaining.Text = tostring(combatDuration) .. "s"
        else
            UI.Enabled = false
        end
    elseif Action == "BladeTrail" then
        local Sword = Variable2
        local Toggle = Variable3
        local Trail = Sword.Handle:FindFirstChild("TrailFX")
        if Trail then
            if Toggle == true then
                Trail.Enabled = true
            else
                --task.delay(Trail.Lifetime, function()
                Trail.Enabled = false
                --end)
            end
        end
    end
end
