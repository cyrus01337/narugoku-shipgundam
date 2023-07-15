local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AnimationManager
local StateHandler = require(script.Parent)
local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)
local SoundManager = require(ReplicatedStorage.Modules.Shared.SoundManager)

if RunService:IsClient() then
	AnimationManager = require(ReplicatedStorage.Modules.Shared.AnimationManager)
end

local ServerRemote = ReplicatedStorage.Remotes.ServerRemote
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local SpeedHandler = {}


function SpeedHandler.changeSpeed(Character, Speed, Duration, Priority, Trail, UnequipSound)
	local Humanoid = Character:FindFirstChild("Humanoid")
	local Stands = Character

	StateHandler:ChangeState(Character, "Speed", Duration)

	local SpeedData = StateHandler:ReturnData(Character, "Speed")
	
	if Priority < SpeedData.Priority then return end

	task.spawn(function()
		SpeedData.Priority = Priority
		Humanoid.WalkSpeed = Speed
		Humanoid.JumpPower = 0
		
		-- FIXME: the priority statement might not work
		while not StateHandler:Peek(Character,"Speed") --[[or SpeedData.Priority <= Priority]] do
			local SpeedData = StateHandler:ReturnData(Character,"Speed")

			for _,v in ipairs(Character:GetChildren()) do
				if string.find(v.Name,"Sword") and not string.find(v.Name,"SheateSword") then
					if v:FindFirstChild("Blade") and v.Blade:FindFirstChild("Trail") and Trail == nil then
						v.Blade.Trail.Enabled = true
					end
				end
			end

			if Character:FindFirstChild("SwordEffect") then
				SpeedHandler.AppearSword(Character)
			end

			if SpeedData.Priority > Priority then
				break
			end

			RunService.Heartbeat:Wait()
		end
		
		Humanoid.WalkSpeed = SpeedData.DefaultSpeed
		Humanoid.JumpPower = 50
		SpeedData.Priority = 0

		if Character:FindFirstChild("SwordEffect") then
			SpeedHandler.HideSword(Character, UnequipSound)
		end
		
		for _,v in ipairs(Character:GetChildren()) do
			if string.find(v.Name,"Sword") then
				if v:FindFirstChild("Blade") and v.Blade:FindFirstChild("Trail") then
					v.Blade.Trail.Enabled = false
					v.Handle.Transparency = 1
				end
			end
		end
	end)
end


function SpeedHandler.HideSword(Character, Sound)
	if Character:FindFirstChild("AokijiSword") or not Character:FindFirstChild("SwordEffect") then return end

	if RunService:IsClient() then
		AnimationManager.PlayAnimation("UnequipSword")
		
		if Sound == nil then
			--SoundManager:AddSound("zzszsz", {Parent = Character.HumanoidRootPart, Volume = .65}, "Client")
		end
	else
		AnimationRemote:FireClient(Players:GetPlayerFromCharacter(Character), "UnequipSword", "Play")
		
		if StateHandler:Peek(Character,"Attacking") and StateHandler:Peek(Character,"Guardbroken") and Sound == nil then
			--SoundManager:AddSound("zzszsz", {Parent = Character.HumanoidRootPart, Volume = .85}, "Client")
		end
	end

	task.wait(.225)	
	
	for _,v in Character:GetChildren() do
		if string.find(v.Name,"Sword") and not string.find(v.Name,"SheateSword") then
			for _,v in ipairs(v:GetChildren()) do
				if v:IsA("Part") or v:IsA("MeshPart") and v.Name ~= "Handle" then
					v.Transparency = 1
				end
			end
		end
	end				

	for _,v in Character:GetChildren() do
		if string.find(v.Name,"Sword") then
			for _,v in v:GetDescendants() do
				if string.find(v.Name,"SwordPart") then
					for _,v in v:GetChildren() do
						if v:IsA("Part") or v:IsA("MeshPart") and v.Name ~= "Handle" then
							v.Transparency = 0
						end
					end
				end
			end
		end
	end
end


function SpeedHandler.AppearSword(Character)
	for _,v in ipairs(Character:GetChildren()) do
		if string.find(v.Name,"Sword") then
			for _,v in ipairs(v:GetChildren()) do
				if v:IsA("Part") or v:IsA("MeshPart") and not string.find(v.Name,"Handl") then
					v.Transparency = 0
				end
			end
		end
	end	

	for _,v in ipairs(Character:GetChildren()) do
		if string.find(v.Name,"Sword") then
			for _,v in ipairs(v:GetDescendants()) do
				if string.find(v.Name,"SwordPart") then
					for _,v in ipairs(v:GetChildren()) do
						if v:IsA("Part") or v:IsA("MeshPart") then
							v.Transparency = 1
						end
					end
				end
			end
		end
	end	
	for _,v in ipairs(Character:GetDescendants()) do
		if v.Name == "Handle" and v:IsA("Part") then
			v.Transparency = 1
		end
	end
end

return SpeedHandler