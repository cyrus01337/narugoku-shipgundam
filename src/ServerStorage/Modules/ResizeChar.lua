--|| Services ||--
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

--|| Modules||--

--|| Variables ||--
return function(Player, Size)
    local Character = Player.Character
    if Character then
        local function Scale(Character, Scale)
            for _, v in ipairs(Character:GetChildren()) do
                if v:IsA("Hat") or v:IsA("Accessory") then
                    v:Clone()
                    v.Parent = Lighting
                end
            end

            local Head = Character["Head"]
            local Torso = Character["Torso"]
            local LA = Character["Left Arm"]
            local RA = Character["Right Arm"]
            local LL = Character["Left Leg"]
            local RL = Character["Right Leg"]
            local HRP = Character["HumanoidRootPart"]

            wait(0.1)

            Head.formFactor = 3
            Torso.formFactor = 3
            LA.formFactor = 3
            RA.formFactor = 3
            LL.formFactor = 3
            RL.formFactor = 3
            HRP.formFactor = 3

            Head.Size = Vector3.new(Scale * 2, Scale, Scale)
            Torso.Size = Vector3.new(Scale * 2, Scale * 2, Scale)
            LA.Size = Vector3.new(Scale, Scale * 2, Scale)
            RA.Size = Vector3.new(Scale, Scale * 2, Scale)
            LL.Size = Vector3.new(Scale, Scale * 2, Scale)
            RL.Size = Vector3.new(Scale, Scale * 2, Scale)
            HRP.Size = Vector3.new(Scale * 2, Scale * 2, Scale)

            local Motor1 = Instance.new("Motor6D", Torso)
            Motor1.Part0 = Torso
            Motor1.Part1 = Head
            Motor1.C0 = CFrame.new(0, 1 * Scale, 0) * CFrame.Angles(-1.6, 0, 3.1)
            Motor1.C1 = CFrame.new(0, -0.5 * Scale, 0) * CFrame.Angles(-1.6, 0, 3.1)
            Motor1.Name = "Neck"

            local Motor2 = Instance.new("Motor6D", Torso)
            Motor2.Part0 = Torso
            Motor2.Part1 = LA
            Motor2.C0 = CFrame.new(-1 * Scale, 0.5 * Scale, 0) * CFrame.Angles(0, -1.6, 0)
            Motor2.C1 = CFrame.new(0.5 * Scale, 0.5 * Scale, 0) * CFrame.Angles(0, -1.6, 0)
            Motor2.Name = "Left Shoulder"

            local Motor3 = Instance.new("Motor6D", Torso)
            Motor3.Part0 = Torso
            Motor3.Part1 = RA
            Motor3.C0 = CFrame.new(1 * Scale, 0.5 * Scale, 0) * CFrame.Angles(0, 1.6, 0)
            Motor3.C1 = CFrame.new(-0.5 * Scale, 0.5 * Scale, 0) * CFrame.Angles(0, 1.6, 0)
            Motor3.Name = "Right Shoulder"

            local Motor4 = Instance.new("Motor6D", Torso)
            Motor4.Part0 = Torso
            Motor4.Part1 = LL
            Motor4.C0 = CFrame.new(-1 * Scale, -1 * Scale, 0) * CFrame.Angles(0, -1.6, 0)
            Motor4.C1 = CFrame.new(-0.5 * Scale, 1 * Scale, 0) * CFrame.Angles(0, -1.6, 0)
            Motor4.Name = "Left Hip"

            local Motor5 = Instance.new("Motor6D", Torso)
            Motor5.Part0 = Torso
            Motor5.Part1 = RL
            Motor5.C0 = CFrame.new(1 * Scale, -1 * Scale, 0) * CFrame.Angles(0, 1.6, 0)
            Motor5.C1 = CFrame.new(0.5 * Scale, 1 * Scale, 0) * CFrame.Angles(0, 1.6, 0)
            Motor5.Name = "Right Hip"

            local Motor6 = Instance.new("Motor6D")
            Motor6.Part0 = HRP
            Motor6.Part1 = Torso
            Motor6.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(-1.6, 0, -3.1)
            Motor6.C1 = CFrame.new(0, 0, 0) * CFrame.Angles(-1.6, 0, -3.1)
            Motor6.Parent = HRP
        end

        Scale(Character, Size)

        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Hat") or v:IsA("Accoutrement") then
                v.Parent = Character
            end
        end
    end
end
