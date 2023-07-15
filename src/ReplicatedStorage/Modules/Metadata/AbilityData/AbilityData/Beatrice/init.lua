return {
	["FirstAbility"] = {
		Name = "Push",
		
		Copyable = true,
		Bool = false,

		StartTime = os.clock(),
		Cooldown = 12,

		Damage = 15,
	},

	["SecondAbility"] = {
		Name = "Al~Shamac",
		
		Copyable = true,
		Guardbreak = true,
		Bool = false,

		StartTime = os.clock(),
		Cooldown = 20,

		Damage = 8,
	},
	
	["ThirdAbility"] = {
		Name = "Barrier",
		
		Copyable = false,
		Bool = false,

		StartTime = os.clock(),
		Cooldown = 15,
	},
	
	["FourthAbility"] = {
		Name = "Spectrum Bombs",
		
		Copyable = true,
		Bool = false,

		ZeBall = 1,
		
		StartTime = os.clock(),
		Cooldown = 20,

		Damage = 5,
	}
}