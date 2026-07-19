extends Ship
class_name SpaceShip

var shuttles: Array[Shuttle] = []
var capacity: int = 250

func turn():
	for shuttle in getShuttles():
		shuttle.used = false

func embark(shuttle: Shuttle):
	shuttles.append(shuttle)
	getRoster().append_array(shuttle.getRoster())

func disembark(units: Array[Unit], destiantion: Planet, port: Settlement = null):
	var available = getShuttles()
	if available.is_empty():
		return
	var shuttle = available.front()

func getShuttles() -> Array[Shuttle]:
	for shuttle in range(shuttles.size()-1,-1,-1):
		if !is_instance_valid(shuttles[shuttle]):
			shuttles.erase(shuttles[shuttle])
	return shuttles

func _ready() -> void:
	var names = Names.new().shipNames
	generateTitle(names)

func _to_string() -> String:
	var used: int = 0
	for shuttle in shuttles:
		if shuttle.used == false:
			used += 1
	return title + " (" + str(used) + "/" + str(shuttles.size()) + ")" 
