Hooks:PostHook( PlayerStandard, "_can_run_directional", "mdragon__can_run_directional", function(self)
	return Hooks:GetReturn() or managers.player:mdragon_try_sprint_bonus()
end )

Hooks:PostHook( PlayerStandard, "_get_swap_speed_multiplier", "mdragon__get_swap_speed_multiplier", function(self)
	return Hooks:GetReturn() * managers.player:mdragon_get_nimble_amount()
end )

-- i hate this so fucking much.
-- this disgusting fucking garbage below is just to make melee while sprinting not be weird.

local empty = function() end
local _interupt_action_running_original = PlayerStandard._interupt_action_running
local _is_meleeing_original = PlayerStandard._is_meleeing
local _changing_weapon_original = PlayerStandard._changing_weapon

PlayerStandard._mdragon_was_meleeing = nil

Hooks:PostHook( PlayerStandard, "init", "mdragon_init", function(self)
	self._mdragon_ext_camera_play_redirect_original = self._ext_camera.play_redirect
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
				log("start running")
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
	if managers.player:mdragon_try_agility_bonus() then
		self._interupt_action_running = empty
	end

	local result = _start_action_melee_original(self, ...)

	self._interupt_action_running = _interupt_action_running_original

	return result
end

local _start_action_unequip_weapon_original = PlayerStandard._start_action_unequip_weapon
function PlayerStandard:_start_action_unequip_weapon(...)
	if managers.player:mdragon_try_agility_bonus() then
		self._interupt_action_running = empty
	end

	local result = _start_action_unequip_weapon_original(self, ...)

	self._interupt_action_running = _interupt_action_running_original

	return result
end

local _start_action_running_original = PlayerStandard._start_action_running
function PlayerStandard:_start_action_running(...)
	if managers.player:mdragon_try_agility_bonus() then
		if self:_is_meleeing() or self._mdragon_was_meleeing then
			self._ext_camera.play_redirect = empty
		end

		self._is_meleeing = empty
		self._changing_weapon = empty
	end

	local result = _start_action_running_original(self, ...)

	self._ext_camera.play_redirect = self._mdragon_ext_camera_play_redirect_original
	self._is_meleeing = _is_meleeing_original
	self._changing_weapon = _changing_weapon_original

	return result
end

local _end_action_running_original = PlayerStandard._end_action_running
function PlayerStandard:_end_action_running(...)
	if managers.player:mdragon_try_agility_bonus() then
		if self:_is_meleeing() or self._mdragon_was_meleeing then
			self._ext_camera.play_redirect = empty
		end
	end

	local result = _end_action_running_original(self, ...)

	self._mdragon_was_meleeing = nil
	self._ext_camera.play_redirect = self._mdragon_ext_camera_play_redirect_original

	return result
end

local _start_action_jump_original = PlayerStandard._start_action_jump
function PlayerStandard:_start_action_jump(...)
	if managers.player:mdragon_try_agility_bonus() then
		if self:_is_meleeing() then
			self._ext_camera.play_redirect = empty
		end
	end

	local result = _start_action_jump_original(self, ...)

	if self._running_wanted then
		self._mdragon_was_meleeing = nil
	end

	self._ext_camera.play_redirect = self._mdragon_ext_camera_play_redirect_original

	return result
end

-- local _update_foley_original = PlayerStandard._update_foley
-- function PlayerStandard:_update_foley(...)
-- 	local was_in_air = self._state_data.in_air == true

-- 	local result = _update_foley_original(self, ...)

-- 	if was_in_air and not self._state_data.in_air and self._running_wanted then

-- 	end

-- 	return result
-- end
