Hooks:PostHook( UpgradesTweakData, "_player_definitions", "mdragon__player_definitions", function(self)

	-- unchanging data related to core functionality (stacks, flak jacket requirement)

	local fright_radius = 900
	self.mdragon_data = {
		stacks_min = 0,  -- minimum stacks
		stacks_max = 20,  -- self-explanatory
		stacks_gain = 1,  -- gain this many stacks on taking damage
		stacks_decay = 1,  -- lose this many stacks per decay
		stacks_decay_t = 4,  -- time in seconds of having armour and not taking damage before stacks start decaying
		stacks_decay_dt_mul = 4,  -- multiplier on decay bank buildup rate
		fright_radius = fright_radius,  -- in centimeters
		fright_radius_sq = fright_radius ^ 2,  -- in centimeters
		works_with_armor_kit = true,  -- works only after equipping the flak jacket if somehow using the armour bag
		armors_allowed  = { level_5 = true, },  -- flak jacket
	}

	-- related to upgrades gained
	self.values.player.mdragon = { true }  -- enable the dragon
	self.values.player.mdragon_swift = {
		{ min = 1, max = 1.3 }  -- move speed multiplier
	}
	self.values.player.mdragon_flight = { 5 }  -- stack activation requirement
	self.values.weapon.mdragon_nimble = {
		{ min = 1, max = 1.4 }  -- swap speed multiplier
	}
	self.values.player.mdragon_might = { 10 }  -- stack activation requirement
	self.values.weapon.mdragon_ruthless = {
		{ min = 0, max = 1 }  -- decimal chance to stagger
	}
	self.values.weapon.mdragon_fright = { 15 }  -- stack activation requirement
	self.values.weapon.mdragon_perforating = {
		{ min = 0, max = 1 }  -- decimal chance to pierce
	}
	self.values.player.mdragon_life = { 20 }  -- stack activation requirement/cost
	self.values.player.mdragon_survivor = {
		{ min = 0, max = 0.01 }  -- decimal % max hp regenerated per second
	}

	-- dev values
	self.values.player.mdragon_swift = {
		{ min = 1.3, max = 1.3 }
	}
	self.values.weapon.mdragon_nimble = {
		{ min = 1.4, max = 1.4 }
	}
	self.values.weapon.mdragon_ruthless = {
		{ min = 1, max = 1 }
	}
	self.values.weapon.mdragon_perforating = {
		{ min = 1, max = 1 }
	}
	self.values.player.mdragon_survivor = {
		{ min = 0.01, max = 0.01 }
	}
	self.values.player.mdragon_flight = { 0 }
	self.values.player.mdragon_might = { 0 }
	self.values.weapon.mdragon_fright = { 0 }
	self.values.player.mdragon_life = { 0 }

	self.definitions.player_mdragon = {
		name_id = "bingus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mdragon",
			category = "player"
		}
	}
	self.definitions.player_mdragon_swift = {
		name_id = "bingus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mdragon_swift",
			category = "player"
		}
	}
	self.definitions.player_mdragon_flight = {
		name_id = "bingus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mdragon_flight",
			category = "player"
		}
	}
	self.definitions.weapon_mdragon_nimble = {
		name_id = "bingus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mdragon_nimble",
			category = "weapon"
		}
	}
	self.definitions.player_mdragon_might = {
		name_id = "bingus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mdragon_might",
			category = "player"
		}
	}
	self.definitions.weapon_mdragon_ruthless = {
		name_id = "bingus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mdragon_ruthless",
			category = "weapon"
		}
	}
	self.definitions.weapon_mdragon_fright = {
		name_id = "bingus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mdragon_fright",
			category = "weapon"
		}
	}
	self.definitions.weapon_mdragon_perforating = {
		name_id = "bingus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mdragon_perforating",
			category = "weapon"
		}
	}
	self.definitions.player_mdragon_life = {
		name_id = "bingus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mdragon_life",
			category = "player"
		}
	}
	self.definitions.player_mdragon_survivor = {
		name_id = "bingus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mdragon_survivor",
			category = "player"
		}
	}

end )
