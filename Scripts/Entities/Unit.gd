extends TextureRect
class_name Unit
## Base "container" class for a group of Entities (e.g. a Squad of Soldiers).
## Subclasses override `combatUpdate()` to refresh their own UI.

var title: String
var roster: Array[Entity] = []
var rosterCap: int = 5
var faction: Faction
# NOTE: untyped because a Unit's location can be a Location (Settlement,
# Planet, System, Sector, Convoy) OR a Ship (Entity) once it's embarked.
var location
var line: int = 1

func define(t: String, rC: int, f: Faction) -> void:
	title = t
	rosterCap = rC
	faction = f

## True if this unit still has at least one living entity.
func validate() -> bool:
	return getAlive() > 0

## Points every entity currently in the roster back at this unit.
func assignModels() -> void:
	for model in getRoster():
		model.unit = self

func removeEntity(model: Entity) -> void:
	getFaction().removeEntity(model)

## Counts how many entities in the roster are still alive.
func getAlive() -> int:
	var counter: int = 0
	for model in getRoster():
		if model.alive():
			counter += 1
	return counter

## Turns fallen entities into battlescars (or kills them once they're out of
## scars to take), then frees this unit entirely once its roster is empty.
func clean() -> void:
	for i in range(getRoster().size() - 1, -1, -1):
		var model: Entity = getRoster()[i]
		if model.getWounds() <= 0:
			model.battlescars += 1
			if model.getBattlescars() > model.getMaxBattlescars():
				model.kill()
			else:
				model.setWounds(1)

	if getRoster().is_empty():
		if get_parent() != null:
			get_parent().remove_child(self)
		getFaction().getRoster().erase(self)
		queue_free()

## Overridden by subclasses (e.g. Squad) to refresh their own combat UI.
func combatUpdate() -> void:
	pass

## -- Setters --
func setTitle(t: String) -> void:
	title = t
func setRosterCap(val: int) -> void:
	rosterCap = val
func setFaction(val: Faction) -> void:
	faction = val
func setLocation(val) -> void:
	location = val

## -- Getters --
func getTitle() -> String:
	return title
func getRoster() -> Array[Entity]:
	EntityUtils.pruneInvalid(roster)
	return roster
func getRosterCap() -> int:
	return rosterCap
func getFaction() -> Faction:
	return faction
func getTeam() -> String:
	return getFaction().getTeam()
func getLine() -> String:
	return str(line)
func getLocation() -> Location:
	return location if is_instance_valid(location) else null
func getWeight() -> int:
	var n: int = 0
	for model in getRoster():
		n += model.getWeight()
	return n
func getSize() -> int:
	var n: int = 0
	for model in getRoster():
		n += model.getSize()
	return n

func _to_string() -> String:
	return str(getFaction().getTitle()) + " " + getTitle() + " - Size[" + str(getRoster().size()) + "]"
