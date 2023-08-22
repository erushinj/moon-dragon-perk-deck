if not MoonDragonPerkDeck then

	MoonDragonPerkDeck = {
		mod_path = ModPath,
		required = {},
	}

	Hooks:Add( "LocalizationManagerPostInit", "LocalizationManagerPostInitMoonDragonPerkDeck", function(loc)
		loc:add_localized_strings({
			menu_deck_mdragon_title = "Dragon",
			menu_deck_mdragon_desc = "The Dragon lives its life, isolated from all - and all bow down to it if they know what's good for them.\n\nYou will strike down all challengers. Wounds only strengthen your abilities. You are the unknown variable, an anomaly thriving on life near death. You are fear.",
			menu_deck_mdragon_1 = "Swift",
			menu_deck_mdragon_1_desc = "##While wearing the Flak Jacket##, unlocks Heat Stacks; you gain ##1## on melee striking an enemy, up to a maximum of ##8##.\n##While having full armour##, ##1## Heat Stack decays per second, but dealing damage to or taking damage from an enemy resets Heat Stack decay.\nHaving Heat Stacks enables multiple passive bonuses - these bonuses get stronger as you gain more Heat Stacks.\n\nYou gain ##between 10% and 40%## movement speed while having Heat Stacks.",
			menu_deck_mdragon_2 = "God of Might",
			menu_deck_mdragon_2_desc = "Your melee strikes innately deal critical damage and regenerate ##5## armor on a successful strike.\nWhile charging or using a melee strike, gain damage absorption - the maximum amount is dependent on difficulty. Damage absorption decays while not using a melee strike.",
			menu_deck_mdragon_3 = "Slick",
			menu_deck_mdragon_3_desc = "You gain ##between 20% and 80%## weapon swap speed while having Heat Stacks.",
			menu_deck_mdragon_4 = "God of Flight",
			menu_deck_mdragon_4_desc = "You innately sprint like it's 2011 - in any direction, without draining stamina.\nIn addition, using a melee attack, swapping weapons, and reloading no longer interrupt sprinting.",
			menu_deck_mdragon_5 = "Staggering",
			menu_deck_mdragon_5_desc = "You gain ##between 20% and 70%## chance to stagger a shot enemy while having Heat Stacks.",
			menu_deck_mdragon_6 = "God of Fright",
			menu_deck_mdragon_6_desc = "You innately defeat staggered or panicking enemies with one melee strike or headshot, excluding Bulldozers, Captain Winters, and boss enemies.\nDefeating a special enemy with a melee strike causes all non-special enemies within a ##9## meter radius of you to panic.",
			menu_deck_mdragon_7 = "Shattering",
			menu_deck_mdragon_7_desc = "You gain ##100%## chance to pierce enemy armour while having Heat Stacks.",
			menu_deck_mdragon_8 = "God of Life",
			menu_deck_mdragon_8_desc = "##While having 8## Heat Stacks:\nUpon taking fatal damage, instead of going down, your health regenerates. ##Consumes all## Heat Stacks on activation. Does not trigger from environmental damage. ##Shares the same cooldown as Uppers ACE - activating this ability or Uppers ACE puts both on cooldown.##",
			menu_deck_mdragon_9 = "Stalwart",
			menu_deck_mdragon_9_desc = "You gain ##between 1% and 5%## health regeneration per second while having Heat Stacks.",
		})
	end )

end


if RequiredScript and not MoonDragonPerkDeck.required[RequiredScript] then

	local fname = MoonDragonPerkDeck.mod_path .. RequiredScript:gsub(".+/(.+)", "lua/%1.lua")
	if io.file_is_readable(fname) then
		dofile(fname)
	end

	MoonDragonPerkDeck.required[RequiredScript] = true

end
