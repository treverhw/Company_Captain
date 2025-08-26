extends Location
class_name Sector

var systems: Array[System] = []
var ships: Array[Ship] = []

func turn():
	for ship in getShips():
		ship.move()
	for system in getSystems():
		system.turn()

func getSystems() -> Array[System]:
	return systems

func getShips() -> Array[Ship]:
	return ships
