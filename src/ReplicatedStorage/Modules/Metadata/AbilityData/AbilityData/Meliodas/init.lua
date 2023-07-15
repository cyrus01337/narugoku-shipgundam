return {
	["FirstAbility"] = {
		Name = "Hellblaze",

		StartTime = 0,
		Cooldown = 1,
		
		ZeBall = 1,
		
		Copyable = false,
		Bool = false,

		Damage = 12,
	},

	["SecondAbility"] = {
		Name = "",
		
		StartTime = os.clock(),
		Cooldown = 5,
		
		
		Copyable = false,
		Bool = false,

		Guardbreak = false,
		Damage = 18,
	},
	
	["ThirdAbility"] = {
		Name = "Sharingan",

		StartTime = os.clock(),
		Cooldown = 5,
		
	},
	
	["FourthAbility"] = {
		Name = "FullCounter",
		
		Copyable = false,
		Bool = false,

		StartTime = os.clock(),
		Cooldown = 0,

	}
}