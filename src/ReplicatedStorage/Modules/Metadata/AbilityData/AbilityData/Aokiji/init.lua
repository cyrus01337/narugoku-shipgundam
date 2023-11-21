return {
    ["FirstAbility"] = {
        Name = "Ice Trident",

        StartTime = os.clock(),
        Cooldown = 13,

        Guardbreak = false,
        Copyable = false,

        Bool = false,

        Damage = 12,
    },

    ["SecondAbility"] = {
        Name = "Ice Sword",

        StartTime = os.clock(),
        Cooldown = 15,
        StunTime = 0.75,

        Guardbreak = false,
        Copyable = false,

        Bool = false,

        Damage = 3,
    },

    ["ThirdAbility"] = {
        Name = "Ice Freeze",

        HitList = {},

        StartTime = os.clock(),
        Cooldown = 25,

        Guardbreak = false,
        Copyable = false,

        Bool = false,

        ModePoints = 0.85,
        Damage = 0.5,
    },

    ["FourthAbility"] = {
        Name = "Ice Stomp",

        StartTime = os.clock(),
        Cooldown = 25,
        StunTime = 1.25,

        Guardbreak = true,
        Copyable = true,

        Bool = false,

        Damage = 12,
    },
}
