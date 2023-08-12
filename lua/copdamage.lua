local sh = BLT.Mods:GetModByName("Streamlined Heisting")
local is_streamlined = sh and sh:IsEnabled() and sh:WasEnabledAtStart() and StreamHeist and true


Hooks:PostHook( CopDamage, "roll_critical_hit", "mdragon_roll_critical_hit", function(self, attack_data)

	local critical_hit, damage = Hooks:GetReturn()

	-- check that the hit is a melee that isnt already a crit
	if critical_hit or attack_data.variant ~= "melee" then
		return critical_hit, damage
	end

	-- check again that the hit can crit
	if not self:can_be_critical(attack_data) then
		return critical_hit, damage
	end

	if not managers.player:mdragon_try_melee_bonus() then
		return critical_hit, damage
	end

	critical_hit = true

	local critical_damage_mul
	if is_streamlined then
		critical_damage_mul = 3
	else
		local critical_hits = self._char_tweak.critical_hits or {}

		critical_damage_mul = critical_hits.damage_mul or self._char_tweak.headshot_dmg_mul
	end

	damage = critical_damage_mul and damage * critical_damage_mul or self._health * 10

	return critical_hit, damage

end )

Hooks:PreHook( CopDamage, "damage_bullet", "mdragon_damage_bullet", function(self, attack_data)
	if self:is_head(attack_data.col_ray.body) then
		self:_mdragon_headshot_bonus_helper(attack_data)
	end
end )

Hooks:PreHook( CopDamage, "damage_melee", "mdragon_damage_melee", function(self, attack_data)
	if self:_mdragon_headshot_bonus_helper(attack_data) then
		attack_data.damage = self._HEALTH_INIT
	end
end )

function CopDamage:mdragon_chk_ruthless_allowed()
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


-- this is a bit disgusting, accessing private stuff from here, but eh.
local forbidden_hurt_types = table.set("light_hurt", "healed")
function CopDamage:_mdragon_chk_is_enemy_disabled(attack_data)
	if self._dead or self._invulnerable then
		return false
	end

	if self:chk_immune_to_attacker(attack_data.attacker_unit) then
		return false
	end

	local movement = alive(self._unit) and self._unit:movement()
	local active_actions = movement and movement._active_actions
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

function CopDamage:_mdragon_headshot_bonus_helper(attack_data)
	if not self:_mdragon_chk_is_enemy_disabled(attack_data) then
		return false
	end

	if not managers.player:mdragon_try_headshot_bonus() then
		return false
	end

	self.check_medic_heal = function() return false end
	self._apply_damage_reduction = function(self, damage) return damage end

	local char_tweak = clone(self._char_tweak)

	char_tweak.headshot_dmg_mul = nil
	char_tweak.bullet_damage_only_from_front = nil
	char_tweak.DAMAGE_CLAMP_BULLET = nil

	self._char_tweak = char_tweak

	self._has_plate = nil
	self._marked_dmg_dist_mul = nil
	self._damage_reduction_multiplier = nil

	return true
end
