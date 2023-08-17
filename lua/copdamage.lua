local guaranteed = function() return 2 end
local roll_critical_hit_original = CopDamage.roll_critical_hit
function CopDamage:roll_critical_hit(attack_data, ...)
	local can_crit = self:can_be_critical(attack_data)
	local is_melee = attack_data.variant == "melee"

	if can_crit and is_melee and managers.player:mdragon_try_melee_bonus() then
		managers.player.critical_hit_chance = guaranteed
	end

	local result = { roll_critical_hit_original(self, attack_data, ...) }

	managers.player.critical_hit_chance = nil

	return unpack(result)
end

Hooks:PreHook( CopDamage, "damage_bullet", "mdragon_damage_bullet", function(self, attack_data)
	if self:mdragon_not_hostage() and self:mdragon_chk_attacker_is_player(attack_data) then
		if self:is_head(attack_data.col_ray.body) then
			managers.player:mdragon_reset_decay()

			self:_mdragon_headshot_bonus_helper(attack_data)
		end
	end
end )

Hooks:PreHook( CopDamage, "damage_melee", "mdragon_damage_melee", function(self, attack_data)
	if self:mdragon_not_hostage() and self:mdragon_chk_attacker_is_player(attack_data) then
		managers.player:mdragon_reset_decay()

		if managers.player:mdragon_try_melee_bonus() then
			managers.player:mdragon_melee_add_armor("strike")
		end

		if self:_mdragon_headshot_bonus_helper(attack_data) then
			attack_data.damage = self._HEALTH_INIT
		end
	end
end )

function CopDamage:mdragon_chk_attacker_is_player(attack_data)
	return attack_data and attack_data.attacker_unit == managers.player:local_player()
end

function CopDamage:mdragon_not_hostage()
	return alive(self._unit) and not self._unit:in_slot(16) and not self._unit:in_slot(22)
end

function CopDamage:mdragon_chk_ruthless()
	if self._dead or self._char_tweak.immune_to_knock_down then
		return false
	end

	return true
end

function CopDamage:mdragon_chk_is_special()
	return self._unit:base():has_tag("special")
end

function CopDamage:mdragon_chk_has_shield()
	return self._unit:inventory() and alive(self._unit:inventory():shield_unit())
end


local forbidden_hurt_types = table.set("light_hurt", "healed")
function CopDamage:_mdragon_chk_is_enemy_disabled(attack_data)
	if self._dead or self._invulnerable then
		return false
	end

	if self:chk_immune_to_attacker(attack_data.attacker_unit) then
		return false
	end

	local active_actions = self._unit:movement()._active_actions
	local full_body_action = active_actions and active_actions[1]
	if not full_body_action then
		return false
	end

	local action_type = full_body_action:type()
	if action_type == "hurt" then
		if not forbidden_hurt_types[full_body_action:hurt_type()] then
			return true
		end
	elseif action_type == "act" then
		local variant = full_body_action._action_desc.variant or ""

		if variant:match("fumble") or variant:match("panic") then
			return true
		end
	end

	return false
end

local no_medic_heal = function() return false end
local no_damage_reduction = function(self, damage) return damage end
function CopDamage:_mdragon_headshot_bonus_helper(attack_data)
	if not self:_mdragon_chk_is_enemy_disabled(attack_data) then
		return false
	end

	if not managers.player:mdragon_try_headshot_bonus() then
		return false
	end

	local char_tweak = clone(self._char_tweak)

	char_tweak.headshot_dmg_mul = nil
	char_tweak.bullet_damage_only_from_front = nil
	char_tweak.DAMAGE_CLAMP_BULLET = nil

	self._char_tweak = char_tweak
	self.check_medic_heal = no_medic_heal
	self._apply_damage_reduction = no_damage_reduction
	self._has_plate = nil
	self._marked_dmg_dist_mul = nil
	self._damage_reduction_multiplier = nil

	return true
end
