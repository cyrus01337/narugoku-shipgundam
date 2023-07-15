return {
	["FirstAbility"] = {
		Name = "Lightning Palm",

		Damage = 20,
		StunTime = 2,
		EndLag = 1,

		Guardbreak = true,

		StartTime = os.clock(),
		Cooldown = 20,
	},

	["SecondAbility"] = {
		Name = "Whirlwind",

		Damage = 1.5,
		StunTime = 2,
		EndLag = 1,

		Guardbreak = false,

		StartTime = os.clock(),
		Cooldown = 25,
	},

	["ThirdAbility"] = {
		Name = "-",

		Damage = 12,
		StunTime = 1,
		Rocks = 3,
		Range = 10,

		Guardbreak = false,

		StartTime = os.clock(),
		Cooldown = 1,
	},

	["FourthAbility"] = {
		Name = "-",	

		Damage = 30,
		StunTime = 1,

		Guardbreak = false,

		StartTime = os.clock(),
		Cooldown = 1,
	},
}