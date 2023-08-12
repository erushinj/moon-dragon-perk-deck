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
			menu_deck_mdragon_1_desc = "While wearing the ##Flak Jacket##, unlocks Heat Stacks - you gain ##1## on taking damage, or ##20## on going into bleedout, up to a maximum of ##20##.\nWhile your armour is full, ##4## Heat Stacks decay per second after ##4## seconds.\nHeat Stacks enable or strengthen multiple passive effects, and enable activated effects.\n\nPassive: You gain up to ##+30%## movement speed the more Heat Stacks you have.",
			menu_deck_mdragon_2 = "God of Fight",
			menu_deck_mdragon_2_desc = "While having ##at least 5## Heat Stacks:\nPassive: Your melee strikes are instantly charged. \nActive: Defeating an enemy with a melee strike refills your armour and resets the Heat Stack drain timer.",
			menu_deck_mdragon_3 = "Nimble",
			menu_deck_mdragon_3_desc = "Passive: You gain up to ##+160%## weapon swap speed the more Heat Stacks you have.",
			menu_deck_mdragon_4 = "God of Flight",
			menu_deck_mdragon_4_desc = "While having ##at least 10## Heat Stacks:\nPassive: Stamina no longer drains, and you can sprint in all directions.\nActive: While sprinting, gain up to ##30## damage absorption the longer you sprint. Damage absorption decays while not sprinting.",
			menu_deck_mdragon_5 = "Ruthless",
			menu_deck_mdragon_5_desc = "Passive: You gain up to ##+75%## chance to stagger a shot enemy the more Heat Stacks you have.",
			menu_deck_mdragon_6 = "God of Fright",
			menu_deck_mdragon_6_desc = "While having ##at least 15## Heat Stacks:\nPassive: Headshotting or meleeing a staggered or panicking enemy instantly defeats them. \nActive: Defeating a staggered special enemy with a headshot causes all non-special enemies within a ##9## meter radius of the defeated special to panic.",
			menu_deck_mdragon_7 = "Perforating",
			menu_deck_mdragon_7_desc = "Passive: You gain up to ##+100%## enemy armour piercing chance the more Heat Stacks you have.",
			menu_deck_mdragon_8 = "God of Freight",
			menu_deck_mdragon_8_desc = "While having ##20## Heat Stacks:\nPassive: Using a melee attack, swapping weapons, or reloading no longer interrupts sprinting.\nActive: Upon taking fatal damage, instead of going down, your health and armour regenerate. ##Consumes all Heat Stacks##, and does not trigger from environmental damage.",
			menu_deck_mdragon_9 = "Survivor",
			menu_deck_mdragon_9_desc = "Passive: You gain up to ##+1%## health regeneration per second the more Heat Stacks you have.",
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
