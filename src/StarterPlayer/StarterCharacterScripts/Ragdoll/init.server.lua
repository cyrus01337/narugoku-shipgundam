local Debris = game:GetService("Debris")

wait()
if script.Parent.Humanoid.RigType ~= Enum.HumanoidRigType.R6 then
    Debris:AddItem(script, 1)
else
    wait()
    function getAttachment0(attachmentName)
        for _, child in next, script.Parent:GetChildren() do
            local attachment = child:FindFirstChild(attachmentName)
            if attachment then
                return attachment
            end
        end
    end
    script.Parent.Humanoid.Died:Connect(function(var)
        local removeHRP = true
        local head = script.Parent["Head"]
        local leftarm = script.Parent["Left Arm"]
        local leftleg = script.Parent["Left Leg"]
        local rightleg = script.Parent["Right Leg"]
        local rightarm = script.Parent["Right Arm"]
        local torso = script.Parent.Torso
        local root = script.Parent.HumanoidRootPart
        local camera = workspace.CurrentCamera
        if camera.CameraSubject == script.Parent.Humanoid then
            camera.CameraSubject = script.Parent.Torso
        end
        if removeHRP == true then
            root:Destroy()
        end
        local impactH = script.ImpactSound:Clone()
        impactH.Parent = head
        impactH.Disabled = false
        local impactLA = script.ImpactSound:Clone()
        impactLA.Parent = leftarm
        impactLA.Disabled = false
        local impactRA = script.ImpactSound:Clone()
        impactRA.Parent = rightarm
        impactRA.Disabled = false
        local rootA = Instance.new("Attachment")
        local HeadA = Instance.new("Attachment")
        local LeftArmA = Instance.new("Attachment")
        local LeftLegA = Instance.new("Attachment")
        local RightArmA = Instance.new("Attachment")
        local RightLegA = Instance.new("Attachment")
        local TorsoA = Instance.new("Attachment")
        local TorsoA1 = Instance.new("Attachment")
        local TorsoA2 = Instance.new("Attachment")
        local TorsoA3 = Instance.new("Attachment")
        local TorsoA4 = Instance.new("Attachment")
        local TorsoA5 = Instance.new("Attachment")
        function set1()
            HeadA.Name = "HeadA"
            HeadA.Parent = head
            HeadA.Position = Vector3.new(0, -0.5, 0)
            HeadA.Rotation = Vector3.new(0, 0, 0)
            HeadA.Axis = Vector3.new(1, 0, 0)
            HeadA.SecondaryAxis = Vector3.new(0, 1, 0)
            LeftArmA.Name = "LeftArmA"
            LeftArmA.Parent = leftarm
            LeftArmA.Position = Vector3.new(0.5, 1, 0)
            LeftArmA.Rotation = Vector3.new(0, 0, 0)
            LeftArmA.Axis = Vector3.new(1, 0, 0)
            LeftArmA.SecondaryAxis = Vector3.new(0, 1, 0)
            LeftLegA.Name = "LeftLegA"
            LeftLegA.Parent = leftleg
            LeftLegA.Position = Vector3.new(0, 1, 0)
            LeftLegA.Rotation = Vector3.new(0, 0, 0)
            LeftLegA.Axis = Vector3.new(1, 0, 0)
            LeftLegA.SecondaryAxis = Vector3.new(0, 1, 0)
            RightArmA.Name = "RightArmA"
            RightArmA.Parent = rightarm
            RightArmA.Position = Vector3.new(-0.5, 1, 0)
            RightArmA.Rotation = Vector3.new(0, 0, 0)
            RightArmA.Axis = Vector3.new(1, 0, 0)
            RightArmA.SecondaryAxis = Vector3.new(0, 1, 0)
            RightLegA.Name = "RightLegA"
            RightLegA.Parent = rightleg
            RightLegA.Position = Vector3.new(0, 1, 0)
            RightLegA.Rotation = Vector3.new(0, 0, 0)
            RightLegA.Axis = Vector3.new(1, 0, 0)
            RightLegA.SecondaryAxis = Vector3.new(0, 1, 0)
            rootA.Name = "rootA"
            rootA.Parent = root
            rootA.Position = Vector3.new(0, 0, 0)
            rootA.Rotation = Vector3.new(0, 90, 0)
            rootA.Axis = Vector3.new(0, 0, -1)
            rootA.SecondaryAxis = Vector3.new(0, 1, 0)
        end
        function set2()
            TorsoA.Name = "TorsoA"
            TorsoA.Parent = torso
            TorsoA.Position = Vector3.new(0.5, -1, 0)
            TorsoA.Rotation = Vector3.new(0, 0, 0)
            TorsoA.Axis = Vector3.new(1, 0, 0)
            TorsoA.SecondaryAxis = Vector3.new(0, 1, 0)
            TorsoA1.Name = "TorsoA1"
            TorsoA1.Parent = torso
            TorsoA1.Position = Vector3.new(-0.5, -1, 0)
            TorsoA1.Rotation = Vector3.new(0, 0, 0)
            TorsoA1.Axis = Vector3.new(1, 0, 0)
            TorsoA1.SecondaryAxis = Vector3.new(0, 1, 0)
            TorsoA2.Name = "TorsoA2"
            TorsoA2.Parent = torso
            TorsoA2.Position = Vector3.new(-1, 1, 0)
            TorsoA2.Rotation = Vector3.new(0, 0, 0)
            TorsoA2.Axis = Vector3.new(1, 0, 0)
            TorsoA2.SecondaryAxis = Vector3.new(0, 1, 0)
            TorsoA3.Name = "TorsoA3"
            TorsoA3.Parent = torso
            TorsoA3.Position = Vector3.new(1, 1, 0)
            TorsoA3.Rotation = Vector3.new(0, 0, 0)
            TorsoA3.Axis = Vector3.new(1, 0, 0)
            TorsoA3.SecondaryAxis = Vector3.new(0, 1, 0)
            TorsoA4.Name = "TorsoA4"
            TorsoA4.Parent = torso
            TorsoA4.Position = Vector3.new(0, 1, 0)
            TorsoA4.Rotation = Vector3.new(0, 0, 0)
            TorsoA4.Axis = Vector3.new(1, 0, 0)
            TorsoA4.SecondaryAxis = Vector3.new(0, 1, 0)
            TorsoA5.Name = "TorsoA5"
            TorsoA5.Parent = torso
            TorsoA5.Position = Vector3.new(0, 0, 0)
            TorsoA5.Rotation = Vector3.new(0, 90, 0)
            TorsoA5.Axis = Vector3.new(0, 0, -1)
            TorsoA5.SecondaryAxis = Vector3.new(0, 1, 0)
        end
        function set3() end
        task.spawn(set1)
        task.spawn(set2)
        local HA = Instance.new("HingeConstraint")
        HA.Parent = head
        HA.Attachment0 = HeadA
        HA.Attachment1 = TorsoA4
        HA.Enabled = true
        HA.LimitsEnabled = true
        HA.LowerAngle = 0
        HA.UpperAngle = 0
        local LAT = Instance.new("BallSocketConstraint")
        LAT.Parent = leftarm
        LAT.Attachment0 = LeftArmA
        LAT.Attachment1 = TorsoA2
        LAT.Enabled = true
        LAT.LimitsEnabled = true
        LAT.UpperAngle = 90
        local RAT = Instance.new("BallSocketConstraint")
        RAT.Parent = rightarm
        RAT.Attachment0 = RightArmA
        RAT.Attachment1 = TorsoA3
        RAT.Enabled = true
        RAT.LimitsEnabled = true
        RAT.UpperAngle = 90
        local HA = Instance.new("BallSocketConstraint")
        HA.Parent = head
        HA.Attachment0 = HeadA
        HA.Attachment1 = TorsoA4
        HA.Enabled = true
        local TLL = Instance.new("BallSocketConstraint")
        TLL.Parent = torso
        TLL.Attachment0 = TorsoA1
        TLL.Attachment1 = LeftLegA
        TLL.Enabled = true
        TLL.LimitsEnabled = true
        TLL.UpperAngle = 90
        local TRL = Instance.new("BallSocketConstraint")
        TRL.Parent = torso
        TRL.Attachment0 = TorsoA
        TRL.Attachment1 = RightLegA
        TRL.Enabled = true
        TRL.LimitsEnabled = true
        TRL.UpperAngle = 90
        local RTA = Instance.new("BallSocketConstraint")
        RTA.Parent = root
        RTA.Attachment0 = rootA
        RTA.Attachment1 = TorsoA5
        RTA.Enabled = true
        RTA.LimitsEnabled = true
        RTA.UpperAngle = 0
        head.Velocity = head.CFrame.lookVector * 30

        for _, child in next, script.Parent:GetChildren() do
            if child:IsA("Accoutrement") then
                for _, part in next, child:GetChildren() do
                    if part:IsA("BasePart") then
                        part.Parent = script.Parent
                        child:remove()
                        local attachment1 = part:FindFirstChildOfClass("Attachment")
                        local attachment0 = getAttachment0(attachment1.Name)
                        if attachment0 and attachment1 then
                            local constraint = Instance.new("HingeConstraint")
                            constraint.Attachment0 = attachment0
                            constraint.Attachment1 = attachment1
                            constraint.LimitsEnabled = true
                            constraint.UpperAngle = 0
                            constraint.LowerAngle = 0
                            constraint.Parent = script.Parent
                        end
                    end
                end
            end
        end
    end)
end
