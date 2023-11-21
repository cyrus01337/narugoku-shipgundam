local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

return function(data)
    local model = Instance.new("Model", workspace.World.Visuals)
    for i = 1, data.points do
        local Angle = ((2 * math.pi) / data.points) * i
        local x = math.cos(Angle) * data.radius
        local z = math.sin(Angle) * data.radius
        local determinedPos = data.position + Vector3.new(x, 0, z)
        local tween, moving = nil, true

        local Part = Instance.new("Part")
        Part.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
        Part.Anchored = true
        Part.Size = Vector3.new(data.size, data.size, data.size)
            + Vector3.new(math.random(10, 40) / 100, math.random(10, 40) / 100, math.random(10, 40) / 100)
        Part.CanCollide = false

        if data.movement then
            Part.Position = data.position
            tween = tweenService:Create(
                Part,
                TweenInfo.new(data.speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Position = determinedPos }
            )
            tween:Play()
            local connection
            connection = tween.Completed:connect(function()
                moving = false
                connection:Disconnect()
                connection = nil
            end)
            coroutine.wrap(function()
                while moving do
                    local rayCheck = GlobalFunctions.CastRay(
                        Part.Position + Vector3.new(0, data.size, 0),
                        Vector3.new(0, -10, 0),
                        data.Exclude
                    )
                    if rayCheck then
                        Part.Material = rayCheck.Instance.Material
                        Part.Color = rayCheck.Instance.Color
                    end
                    runService.Heartbeat:wait()
                end
            end)()
        else
            local rayCheck = GlobalFunctions.CastRay(
                Part.Position + Vector3.new(0, data.size, 0),
                Vector3.new(0, -10, 0),
                data.Exclude
            )
            if rayCheck then
                Part.Material = rayCheck.Instance.Material
                Part.Color = rayCheck.Instance.Color
            end
            Part.Position = determinedPos
        end

        Part.Parent = model
        coroutine.wrap(function()
            if tween then
                tween.Completed:wait()
            end

            if data.yield then
                wait(data.yield)
            end

            if not data.domino then
                tween = tweenService:Create(
                    Part,
                    TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    {
                        Size = Vector3.new(0, 0, 0),
                        Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90)),
                    }
                )
                tween:Play()
                game.Debris:AddItem(Part, 1)
            end
        end)()
    end

    coroutine.wrap(function()
        if data.domino then
            for i, v in ipairs(model:GetChildren()) do
                tweenService
                    :Create(
                        v,
                        TweenInfo.new(data.clearSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                        {
                            Size = Vector3.new(0, 0, 0),
                            Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90)),
                        }
                    )
                    :Play()
                game.Debris:AddItem(v, data.clearSpeed)
                wait(data.clearSpeed)
            end
        end
        model:Destroy()
    end)()
end
