--|| SERVICES ||--
local RunService = game:GetService("RunService")

--|| MODULES ||--
local RayService = require(script.RayService)
local NetworkStream = require(script.Parent.Parent.Utility.NetworkStream)

local HitboxService = {}

local function GetPositionFromCFrame(Point)
    if typeof(Point) == "CFrame" then
        return Point.Position
    elseif typeof(Point) == "Vector3" then
        return Point
    end
end

function HitboxService:GetEntitiesFromPoint(Point, List, IgnoreList, Range, Environment)
    Point = GetPositionFromCFrame(Point)
    local Entities = {}
    for _, Entity in next, List do
        if Entity:IsA("Model") and Entity.PrimaryPart and not IgnoreList[Entity] then
            local Distance = (Point - Entity.PrimaryPart.Position).Magnitude
            if Distance <= Range then
                if Environment then
                    local Result =
                        RayService:Cast(Point, Entity.PrimaryPart.Position, IgnoreList, Enum.RaycastFilterType.Exclude)
                    if not Result or Result.Instance:IsDescendantOf(Entity) then
                        Entities[#Entities + 1] = Entity
                    end
                else
                    Entities[#Entities + 1] = Entity
                end
            end
        end
    end
    return Entities
end

function HitboxService:GetRadialPoints(CF, points, distance)
    local list = {}
    for i = 1, points do
        local degree = ((2 * math.pi) / points) * i
        local z = math.sin(degree) * distance
        local x = math.cos(degree) * distance
        local cf = CF * CFrame.new(x, 0, z)
        list[i] = cf
    end
    return list
end

function HitboxService:GetSquarePoints(CF, x, y)
    local hSizex, hSizey = 2, 2
    local splitx, splity = 1 + math.floor(x / hSizex), 1 + math.floor(y / hSizey)
    local studPerPointX = x / splitx
    local studPerPointY = y / splity

    --> A table and starting cframe
    local startCFrame = CF * CFrame.new(-x / 2 - studPerPointX / 2, -y / 2 - studPerPointY / 2, 0)
    local points = { CF }

    for x = 1, splitx do
        for y = 1, splity do
            points[#points + 1] = startCFrame * CFrame.new(studPerPointX * x, studPerPointY * y, 0)
        end
    end
    return points
end

function HitboxService:CastProjectileHitbox(Data)
    --[[
	Example Call
	
		
		HitboxService:CastProjectileHitbox({ -- Everything is required
			Points = {}, -- Array Of CFrames
			Direction = Vector3.new(), -- Direction
			Velocity = 10, -- Velocity Of Projectile
			Lifetime = 1, -- Total Duration 
			Iterations = 1, -- Amount of times it's splitted,
			Visualize = true, -- Visualizes the hitbox using RayService
			Function = function(RaycastResult) -- Callback

			end,
			Ignore = {} -- Array Of Objects To be Ignored
		})


	]]

    --| Data
    local Points = Data.Points
    local Direction = Data.Direction
    local Velocity = Data.Velocity
    local Lifetime = Data.Lifetime
    local Iterations = Data.Iterations
    local Visualize = Data.Visualize
    local BreakOnHit = Data.BreakOnHit or true

    local Function = Data.Function or function()
        warn("There was no function provided for projectile hitbox")
    end
    local Ignore = Data.Ignore or {}

    local Start = os.clock()

    coroutine.resume(coroutine.create(function()
        local LastCast = nil
        local Interception = false
        local CastInterval = Lifetime / Iterations
        while os.clock() - Start < Lifetime and ((BreakOnHit and not Interception) or not BreakOnHit) do
            local Delta = LastCast and os.clock() - LastCast or CastInterval
            if not LastCast or Delta >= CastInterval then
                local Distance = Velocity * Delta
                LastCast = os.clock()

                for Index, Point in next, Points do
                    local StartPosition = Point.Position
                    local EndPosition = Point.Position + Direction * Distance
                    local Result =
                        RayService:Cast(StartPosition, EndPosition, Ignore, Enum.RaycastFilterType.Exclude, true)
                    if Visualize then
                        RayService:Visualize(StartPosition, EndPosition)
                    end

                    if Result then
                        Interception = true
                        Function(Result)
                        if BreakOnHit then
                            break
                        end
                    end
                    Points[Index] = CFrame.new(EndPosition)
                end
            end
            RunService.Stepped:Wait()
        end
    end))
end

return HitboxService
