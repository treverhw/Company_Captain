extends Node
class_name Entity

var rand : RandomNumberGenerator = RandomNumberGenerator.new()

#Informational
var title : String
var faction: Faction
var unit: Unit
var weapons: Array[Weapon]
var xp: int

#Stats
var ballisticSkill : int
var weaponSkill : int
var wounds : int
var battlescars : int
var maxBattlescars : int
var maxWounds : int

#Checks for wounds above 0
func alive() -> bool:
	if getWounds() <= 0:
		return false
	return true

#Calls upon the faction to remove this model from any unit its in.
func kill():
	print(self.to_string())
	getFaction().removeEntity(self)

#returns current combat line in combat
func findColumn() -> VBoxContainer:
	return unit.get_parent()

## Setters
func setTitle(val : String):
	title = val
func generateTitle(val : Array):
	title = val[rand.randi_range(0, val.size()-1)]
	name = title
func setFaction(val : Faction):
	faction = val

func setBallisticSkill(val : int):
	ballisticSkill = val
func setWeaponSkill(val : int):
	weaponSkill = val
func setWounds(val : int):
	wounds = val
func setBattlescars(val : int):
	battlescars = val
func setMaxBattlescars(val : int):
	maxBattlescars =val
func setMaxWounds(val : int):
	maxWounds = val


## Getters
func getTitle() -> String:
	return title
func getFaction() -> Faction:
	return faction
func getTeam() -> String:
	return getFaction().getTeam()
func getUnit() -> Unit:
	return unit
func getLocation() -> Location:
	return getUnit().getLocation()

func getBallisticSkill() -> int:
	return ballisticSkill
func getWeaponSkill() -> int:
	return weaponSkill
func getWounds() -> int:
	return wounds
func getMaxWounds() -> int:
	return maxWounds
func getBattlescars() -> int:
	return battlescars
func getMaxBattlescars() -> int:
	return maxBattlescars
func getActiveWeapons(distance: int) -> Array[Weapon]:
	return [null]
func getWeight() -> int:
	return 0

func _to_string() -> String:
	return getTitle() + " " + str(getWounds()) + "/" + str(getMaxWounds()) + " | " + str(getBattlescars()) + "/" + str(getMaxBattlescars())
