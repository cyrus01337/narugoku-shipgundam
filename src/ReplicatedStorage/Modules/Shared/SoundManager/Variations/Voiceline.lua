--|| Services ||--
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local MarketPlaceService = game:GetService("MarketplaceService")

--|| Directories ||--
local Variations = script.Parent

--|| Import ||--
local ClientVariation = require(Variations.Client)

return function(Table, SoundName, SoundProperties, RemoteData)
	local Player = SoundProperties.Parent ~= nil and Players:GetPlayerFromCharacter(SoundProperties.Parent.Parent)
	if Player and MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, 19385554) then
		local Sound = ClientVariation(Table,SoundName,SoundProperties,RemoteData)
		return Sound
	end
end