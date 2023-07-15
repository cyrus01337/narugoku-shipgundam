-- SERVICES --
local RS = game:GetService("ReplicatedStorage")

-- Folders --
local Remotes = RS.Remotes
local Modules = RS.Modules

-- EVENTS --
local Replicate = Remotes.Replicate

-- REMOTE HANDLER --
Replicate.OnClientEvent:Connect(function(Action,Hotkey, ...) -- Using ... Allows you to send as many variables as you want
	--print(Action)
	if script:FindFirstChild(Action) and script:FindFirstChild(Action):IsA("ModuleScript") then -- If the name of a ModuleScript inside this script fits the Action parameter,
		require(script[Action])(Hotkey,...) 						-- it'll require it
	elseif script:FindFirstChild(Action) and script:FindFirstChild(Action):IsA("Folder") then
		require(script[Action][Hotkey])(...) 
	end
end)
