extends Node
class_name Faction

const weapons = preload("res://Scripts/Equipment/WeaponArrays.gd")
const armour = preload("res://Scripts/Equipment/ArmourArrays.gd")
const soldiers = preload("res://Scripts/Entities/Foot/SoldierArrays.gd")

var title: String
var team: String
var roster: Array[Unit] = []
var ships: Array[Ship] = []
var id: int

#region Ships

#add ship classes later
func spawnShip(shipClass: String, system: Location):
	var ship = load("res://Scenes/Entities/Ships/SpaceShip.tscn").instantiate()
	add_child(ship)
	ships.append(ship)
	system.ships.append(ship)
	ship.location = system
	ship.setFaction(self)
	match shipClass:
		"Bigun":
			spawnShuttles(10, ship)
		_:
			"Error: not a real shipclass"

func removeShip(ship: Ship):
	for unit in ship.getRoster():
		removeUnit(unit)
	ships.erase(ship)
	ship.location.ships.erase(ship)
	remove_child(ship)
	for shuttle in ship.getShuttles():
		ship.shuttles.erase(shuttle)
		shuttle.queue_free()
		remove_child(shuttle)
	ship.queue_free()

#Move a ship from one faction to another. Deletes the current roster! Optional roster setting.
func transferShip(ship: Ship, faction: Faction, tempRoster: Array[Unit] = []):
	for unit in ship.getRoster():
		removeUnit(unit)
	ships.erase(ship)
	ship.reparent(faction)
	faction.ships.append(ship)
	ship.roster = tempRoster

func spawnShuttles(n: int, ship: Ship):
	for i in range(0, n):
		var shuttle = load("res://Scenes/Entities/Ships/Shuttle.tscn").instantiate()
		ship.shuttles.append(shuttle)
		shuttle.setFaction(self)
		shuttle.mothership = ship
		add_child(shuttle)

#endregion

#region Units & Entities

## Spawns a starting unit at the given location. All factions currently spawn
## the same base unit regardless of location; override in a subclass if a
## faction should vary its spawn based on where it's spawning.
func spawnLocational(location: Location) -> Unit:
	return spawnBase()

## Returns this faction's default starting unit. Overridden by subclasses.
func spawnBase() -> Unit:
	return null

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

func removeUnit(unit: Unit):
	for model in unit.getRoster():
		removeEntity(model)

#endregion

#region Setters & Getters

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

#endregion

func _to_string() -> String:
	var ret: String = getTitle()
	for item in roster:
		ret += "\n" + str(item)
	return ret
