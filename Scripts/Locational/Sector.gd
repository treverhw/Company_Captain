extends Location
class_name Sector

var systems: Array[System] = []
var ships: Array[Ship] = []

func _ready() -> void:
	generateSystems()
	get_parent().get_node("BottomBar/Turn").button_down.connect(turn)

func generateSystems() -> void:
	for n in randi_range(25, 35):
		var newSystem: System
		newSystem = SYSTEM_SCENE.instantiate()
		newSystem.global_position = Vector2(randi_range(-800, 800), randi_range(-350, 350))
		var counter := 0
		while !validateDistance(newSystem, systems, 64) and counter != 100:
			counter += 1
			newSystem.global_position = Vector2(randi_range(-800, 800), randi_range(-350, 350))
		if counter == 100:
			break
		get_node("Systems").add_child(newSystem)
		systems.append(newSystem)
		newSystem.sector = self

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
