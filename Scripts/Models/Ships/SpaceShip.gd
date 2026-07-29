extends Ship
class_name SpaceShip

var capacity: int = 250

func turn():
	pass

func embark(shuttle: Shuttle):
	pass

func disembark(units: Array[Unit], destiantion: Planet, port: Settlement = null):
	pass

func getCapacity() -> int:
	return capacity

func getRemainingCapacity() -> int:
	var total: int = 0
	for unit in getRoster():
		total += unit.getSize()
	return capacity - total

func _ready() -> void:
	var names = Names.shipNames
	generateTitle(names)

func _to_string() -> String:
	var used: int = 0
	return title + " (" + str(capacity-getRemainingCapacity()) + "/" + str(capacity) + ")" 
