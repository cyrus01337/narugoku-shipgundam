type Prefix = {
    JumpPower: number,
    Volume: number,
    WalkSpeed: number,
}

local Prefixes: { [string]: Prefix } = {
    ["default dance"] = {
        WalkSpeed = 3,
        JumpPower = 25,
        Volume = 5,
    },
    ["goopie"] = {
        WalkSpeed = 3,
        JumpPower = 25,
        Volume = 5,
    },
}

return Prefixes
