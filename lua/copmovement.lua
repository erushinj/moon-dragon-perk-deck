CopMovement._mdragon_panic_state = false

Hooks:PreHook( CopMovement, "on_suppressed", "mdragon_on_suppressed", function(self, state)
	self._mdragon_panic_state = state == "panic"
end )

function CopMovement:mdragon_panic_state()
	return self._mdragon_panic_state
end
