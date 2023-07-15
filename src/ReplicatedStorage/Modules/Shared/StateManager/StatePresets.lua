return {
    --[[
        ["Name"] = {
            StartTime = os.clock(),
            Duration = 0,
            
            ExtraData = {}
            
            Type = "NormalInteger" 
    
    ]]--
	["Emoting"] = {
		StartTime = os.clock(),
		Duration = 0,

		Type = "NormalInteger",
	},
	["Frozen"] = {
		StartTime = os.clock(),
		Duration = 0,
		
		Type = "NormalInteger",
	},
	["Guardbroken"] = {
		StartTime = os.clock(),
		Duration =  0,

		Type = "NormalInteger"
	},
	["Mode"] = {
		StartTime = os.clock(),
		Duration = 0,
		
		MaxModeValue = 285,
		ModeValue = 0,
		
		Type = "NormalInterger"
	},
	["StandAttack"] = {
		StartTime = os.clock(),
		Duration =  0,
		
		InStand = CFrame.new(0,0,3),
		OutStand = CFrame.new(1,-0.5,-2),
		
		Priority = 1,

		Type = "NormalInteger"
	},
	["InAir"] = {
		StartTime = os.clock(),
		Duration =  0,

		Type = "NormalInteger"
	},
	["Dashing"] = {
		StartTime = os.clock(),
		Duration =  0,

		Type = "NormalInteger"
	},
	["IFrame"] = {
		StartTime = os.clock(),
		Duration =  0,
		
		IFrameType = "",
		
		Type = "NormalInteger"
	},
	["DamageMultiplier"] = {
		StartTime = os.clock(),
		Duration =  0,
		
		DamageBooster = 1,

		Type = "NormalInteger"
	},
	["Attacking"] = {
		StartTime = os.clock(),
		Duration =  0,
		
		AllowedSkills = {}, --[SkillName] = true
		
		Type = "NormalInteger"
	},
	["Blocking"] = {
		StartTime = os.clock(),
		Duration = 0,
		
		AllowedSkills = {}, --[SkillName] = true
		
		BlockVal = 1000,
		IsBlocking = false,

		Type = "Boolean"
	},
		
	["ForceField"] = {
		StartTime = os.clock(),
		Duration = 0,

		EquippedForceField = false,

		Type = "Boolean"
	},
		
	["Running"] = {
		StartTime = os.clock(),
		Duration = 0,

		Type = "Boolean"
	},
	["Stunned"] = {
		StartTime = os.clock(),
		Duration = 0,

		Type = "SpecialInteger"
	},
	["Speed"] = {
		StartTime = os.clock(),
		Duration =  0,
		
		DefaultSpeed = 14,
		Priority = 1,
		
		Type = "NormalInteger"
	},	
	["LastAbility"] = {
		StartTime = os.clock(),
		Duration = 0,

		Skill = "",

		Type = "SpecialInteger"
	},
	["LastSkill"] = {
		StartTime = os.clock(),
		Duration = 0,
		
		Skill = "",

		Type = "SpecialInteger"
	},
	["LastHit"] = {
		StartTime = os.clock(),
		Duration =  .5,
		
		LastTarget = "",
		LastDamaged = 0,
		
		Type = "SpecialInteger"
	}
}