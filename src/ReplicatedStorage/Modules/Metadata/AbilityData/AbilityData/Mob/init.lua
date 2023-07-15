return {
	["FirstAbility"] = {
		Name = "Physco Choke",

		StartTime = 0,
		Cooldown = 15,
		
		Copyable = false,
		Guardbreak = false,
		Bool = false,

		BlockDeduction = .00001,
		
		Damage = .875,
		StunTime = .775,		
	},
	
	["SecondAbility"] = {
		Name = "Physco Slam",
		
		Damage = 10,
		StunTime = 2,
		EndLag = 1,
		
		LastUsed = 0,
		Amount = 0,
		
		Copyable = true,
		Guardbreak = false,
		Bool = false,

		StartTime = 0,
		Cooldown = 25,
	},
	
	["ThirdAbility"] = {
		Name = "Physco Rocks",
			
		Damage = 5,
		StunTime = 1,
		Rocks = 3,
		Range = 10,
		
		Copyable = true,
		Guardbreak = false,
		Bool = false,

		StartTime = 0,
		Cooldown = 30,
	},
	
	["FourthAbility"] = {
		Name = "Metoer Slam",	
		
		Damage = 18,
		StunTime = 1,
		
		Copyable = true,
		Guardbreak = true,
		
		StartTime = 0,
		Cooldown = 35,

	},

}