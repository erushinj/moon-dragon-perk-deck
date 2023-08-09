-- PlayerStandard._mdragon_decay_stacks_t = nil

local _update_running_timers_original = PlayerStandard._update_running_timers
-- function PlayerStandard:_update_running_timers(t, ...)
-- 	local is_stamina_drained = self._unit:movement():is_stamina_drained()
-- 	local can_run_directional = self:_can_run_directional()
-- 	local try_sprint_bonus = managers.player:mdragon_try_sprint_bonus()
-- 	local success = is_stamina_drained and can_run_directional and try_sprint_bonus

-- 	if self._end_running_expire_t or not success then
-- 		return _update_running_timers_original(self, t, ...)
-- 	end

-- 	self._mdragon_decay_stacks_t = self._mdragon_decay_stacks_t or t + 1
-- 	if self._mdragon_decay_stacks_t <= t then
-- 		self._mdragon_decay_stacks_t = nil

-- 		managers.player:mdragon_upd_sprint_bonus()
-- 	end
-- end

function PlayerStandard:_update_running_timers(t, ...)
	local try_sprint_bonus = managers.player:mdragon_try_sprint_bonus()

	if self._end_running_expire_t or not try_sprint_bonus then
		return _update_running_timers_original(self, t, ...)
	end
end

Hooks:PostHook( PlayerStandard, "_can_run_directional", "mdragon__can_run_directional", function(self)
	return Hooks:GetReturn() or managers.player:mdragon_try_sprint_bonus()
end )

Hooks:PostHook( PlayerStandard, "_get_swap_speed_multiplier", "mdragon__get_swap_speed_multiplier", function(self)
	return Hooks:GetReturn() * managers.player:mdragon_get_nimble_amount()
end )
