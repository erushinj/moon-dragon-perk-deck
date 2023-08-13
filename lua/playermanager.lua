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

		local function on_player_damage()
			if self:_mdragon_valid() then
				self._mdragon_decay = false

				self:_mdragon_change_stacks(mdragon_data.stacks_gain)
			end
		end

		self._message_system:register( Message.OnPlayerDamage, "mdragon", on_player_damage )
	else
		self._is_mdragon = false

		self._message_system:unregister( Message.OnPlayerDamage, "mdragon" )
	end

	if self:has_category_upgrade("weapon", "mdragon_ruthless") then
		local function on_enemy_shot(unit, attack_data)
			if not alive(unit) then
				return
			end

			local character_damage = unit:character_damage()
			if not character_damage then
				return
			end

			-- must be an enemy unit - probably not one if lacking these
			local ruthless_func = character_damage.mdragon_chk_ruthless_allowed
			local shield_func = character_damage.mdragon_chk_has_shield
			if not ruthless_func or not shield_func then
				return
			end

			-- must be allowed to stagger
			if not character_damage:mdragon_chk_ruthless_allowed() then
				return
			end

			local chance = self:mdragon_get_ruthless_amount()
			if chance >= math.random() then
				local is_shield = character_damage:mdragon_chk_has_shield()
				local result_type = is_shield and "shield_knock" or "stagger"

				attack_data.result = attack_data.result or {}
				attack_data.result.type = result_type
				attack_data[result_type] = true
				attack_data.damage = 0

				character_damage:force_hurt(attack_data)
			end
		end

		self._message_system:register( Message.OnEnemyShot, "mdragon_ruthless", on_enemy_shot )
	else
		self._message_system:unregister( Message.OnEnemyShot, "mdragon_ruthless" )
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
		if variant == "melee" then
			if self:mdragon_try_melee_bonus() then
				self._mdragon_decay = false

				self:_mdragon_change_stacks(mdragon_data.stacks_gain)
				self:local_player():character_damage():regenerate_armor()
			end
		elseif headshot and self:mdragon_try_headshot_bonus() then
			self:_mdragon_panic_helper(killed_unit)
		end
	end
end )


Hooks:PostHook( PlayerManager, "update", "mdragon_update", function(self, t, dt)
	if self._mdragon_upd_t <= t then
		self._mdragon_upd_t = t + mdragon_data.upd_t

		if self:_mdragon_valid() then
			self:_mdragon_upd_regen()
			self:_mdragon_upd_dexterity()
			self:_mdragon_upd_decay(t)
			self:_mdragon_upd_ratio()
			self:_mdragon_upd_sprint()
			self:_mdragon_upd_hud()
		end
	end
end )


function PlayerManager:_mdragon_panic_helper(killed_unit)
	local character_damage = alive(killed_unit) and killed_unit:character_damage()

	if not character_damage or not character_damage.mdragon_chk_is_special then
		return
	end

	if not character_damage:mdragon_chk_is_special() then
		return
	end

	local player_pos = self:local_player():movement():m_pos()
	local unit_pos = killed_unit:movement():m_pos()
	local distance_sq = mvector3.distance_sq(player_pos, unit_pos)
	if distance_sq <= mdragon_data.fright_radius_sq then
		local slotmask = managers.slot:get_mask("enemies")
		local fright_radius = mdragon_data.fright_radius
		local units = World:find_units_quick("sphere", unit_pos, fright_radius, slotmask)

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

function PlayerManager:_mdragon_chk_armor()
	local armor = managers.blackmarket:equipped_armor(mdragon_data.works_with_armor_kit, true)
	if not mdragon_data.armors_allowed[armor] then
		return false
	end

	return true
end

function PlayerManager:_mdragon_valid()
	local pass = false

	if alive(self:local_player()) and self._is_mdragon then
		local armor = managers.blackmarket:equipped_armor(mdragon_data.works_with_armor_kit, true)

		if mdragon_data.armors_allowed[armor] then
			pass = true
		end
	end

	if not pass then
		self._mdragon_decay = false
		self._mdragon_stacks = 0
		self._mdragon_ratio = 0
		self._mdragon_absorption = 0
	end

	return pass
end

function PlayerManager:_mdragon_upd_regen()
	local character_damage = self:local_player():character_damage()

	if character_damage:get_real_health() < character_damage:_max_health() then
		character_damage:restore_health(self:mdragon_get_survivor_amount(), false, false)
	end
end

function PlayerManager:_mdragon_upd_dexterity()
	local movement = self:local_player():movement()
	local state = movement and movement:current_state()

	if not state then
		return
	end

	if self._mdragon_old_run_and_reload == nil then
		self._mdragon_old_run_and_reload = state.RUN_AND_RELOAD
	end

	if self:mdragon_try_dexterity_bonus() then
		state.RUN_AND_RELOAD = true
	else
		state.RUN_AND_RELOAD = self._mdragon_old_run_and_reload
	end
end

function PlayerManager:_mdragon_upd_decay(t)
	if not self._mdragon_decay then
		self._mdragon_decay_t = t + mdragon_data.stacks_start_decay_t
	end

	local character_damage = self:local_player():character_damage()
	if character_damage:bleed_out() then
		self:_mdragon_change_stacks(mdragon_data.stacks_max)
	elseif self._mdragon_stacks > 0 then
		if character_damage:get_real_armor() >= character_damage:_max_armor() then
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

function PlayerManager:_mdragon_upd_sprint()
	local change = mdragon_data.absorption_gain
	local movement = self:local_player():movement()
	local running = movement and movement:current_state() and movement:current_state():running()

	if not self:mdragon_try_sprint_bonus() or not running then
		change = mdragon_data.absorption_decay
	end

	local max = mdragon_data.absorption_max

	self._mdragon_absorption = math.clamp(self._mdragon_absorption + change, 0, max)
end

function PlayerManager:_mdragon_upd_hud()
	if not managers.hud then
		return
	end

	managers.hud:set_stored_health_max(mdragon_data.stacks_max)
	managers.hud:set_stored_health(self._mdragon_ratio)

	if not has_wf_hud then
		return
	end

	local stacks = WFHud.value_format.default(self._mdragon_stacks)
	if tonumber(stacks) > 0 then
		WFHud:add_buff("player", "armor_health_store_amount", stacks)
	else
		WFHud:remove_buff("player", "armor_health_store_amount")
	end

	-- local absorption = WFHud.value_format.default(math.ceil(self:damage_absorption()) * 10)
	local absorption = WFHud.value_format.default(math.round(self:damage_absorption() * 10))
	if tonumber(absorption) > 0 then
		WFHud:add_buff("player", "cocaine_stacking", absorption)
	else
		WFHud:remove_buff("player", "cocaine_stacking")
	end
end

function PlayerManager:_mdragon_passive_ability_amount(category, upgrade, default)
	if not self:_mdragon_valid() then
		return default
	end

	local value = self:upgrade_value(category, upgrade, { default, default })
	if not value then
		return default
	end

	return math.lerp(value.min, value.max, self._mdragon_ratio)
end

function PlayerManager:mdragon_get_swift_amount()
	return self:_mdragon_passive_ability_amount("player", "mdragon_swift", 1)
end

function PlayerManager:mdragon_get_nimble_amount()
	return self:_mdragon_passive_ability_amount("weapon", "mdragon_nimble", 1)
end

function PlayerManager:mdragon_get_ruthless_amount()
	return self:_mdragon_passive_ability_amount("weapon", "mdragon_ruthless", 0)
end

function PlayerManager:mdragon_get_perforating_amount()
	return self:_mdragon_passive_ability_amount("weapon", "mdragon_perforating", 1)
end

function PlayerManager:mdragon_get_survivor_amount()
	return self:_mdragon_passive_ability_amount("player", "mdragon_survivor", 0)
end

function PlayerManager:_mdragon_chk_active_ability(category, upgrade, spend)
	if not self:_mdragon_valid() then
		return false
	end

	local default = mdragon_data.stacks_max + 1
	local cost = self:upgrade_value(category, upgrade, default)
	if self._mdragon_stacks < (cost or default) then
		return false
	end

	if spend then
		self:_mdragon_change_stacks(-cost)
	end

	return true
end

-- guaranteed critical melee strikes
function PlayerManager:mdragon_try_melee_bonus()
	return self:_mdragon_chk_active_ability("player", "mdragon_fight", false)
end

-- unlimited sprint in all directions
function PlayerManager:mdragon_try_sprint_bonus()
	return self:_mdragon_chk_active_ability("player", "mdragon_flight", false)
end

-- instant kill on headshotting/meleeing staggered/panicking enemy
function PlayerManager:mdragon_try_headshot_bonus()
	return self:_mdragon_chk_active_ability("weapon", "mdragon_fright", false)
end

-- reload/swap/melee while sprinting
function PlayerManager:mdragon_try_dexterity_bonus()
	return self:_mdragon_chk_active_ability("player", "mdragon_freight", false)
end

-- fak effect
function PlayerManager:mdragon_try_undying_bonus()
	return self:_mdragon_chk_active_ability("player", "mdragon_freight", true)
end

function PlayerManager:_mdragon_change_stacks(change)
	self._mdragon_stacks = math.clamp(self._mdragon_stacks + change, 0, mdragon_data.stacks_max)
end
