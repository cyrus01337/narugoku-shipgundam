--|| Services ||--
local Players = game:GetService("Players")

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

--|| Modules ||--
local NetworkStream = require(ReplicatedStorage.Modules.Utility.NetworkStream)

return function(Data)
	local Character = Data.Character
	local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

	local Victim = Data.Victim
	local VRoot,VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {workspace.World.Map}
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	
	local Direction = CFrame.new(Root.Position, Root.Position + (Root.CFrame.lookVector * 10) + (Root.CFrame.upVector * -10)).lookVector * 300
	local Start = Root.Position
	
	local Duration = Data.Duration or 1.5
	
	local RaycastResult = workspace:Raycast(Start,Direction,raycastParams)
	if RaycastResult and RaycastResult.Instance and RaycastResult.Instance and (RaycastResult.Position - Start).Magnitude <= 300 then
		local NewCFrame = CFrame.new(RaycastResult.Position,RaycastResult.Position + RaycastResult.Normal)
		local TargetCFrame = NewCFrame * CFrame.new(0,0,-.5)
		
		local X,Y,Z = TargetCFrame:ToOrientation()
		local Rot = VRoot.CFrame - VRoot.Position
		local Cframe = CFrame.new(TargetCFrame.Position) * Rot				

		local NewtoCFrame = Cframe * CFrame.Angles(X,0,Z)

		if VRoot and NewtoCFrame then
			local FakeRoot = Instance.new("Part")
			FakeRoot.Anchored = true
			FakeRoot.CanCollide = false
			FakeRoot.Transparency = 1
			FakeRoot.Massless = true
			FakeRoot.Parent = workspace.World.Visuals
			
			local Weld = Instance.new("Weld")		
			Weld.Part0 = VRoot
			Weld.Part1 = FakeRoot
			Weld.Parent = VRoot
			
			FakeRoot.CFrame = NewtoCFrame

			Debris:AddItem(FakeRoot,Duration)
			Debris:AddItem(Weld,Duration - .5)
			
			coroutine.resume(coroutine.create(function()
				wait(Duration)
				if FakeRoot and VRoot then
					if VHum and Players:GetPlayerFromCharacter(Victim) == nil then
						VHum:ChangeState(Enum.HumanoidStateType.GettingUp)
					end
					if Victim then
						local Player = Players:GetPlayerFromCharacter(Victim)
						if Player then
							Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
						end
					end
				end
			end))
		end
		local Point = CFrame.new(RaycastResult.Position) * CFrame.new(0,6,0)
	else
		NetworkStream.FireClientDistance(Character,"ClientRemote",150,{Character = Character, Victim = Victim, Module = "CombatVFX", Function = "LastHit"})
	end
end