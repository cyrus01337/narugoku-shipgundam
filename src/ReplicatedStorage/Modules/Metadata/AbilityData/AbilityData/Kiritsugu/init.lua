return {
	["FirstAbility"] = {
		Name = "Fireball Jutsu",

		StartTime = 0,
		Cooldown = 15,
		
		Copyable = false,
		Bool = false,

		Damage = 12,
	},

	["SecondAbility"] = {
		Name = "Chidori",
		
		StartTime = 0,
		Cooldown = 25,
		Copyable = false,
		Bool = false,

		Guardbreak = true,
		Damage = 18,
	},
	
	["ThirdAbility"] = {
		Name = "Sharingan",

		StartTime = os.clock(),
		Cooldown = 5,
		
		Bool = false,		
	},
	
	["FourthAbility"] = {
		Name = "Shuriken",

		Bool = false,

		StartTime = os.clock(),
		Cooldown = 0,

		Damage = 5,
	}
}