extends Ship
class_name SpaceShip

var capacity: int = 250

func turn():
	pass

func getCapacity() -> int:
	return capacity

func getRemainingCapacity() -> int:
	var total: int = 0
	for guy in getRoster():
		total += guy.getSize()
	return capacity - total

func _ready() -> void:
	generateTitle(Names.shipNames)

func _to_string() -> String:
	return title + " (" + str(capacity-getRemainingCapacity()) + "/" + str(capacity) + ")" 
