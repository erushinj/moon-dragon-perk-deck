Hooks:PostHook( SkillTreeTweakData, "init", "mdragon_init", function(self)

	table.insert(self.specializations, {
		name_id = "menu_deck_mdragon_title",
		desc_id = "menu_deck_mdragon_desc",
		category = { "offensive", "mod", },
		{
			name_id = "menu_deck_mdragon_1",
			desc_id = "menu_deck_mdragon_1_desc",
			cost = 0,
			upgrades = { "player_mdragon", "player_mdragon_swift", },
			texture_bundle_folder = "max",
			icon_xy = { 2, 0 }
		},
		{
			name_id = "menu_deck_mdragon_2",
			desc_id = "menu_deck_mdragon_2_desc",
			cost = 0,
			upgrades = { "player_mdragon_fight", },
			icon_xy = { 2, 7 }
		},
		{
			name_id = "menu_deck_mdragon_3",
			desc_id = "menu_deck_mdragon_3_desc",
			cost = 0,
			upgrades = { "weapon_mdragon_nimble", },
			icon_xy = { 7, 2 }  -- not a good icon but the best i can do
		},
		{
			name_id = "menu_deck_mdragon_4",
			desc_id = "menu_deck_mdragon_4_desc",
			cost = 0,
			upgrades = { "player_mdragon_flight", },
			icon_xy = { 2, 0 }
		},
		{
			name_id = "menu_deck_mdragon_5",
			desc_id = "menu_deck_mdragon_5_desc",
			cost = 0,
			upgrades = { "weapon_mdragon_ruthless", },
			icon_xy = { 3, 5 }
		},
		{
			name_id = "menu_deck_mdragon_6",
			desc_id = "menu_deck_mdragon_6_desc",
			cost = 0,
			upgrades = { "weapon_mdragon_fright", },
			icon_xy = { 2, 5 }
		},
		{
			name_id = "menu_deck_mdragon_7",
			desc_id = "menu_deck_mdragon_7_desc",
			cost = 0,
			upgrades = { "weapon_mdragon_perforating", },
			icon_xy = { 5, 2 }
		},
		{
			name_id = "menu_deck_mdragon_8",
			desc_id = "menu_deck_mdragon_8_desc",
			cost = 0,
			upgrades = { "player_mdragon_freight", },
			icon_xy = { 3, 7 }
		},
		{
			name_id = "menu_deck_mdragon_9",
			desc_id = "menu_deck_mdragon_9_desc",
			cost = 0,
			upgrades = { "player_mdragon_survivor", },
			icon_xy = { 5, 7 }
		}
	})

end )
