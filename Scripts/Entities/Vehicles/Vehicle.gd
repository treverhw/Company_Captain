extends Entity

var weapons : Array[Weapon] = []
var speed: int
var toughness : int
var save : int


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
