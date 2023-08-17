Hooks:PostHook( NewRaycastWeaponBase, "armor_piercing_chance", "mdragon_armor_piercing_chance", function(self)
	return Hooks:GetReturn() + managers.player:mdragon_get_shattering_amount()
end )
