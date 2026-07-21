extends TextureRect
class_name Unit
## Base "container" class for a group of Models (e.g. a Squad of Soldiers).
## Subclasses override `combatUpdate()` to refresh their own UI.

var title: String
var roster: Array[Model] = []
var rosterCap: int = 5
var faction: Faction
# NOTE: untyped because a Unit's location can be a Location (Settlement,
# Planet, System, Sector, Convoy) OR a Ship (Model) once it's embarked.
var location
var line: int = 1
var type: String

func define(t: String, rC: int, f: Faction) -> void:
	title = t
	rosterCap = rC
	faction = f

## True if this unit still has at least one living Model.
func validate() -> bool:
	return getAlive() > 0

## Points every Model currently in the roster back at this unit.
func assignModels() -> void:
	for model in getRoster():
		model.unit = self

func removeModel(model: Model) -> void:
	getFaction().removeModel(model)

## Counts how many Models in the roster are still alive.
func getAlive() -> int:
	var counter: int = 0
	for model in getRoster():
		if model.alive():
			counter += 1
	return counter

## Turns fallen Models into battlescars (or kills them once they're out of
## scars to take), then frees this unit entirely once its roster is empty.
func clean() -> void:
	for i in range(getRoster().size() - 1, -1, -1):
		var model: Model = getRoster()[i]
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

func addModel(model: Model) -> Model:
	roster.append(model)
	model.unit = self
	return model

func popModel() -> Model:
	var model = roster.pop_back()
	model.unit = null
	return model

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
func getRoster() -> Array[Model]:
	ModelUtils.pruneInvalid(roster)
	return roster
func getRosterCap() -> int:
	return rosterCap
func getFaction() -> Faction:
	return faction
func getTeam() -> String:
	return getFaction().getTeam()
func getLine() -> String:
	return str(line)
func getLocation() -> Node:
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

func getRosterSize() -> int:
	return getRoster().size()

func getNeededModels() -> int:
	return getRosterCap() - getRosterSize()

func _to_string() -> String:
	return str(getFaction().getTitle()) + " " + getTitle() + " - Size[" + str(getRoster().size()) + "]"
