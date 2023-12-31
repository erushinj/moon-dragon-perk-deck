Hooks:PostHook( PlayerStandard, "_can_run_directional", "mdragon__can_run_directional", function(self)
	return Hooks:GetReturn() or managers.player:mdragon_try_sprint_bonus()
end )

Hooks:PostHook( PlayerStandard, "_get_swap_speed_multiplier", "mdragon__get_swap_speed_multiplier", function(self)
	return Hooks:GetReturn() * managers.player:mdragon_get_slick_amount()
end )

-- i hate this so fucking much.
-- this disgusting fucking garbage below is just to make melee while sprinting not be weird.
-- still has some visual bugs. not sure i care enough to try to fix them.

local empty = function() end

PlayerStandard._mdragon_was_meleeing = nil

Hooks:PostHook( PlayerStandard, "init", "mdragon_init", function(self, unit)
	self.RUN_AND_RELOAD = self.RUN_AND_RELOAD or managers.player:is_mdragon()
end )

Hooks:PreHook( PlayerStandard, "_do_action_melee", "mdragon__do_action_melee", function(self)
	-- if self._running then
		self._mdragon_was_meleeing = true
	-- end
end )

local _update_running_timers_original = PlayerStandard._update_running_timers
function PlayerStandard:_update_running_timers(...)
	if self._mdragon_was_meleeing and self._running then
		local is_meleeing = self:_is_meleeing()
		local running_and_reloading = self.RUN_AND_RELOAD and self:_is_reloading()
		local run_and_shoot = self._equipped_unit:base():run_and_shoot_allowed()
		local need_start_running = not running_and_reloading and not run_and_shoot

		if not is_meleeing and need_start_running then
			if self._ext_camera:play_redirect(self:get_animation("start_running")) then
				self._mdragon_was_meleeing = nil
			end
		end
	end

	if self._end_running_expire_t or not managers.player:mdragon_try_sprint_bonus() then
		return _update_running_timers_original(self, ...)
	end
end

local _start_action_melee_original = PlayerStandard._start_action_melee
function PlayerStandard:_start_action_melee(...)
	if managers.player:mdragon_try_sprint_bonus() then
		self._interupt_action_running = empty
	end

	local result = _start_action_melee_original(self, ...)

	self._interupt_action_running = nil

	return result
end

local _start_action_unequip_weapon_original = PlayerStandard._start_action_unequip_weapon
function PlayerStandard:_start_action_unequip_weapon(...)
	if managers.player:mdragon_try_sprint_bonus() then
		self._interupt_action_running = empty
	end

	local result = _start_action_unequip_weapon_original(self, ...)

	self._interupt_action_running = nil

	return result
end

local _start_action_running_original = PlayerStandard._start_action_running
function PlayerStandard:_start_action_running(...)
	if managers.player:mdragon_try_sprint_bonus() then
		if self:_is_meleeing() or self._mdragon_was_meleeing then
			self._ext_camera.play_redirect = empty
		end

		self._is_meleeing = empty
		self._changing_weapon = empty
	end

	local result = _start_action_running_original(self, ...)

	self._ext_camera.play_redirect = nil
	self._is_meleeing = nil
	self._changing_weapon = nil

	return result
end

local _end_action_running_original = PlayerStandard._end_action_running
function PlayerStandard:_end_action_running(...)
	if managers.player:mdragon_try_sprint_bonus() then
		if self:_is_meleeing() or self._mdragon_was_meleeing then
			self._ext_camera.play_redirect = empty
		end
	end

	local result = _end_action_running_original(self, ...)

	self._mdragon_was_meleeing = nil
	self._ext_camera.play_redirect = nil

	return result
end

local _start_action_jump_original = PlayerStandard._start_action_jump
function PlayerStandard:_start_action_jump(...)
	if managers.player:mdragon_try_sprint_bonus() then
		if self:_is_meleeing() then
			self._ext_camera.play_redirect = empty
		end
	end

	local result = _start_action_jump_original(self, ...)

	if self._running_wanted then
		self._mdragon_was_meleeing = nil
	end

	self._ext_camera.play_redirect = nil

	return result
end
