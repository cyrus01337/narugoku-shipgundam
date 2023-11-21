return {
    ["FirstAbility"] = {
        Name = "Barrage",

        StartTime = 0,
        Cooldown = 15,

        BlockDeduction = 0.0,
        Guardbreak = false,
        Bool = false,

        Copyable = false,

        Damage = 0.875,
        StunTime = 0.8,
    },

    ["SecondAbility"] = {
        Name = "Coin Explosion",

        Damage = 12,
        StunTime = 0.75,
        EndLag = 1,

        Guardbreak = true,
        Copyable = false,
        Bool = false,

        StartTime = 0,
        Cooldown = 20,
    },

    ["ThirdAbility"] = {
        Name = "Bomb Implant",

        HasBomb = false,

        Damage = 3,
        StunTime = 0.85,

        Guardbreak = false,
        Copyable = false,
        Bool = false,

        StartTime = 0,
        Cooldown = 10,
    },

    ["FourthAbility"] = {
        Name = "Explosion",

        Damage = 15,
        StunTime = 2,

        Guardbreak = false,
        Copyable = true,
        Bool = false,

        StartTime = 0,
        Cooldown = 25,
    },
}
