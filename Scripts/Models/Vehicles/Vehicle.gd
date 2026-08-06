extends Model

var speed: int
var toughness : int
var save : int

#Constructor that is sent an information array to build a basic stat profile.
func define(arr : Array, arm : Armour, inputSpeed: int, inputToughness: int, inputSave: int, weaponSet: Array[Weapon], fac: Faction, bw: int = 0, bs: int = 0, bt: int = 0, bS: int = 0):
	ballisticSkill = arr[0]
	weaponSkill = arr[1]
	speed = arr[2]
	toughness = arr[3]
	save = arr[4]
	weapons = arr[5]
	wounds = maxWounds
	
	generateTitle(Names.shipNames)

#creates an array of all weapons, then erases those weapons that aren't currently valid based on distance.
func getActiveWeapons(distance: int) -> Array[Weapon]:
	return weapons


## Setters
func setWeapons(val: Array[Weapon]):
	weapons = val
func setSpeed(val: int):
	speed = val
func setToughness(val: int):
	toughness = val
func setSave(val: int):
	save = val


## Getters
func getSpeed() -> int:
	return speed
func getToughness() -> int:
	return toughness
func getSave() -> int:
	return save
