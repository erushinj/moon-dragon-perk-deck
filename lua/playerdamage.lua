PlayerDamage._mdragon_health_regen_update_timer = nil

local _check_bleed_out_original = PlayerDamage._check_bleed_out
function PlayerDamage:_check_bleed_out(can_activate_berserker, ...)
	if not (self:get_real_health() == 0 and can_activate_berserker) then
		return _check_bleed_out_original(self, can_activate_berserker, ...)
	end

	if not managers.player:mdragon_try_undying_bonus() then
		return _check_bleed_out_original(self, can_activate_berserker, ...)
	end

	self:set_health(0.1)

	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})

	self:_send_set_health()
	self:_regenerate_armor()
end

Hooks:PostHook( PlayerDamage, "_upd_health_regen", "mdragon__upd_health_regen", function(self, t, dt)
	if managers.player:is_mdragon() then
		if self._mdragon_health_regen_update_timer then
			self._mdragon_health_regen_update_timer = self._mdragon_health_regen_update_timer - dt

			if self._mdragon_health_regen_update_timer <= 0 then
				self._mdragon_health_regen_update_timer = nil
			end
		end

		if not self._mdragon_health_regen_update_timer then
			if self:get_real_health() < self:_max_health() then
				self:restore_health(managers.player:mdragon_get_survivor_amount(), false)

				self._mdragon_health_regen_update_timer = 1
			end
		end
	end
end)
