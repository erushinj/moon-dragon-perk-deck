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
	if self:_mdragon_bonuses_valid(attack_data) then
		if self:is_head(attack_data.col_ray.body) then
			self:_mdragon_headshot_bonus_helper(attack_data)
		end
	end
end )

local damage_melee_original = CopDamage.damage_melee
function CopDamage:damage_melee(attack_data, ...)
	if self:_mdragon_bonuses_valid(attack_data) then
		if self:_mdragon_headshot_bonus_helper(attack_data) then
			attack_data.damage = self._HEALTH_INIT
		end
	end

	local result = damage_melee_original(self, attack_data, ...)

	if type(result) == "table" then
		managers.player:send_message( Message.OnEnemyShot, "mdragon", self._unit, attack_data )
	end

	return result
end

-- Hooks:PreHook( CopDamage, "damage_melee", "mdragon_damage_melee", function(self, attack_data)
-- 	if self:_mdragon_bonuses_valid(attack_data) then
-- 		managers.player:mdragon_on_melee_attack()

-- 		if self:_mdragon_headshot_bonus_helper(attack_data) then
-- 			attack_data.damage = self._HEALTH_INIT
-- 		end
-- 	end
-- end )

function CopDamage:_mdragon_bonuses_valid(attack_data)
	if self:mdragon_not_hostage() and not self._dead then
		if attack_data.attacker_unit == managers.player:local_player() then
			return true
		end
	end

	return false
end

local forbidden_slots = table.set(16, 22)
function CopDamage:mdragon_not_hostage()
	local unit = alive(self._unit) and self._unit

	if not unit or managers.enemy:is_civilian(unit) then
		return false
	end

	for slot in pairs(forbidden_slots) do
		if not unit or unit:in_slot(slot) then
			return false
		end
	end

	return true
end

function CopDamage:mdragon_chk_ruthless()
	return not self._dead and not self._char_tweak.immune_to_knock_down
end

function CopDamage:mdragon_chk_is_special()
	local unit_base = alive(self._unit) and self._unit:base()

	return unit_base and unit_base:has_tag("special")
end

function CopDamage:mdragon_chk_has_shield()
	local unit_inventory = alive(self._unit) and self._unit:inventory()

	return unit_inventory and alive(unit_inventory:shield_unit())
end

local forbidden_tags = { "tank", "phalanx_vip", }
local forbidden_hurt_types = table.set("light_hurt", "healed")
function CopDamage:_mdragon_chk_is_enemy_disabled(attack_data)
	if self._dead or self._invulnerable then
		return false
	end

	local unit = self._unit
	local unit_base = unit:base()
	local has_forbidden_tag = unit_base:has_any_tag(forbidden_tags)
	local has_forbidden_tweak = unit_base:char_tweak_name():match("boss")
	if has_forbidden_tag or has_forbidden_tweak then
		return false
	end

	if self:chk_immune_to_attacker(attack_data.attacker_unit) then
		return false
	end

	local active_actions = unit:movement()._active_actions
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
