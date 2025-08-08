extends Node
class_name Faction

const weapons = preload("res://Scripts/Equipment/WeaponArrays.gd")
const armour = preload("res://Scripts/Equipment/ArmourArrays.gd")
const soldiers = preload("res://Scripts/Entities/Foot/SoldierArrays.gd")

var title : String
var team : String
var roster : Array[Unit] = []
var id : int

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

func spawnLocational(location: Location):
	var unit = spawnBase()
	return unit

func spawnBase() -> Unit:
	return null

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

func _to_string() -> String:
	var ret: String = getTitle()
	
	for item in roster:
		ret += "\n" + str(item)
	return ret
