extends Node
class_name Model
## Base class for anything that can fight and be tracked in a Unit's roster
## (soldiers, vehicles, etc). Subclasses provide their own `define()` and
## `getActiveWeapons()`.

var rand: RandomNumberGenerator = RandomNumberGenerator.new()

## -- Informational --
var title: String
var faction: Faction
var unit: Unit
var location
var weapons: Array[Weapon]
var rank: String = "Base"
var role: String = "Battleline"
var xp: int
var leader: bool

## -- Stats --
var ballisticSkill: int
var weaponSkill: int
var wounds: int
var maxWounds: int
var battlescars: int
var maxBattlescars: int

## True while the Model still has wounds remaining.
func alive() -> bool:
	return getWounds() > 0

## Removes this Model from its faction's roster entirely.
func kill() -> void:
	getFaction().removeModel(self)

## Returns the combat line (VBoxContainer) this Model's unit currently occupies.
func findColumn() -> VBoxContainer:
	return unit.get_parent()

func increaseXP(val: int) -> int:
	xp += val
	#promote
	return xp

## -- Setters --
func setTitle(val: String) -> void:
	title = val
## Picks a random name from `val` and uses it as both title and node name.
func generateTitle(val: Array) -> void:
	title = val[rand.randi_range(0, val.size() - 1)]
	name = title
func setFaction(val: Faction) -> void:
	faction = val
func setLocation(val) -> void:
	if location:
		location.getRoster().erase(self)
	val.getRoster().append(self)
	location = val
func setBallisticSkill(val: int) -> void:
	ballisticSkill = val
func setWeaponSkill(val: int) -> void:
	weaponSkill = val
func setWounds(val: int) -> void:
	wounds = val
func setBattlescars(val: int) -> void:
	battlescars = val
func setMaxBattlescars(val: int) -> void:
	maxBattlescars = val
func setMaxWounds(val: int) -> void:
	maxWounds = val

## -- Getters --
func getTitle() -> String:
	return title
func getFaction() -> Faction:
	return faction
func getTeam() -> String:
	return getFaction().getTeam()
func getUnit() -> Unit:
	return unit
func getLocation() -> Node:
	return getUnit().getLocation()
func getRank() -> String:
	return rank
func getXP() -> int:
	return xp
func getRole() -> String:
	return role
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
## Weapons usable at the given distance. Base Model has no weapon logic
## of its own — overridden by Soldier/Vehicle.
func getActiveWeapons(_distance: int) -> Array[Weapon]:
	return [null]
## Carry weight. 0 by default; overridden by subclasses.
func getWeight() -> int:
	return 0

func _to_string() -> String:
	
	return "%-10s %-10s %10d/%d | %d/%d" % [getRank(), getTitle(), getWounds(), getMaxWounds(), getBattlescars(), getMaxBattlescars()]
