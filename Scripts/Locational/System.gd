extends Location
class_name System

var ships: Array[Ship] = []
var planets: Array[Planet] = []
var priority: Array[Planet] = []

func turn(exploreRoutes: Dictionary = {}) -> void:
	for ship in getShips():
		ship.turn()
	getCompliance()
	for planet in planets:
		await planet.turn(exploreRoutes)
	#if !compliant:
	#	offloadShips()
	#onloadShips()
	#if compliant:
	#	transferShips()
	#var text = "Ships: " + str(ships.size())
	#for ship in ships:
	#	text += " | " + str(ship) + " - " + ship.getFaction().getTitle()
	#get_node("ShipCount").text = text

func offloadShips():
	print("Offloading!")
	var teams: Array[String] = []
	for ship in getShips():
		if !teams.has(ship.getTeam()):
			teams.append(ship.getTeam())
	for team in teams:
		createPlanetPriority(team)
		var shuttles: Array[Ship] = []
		var shuttleSum: int = 0
		var requests = {}
		var balanceSum: int = 0
		for planet in getPlanets():
			requests[planet] = planet.getBalance(team)
			balanceSum += requests[planet]
		for ship in getShips():
			if !ship.getRoster().is_empty() and ship.getTeam() == team:
				for shuttle in ship.getShuttles():
					if !shuttle.used:
						shuttles.append(shuttle)
						shuttle.embark()
						shuttleSum += shuttle.getWeight()
		if balanceSum == 0:
			break
		var need: int = floor(shuttleSum/balanceSum)
		var planetShuttles = {}
		for planet in getPlanets():
			requests[planet] = requests[planet]*need
			planetShuttles[planet] = []
		shuttles = sortShuttles(shuttles)
		for planet in getPlanets():
			for shuttle in shuttles:
				var weight = shuttle.getWeight()
				if requests[planet] >= weight:
					planetShuttles[planet].append(shuttle)
					shuttles.erase(shuttle)
					requests[planet] -= weight
		while !shuttles.is_empty():
			var neediest: Planet
			var neediestVal: = 0 
			for planet in getPlanets():
				if requests[planet] >= neediestVal:
					neediest = planet
			var shuttleOfChoice = shuttles.pop_front()
			planetShuttles[neediest].append(shuttleOfChoice)
			requests[neediest] -= shuttleOfChoice.getWeight()
		for planet in getPlanets():
			for shuttle in planetShuttles[planet]:
				shuttle.disembark(planet)

func onloadShips():
	print("Onloading!")
	for ship in getShips():
		for planet in getPlanets():
			for shuttle in ship.getShuttles():
				if !shuttle.used:
					#print(planet)
					#print(str(ship) + " | " + str(planet.getTeam()))
					if planet.compliance() and planet.getTeam() == ship.getTeam():
						print(planet.getTitle() + " is Embarking!")
						shuttle.embark(planet)
						shuttle.disembark()

func transferShips():
	pass

func createPlanetPriority(team: String):
	var test = {}
	planets = getPlanets()
	for planet in planets:
		if !planet.compliance():
			planet.setBalance(team)
			test[planet] = planet.balance
	planets.sort_custom(func(a,b): return a.balance < b.balance)
	#print(test)

func sortShuttles(shuttles: Array[Ship]) -> Array[Ship]:
	shuttles.sort_custom(func(a,b): return a.getWeight() < b.getWeight())
	return shuttles

func getCompliance() -> bool:
	compliant = true
	for planet in getPlanets():
		if !planet.compliance():
			compliant = false
			return false
		else:
			print(str(planet) + " is compliant!")
	return true

func getBalanceSum(team: String) -> int:
	var balanceSum: int = 0
	for planet in getPlanets():
		balanceSum += planet.getBalance(team)
	return balanceSum

func getShips() -> Array[Ship]:
	return ships

func getPlanets() -> Array[Planet]:
	return planets

func _ready() -> void:
	var positions = [Vector2(478, 813), Vector2(762, 724), Vector2(1079, 704), Vector2(1567, 897), 
					 Vector2(233, 716), Vector2(478, 616), Vector2(998, 551),  Vector2(1404, 605),
					 Vector2(218, 550), Vector2(597, 443), Vector2(937, 412),  Vector2(1385, 446),  Vector2(1706, 545)]
	for x in range(0,randi_range(2,5)):
		var planet = load("res://Scenes/Locational/Planet.tscn").instantiate()
		var val = positions[randi_range(0,positions.size()-1)]
		planet.get_node("PlanetNode").global_position = val - Vector2(1920/2, 1080/2)
		positions.erase(val)
		add_child(planet)
		planets.append(planet)
		#print(str(planet.get_node("PlanetNode").global_position))
	
	#Create some ships (To be replaced later by Sector map generation)
	var guard = get_node("/root/Main/").getFaction("guard")
	var chaos = get_node("/root/Main/").getFaction("chaos")
	guard.spawnShip("Bigun", self)
	guard.spawnShip("Bigun", self)
	chaos.spawnShip("Bigun", self)
	chaos.spawnShip("Bigun", self)
	#print(ships)
	var text = "Ships: " + str(ships.size())
	for ship in ships:
		text += " | " + str(ship) + " - " + ship.getFaction().getTitle()
	get_node("ShipCount").text = text


func _on_button_pressed() -> void:
	for ship in getShips():
		print(str(ship) + "\n" + str(ship.getRoster()))
