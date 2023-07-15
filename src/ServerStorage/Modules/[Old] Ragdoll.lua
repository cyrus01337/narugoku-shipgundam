--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

--|| Imports ||--
local StatesManager = require(ReplicatedStorage.Modules.Shared.StateManager)

--|| Init ||--
PhysicsService:CreateCollisionGroup("Colliders")
PhysicsService:CollisionGroupSetCollidable("Colliders", "Colliders", false)

local RagdollManager = {
	Motors = {},
	BaseParts = {}
}

function RagdollManager:RagdollCharacter(Character, Enabled)
	local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

	if not Character or (Character and not Root and Humanoid) then return nil end

	if Enabled and not RagdollManager.Motors[Character] and not RagdollManager.BaseParts[Character] then
		RagdollManager.Motors[Character] = {}
		RagdollManager.BaseParts[Character] = {}
		
		Humanoid.AutoRotate = false
		Humanoid.PlatformStand = true
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		
		for _,Object in ipairs(Character:GetDescendants()) do
			if Object:IsA("Motor6D") then
				local Socket = Instance.new("BallSocketConstraint")
				local Part0 = Object.Part0
				local Part1 = Object.Part1

				RagdollManager.Motors[Character][Object] = {Part0 = Object.Part0, Socket = Socket}

				local Attachment = Instance.new("Attachment")
				Attachment.CFrame = Object.C0
				Attachment.Parent = Part0

				local Attachment2 = Instance.new("Attachment")
				Attachment2.CFrame = Object.C1
				Attachment2.Parent = Part1

				if Attachment and Attachment2 then
					Socket.Attachment0, Socket.Attachment1 = Attachment, Attachment2
					Socket.Parent = Object.Parent
					Object.Part0 = nil;
				end
			elseif Object:IsA("BasePart") then
				local Collider = Instance.new("Part")
				Collider.Name = "Ragdoll"
				Collider.Size = Object.Size
				Collider.CFrame = Object.CFrame
				Collider.CanCollide = true
				Collider.Anchored = false
				Collider.Transparency = 1

				local Weld = Instance.new("Weld")
				Weld.Part0 = Object
				Weld.Part1 = Collider
				Weld.C0 = CFrame.new()
				Weld.C1 = Weld.Part1.CFrame:toObjectSpace(Weld.Part0.CFrame)
				Weld.Parent = Collider
				Collider.Parent = Object

				PhysicsService:SetPartCollisionGroup(Object, "Colliders")
				PhysicsService:SetPartCollisionGroup(Collider, "Colliders")

				RagdollManager.BaseParts[Character][Object] = Collider				
			end
		end
	elseif not Enabled and RagdollManager.Motors[Character] then
		Root.CFrame = CFrame.new(Root.CFrame.Position)
		
		Humanoid.AutoRotate = true
		Humanoid.PlatformStand = false
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

		for Parent,Attachment in next, RagdollManager.Motors[Character] do
			Parent.Part0 = Attachment.Part0

			Attachment.Socket.Attachment0:Destroy()
			Attachment.Socket.Attachment1:Destroy()
			Attachment.Socket:Destroy()
		end

		for _,v in ipairs(Character:GetDescendants()) do
			if v.Name == "DeleteMe" or v.Name == "Ragdoll" then
				v:Destroy()
			end
		end

		RagdollManager.Motors[Character] = nil
		RagdollManager.BaseParts[Character] = nil
	end
end

function RagdollManager.DurationRagdoll(Character,Duration)
	coroutine.wrap(function()
		RagdollManager:RagdollCharacter(Character,true)
		wait(Duration)
		RagdollManager:RagdollCharacter(Character,false)
	end)()
end

return RagdollManager