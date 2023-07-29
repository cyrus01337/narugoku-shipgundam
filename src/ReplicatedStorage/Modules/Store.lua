local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Modules.Utility.Signal)


return {
	Frames = nil,
	PopulatedFrames = Signal.New(),
}
