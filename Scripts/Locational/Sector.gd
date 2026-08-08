extends Location
class_name Sector

var systems: Array[System] = []
var ships: Array[Ship] = []
signal generation_progress(current: int, total: int)

func generate() -> void:
	await generateSystems()
	get_parent().get_node("BottomBar/Turn").button_down.connect(turn)

func generateSystems() -> void:
	var count: int = randi_range(25, 35)
	for n in count:
		var newSystem: System = SYSTEM_SCENE.instantiate()
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
		await newSystem.generate()
		generation_progress.emit(n+1, count)
		await get_tree().process_frame

signal turn_progress(current: int, total: int)
var inProg: bool = false
func turn():
	if inProg:
		return
	inProg = true
	
	var allPlanets: Array[Planet] = getAllPlanets()
	var exploreRoutes: Dictionary = SectorUtils.precomputeAllExploreRoutes(allPlanets)
	
	var systemList = getSystems()
	for i in systemList.size():
		await systemList[i].turn()
		turn_progress.emit(i + 1, systemList.size())
		await get_tree().process_frame
	
	var remaining = [allPlanets.size()]
	for planet in allPlanets:
		planetTurn(planet, exploreRoutes, remaining)
	while remaining[0] > 0:
		await get_tree().process_frame 
	
	for system: System in systemList:
		var comp = true
		for planet in system.getPlanets():
			if !planet.compliant:
				comp = false
		system.compliant = comp
		if !system.compliant:
			for ship in system.ships:
				await ship.disembark()
				await ship.embark()
			for t in system.presentTeams:
				if GlobalFunctions.compareAttackWeight(system.assaultUnits[t], system.assaultTarget[t].getRoster()):
					system.assaultTarget[t].invade(system.assaultUnits[t])
		else: 
			for ship: Ship in system.ships:
				await ship.embark()
				if ship.getRemainingCapacity() / ship.getCapacity() >= .9:
					pass
					#seek new system.
	
	inProg = false

func planetTurn(planet: Planet, exploreRoutes: Dictionary, remaining: Array) -> void:
	await planet.turn(exploreRoutes)
	remaining[0] -= 1

func getSystems() -> Array[System]:
	return systems

func getAllPlanets() -> Array[Planet]:
	var planets: Array[Planet] = []
	for system in getSystems():
		planets.append_array(system.getPlanets())
	return planets

func getShips() -> Array[Ship]:
	return ships
