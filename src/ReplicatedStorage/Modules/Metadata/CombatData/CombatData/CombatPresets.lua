return {
	["Aerial"] = {
		Name = "Aerial",

		Damage = 3,
		StunTime = 2.5,
		Stamina = 5,

		StartTime = os.clock(),
		Cooldown = .75
	},

	["Swing"] = {
		Name = "Swing",

		Damage = 3,
		StunTime = .55,
		Stamina = 3,

		StartTime = os.clock(),
		Cooldown = .285,
	},
	
	["Swing2"] = {
		Name = "Swing2",

		Damage = 3,
		StunTime = .55,
		Stamina = 3,

		StartTime = os.clock(),
		Cooldown = .285,
	},

	["Block"] = {
		Name = "Block",

		Guardbroken = false,
		CanParry = true,

		StartTime = os.clock(),
		Cooldown = 1,
	},

	["Run"] = {
		Name = "Run",

		StartTime = os.clock(),
		Cooldown = 0,
	},

	["Mode"] = {
		Name = "Mode",

		StartTime = os.clock(),
		Cooldown = 1.75,
	},


	["Dash"] = {
		Name = "Dash",

		StartTime = os.clock(),
		Cooldown = 1.75,
		BlockInterference = .125,

		DashType = "Normal",

		CanDash = true,

		DashingForce = 60, -- change this according to player's speed (if running, higher = more dramatic dash, etc...)

		Keys = {
			["W"] = {
				Direction = {["X"] = 0,["Z"] = -20}
			},
			["A"] = {
				Direction = {["X"] = -20,["Z"] = 0}
			},
			["S"] = {
				Direction = {["X"] = 0,["Z"] = 20}
			},
			["D"] = {
				Direction = {["X"] = 20,["Z"] = 0}
			},
		}
	}
}