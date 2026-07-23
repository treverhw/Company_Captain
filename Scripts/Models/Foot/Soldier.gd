extends Model
class_name Soldier

## -- Equipment --
var armour: Armour
var main: Weapon
var off: Weapon

## -- Mod Stats --
var bonusWounds: int = 0
var bonusSpeed: int = 0
var bonusToughness: int = 0
var bonusSave: int = 0

## Constructor that builds a soldier's stat profile from an info array.
func define(res: ModelStats, arm: Armour, wpn1: Weapon, wpn2: Weapon, fac: Faction) -> void:
	armour = arm
	main = wpn1
	off = wpn2
	weapons = [main, off]
	ballisticSkill = res.ballisticSkill + main.getBSMod()
	weaponSkill = res.weaponSkill
	maxWounds = res.wounds + armour.getWounds()
	wounds = maxWounds
	battlescars = 0
	maxBattlescars = res.maxBattlescars
	faction = fac
	rank = res.rank
	role = res.role

	var names = Names.new().marineNames
	generateTitle(names)

## Returns the weapons usable at the given distance (melee/pistol up close,
## ranged at mid distance, no melee/pistol at long range — two-handers lock
## the loadout to just that weapon).
func getActiveWeapons(distance: int) -> Array[Weapon]:
	#print(rank + " " + title + " attacking from a distance of " + str(distance))
	
	if (distance < 0):
		return weapons
		
	var exclude: Array[Weapon]
	#print("Available Weapons: " + str(weapons))
	
	if range(0, 65).has(distance):
		print(str(distance) + " in 0 - 65")
		for item in weapons:
			if !item.isMelee() and !item.isPistol():
				exclude.append(item)
	elif range(66, 130).has(distance):
		for item in weapons:
			if item.isMelee():
				exclude.append(item)
	else:
		for item in weapons:
			if item.isMelee() or item.isPistol():
				exclude.append(item)
	
	var ret: Array[Weapon]
	for item in weapons:
		if item not in exclude:
			ret.append(item)
		if item.isTwoHander():
			ret = [item]
			break
	
	#print("Selected Weapons: " + str(ret))
	return ret

func refit(r: String, equipment: Array) -> Soldier:
	role = r
	setArmour(equipment[0])
	setMain(equipment[1])
	setOff(equipment[2])
	return self

## -- Setters --
func setArmour(val: Armour) -> void:
	if val:
		#Return armour to armoury
		armour.queue_free()
		armour = val
func setMain(val: Weapon) -> void:
	if val:
		#Return weapon to armoury
		main.queue_free()
		main = val
func setOff(val: Weapon) -> void:
	if val:
		#Return weapon to armoury
		off.queue_free()
		off = val

func setBonuses(a: int = bonusWounds, b: int = bonusSpeed, c: int = bonusToughness, d: int = bonusSave) -> void:
	bonusWounds = a
	bonusSpeed = b
	bonusToughness = c
	bonusSave = d

## -- Getters --
func getArmour() -> Armour:
	return armour
func getMain() -> Weapon:
	return main
func getOff() -> Weapon:
	return off
func getMaxWounds() -> int:
	return getArmour().getWounds() + bonusWounds
func getSpeed() -> int:
	return getArmour().getSpeed() + bonusSpeed
func getToughness() -> int:
	return getArmour().getToughness() + bonusToughness
func getSave() -> int:
	return getArmour().getSave() + bonusSave
func getWeight() -> int:
	return getArmour().getWeight()
func getSize() -> int:
	return getArmour().getSize()
