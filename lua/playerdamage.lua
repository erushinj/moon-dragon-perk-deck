local function on_player_damage()
	managers.player:send_message(Message.OnPlayerDamage, "mdragon")
end

Hooks:PostHook( PlayerDamage, "damage_tase", "mdragon_damage_tase", on_player_damage )
Hooks:PostHook( PlayerDamage, "damage_killzone", "mdragon_damage_killzone", on_player_damage )
Hooks:PostHook( PlayerDamage, "damage_explosion", "mdragon_damage_explosion", on_player_damage )
Hooks:PostHook( PlayerDamage, "damage_fire", "mdragon_damage_fire", on_player_damage )
Hooks:PostHook( PlayerDamage, "damage_fire_hit", "mdragon_damage_fire_hit", on_player_damage )
Hooks:PostHook( PlayerDamage, "damage_simple", "mdragon_damage_simple", on_player_damage )

local _check_bleed_out_original = PlayerDamage._check_bleed_out
function PlayerDamage:_check_bleed_out(can_activate_berserker, ignore_movement_state, ...)
	local can_try_undying_bonus = can_activate_berserker

	if ignore_movement_state then
		on_player_damage()

		can_try_undying_bonus = false
	end

	if not can_try_undying_bonus or self:get_real_health() > 0 then
		return _check_bleed_out_original(self, can_activate_berserker, ignore_movement_state, ...)
	end

	if not managers.player:mdragon_try_undying_bonus() then
		return _check_bleed_out_original(self, can_activate_berserker, ignore_movement_state, ...)
	end

	self:set_health(self:_max_health())

	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})

	self:_send_set_health()
	self:_regenerate_armor()
end
