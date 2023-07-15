--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--|| Modules ||--
local Utility = require(ReplicatedStorage.Modules.Utility.Utility)

--|| Folders ||--
local AnimationFolder = ReplicatedStorage.Assets.Animations

--|| Remotes ||--
local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote

--|| Module ||--
local AnimationHandler = {
	Characters = {},

	QueuedList = {"Pain"}
}

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local INVALID_ANIMATION_ERROR = "Requested Animation is an invalid type"

function AnimationHandler.CreateProfile(Character)
	local Profile = AnimationHandler[Character.Name]

	if Profile == true then return end

	AnimationHandler[Character.Name] = {
		LoadedAnimations = {}
	}
end

function AnimationHandler:GetProfile(Character)
	if AnimationHandler[Character.Name] == true then
		return true, AnimationHandler[Character.Name]
	else
		AnimationHandler.CreateProfile(Character)
		return true, AnimationHandler[Character.Name]
	end

end

function AnimationHandler.LoadAnimations(Character,ClassNames)
	local _,Profile = AnimationHandler:GetProfile(Character)
	ClassNames = (typeof(ClassNames) == "string" and {ClassNames}) or ClassNames

	local Humanoid = Character:WaitForChild("Humanoid")
	local Animator = Humanoid:FindFirstChildOfClass("Animator")

	for _,ClassName in ipairs(ClassNames) do
		local SharedAnimations = AnimationFolder.Shared

		local CachedShared = Utility:deepSearchFolder(SharedAnimations,"Animation")

		for _,Animation in ipairs(CachedShared) do
			if AnimationHandler[Character.Name].LoadedAnimations[Animation.Name] then continue end
			AnimationHandler[Character.Name].LoadedAnimations[Animation.Name] = Animator:LoadAnimation(Animation)			
		end
	end
end

function AnimationHandler.PlayAnimation(AnimationName,AnimationData)
	AnimationName = (typeof(AnimationName) == "string" and AnimationName) or warn(INVALID_ANIMATION_ERROR)
	if not AnimationHandler[Character.Name].LoadedAnimations[AnimationName] then warn(AnimationName,"is not a valid animation") return end

	local FadeTime = AnimationData and AnimationData.FadeTime or .1
	local Weight =  AnimationData and AnimationData.Weight or 1
	local AdjustSpeed = AnimationData and AnimationData.AdjustSpeed or 1
	local Looped = AnimationData and AnimationData.Looped or false

	local Track = AnimationHandler[Character.Name].LoadedAnimations[AnimationName]
	Track:Play(FadeTime,Weight)
	Track:AdjustSpeed(AdjustSpeed)

	Track.Looped = Looped
end

function AnimationHandler.StopAnimation(AnimationName,AnimationData)
	AnimationName = (typeof(AnimationName) == "string" and AnimationName) or warn(INVALID_ANIMATION_ERROR)
	if not AnimationHandler[Character.Name].LoadedAnimations[AnimationName] then return end

	local FadeTime = AnimationData and AnimationData.FadeTime or .1
	local Weight = AnimationData and AnimationData.Weight or 1

	local Track = AnimationHandler[Character.Name].LoadedAnimations[AnimationName]
	Track:Stop(FadeTime,Weight)
end

function AnimationHandler.AddQueue(AnimationStyle)
	AnimationStyle = (typeof(AnimationStyle) == "string" and AnimationStyle) or warn(INVALID_ANIMATION_ERROR)

	for _,QueuedStyle in ipairs(AnimationHandler.QueuedList) do
		if QueuedStyle == AnimationStyle then
			return
		end
	end
	AnimationHandler.QueuedList[#AnimationHandler.QueuedList + 1] = AnimationStyle
end

function AnimationHandler.RemoveQueue(AnimationStyle)
	AnimationStyle = (typeof(AnimationStyle) == "string" and AnimationStyle) or warn(INVALID_ANIMATION_ERROR)

	for _,QueuedStyle in ipairs(AnimationHandler.QueuedList) do
		if QueuedStyle == AnimationStyle then
			AnimationHandler.QueuedList[QueuedStyle] = nil
		end
	end
end

function AnimationHandler.ClearAnimations(Character)
	local HasProfile,Profile = AnimationHandler:GetProfile(Character)
	if HasProfile == nil then return end

	for AnimationName, _ in ipairs(AnimationHandler.LoadedAnimations) do
		Profile.LoadedAnimations[AnimationName] = nil
	end
end

task.spawn(function()
	AnimationHandler.CreateProfile(Character)
	AnimationHandler.LoadAnimations(Character,AnimationHandler.QueuedList)
end)

Player.CharacterAdded:Connect(function(NewCharacter)

	Character = NewCharacter

	AnimationHandler.CreateProfile(NewCharacter)

	AnimationHandler.LoadAnimations(Character,AnimationHandler.QueuedList)
end)

Player.CharacterRemoving:Connect(function(Character)
	AnimationHandler.ClearAnimations(Character)
end)

return AnimationHandler 
