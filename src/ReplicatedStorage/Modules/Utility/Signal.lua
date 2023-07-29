local Signal = {}
local Dis = {}
Signal.__index = Signal
Dis.__index = Dis

function Signal.New()
	local Info = setmetatable( {
		Callbacks = {},
	} , Signal )
	return Info
end

function Dis:Disconnect()
	local Callbacks = self.Info.Callbacks
	Callbacks[self.Index] = nil
end

function Signal:Connect(Func)
	local Callbacks = self.Callbacks
	local CallbackCount = #Callbacks
	local Index = CallbackCount + 1
	Callbacks[Index] = Func
	local Data = setmetatable( {
		["Info"] = self,
		["Index"] = Index
	} , Dis )
	return Data
end

function Signal:Wait()
	local Thread, Connection = coroutine.running()
	Connection = self:Connect(function(...)
		Connection:Disconnect()
		Connection = nil
		coroutine.resume(Thread, ...)
	end)
	return coroutine.yield(Thread)
end

function Signal:Fire(...)
	local Callbacks = self.Callbacks
	for _, Callback in ipairs(Callbacks) do
		local _ = type(Callback) == "function" or error("Not a function")
		Callback(...)
	end

end

return Signal