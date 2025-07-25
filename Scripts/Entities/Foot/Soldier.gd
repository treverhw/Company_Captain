extends Entity
class_name Soldier

#Equipment
var armour : Armour
var main : Weapon
var off : Weapon

#Mod Stats
var bonusWounds : int = 0
var bonusSpeed : int = 0
var bonusToughness : int = 0
var bonusSave : int = 0

#Constructor that is sent an information array to build a basic stat profile.
func define(arr : Array, arm : Armour, wpn1 : Weapon, wpn2 : Weapon, fac: Faction, bw: int = 0, bs: int = 0, bt: int = 0, bS: int = 0):
	ballisticSkill = arr[0]
	weaponSkill = arr[1]
	armour = arm
	main = wpn1
	off = wpn2
	weapons = [main, off]
	faction = fac
	maxWounds = armour.getWounds()
	wounds = maxWounds
	battlescars = 0
	maxBattlescars = arr[3]
	bonusWounds = bw
	bonusSpeed = bs
	bonusToughness = bt
	bonusSave = bS
	
	var names = Names.new().marineNames
	generateTitle(names)

#creates an array of all weapons, then erases those weapons that aren't currently valid based on distance.
func getActiveWeapons(distance: int) -> Array[Weapon]:
	var ret: Array[Weapon]
	for item in weapons:
		ret.append(item)
	
	if range(0,65).has(distance):
		for item in ret:
			if !item.isMelee() and !item.isPistol():
				ret.erase(item)
	elif range(66,130).has(distance):
		for item in ret:
			if item.isMelee():
				ret.erase(item)
	else: 
		for item in ret:
			if item.isMelee() or item.isPistol():
				ret.erase(item)
	for item in ret:
		if item.isTwoHander():
			ret = [item]
	return ret


## Setters
func setUnit(val : Squad):
	if val.addToRoster(self):
		unit = val
	else:
		print("Error: Unable to join Unit")

func setArmour(val : Armour):
	if val:
		#Return armour to armoury
		pass
	armour = val
func setMain(val : Weapon):
	if val:
		#Return weapon to armoury
		pass
	main = val
func setOff(val : Weapon):
	if val:
		#Return weapon to armoury
		pass
	off = val

func setBonuses(a: int = bonusWounds, b: int = bonusSpeed, c: int = bonusToughness, d: int = bonusSave):
	bonusWounds = a
	bonusSpeed = b
	bonusToughness = c
	bonusSave = d


## Getters
func getArmour() -> Armour:
	return armour
func getMain() -> Weapon:
	return main
func getOff() -> Weapon:
	return off

func getMaxWounds() -> int:
	return armour.getWounds() + bonusWounds
func getSpeed() -> int:
	return armour.getSpeed() + bonusSpeed
func getToughness() -> int:
	return armour.getToughness() + bonusToughness
func getSave() -> int:
	return armour.getSave() + bonusSave
