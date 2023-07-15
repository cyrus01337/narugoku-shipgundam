return {
	["FirstAbility"] = {
		Name = "Pistol",

		StartTime = os.clock(),
		Cooldown = 10,
		
		BlockDeduction = .015,
		
		Copyable = true,
		Guardbreak = false,
		Bool = false,

		Damage = 12,
		StunTime = 1,		
	},
	
	["SecondAbility"] = {
		Name = "Battle Axe",
		
		Damage = 15,
		StunTime = 2,
		
		Copyable = true,
		Guardbreak = false,
		Bool = false,

		StartTime = os.clock(),
		Cooldown = 10,
	},
	
	["ThirdAbility"] = {
		Name = "Bazooka",
					
		Damage = 12,
		StunTime = 1,
		
		Copyable = true,
		Guardbreak = true,
		Bool = false,

		StartTime = os.clock(),
		Cooldown = 15,
	},
	
	["FourthAbility"] = {
		Name = "Gattling",	
		
		Damage = 1.5,
		StunTime = .875,
		
		Copyable = true,
		Guardbreak = false,
		Bool = false,

		StartTime = os.clock(),
		Cooldown = 20,
	},


}