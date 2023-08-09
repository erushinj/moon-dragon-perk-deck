local ModPath = ModPath
local RequiredScript = RequiredScript
local key = "mdragon    " .. ModPath .. "    " .. RequiredScript

-- very temporary
if _G[key] then
	return
end

_G[key] = true

local name = ModPath .. RequiredScript:gsub(".+/(.+)", "lua/%1.lua")
if io.file_is_readable(name) then
	dofile(name)
end

Hooks:Add( "LocalizationManagerPostInit", "LocalizationManagerPostInitDragonPerkDeck", function(loc)
	loc:add_localized_strings({
		menu_deck_mdragon_title = "Dragon",
		-- menu_deck_mdragon_desc = "The Dragon is a master of grace. Fundamentally lethal to all would-be challengers, taking one down is no easy feat. The Dragon lives its life, isolated from all - and all bow down to it if they know what's good for them.\n\nThe yakuza, isolated from the rest of society yet still the yin to the law's yang, have seen a new kind of Dragon enter their ranks. Because of training.",
		menu_deck_mdragon_desc = "The Dragon lives its life, isolated from all - and all bow down to it if they know what's good for them.\n\nYou will strike down all challengers. Wounds only strengthen your abilities. You are the unknown variable, an anomaly thriving on life near death. You are fear.",
		menu_deck_mdragon_1 = "Swift",
		menu_deck_mdragon_1_desc = "While wearing the ##Flak Jacket##, unlocks Heat Stacks - you gain ##1## on taking damage, or ##20## on going into bleedout, up to a maximum of ##20##.\nWhile having armour, not taking damage for ##4## seconds causes ##4## Heat Stacks to decay per second until you take damage.\nHeat Stacks enable or strengthen multiple passive effects, and enable activated effects.\n\nPassive: You gain up to ##+30%## movement speed the more Heat Stacks you have.",
		menu_deck_mdragon_2 = "God of Flight",
		-- menu_deck_mdragon_2_desc = "Active: Sprinting while stamina is empty instead consumes ##2## Heat Stacks per second",
		menu_deck_mdragon_2_desc = "While having at least ##10## Heat Stacks:\nPassive: You can sprint endlessly in any direction. \nActive: While sprinting, gain ##10## damage absorption.",
		menu_deck_mdragon_3 = "Nimble",
		menu_deck_mdragon_3_desc = "Passive: You gain up to ##+40%## weapon swap speed the more Heat Stacks you have.",
		menu_deck_mdragon_4 = "God of Might",
		-- menu_deck_mdragon_4_desc = "Active: Melee strikes that hit an enemy do critical damage and consume ##5## Heat Stacks",
		menu_deck_mdragon_4_desc = "While having at least ##10## Heat Stacks:\nPassive: Your melee strikes deal critical damage. \nActive: Defeating an enemy with a melee strike refills your armour and resets the Heat Stack drain timer.",
		menu_deck_mdragon_5 = "Ruthless",
		menu_deck_mdragon_5_desc = "Passive: You gain up to ##+20%## chance to stagger a shot enemy the more Heat Stacks you have.",
		menu_deck_mdragon_6 = "God of Fright",
		-- menu_deck_mdragon_6_desc = "Active: Headshotting a heavily staggered or panicking enemy instantly defeats them and consumes ##6## Heat Stacks",
		menu_deck_mdragon_6_desc = "While having ##20## Heat Stacks:\nPassive: Headshotting a staggered or panicking enemy instantly defeats them. \nActive: Defeating a staggered special enemy with a headshot causes all non-special enemies within a ##9## meter radius of the defeated special to panic.",
		menu_deck_mdragon_7 = "Perforating",
		menu_deck_mdragon_7_desc = "Passive: You gain up to ##+100%## enemy armour piercing chance the more Heat Stacks you have.",
		menu_deck_mdragon_8 = "God of Life",
		-- menu_deck_mdragon_8_desc = "Active: Taking fatal damage instead regenerates your armour and consumes ##20## Heat Stacks",
		menu_deck_mdragon_8_desc = "While having ##20## Heat Stacks:\nActive: Upon taking fatal damage, instead of going down, your health is set to 1 and your armour is regenerated. ##Consumes all Heat Stacks##.",
		menu_deck_mdragon_9 = "Survivor",
		menu_deck_mdragon_9_desc = "Passive: You gain up to ##+1%## health regeneration per second the more Heat Stacks you have.",
	})
end )
