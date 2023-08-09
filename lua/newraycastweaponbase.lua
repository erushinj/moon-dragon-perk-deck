Hooks:PostHook( NewRaycastWeaponBase, "armor_piercing_chance", "mdragon_armor_piercing_chance", function(self)
	local armor_piercing_chance = Hooks:GetReturn()
	local add = managers.player:mdragon_get_perforating_amount()

	return armor_piercing_chance + add
end )
