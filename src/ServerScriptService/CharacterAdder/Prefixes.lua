type Prefix = {
    JumpPower: number,
    Volume: number,
    WalkSpeed: number,
}

local DEFAULT_PREFIX: Prefix = {
    WalkSpeed = 3,
    JumpPower = 25,
    Volume = 5,
}
local Prefixes: { [string]: Prefix } = {
    ["default dance"] = DEFAULT_PREFIX,
    ["goopie"] = DEFAULT_PREFIX,
}

return Prefixes
