return {
	["FirstAbility"] = {
		Name = "-",

		StartTime = os.clock(),
		Cooldown = 1,

		Guardbreak = false,
		BlockDeduction = .25,

		Damage = 1.15,
		StunTime = .775,	
	},

	["SecondAbility"] = {
		Name = "-",

		Damage = 15,
		StunTime = 2,
		EndLag = 1,

		Guardbreak = true,

		StartTime = os.clock(),
		Cooldown = 1,
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