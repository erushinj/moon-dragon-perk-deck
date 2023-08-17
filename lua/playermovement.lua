Hooks:PostHook( PlayerMovement, "is_above_stamina_threshold", "mdragon_is_above_stamina_threshold", function(self)
	return managers.player:mdragon_try_sprint_bonus() or Hooks:GetReturn()
end )


local empty = function() end
local subtract_stamina_original = PlayerMovement.subtract_stamina
function PlayerMovement:subtract_stamina(...)
	if managers.player:mdragon_try_sprint_bonus() then
		self._change_stamina = empty
	end

	local result = subtract_stamina_original(self, ...)

	self._change_stamina = nil

	return result
end
