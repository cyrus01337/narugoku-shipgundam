-- SERVICES --
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")

-- FOLDERS --
local Modules = RS.Modules
local debrisFolder = workspace.Debris

-- MODULES --
local bezierTween = require(Modules.BezierTweens)
local Waypoints = bezierTween.Waypoints
local partCacheMod = require(Modules.PartCache)

-- CACHE --
local cacheFolder
if debrisFolder:FindFirstChild("Mochi") then
    cacheFolder = debrisFolder.Mochi
else
    cacheFolder = Instance.new("Folder")
    cacheFolder.Name = "Mochi"
    cacheFolder.Parent = debrisFolder
end

local partCache = partCacheMod.new(RS.FX.Mochi.MochiBall, 300, cacheFolder)

local function mochiExplosion(OriginPosition, OriginInstance)
    local amount = math.random(1, 2)

    local hitSFX = {
        RS.Sounds.Mochi.MochiFistHit1,
        RS.Sounds.Mochi.MochiFistHit2,
    }

    for sounds, sfx in pairs(hitSFX) do
        local clonedSFX = sfx:Clone()
        clonedSFX.Parent = OriginInstance
        clonedSFX:Play()
        game.Debris:AddItem(clonedSFX, 2)
    end

    for i = 1, amount do
        local mochiSize = Random.new():NextNumber(1, 3)
        local mochiPart = partCache:GetPart() --RS.FX.MochiDrip:Clone()
        mochiPart.Size = Vector3.new(mochiSize, mochiSize, mochiSize)
        mochiPart.CFrame = CFrame.new(OriginPosition)

        local rayCheck = CFrame.new(OriginPosition)
            * CFrame.new(Random.new():NextNumber(-30, 30), 15, Random.new():NextNumber(-30, 30))

        local RayParam = RaycastParams.new()
        RayParam.FilterType = Enum.RaycastFilterType.Exclude
        RayParam.FilterDescendantsInstances = { mochiPart, debrisFolder }

        local RaycastResult = workspace:Raycast(rayCheck.Position, Vector3.yAxis * 50, RayParam) or {}

        local Rhit, Rvec2Pos, RsurfaceNormal = RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal

        local maxHeight

        local origin
        local direction = Vector3.yAxis * -1000

        if Rhit then
            maxHeight = (OriginPosition.Y - Rhit.Position.Y)
            origin = Vector3.new(rayCheck.Position.X, maxHeight - 1, rayCheck.Position.Z)
        else
            maxHeight = 50
            origin = rayCheck.Position
        end

        local RayParam = RaycastParams.new()
        RayParam.FilterType = Enum.RaycastFilterType.Exclude
        RayParam.FilterDescendantsInstances = { mochiPart, debrisFolder }

        local RaycastResult = workspace:Raycast(origin, direction, RayParam) or {}

        local hit, vec2Pos, surfaceNormal = RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal

        if hit then
            local endCF = CFrame.new(vec2Pos, vec2Pos + surfaceNormal) * CFrame.Angles(-math.pi / 2, 0, 0)
            local p0 = mochiPart.Position
            local p2 = endCF.Position
            local p1 = CFrame.new((p0 + p2) / 2)
                * CFrame.new(0, Random.new():NextNumber(maxHeight * 0.25, maxHeight), 0).Position

            local distance = (p0 - p2).Magnitude
            local speed = 40

            local poolSize = Random.new():NextNumber(2, 4)

            mochiPart.Parent = debrisFolder

            local Tween = bezierTween.Create(mochiPart, {
                Waypoints = Waypoints.new(p0, p1, p2),
                EasingStyle = Enum.EasingStyle.Linear,
                EasingDirection = Enum.EasingDirection.In,
                Time = distance / speed,
            })

            Tween:Play()
            TS:Create(
                mochiPart,
                TweenInfo.new(distance / speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                { Color = Color3.fromRGB(255, 246, 208) }
            ):Play()

            Tween.Completed:Connect(function()
                mochiPart.CFrame = CFrame.new(vec2Pos, vec2Pos + surfaceNormal) * CFrame.Angles(-math.pi / 2, 0, 0)
                TS:Create(
                    mochiPart,
                    TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Size = Vector3.new(poolSize * 2, 0.5, poolSize * 2) }
                ):Play()
                task.delay(5, function()
                    TS:Create(
                        mochiPart,
                        TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                        { Size = Vector3.new(0, 0, 0) }
                    ):Play()
                    --game.Debris:AddItem(mochiPart, .7)
                    task.delay(0.7, function()
                        partCache:ReturnPart(mochiPart)
                    end)
                end)
            end)
        else
            partCache:ReturnPart(mochiPart)
        end
    end
end

return function(HitboxPos, Character)
    local HRP = Character.HumanoidRootPart
    local mochiSize = Random.new():NextNumber(1, 2)
    local mochiPart = partCache:GetPart()
    mochiPart.Size = Vector3.new(mochiSize, mochiSize, mochiSize)

    local ray = Ray.new(HitboxPos + Vector3.new(0, 1, 0), Vector3.new(0, -50, 0))
    local hit, vec2Pos, surfaceNormal =
        workspace:FindPartOnRayWithIgnoreList(ray, { mochiPart, debrisFolder, Character })
    local angle = math.rad(math.random(360))

    if hit then
        local endCF = CFrame.new(vec2Pos, vec2Pos + surfaceNormal)
            * CFrame.Angles(-math.pi / 2, 0, 0)
            * CFrame.Angles(0, angle, 0)
        local p0 = HRP.Position
        local p2 = endCF.Position
        local p1 = CFrame.new((p0 + p2) / 2) * CFrame.new(0, Random.new():NextNumber(25, 45), 0).Position

        local distance = (p0 - p2).Magnitude
        local speed = 100

        local poolSize = Random.new():NextNumber(8, 14)

        mochiPart.Parent = debrisFolder

        local Tween = bezierTween.Create(mochiPart, {
            Waypoints = Waypoints.new(p0, p1, p2),
            EasingStyle = Enum.EasingStyle.Linear,
            EasingDirection = Enum.EasingDirection.In,
            Time = distance / speed,
        })

        Tween:Play()
        TS:Create(
            mochiPart,
            TweenInfo.new(distance / speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            { Color = Color3.fromRGB(255, 246, 208) }
        ):Play()

        Tween.Completed:Connect(function()
            mochiPart.CFrame = CFrame.new(vec2Pos, vec2Pos + surfaceNormal)
                * CFrame.Angles(-math.pi / 2, 0, 0)
                * CFrame.Angles(0, angle, 0)
            --mochiPart.Transparency = 1

            local mochiFloor = RS.FX.Mochi.C.MochiCFloor:Clone()
            mochiFloor.Size = Vector3.new(0, 1, 0)
            mochiFloor.CFrame = mochiPart.CFrame

            partCache:ReturnPart(mochiPart)

            mochiFloor.Parent = debrisFolder

            TS:Create(
                mochiFloor,
                TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                { Size = Vector3.new(poolSize * 2, 1.5, poolSize * 2) }
            ):Play()

            local spikes = {
                RS.FX.Mochi.C.Spike1,
                RS.FX.Mochi.C.Spike2,
                RS.FX.Mochi.C.Spike3,
            }

            local mochiSpike = spikes[math.random(1, #spikes)]:Clone()
            mochiSpike.CFrame = mochiFloor.CFrame

            task.delay(0.7, function()
                mochiSpike.Size = Vector3.new(mochiFloor.Size.X * 0.45, 0.01, mochiFloor.Size.Z * 0.5)
                mochiSpike.Parent = debrisFolder
                local spikeHeight = Random.new():NextNumber(20, 35)
                --print(spikeHeight)
                TS
                    :Create(
                        mochiSpike,
                        TweenInfo.new(0.17, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                        {
                            Size = Vector3.new(mochiSpike.Size.X, spikeHeight, mochiSpike.Size.Z),
                            CFrame = CFrame.new(vec2Pos, vec2Pos + surfaceNormal)
                                * CFrame.Angles(-math.pi / 2, 0, 0)
                                * CFrame.new(0, spikeHeight / 2 - 2, 0)
                                * CFrame.Angles(0, angle, 0),
                        }
                    )
                    :Play()

                mochiExplosion(mochiSpike.Position, mochiSpike)
                for i, v in pairs(mochiFloor.ExpFX:GetChildren()) do
                    v:Emit(v:GetAttribute("EmitCount"))
                end

                task.delay(1, function()
                    --warn(mochiSpike.Size)
                    TS:Create(
                        mochiSpike,
                        TweenInfo.new(5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                        {
                            Size = mochiSpike.Size * 0.98,
                            CFrame = CFrame.new(vec2Pos, vec2Pos + surfaceNormal)
                                * CFrame.Angles(-math.pi / 2, 0, 0)
                                * CFrame.new(0, (mochiSpike.Size.Y * 0.98) / 2 - 3, 0),
                        }
                    ):Play()
                    task.delay(3, function()
                        TS
                            :Create(
                                mochiSpike,
                                TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                                {
                                    Size = Vector3.new(poolSize * 2, 0.3, poolSize * 2),
                                    CFrame = CFrame.new(vec2Pos, vec2Pos + surfaceNormal)
                                        * CFrame.Angles(-math.pi / 2, 0, 0),
                                }
                            )
                            :Play()
                        task.delay(0.45, function()
                            TS
                                :Create(
                                    mochiSpike,
                                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                                    { Size = Vector3.new() }
                                )
                                :Play()
                            game.Debris:AddItem(mochiSpike, 0.6)
                        end)
                    end)
                end)
            end)

            task.delay(6, function()
                TS:Create(
                    mochiFloor,
                    TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Size = Vector3.new(0, 0, 0) }
                ):Play()
                game.Debris:AddItem(mochiFloor, 0.7)
            end)
        end)
    end
end
