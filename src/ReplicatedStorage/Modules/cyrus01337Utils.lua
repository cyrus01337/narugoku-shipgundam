--[[
    This will be renamed to something more appropriate once utils has been
    refactored

    I apologise in advance kinda sorta maybe lol
]]
local cyrus01337Utils = {}

function cyrus01337Utils.retryForever(name: string, callback: () -> ())
    local success
    local iterations = 0

    while not success do
        success = pcall(callback)
        iterations += 1

        if not success then
            task.wait(1)
        end

        if iterations % 10 == 0 then
            warn(string.format("Reached %d iterations whilst running %s", iterations, name))
        end
    end
end

return cyrus01337Utils
