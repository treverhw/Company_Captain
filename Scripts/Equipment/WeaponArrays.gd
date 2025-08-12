## Title, Attacks, Strength, AP, Damage, Two Handed?, Melee?, Pistol?

static var astartesWeapons = {
	#Ranged                     Title        att str ap dmg twoH  melee  pistol  desc
	"Bolt Rifle" : 				["Bolt Rifle", 2, 4, -1, 1, true, false, false, "Standard weapon south of the rubicon."],
	"Boltgun" : 				["Boltgun", 2, 4, 0, 1, true, false, false, "Standard weapon north of the rubicon."],
	"Bolt Pistol" : 			["Bolt Pistol", 1, 4, 0, 1, false, true, true, "Wrist Snapper 9000."],
	"Plasma Pistol" : 			["Plasma Pistol", 1, 7, -2, 1, true, false, true, "For when you only have time for one quick shot."],
	
	#Melee
	"Astartes Chainsword" : 	["Astartes Chainsword", 5, 4, -1, 1, false, true, false, "The crab of swords."],
	"Power Fist" : 				["Power Fist", 3, 8, -2, 2, false, true, false, "Don't Laugh."],
	"Close Combat Weapon" : 	["Close Combat Weapon", 3, 4, 0, 1, false, true, false, "Standard melee weapon."],
}

static var guardWeapons = {
	#Ranged                     Title      att str ap dmg twoH  melee  pistol  desc
	"Lasgun" :					["Lasgun", 2, 3, 0, 1,    true, false, false, "'Anyone got a flashlight?'"],
	"Laspistol" :				["Laspistol", 1, 3, 0, 1, false, true, true, "'No, a smaller one.'"],
	#Melee
	"Close Combat Weapon" : 	["Close Combat Weapon", 2, 3, 0, 1, false, true, false, "Standard melee weapon."],
}

static var chaosWeapons = {
	#Ranged                     Title          att str ap dmg twoH  melee  pistol  desc
	"Autopistol" :				["Autopistol", 1, 3, 0, 1,    false, false, true, "'Brrrrr'"],
	"Bolt Pistol" : 			["Bolt Pistol", 1, 4, 0, 1, false, true, true, "Wrist Snapper 9000."],
	#Melee
	"Brutal Assault Weapon" : 	["Brutal Assault Weapon", 2, 3, 0, 1, false, true, false, "Chaos melee weapon."]
}
