--|| Services ||--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Mouse = Player:GetMouse()

local PlayerGui = Player:WaitForChild("PlayerGui")

--|| Modules ||--
local GuisEffect = require(PlayerGui:WaitForChild("GuiEffects"))

--||Remotes||--
local GUIRemote = ReplicatedStorage.Remotes.GUIRemote

--|| Debounces ||--

--|| Assets ||--
local PlayerHUD = PlayerGui.HUD


local SkillUi = script.Parent.Parent.SkillUI


local SkillUI = {
	["ChangeSlots"] = function(UiData)	
		local SelectedCharacter = UiData.Character		
		local ZSlot,XSlot,CSlot,VSlot = SkillUi.FirstAbilitySlot, SkillUi.SecondAbilitySlot, SkillUi.ThirdAbilitySlot, SkillUi.FourthAbilitySlot 

		local CharacterModule = require(ReplicatedStorage.Modules.Metadata.AbilityData.AbilityData[SelectedCharacter][SelectedCharacter.."Mode"])

		if UiData.HasMode then
			ZSlot.Skill.Text = CharacterModule["FirstAbility"].Name or ""

			XSlot.Skill.Text = CharacterModule["SecondAbility"].Name or ""

			CSlot.Skill.Text = CharacterModule["ThirdAbility"].Name  or ""

			VSlot.Skill.Text = CharacterModule["FourthAbility"].Name or ""
		else
			local CharacterModule = require(ReplicatedStorage.Modules.Metadata.AbilityData.AbilityData[SelectedCharacter])
			
			local Animate = Character:WaitForChild("Animate")
			--http://www.roblox.com/asset/?id=180435571

			ZSlot.Skill.Text = CharacterModule["FirstAbility"].Name or ""

			XSlot.Skill.Text = CharacterModule["SecondAbility"].Name or ""

			CSlot.Skill.Text = CharacterModule["ThirdAbility"].Name  or ""

			VSlot.Skill.Text = CharacterModule["FourthAbility"].Name or ""
			
		--[[repeat RunService.RenderStepped:Wait() until _G.Data.Character
			if _G.Data.Character == "Sanji" then
				Animate.idle.Animation1.AnimationId = "rbxassetid://6932966037"
				Animate.idle.Animation2.AnimationId = "rbxassetid://6932966037"
			else
				Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=180435571"
				Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=180435571"
			end ]]
		end
	end,
}

return SkillUI