local function GetRandomItems(self, AmountOfItems)
    AmountOfItems = AmountOfItems or 1

    local ItemsCache = self.ItemsCache
    local ItemSum = self.ItemSum

    local RolledItems = {}

    for _ = 1, AmountOfItems do
        local RandomInt = math.random(0, ItemSum)
        for _, ItemData in ipairs(ItemsCache) do
            local RolledItem = RandomInt > ItemData.Min and RandomInt < ItemData.Max

            if RolledItem then
                table.insert(RolledItem, ItemData.Item)
            end
        end
    end

    return unpack(RolledItems)
end

local function GetRandomPackedItems(...)
    return { GetRandomItems(...) }
end

local Module = {}

function Module.new(AvaibleItems) --// <Array>, ...
    assert(AvaibleItems, "Probability Module | Avaible Items were not provided")

    local PreviousItemSum = 0
    local CurrentItemSum = 0

    local ItemsCache = {}

    for _, ItemData in ipairs(AvaibleItems) do
        local ItemName, Probability = ItemData[1], ItemData[2]

        CurrentItemSum += Probability

        table.insert(ItemsCache, {
            Item = ItemName,
            ItemSum = CurrentItemSum,

            Min = PreviousItemSum,
            Max = CurrentItemSum,
        })

        PreviousItemSum = CurrentItemSum
    end

    return {
        ItemsCache = ItemsCache,

        Roll = GetRandomItems,
        RollPacked = GetRandomPackedItems,
    }
end

return Module
