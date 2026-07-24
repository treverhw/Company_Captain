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
	#for ship in getShips():
	#	ship.move()
	
	var allPlanets: Array[Planet] = getAllPlanets()
	var exploreRoutes: Dictionary = SectorUtils.precomputeAllExploreRoutes(allPlanets)
	
	for system in getSystems():
		await system.turn(exploreRoutes)

func getSystems() -> Array[System]:
	return systems

func getAllPlanets() -> Array[Planet]:
	var planets: Array[Planet] = []
	for system in getSystems():
		planets.append_array(system.getPlanets())
	return planets

func getShips() -> Array[Ship]:
	return ships
