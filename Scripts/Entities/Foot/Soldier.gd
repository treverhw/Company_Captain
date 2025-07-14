extends Entity
class_name Soldier

#Informational
var squad : Squad

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
func define(arr : Array, arm : Armour, wpn1 : Weapon, wpn2 : Weapon, bw: int = 0, bs: int = 0, bt: int = 0, bS: int = 0):
	ballisticSkill = arr[0]
	weaponSkill = arr[1]
	armour = arm
	main = wpn1
	off = wpn2
	maxWounds = arr[2] + armour.getWounds()
	wounds = maxWounds
	battlescars = arr[3]
	maxBattlescars = arr[3]
	bonusWounds = bw
	bonusSpeed = bs
	bonusToughness = bt
	bonusSave = bS
	
	var names = Names.new().marinenames
	generateTitle(names)

func weapons(distance: int) -> Array:
	var weapons = [getMain(), getOff()]
	
	match distance:
		65: #Melee
			for item in weapons:
				if !item.isMelee() && !item.isPistol():
					weapons.erase(item)
		_: #Else
			for item in weapons:
				if item.isMelee():
					weapons.erase(item)
	return weapons

## Setters
func setSquad(val : Squad):
	if val.addToRoster(self):
		squad = val
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
func getSquad() -> Squad:
	return squad
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


## Misc
func printInfo():
	print("Name: " + str(title) + 
		"\nWounds: " + str(wounds) + 
		"\nMax Wounds: " + str(maxWounds) + 
		"\nBattle Scars: " + str(battlescars) + 
		"\nMax Battle Scars: " + str(maxBattlescars) + 
		"\nArmour: " + armour.title + 
		"\nMain: " + main.title + 
		"\nOff: " + off.title + "\n")
