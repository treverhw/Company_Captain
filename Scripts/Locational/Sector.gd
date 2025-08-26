extends Location
class_name Sector

var systems: Array[System] = []
var ships: Array[Ship] = []

func _ready() -> void:
	var system1 = load("res://Scenes/Locational/System.tscn").instantiate()
	systems.append(system1)
	add_child(system1)
	get_parent().get_node("BottomBar/Turn").button_down.connect(turn)

func turn():
	for ship in getShips():
		ship.move()
	for system in getSystems():
		system.turn()

func getSystems() -> Array[System]:
	return systems

func getShips() -> Array[Ship]:
	return ships
