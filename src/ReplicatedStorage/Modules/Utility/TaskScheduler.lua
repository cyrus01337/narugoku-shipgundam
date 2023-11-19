--|| Services ||--
local RunService = game:GetService("RunService")

local TaskScheduler = {}
local Cache = {}
local SteppedConnection = nil

local function OnStepped()
    if #Cache == 0 then
        SteppedConnection = SteppedConnection and SteppedConnection:Disconnect()
    end

    for Index, Queue in next, Cache do
        if os.clock() - Queue[2] >= Queue[1] then
            local Callback = Queue[3]
            table.remove(Cache, Index)
            Callback()
            break
        end
    end
end

function TaskScheduler:AddTask(Duration, Callback)
    if SteppedConnection == nil then
        SteppedConnection = RunService.Stepped:Connect(OnStepped)
    end

    Duration = Duration or 0
    Callback = Callback or function()
        print("Empty Callback Function")
    end

    --| Sort
    local CacheSize = #Cache
    Cache[CacheSize + 1] = { Duration, os.clock(), Callback }
end

return TaskScheduler
