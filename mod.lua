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
			menu_deck_mdragon_1_desc = "##While wearing the Flak Jacket##, unlocks Heat Stacks; you gain ##1## on taking damage, up to a maximum of ##10##.\nGoing into bleedout ##instantly fills all## Heat Stacks.\nWhile your armor is full, ##2## Heat Stacks decay per second after ##4## seconds, but melee striking or landing a headshot on an enemy resets Heat Stack decay.\n\nYou gain up to ##30%## movement speed the more Heat Stacks you have.",
			menu_deck_mdragon_2 = "God of Fight",
			menu_deck_mdragon_2_desc = "##While having at least 2## Heat Stacks:\nYour melee strikes always deal critical damage.\nDefeating an enemy with a melee strike refills your armor.",
			menu_deck_mdragon_3 = "Nimble",
			menu_deck_mdragon_3_desc = "You gain up to ##160%## weapon swap speed the more Heat Stacks you have.",
			menu_deck_mdragon_4 = "God of Flight",
			menu_deck_mdragon_4_desc = "##While having at least 4## Heat Stacks:\nStamina no longer drains, and you can sprint in all directions.\nWhile sprinting, gain up to ##30## damage absorption the longer you sprint. Damage absorption decays while not sprinting.",
			menu_deck_mdragon_5 = "Ruthless",
			menu_deck_mdragon_5_desc = "You gain up to ##75%## chance to stagger a shot enemy the more Heat Stacks you have.",
			menu_deck_mdragon_6 = "God of Fright",
			menu_deck_mdragon_6_desc = "##While having at least 6## Heat Stacks:\nHeadshotting or meleeing a staggered or panicking enemy instantly defeats them. \nDefeating a special enemy with a headshot causes all non-special enemies within a ##9## meter radius of you to panic.",
			menu_deck_mdragon_7 = "Perforating",
			menu_deck_mdragon_7_desc = "You gain up to ##100%## enemy armor piercing chance the more Heat Stacks you have.",
			menu_deck_mdragon_8 = "God of Freight",
			menu_deck_mdragon_8_desc = "##While having at least 8## Heat Stacks:\nUsing a melee attack, swapping weapons, or reloading no longer interrupts sprinting.\nUpon taking fatal damage, instead of going down, your health regenerates. ##Consumes 8## Heat Stacks on activation. Does not trigger from environmental damage. ##Runs on the same cooldown as the Uppers ACE skill##.",
			menu_deck_mdragon_9 = "Survivor",
			menu_deck_mdragon_9_desc = "You gain up to ##2%## health regeneration per second the more Heat Stacks you have.",
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
