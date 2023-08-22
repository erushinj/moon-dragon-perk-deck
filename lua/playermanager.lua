local mdragon_data = tweak_data.upgrades.mdragon_data

local wf_hud = BLT.Mods:GetModByName("Warframe HUD")
local has_wf_hud = wf_hud and wf_hud:IsEnabled() and WFHud and true

PlayerManager._is_mdragon = false
PlayerManager._mdragon_decay = false
PlayerManager._mdragon_upd_t = 0
PlayerManager._mdragon_stacks = 0
PlayerManager._mdragon_ratio = 0
PlayerManager._mdragon_decay_t = 0
PlayerManager._mdragon_absorption = 0

Hooks:PostHook( PlayerManager, "check_skills", "mdragon_check_skills", function(self)

	if self:has_category_upgrade("player", "mdragon") then
		self._is_mdragon = true

		local allowed_variants = table.set("bullet", "melee")
		local function on_enemy_shot(unit, attack_data)
			if not self:_mdragon_valid() then
				return
			end

			if not attack_data or attack_data.attacker_unit ~= self:local_player() then
				return
			end

			if not allowed_variants[attack_data.variant] then
				return
			end

			self._mdragon_decay = false

			if attack_data.variant == "melee" then
				self:_mdragon_change_stacks(mdragon_data.stacks_gain)
				self:_mdragon_melee_add_armor()
			end

			local cop_damage = alive(unit) and unit:character_damage()
			if not cop_damage then
				return
			end

			-- must be an enemy unit - probably not one if lacking these
			if not cop_damage.mdragon_chk_ruthless or not cop_damage.mdragon_chk_has_shield then
				return
			end

			-- must be allowed to stagger
			if not cop_damage:mdragon_chk_ruthless() then
				return
			end

			local chance = self:mdragon_get_staggering_amount()
			if chance >= math.random() then
				local is_shield = cop_damage:mdragon_chk_has_shield()
				local result_type = is_shield and "shield_knock" or "stagger"

				attack_data.result = attack_data.result or {}
				attack_data.result.type = result_type
				attack_data[result_type] = true
				attack_data.damage = 0

				cop_damage:force_hurt(attack_data)
			end
		end

		self._message_system:register( Message.OnEnemyShot, "mdragon", on_enemy_shot )

		local function on_player_damage()
			if not self:_mdragon_valid() then
				return
			end

			self._mdragon_decay = false
		end

		self._message_system:register( Message.OnPlayerDamage, "mdragon", on_player_damage )
	else
		self._is_mdragon = false

		self._message_system:unregister( Message.OnEnemyShot, "mdragon" )
		self._message_system:unregister( Message.OnPlayerDamage, "mdragon" )
	end

end )


Hooks:PostHook( PlayerManager, "movement_speed_multiplier", "mdragon_movement_speed_multiplier", function(self)
	return Hooks:GetReturn() * self:mdragon_get_swift_amount()
end )


Hooks:PostHook( PlayerManager, "damage_absorption", "mdragon_damage_absorption", function(self)
	return Hooks:GetReturn() + self._mdragon_absorption
end )


Hooks:PostHook( PlayerManager, "on_killshot", "mdragon_on_killshot", function(self, killed_unit, variant, headshot, weapon_id)
	if self:_mdragon_valid() then
		local cop_damage = killed_unit:character_damage()

		if cop_damage and cop_damage.mdragon_not_hostage and cop_damage:mdragon_not_hostage() then
			if variant == "melee" then
				if cop_damage.mdragon_chk_is_special and cop_damage:mdragon_chk_is_special() then
					self:_mdragon_panic_helper(killed_unit)
				end
			end
		end
	end
end )


Hooks:PostHook( PlayerManager, "update", "mdragon_update", function(self, t, dt)
	if self._mdragon_upd_t <= t then
		self._mdragon_upd_t = t + mdragon_data.upd_t

		if self:_mdragon_valid() then
			self:_mdragon_upd_regen()
			self:_mdragon_upd_decay(t)
			self:_mdragon_upd_ratio()
			self:_mdragon_upd_absorption()
			self:_mdragon_upd_hud()
		end
	end
end )


function PlayerManager:_mdragon_panic_helper(killed_unit)
	local player_pos = self:local_player():movement():m_pos()
	local unit_pos = killed_unit:movement():m_pos()
	local distance_sq = mvector3.distance_sq(player_pos, unit_pos)

	if distance_sq <= mdragon_data.fright_radius_sq then
		local slotmask = managers.slot:get_mask("enemies")
		local fright_radius = mdragon_data.fright_radius
		local units = World:find_units_quick("sphere", player_pos, fright_radius, slotmask)

		for e_key, unit in pairs(units) do
			local cop_damage = alive(unit) and unit:character_damage()

			if cop_damage and cop_damage.mdragon_chk_is_special then
				if not cop_damage:dead() and not cop_damage:mdragon_chk_is_special() then
					cop_damage:build_suppression(0, -1)
				end
			end
		end
	end
end

function PlayerManager:_mdragon_valid()
	if alive(self:local_player()) and self._is_mdragon then
		if mdragon_data.armor_whitelist[managers.blackmarket:equipped_armor(true, true)] then
			return true
		end
	end

	self._mdragon_decay = false
	self._mdragon_stacks = 0
	self._mdragon_ratio = 0
	self._mdragon_absorption = 0

	return false
end

function PlayerManager:_mdragon_upd_regen()
	if self:_mdragon_no_stacks() then
		return
	end

	local player_damage = self:local_player():character_damage()
	if player_damage:get_real_health() < player_damage:_max_health() then
		player_damage:restore_health(self:mdragon_get_stalwart_amount(), false, false)
	end
end

function PlayerManager:_mdragon_upd_decay(t)
	if not self._mdragon_decay then
		self._mdragon_decay_t = t + mdragon_data.stacks_start_decay_t
	end

	local player_damage = self:local_player():character_damage()
	local armor = player_damage:get_real_armor()
	local threshold = player_damage:_max_armor() * mdragon_data.armor_decay_threshold

	if player_damage:is_downed() then
		self._mdragon_decay = false
		self._mdragon_stacks = 0
		self._mdragon_ratio = 0
		self._mdragon_absorption = 0
	else
		if armor < threshold or self._mdragon_stacks <= 0 then
			self._mdragon_decay = false
		else
			self._mdragon_decay = true
		end
	end

	if self._mdragon_decay_t > t then
		return
	end

	self._mdragon_decay_t = t + mdragon_data.stacks_repeat_decay_t

	self:_mdragon_change_stacks(mdragon_data.stacks_decay)
end

function PlayerManager:_mdragon_upd_ratio()
	self._mdragon_ratio = math.clamp(self._mdragon_stacks / mdragon_data.stacks_max, 0, 1)
end

function PlayerManager:_mdragon_upd_absorption()
	local change = mdragon_data.absorption_gain
	local movement = self:local_player():movement()
	local state = movement and movement:current_state()
	local is_meleeing = state and state:_is_meleeing()

	if not is_meleeing then
		change = mdragon_data.absorption_decay
	end

	if not mdragon_data.absorption_max then
		if tweak_data and tweak_data.weapon and tweak_data.character then
			local dmg = tweak_data.weapon.m4_npc.DAMAGE
			local dmg_mul = tweak_data.character.heavy_swat.weapon.is_rifle.FALLOFF[1].dmg_mul
			local max_mul = mdragon_data.absorption_max_mul

			mdragon_data.absorption_max = math.round(dmg * dmg_mul * max_mul, 0.1)
		end
	end

	local max = mdragon_data.absorption_max or 0

	self._mdragon_absorption = math.clamp(self._mdragon_absorption + change, 0, max)
end

function PlayerManager:_mdragon_upd_hud()
	if not managers.hud then
		return
	end

	local damage_absorption = self:damage_absorption()

	managers.hud:set_stored_health_max(mdragon_data.stacks_max)
	managers.hud:set_stored_health(self._mdragon_ratio)
	managers.hud:set_absorb_active(HUDManager.PLAYER_PANEL, damage_absorption)

	if not has_wf_hud then
		return
	end

	local mdragon_stacks = self._mdragon_stacks
	if mdragon_stacks > 0 then
		local stacks = WFHud.value_format.default(mdragon_stacks)

		WFHud:add_buff("player", "armor_health_store_amount", stacks)
	else
		WFHud:remove_buff("player", "armor_health_store_amount")
	end

	if damage_absorption > 0 then
		WFHud:add_buff("player", "cocaine_stacking", tostring(math.ceil(damage_absorption * 10)))
	else
		WFHud:remove_buff("player", "cocaine_stacking")
	end
end

function PlayerManager:is_mdragon()
	return self._is_mdragon
end

function PlayerManager:_mdragon_no_stacks()
	return self._mdragon_stacks <= 0
end

function PlayerManager:_mdragon_passive_ability_amount(upgrade, default)
	local value = self:upgrade_value_nil("player", upgrade)

	if not self:_mdragon_valid() or self:_mdragon_no_stacks() or not value then
		return default
	end

	return math.lerp(value.min, value.max, self._mdragon_ratio)
end

function PlayerManager:mdragon_get_swift_amount()
	return self:_mdragon_passive_ability_amount("mdragon_swift", 1)
end

function PlayerManager:mdragon_get_slick_amount()
	return self:_mdragon_passive_ability_amount("mdragon_slick", 1)
end

function PlayerManager:mdragon_get_staggering_amount()
	return self:_mdragon_passive_ability_amount("mdragon_staggering", 0)
end

function PlayerManager:mdragon_get_shattering_amount()
	return self:_mdragon_passive_ability_amount("mdragon_shattering", 0)
end

function PlayerManager:mdragon_get_stalwart_amount()
	return self:_mdragon_passive_ability_amount("mdragon_stalwart", 0)
end

function PlayerManager:_mdragon_chk_active_ability(upgrade, spend)
	local cost = self:upgrade_value_nil("player", upgrade)

	if not self:_mdragon_valid() or not cost or self._mdragon_stacks < cost then
		return false
	end

	if spend then
		self:_mdragon_change_stacks(-cost)
	end

	return true
end

-- guaranteed critical melee strikes
function PlayerManager:mdragon_try_melee_bonus()
	return self:_mdragon_chk_active_ability("mdragon_might", false)
end

-- unlimited sprint in all directions
function PlayerManager:mdragon_try_sprint_bonus()
	return self:_mdragon_chk_active_ability("mdragon_flight", false)
end

-- instant kill on headshotting/meleeing staggered/panicking enemy
function PlayerManager:mdragon_try_headshot_bonus()
	return self:_mdragon_chk_active_ability("mdragon_fright", false)
end

-- fak effect
function PlayerManager:mdragon_try_undying_bonus()
	return self:_mdragon_chk_active_ability("mdragon_life", true)
end

function PlayerManager:mdragon_reset_decay()
	self._mdragon_decay = false
end

function PlayerManager:_mdragon_change_stacks(change)
	self._mdragon_stacks = math.clamp(self._mdragon_stacks + change, 0, mdragon_data.stacks_max)
end

function PlayerManager:_mdragon_melee_add_armor()
	self:local_player():character_damage():restore_armor(mdragon_data.fight_armor_gain)
end
