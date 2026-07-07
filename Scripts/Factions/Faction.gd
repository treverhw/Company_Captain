extends Node
class_name Faction

const weapons = preload("res://Scripts/Equipment/WeaponArrays.gd")
const armour = preload("res://Scripts/Equipment/ArmourArrays.gd")
const soldiers = preload("res://Scripts/Entities/Foot/SoldierArrays.gd")

var title: String
var team: String
var roster: Array[Unit] = []
var id: int

## Removes an entity from play: pulls it out of its unit, and if that empties
## the unit, pulls the unit out of its location and this faction's roster too.
func removeEntity(model: Entity) -> void:
	var unit: Unit = model.getUnit()
	unit.getRoster().erase(model)
	if unit.getRoster().size() <= 0:
		if is_instance_valid(unit.getLocation()):
			unit.getLocation().getRoster().erase(unit)
		roster.erase(unit)
		unit.queue_free()
	model.queue_free()

## Spawns a starting unit at the given location. All factions currently spawn
## the same base unit regardless of location; override in a subclass if a
## faction should vary its spawn based on where it's spawning.
func spawnLocational(location: Location) -> Unit:
	return spawnBase()

## Returns this faction's default starting unit. Overridden by subclasses.
func spawnBase() -> Unit:
	return null

func setTitle(t: String) -> void:
	title = t
func setRoster(arr: Array[Unit]) -> void:
	roster = arr.duplicate()

func getTitle() -> String:
	return title
func getTeam() -> String:
	return team
func getRoster() -> Array[Unit]:
	EntityUtils.pruneInvalid(roster)
	return roster

func _to_string() -> String:
	var ret: String = getTitle()
	for item in roster:
		ret += "\n" + str(item)
	return ret
