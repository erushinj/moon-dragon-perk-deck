local is_streamlined = StreamHeist and true or false

CopDamage._mdragon_staggered = false

Hooks:PostHook( CopDamage, "init", "mdragon_init", function(self, unit)
	local function reset_stagger()
		self._mdragon_staggered = false
	end

	managers.player:register_message(Message.ResetStagger, self, reset_stagger)
end )


Hooks:PostHook( CopDamage, "roll_critical_hit", "mdragon_roll_critical_hit", function(self, attack_data)

	local critical_hit, damage = Hooks:GetReturn()

	-- check again that the hit can crit
	if not self:can_be_critical(attack_data) then
		return false, damage
	end

	-- check that the hit is a melee that isnt already a crit
	if critical_hit or attack_data.variant ~= "melee" then
		return critical_hit, damage
	end

	if not managers.player:mdragon_try_melee_bonus() then
		return critical_hit, damage
	end

	local critical_damage_mul
	if is_streamlined then
		critical_damage_mul = 3
	else
		local critical_hits = self._char_tweak.critical_hits or {}

		critical_damage_mul = critical_hits.damage_mul or self._char_tweak.headshot_dmg_mul
	end

	damage = critical_damage_mul and damage * critical_damage_mul or self._health * 10

	return true, damage

end )

function CopDamage:mdragon_chk_forbidden_tags(tags)
	return self._unit:base():has_any_tag(tags)
end

function CopDamage:mdragon_chk_ruthless_allowed()
	if self._dead or self._char_tweak.immune_to_knock_down then
		return false
	end

	return true
end

function CopDamage:mdragon_chk_is_special()
	return self._unit:base():has_tag("special")
end

function CopDamage:mdragon_set_staggered(state)
	self._mdragon_staggered = not not state
end

local stagger_hurts = table.set("hurt", "heavy_hurt", "expl_hurt")
function CopDamage:_mdragon_stagger_helper(damage, attack_data, category)
	if self._dead or self._char_tweak.immune_to_knock_down then
		log("dead or immune to knock down")

		return false
	end

	local staggered = attack_data.knock_down or attack_data.stagger or nil

	if not staggered then
		local precent, granularity = self._HEALTH_INIT_PRECENT, self._HEALTH_GRANULARITY
		local damage_percent = math.ceil(math.clamp(damage / precent, 1, granularity))
		local damage_result = self:get_damage_type(damage_percent, category)

		log(tostring(damage_result))
		log(tostring(damage))

		staggered = stagger_hurts[damage_result] or false
	end

	log("unit stagger", tostring(staggered))

	return staggered
end

local damage_bullet_original = CopDamage.damage_bullet
function CopDamage:damage_bullet(attack_data, ...)
	if not self:is_head(attack_data.col_ray.body) then
		log("not a headshot")

		return damage_bullet_original(self, attack_data, ...)
	end

	-- must be previously staggered or currently panicking
	local panic_state = self._unit:movement():mdragon_panic_state()
	if not self._mdragon_staggered then
		local damage
		if self._char_tweak.headshot_dmg_mul then
			damage = attack_data.damage * self._char_tweak.headshot_dmg_mul
		else
			damage = self._health * 10
		end

		local staggered = self:_mdragon_stagger_helper(damage, attack_data, "bullet")
		log(tostring(staggered))

		if staggered then
			self._mdragon_staggered = true

			if not panic_state then
				log("not staggered prior, not panicking")

				return damage_bullet_original(self, attack_data, ...)
			end
		end
	end

	-- check again, either staggered or panicking
	if not panic_state and not self._mdragon_staggered then
		log("not currently staggered, not panicking")

		return damage_bullet_original(self, attack_data, ...)
	end

	-- must meet the stack requirement
	if not managers.player:mdragon_try_headshot_bonus() then
		log("not enough stacks")

		return damage_bullet_original(self, attack_data, ...)
	end

	-- dummy out various functions and variables, ensures the kill
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

	return damage_bullet_original(self, attack_data, ...)
end

-- function CopDamage:damage_bullet(...)
-- 	local result = damage_bullet_original(self, ...)

-- 	-- return if the original call failed
-- 	if not result then
-- 		log("original call failed")

-- 		return result
-- 	end

-- 	-- unit kind of needs to be alive
-- 	if result.type == "death" then
-- 		log("dead, numbnuts")

-- 		return result
-- 	end

-- 	-- must be a headshot
-- 	if not result.attack_data or not result.attack_data.headshot then
-- 		log("not headshot")

-- 		return result
-- 	end

-- 	-- must be previously staggered or currently panicking
-- 	local panic_state = self._unit:movement():mdragon_panic_state()
-- 	if result.type == "knock_down" or result.type == "stagger" then
-- 		if not self._mdragon_staggered then
-- 			self._mdragon_staggered = true

-- 			if not panic_state then
-- 				log("not staggered prior, not panicking")

-- 				return result
-- 			end
-- 		end
-- 	end

-- 	-- check again, either staggered or panicking
-- 	local staggered = self._mdragon_staggered
-- 	if not staggered or not panic_state then
-- 		log("not currently staggered, not panicking")

-- 		return result
-- 	end

-- 	-- must meet the stack requirement
-- 	local try_headshot_bonus = managers.player:mdragon_try_headshot_bonus()
-- 	if not try_headshot_bonus then
-- 		log("not enough stacks")

-- 		return result
-- 	end

-- 	-- dummy out various functions and variables, ensures the kill
-- 	self.check_medic_heal = function()
-- 		return false
-- 	end

-- 	self._apply_damage_reduction = function(self, damage)
-- 		return damage
-- 	end

-- 	local char_tweak = clone(self._char_tweak)

-- 	char_tweak.headshot_dmg_mul = nil
-- 	char_tweak.bullet_damage_only_from_front = nil
-- 	char_tweak.DAMAGE_CLAMP_BULLET = nil

-- 	self._char_tweak = char_tweak

-- 	self._has_plate = nil
-- 	self._marked_dmg_dist_mul = nil
-- 	self._damage_reduction_multiplier = nil

-- 	-- cause panic on defeating a special this way
-- 	if self._unit:base():has_tag("special") then

-- 	end

-- 	-- return a new call with the changed data
-- 	return damage_bullet_original(self, ...)
-- end
