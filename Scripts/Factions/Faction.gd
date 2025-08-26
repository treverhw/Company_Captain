extends Node
class_name Faction

const weapons = preload("res://Scripts/Equipment/WeaponArrays.gd")
const armour = preload("res://Scripts/Equipment/ArmourArrays.gd")
const soldiers = preload("res://Scripts/Entities/Foot/SoldierArrays.gd")

var title : String
var team : String
var roster : Array[Unit] = []
var ships: Array[Ship] = []
var id : int

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
		add_child(shuttle)

#endregion

#region Units & Entities

func spawnLocational(location: Location):
	var unit = spawnBase()
	return unit

func spawnBase() -> Unit:
	return null

func removeEntity(model: Entity):
	var unit = model.getUnit()
	#print(str(name) + " Removing Model: " + str(model.name))
	unit.getRoster().erase(model)
	if unit.getRoster().size() <= 0:
		#print(str(name) + " Removing Unit: " + str(unit.name))
		if is_instance_valid(unit.getLocation()):
			unit.getLocation().getRoster().erase(unit)
		roster.erase(unit)
		unit.queue_free()
	model.queue_free()

func removeUnit(unit: Unit):
	for model in unit:
		removeEntity(model)

#endregion

#region Setters & Getters

func setTitle(t : String):
	title = t
	
func setRoster(arr : Array[Unit]):
	roster = []
	for unit in arr:
		roster.append(unit)

func getTitle() -> String:
	return title

func getTeam() -> String:
	return team

func getRoster() -> Array[Unit]:
	for unit in range(roster.size()-1,-1,-1):
		if !is_instance_valid(roster[unit]):
			roster.erase(roster[unit])
	return roster

#endregion

func _to_string() -> String:
	var ret: String = getTitle()
	
	for item in roster:
		ret += "\n" + str(item)
	return ret
