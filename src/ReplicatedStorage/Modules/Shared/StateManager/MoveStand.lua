--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

--|| Imports ||--
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)
local TaskScheduler = require(ReplicatedStorage.Modules.Utility.TaskScheduler)

--|| Remotes ||--
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote

--|| Module ||--
local StateManager = require(script.Parent)

local MoveStand = {
	MoveStand = function(Character,Data)
		local Humanoid = Character:FindFirstChild("Humanoid")

		-- out stand == not punching / in stand == punching or doin sum 

		local Broke = false

		local Stand = Character:FindFirstChild(Character.Name.." - Stand")
		if Stand == nil then return end

		StateManager:ChangeState(Character,"StandAttack",Data.Duration)

		local Weld = Stand.PrimaryPart.Weld	

		local StandData = StateManager:ReturnData(Character,"StandAttack")

		GlobalFunctions.TweenFunction({
			["Instance"] = Weld,
			["EasingStyle"] = Enum.EasingStyle.Exponential,
			["EasingDirection"] = Enum.EasingDirection.Out,
			["Duration"] = .4,
		},{
			["C0"] = StandData.InStand
		})
		coroutine.wrap(function()
			pcall(function()
				if Data.Priority >= StandData.Priority then
					StandData.Priority = Data.Priority
					while Players:GetPlayerFromCharacter(Character) and not StateManager:Peek(Character,"StandAttack") do
						local StandData = StateManager:ReturnData(Character,"StandAttack")
						if StandData.Priority > Data.Priority then
							print("broke right here")
							Broke = true
							break
						end
						RunService.Heartbeat:Wait()
					end			
					if not Broke then
						GlobalFunctions.TweenFunction({
							["Instance"] = Weld,
							["EasingStyle"] = Enum.EasingStyle.Exponential,
							["EasingDirection"] = Enum.EasingDirection.Out,
							["Duration"] = .4,
						},{
							["C0"] = StandData.OutStand
						})
					else
						GlobalFunctions.TweenFunction({
							["Instance"] = Weld,
							["EasingStyle"] = Enum.EasingStyle.Exponential,
							["EasingDirection"] = Enum.EasingDirection.Out,
							["Duration"] = .4,
						},{
							["C0"] = StandData.InStand
						})
						Broke = false

						TaskScheduler:AddTask(Data.Duration,function()
							GlobalFunctions.TweenFunction({
								["Instance"] = Weld,
								["EasingStyle"] = Enum.EasingStyle.Exponential,
								["EasingDirection"] = Enum.EasingDirection.Out,
								["Duration"] = .4,
							},{
								["C0"] = StandData.OutStand
							})
						end)
					end

					StandData.Priority = 0
				end
			end)	
		end)()
	end
}

return MoveStand