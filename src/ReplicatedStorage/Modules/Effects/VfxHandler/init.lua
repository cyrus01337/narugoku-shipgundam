--|| Services ||--
local RunService = game:GetService("RunService")

local Client = RunService:IsClient()

local VFXHandler = {}

local Effects = script:GetChildren()

for i = 1, #Effects do
	local Module = Effects[i];
	VFXHandler[Module.Name] = require(Module)
end


function VFXHandler.Emit(Particle, Amount)
	if Client then
		local QualityLevel = UserSettings().GameSettings.SavedQualityLevel
		if QualityLevel == Enum.SavedQualitySetting.Automatic then
			local Compressor = 1 / 2
			Particle:Emit(Amount * Compressor)
		else
			local Compressor = QualityLevel.Value / 10
			if Particle then
				Particle:Emit(Amount * Compressor)
			end
		end
	end
end

return VFXHandler