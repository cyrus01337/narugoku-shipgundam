--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--|| Directories ||--
local Modules = ReplicatedStorage.Modules

local Utility = Modules.Utility
local Shared = Modules.Shared
local MetaData = Modules.Metadata
local Effects = Modules.Effects

--|| Imports ||--
local TaskScheduler = require(Utility.TaskScheduler)

--|| Variables ||--
local ValueIndex = script.Parent

ValueIndex.Changed:Connect(function()
	local Debounce = false
	local Connection; Connection = ValueIndex.Changed:Connect(function()
		if not Debounce then
			Debounce = true
		end
		Connection = Connection and Connection:Disconnect(); Connection = nil;
	end)
	delay(.85,function()
		if not Debounce then
			ValueIndex.Value = 0
		end
	end)
end)