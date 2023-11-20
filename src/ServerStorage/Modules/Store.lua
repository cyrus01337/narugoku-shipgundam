local Players = game:GetService("Players")

type StateSlice = {
    InRound: boolean,
}
type StateSliceStore = { [Player]: StateSlice }
local _internalSliceStore: StateSliceStore = {}
local Store = {}

local function invalidateStateSlice(player: Player)
    _internalSliceStore[player] = nil

    warn(string.format("Invalidated state for %s", player.Name))
end

function createDefaultSlice(): StateSlice
    return {
        InRound = false,
    }
end

function Store.useStateSliceFor(player: Player)
    local sliceFound: StateSlice? = _internalSliceStore[player]

    if sliceFound then
        return sliceFound
    end

    local slice = createDefaultSlice()
    _internalSliceStore[player] = slice

    return slice
end

Players.PlayerRemoving:Connect(invalidateStateSlice)

return Store
