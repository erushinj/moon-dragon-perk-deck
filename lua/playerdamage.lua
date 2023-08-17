-- renamed some parameters for sake of keeping code under 100 columns.
local _check_bleed_out_original = PlayerDamage._check_bleed_out
function PlayerDamage:_check_bleed_out(can_swan_song, was_fall, ignore_reduce_revive, ...)
	local unit = self._unit
	local time = Application:time()
	local pass = can_swan_song and not was_fall and not ignore_reduce_revive
	pass = pass and self:get_real_health() <= 0
	pass = pass and not self._bleed_out_blocked_by_zipline and not unit:movement():zipline_unit()
	pass = pass and not self._bleed_out_blocked_by_movement_state
	pass = pass and not self._block_medkit_auto_revive
	pass = pass and time > self._uppers_elapsed + self._UPPERS_COOLDOWN
	pass = pass and managers.player:mdragon_try_undying_bonus()

	if not pass then
		return _check_bleed_out_original(self, can_swan_song, was_fall, ignore_reduce_revive, ...)
	end

	self._said_hurt = false
	self._uppers_elapsed = time

	self:change_health(self:_max_health() * self._healing_reduction)

	unit:sound():play("pickup_fak_skill")
end
