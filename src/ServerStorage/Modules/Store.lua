local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Modules.Utility.Signal)

local Store = {
    PlayerPassedMainMenu = Signal.new(),
    playersPastMainMenu = {} :: { Player },
    playersFighting = {} :: { Player },
    selectedCharacter = "",
}

function Store.tagPlayerPastMainMenu(player: Player)
    table.insert(Store.playersPastMainMenu, player)
    Store.PlayerPassedMainMenu:Fire(player)
end

return Store
