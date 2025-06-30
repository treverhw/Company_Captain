extends Entity
class_name Soldier

static var Names = ["Steve", "Gary", "Carl", "Bob", "Ethan", "Trever", "Maria", "Zoey", "Angel", "John", "Chief", "Loken"]

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
func _init(arr : Array, arm : Armour, wpn1 : Weapon, wpn2 : Weapon, bw: int = 0, bs: int = 0, bt: int = 0, bS: int = 0):
	ballisticSkill = arr[0]
	weaponSkill = arr[1]
	armour = arm
	main = wpn1
	off = wpn2
	maxWounds = arr[2] + armour.getWounds()
	wounds = maxWounds
	battlescars = arr[3]
	maxBattlescars = arr[3]
	setTitle(Names)
	bonusWounds = bw
	bonusSpeed = bs
	bonusToughness = bt
	bonusSave = bS


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
