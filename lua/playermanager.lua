local mdragon_data = tweak_data.upgrades.mdragon_data

local wf_hud = BLT.Mods:GetModByName("Warframe HUD")
local has_wf_hud = wf_hud and wf_hud:IsEnabled() and WFHud and true

PlayerManager._is_mdragon = false
PlayerManager._mdragon_heat_stacks = mdragon_data.stacks_min
PlayerManager._mdragon_ratio = 0
PlayerManager._mdragon_decay = false
PlayerManager._mdragon_decay_t = nil
PlayerManager._mdragon_decay_bank = 0

Hooks:PostHook( PlayerManager, "check_skills", "mdragon_check_skills", function(self)

	if self:has_category_upgrade("player", "mdragon") then
		self._is_mdragon = true

		local function on_player_damage()
			if self:_mdragon_chk_armor() then
				self:_mdragon_interupt_decay()
				self:_mdragon_add_stacks()
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

			if not character_damage:mdragon_chk_ruthless_allowed() then
				return
			end

			local chance = self:mdragon_get_ruthless_amount()
			if chance >= math.random() then
				attack_data.damage = 0
				attack_data.result = attack_data.result or {}
				attack_data.result.type = "stagger"

				character_damage:force_hurt(attack_data)
				character_damage:mdragon_set_staggered(true)
			end
		end

		self._message_system:register( Message.OnEnemyShot, "mdragon_ruthless", on_enemy_shot )
	else
		self._message_system:unregister( Message.OnEnemyShot, "mdragon_ruthless" )
	end

end )


Hooks:PostHook( PlayerManager, "update", "mdragon_update", function(self, t, dt)
	if self._is_mdragon then
		self:_mdragon_upd_hud()
		self:_mdragon_upd_ratio()
		self:_mdragon_upd_decay(t, dt)
	end
end )


Hooks:PostHook( PlayerManager, "movement_speed_multiplier", "mdragon_movement_speed_multiplier", function(self)
	return Hooks:GetReturn() * self:mdragon_get_swift_amount()
end )


-- killed_unit, variant, headshot, weapon_id
Hooks:PostHook( PlayerManager, "on_killshot", "mdragon_on_killshot", function(self, killed_unit, variant, headshot, weapon_id)
	if not self:_mdragon_chk_player_dead() then
		if variant == "melee" and self:mdragon_try_melee_bonus() then
			self:_mdragon_interupt_decay()
			self:local_player():character_damage():regenerate_armor()
		elseif headshot and self:mdragon_try_headshot_bonus() then
			local character_damage = killed_unit and killed_unit:character_damage()
			if not character_damage or not character_damage:mdragon_chk_is_special() then
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
					local cop_damage = alive(unit) and unit and unit:character_damage()

					if cop_damage then
						if not cop_damage:dead() and not cop_damage:mdragon_chk_is_special() then
							cop_damage:build_suppression(0, -1)
						end
					end
				end
			end
		end
	end
end )

function PlayerManager:is_mdragon()
	return self._is_mdragon
end

function PlayerManager:_mdragon_upd_ratio()
	self._mdragon_ratio = math.clamp(self._mdragon_heat_stacks / mdragon_data.stacks_max, 0, 1)
end

function PlayerManager:_mdragon_upd_decay(t, dt)
	if not self._mdragon_decay then
		self:_mdragon_reset_decay_t()
		self:_mdragon_reset_decay_bank()
	end

	if self:_mdragon_chk_player_dead() then
		return
	end

	if self:local_player():character_damage():get_real_armor() > 0 then
		self:_mdragon_reenable_decay()
	end

	self._mdragon_decay_t = self._mdragon_decay_t or t + mdragon_data.stacks_decay_t
	if self._mdragon_decay_t > t then
		return
	end

	self._mdragon_decay_bank = self._mdragon_decay_bank + (dt * mdragon_data.stacks_decay_dt_mul)

	if self._mdragon_decay_bank >= 1 then
		self:_mdragon_decay_stacks()
		self:_mdragon_reset_decay_bank()
	end
end

function PlayerManager:_mdragon_upd_hud()
	if managers.hud then
		managers.hud:set_stored_health_max(mdragon_data.stacks_max)
		managers.hud:set_stored_health(self._mdragon_ratio)

		if has_wf_hud then
			local stacks = WFHud.value_format.default(self._mdragon_heat_stacks)

			WFHud:add_buff("player", "armor_health_store_amount", stacks)
		end
	end
end

function PlayerManager:_mdragon_passive_ability_amount(category, upgrade, default)
	if not self._is_mdragon then
		return default
	end

	local value = self:upgrade_value(category, upgrade, { min = default, max = default })
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
	if not self._is_mdragon then
		return false
	end

	local default = mdragon_data.stacks_max + 1
	local cost = self:upgrade_value(category, upgrade, default) or default
	if self._mdragon_heat_stacks >= cost then
		if spend then
			self:_mdragon_spend_stacks(cost)
		end

		return true
	end

	return false
end

function PlayerManager:mdragon_fright_radius()
	return mdragon_data.fright_radius
end

function PlayerManager:mdragon_try_sprint_bonus()
	return self:_mdragon_chk_active_ability("player", "mdragon_flight", false)
end

-- was true
function PlayerManager:mdragon_upd_sprint_bonus()
	return self:_mdragon_chk_active_ability("player", "mdragon_flight", false)
end

-- was true
function PlayerManager:mdragon_try_melee_bonus()
	return self:_mdragon_chk_active_ability("player", "mdragon_might", false)
end

-- was true
function PlayerManager:mdragon_try_headshot_bonus()
	return self:_mdragon_chk_active_ability("weapon", "mdragon_fright", false)
end

function PlayerManager:mdragon_try_undying_bonus()
	return self:_mdragon_chk_active_ability("player", "mdragon_life", true)
end

function PlayerManager:_mdragon_interupt_decay()
	self._mdragon_decay = false
end

function PlayerManager:_mdragon_reenable_decay()
	self._mdragon_decay = true
end

function PlayerManager:_mdragon_reset_decay_t()
	self._mdragon_decay_t = nil
end

function PlayerManager:_mdragon_reset_decay_bank()
	self._mdragon_decay_bank = 0
end

function PlayerManager:_mdragon_chk_armor()
	if not self._is_mdragon then
		return false
	end

	if self:_mdragon_chk_player_dead() then
		return false
	end

	local armor = managers.blackmarket:equipped_armor(mdragon_data.works_with_armor_kit, true)
	if not mdragon_data.armors_allowed[armor] then
		return false
	end

	return true
end

function PlayerManager:_mdragon_chk_player_dead()
	if alive(self:local_player()) then
		return false
	end

	self:_mdragon_interupt_decay()
	self:_mdragon_reset_decay_t()
	self:_mdragon_reset_decay_bank()
	self:_mdragon_empty_stacks()

	return true
end

-- set stacks to minimum (0)
function PlayerManager:_mdragon_empty_stacks()
	self._mdragon_heat_stacks = mdragon_data.stacks_min
end

-- set stacks to maximum (20)
function PlayerManager:_mdragon_fill_stacks()
	self._mdragon_heat_stacks = mdragon_data.stacks_max
end

-- adds stacks, amount varying on bleedout or not
function PlayerManager:_mdragon_add_stacks()
	if self:_mdragon_chk_player_dead() then
		return
	end

	if self:local_player():character_damage():bleed_out() then
		self:_mdragon_fill_stacks()

		return
	end

	local max = mdragon_data.stacks_max
	local add = mdragon_data.stacks_gain

	self._mdragon_heat_stacks = math.min(self._mdragon_heat_stacks + add, max)
end

-- decay stacks due to time
function PlayerManager:_mdragon_decay_stacks()
	if self:_mdragon_chk_player_dead() then
		return
	end

	local min = mdragon_data.stacks_min
	local decay = mdragon_data.stacks_decay

	self._mdragon_heat_stacks = math.max(self._mdragon_heat_stacks - decay, min)
end

-- use stacks
function PlayerManager:_mdragon_spend_stacks(cost)
	if self:_mdragon_chk_player_dead() then
		return
	end

	local min = mdragon_data.stacks_min
	local max = mdragon_data.stacks_max

	self._mdragon_heat_stacks = math.clamp(self._mdragon_heat_stacks - cost, min, max)
end
