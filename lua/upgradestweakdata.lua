local sh = BLT.Mods:GetModByName("Streamlined Heisting")
local is_streamlined = sh and sh:IsEnabled() and sh:WasEnabledAtStart() and StreamHeist and true

Hooks:PostHook( UpgradesTweakData, "_player_definitions", "mdragon__player_definitions", function(self)

	-- unchanging data related to core functionality (stacks, flak jacket requirement)
	local fright_radius = 900
	local upd_t = 1 / 8
	self.mdragon_data = {
		stacks_max = 10,  -- maximum heat stacks
		stacks_gain = 1,  -- gain this many heat stacks on taking damage
		stacks_decay = -1,  -- lose this many heat stacks per decay
		stacks_start_decay_t = 4,  -- s of having armour and not taking damage before decay starts
		stacks_repeat_decay_t = upd_t * 4,  -- s between consecutive decays once it starts
		absorption_max = 2.4,  -- maximum damage absorption from god of flight (GoF)
		absorption_gain = 1.2 * upd_t,  -- absorption gain per update while sprinting + GoF
		absorption_decay = is_streamlined and -0.8 * upd_t or -2.4,  -- walking absorption loss
		upd_t = upd_t,  -- update this often in s
		fright_radius = fright_radius,  -- in centimeters
		fright_radius_sq = fright_radius ^ 2,  -- in centimeters
		armors_allowed  = table.set("level_5"),  -- flak jacket
	}

	-- related to upgrades gained
	self.values.player.mdragon = { true }  -- enable the dragon
	self.values.player.mdragon_swift = {
		{ min = 1, max = 1.3 }  -- move speed multiplier
	}
	self.values.player.mdragon_fight = { 2 }  -- stack activation requirement
	self.values.weapon.mdragon_nimble = {
		{ min = 1, max = 2.6 }  -- swap speed multiplier
	}
	self.values.player.mdragon_flight = { 4 }  -- stack activation requirement
	self.values.weapon.mdragon_ruthless = {
		{ min = 0, max = 0.75 }  -- additive decimal chance to stagger
	}
	self.values.weapon.mdragon_fright = { 6 }  -- stack activation requirement
	self.values.weapon.mdragon_perforating = {
		{ min = 0, max = 1 }  -- additive decimal chance to pierce
	}
	self.values.player.mdragon_freight = { 8 }  -- stack activation requirement/cost
	self.values.player.mdragon_survivor = {
		{ min = 0, max = 0.02 * upd_t }  -- decimal % max hp regenerated per second
	}

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
	self.definitions.player_mdragon_fight = {
		name_id = "bingus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mdragon_fight",
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
	self.definitions.player_mdragon_flight = {
		name_id = "bingus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mdragon_flight",
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
	self.definitions.player_mdragon_freight = {
		name_id = "bingus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mdragon_freight",
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
