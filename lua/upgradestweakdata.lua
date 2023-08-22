local sh = BLT.Mods:GetModByName("Streamlined Heisting")
local is_streamlined = sh and sh:IsEnabled() and sh:WasEnabledAtStart() and StreamHeist and true

Hooks:PostHook( UpgradesTweakData, "_player_definitions", "mdragon__player_definitions", function(self)

	-- unchanging data related to core functionality (stacks, flak jacket requirement)
	local fright_radius = 900
	local upd_t = 1 / 8
	self.mdragon_data = {
		stacks_max = 8,  -- maximum heat stacks
		stacks_gain = 1,  -- gain this many heat stacks on taking damage
		stacks_decay = -1,  -- lose this many heat stacks per decay
		stacks_start_decay_t = 1,  -- s of not dealing damage before decay starts
		stacks_repeat_decay_t = 1,  -- s between consecutive decays once it starts
		absorption_max = false,  -- dirty, but set in playermanager once in heist
		absorption_gain = 1.6 * upd_t,  -- absorption gain per update while meleeing
		absorption_decay = is_streamlined and -1.6 * upd_t or -10,  -- non-melee absorption loss
		absorption_max_mul = 0.25,  -- used in playermanager calculation of absorption_max
		upd_t = upd_t,  -- update this often in s
		fright_radius = fright_radius,  -- in centimeters
		fright_radius_sq = fright_radius ^ 2,  -- in centimeters
		armor_whitelist  = table.set("level_5"),  -- flak jacket
		armor_decay_threshold  = 1,  -- % armour at which stacks start decaying (1 = 100%)
		fight_armor_gain = 0.5,  -- gain this much armour on melee strike
	}

	for upgrade, value in pairs({
		mdragon = true,  -- enable the dragon
		mdragon_swift = { min = 1.1, max = 1.4 },  -- move speed multiplier
		mdragon_might = 0,  -- crit melee requirement
		mdragon_slick = { min = 1.2, max = 1.8 },  -- swap speed multiplier
		mdragon_flight = 0,  -- endless sprint requirement
		mdragon_staggering = { min = 0.2, max = 0.8 },  -- stagger chance
		mdragon_fright = 0,  -- instant melee/headshot kill requirement
		mdragon_shattering = { min = 1, max = 1 },  -- ap chance
		mdragon_life = 8,  -- undying cost
		mdragon_stalwart = { min = 0.0125 * upd_t, max = 0.05 * upd_t },
	}) do
		self.values.player[upgrade] = { value }
		self.definitions["player_" .. upgrade] = {
			name_id = "bingus",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = upgrade,
				category = "player"
			}
		}
	end

end )
