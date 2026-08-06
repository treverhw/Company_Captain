extends Location
class_name System

var ships: Array[Ship] = []
var planets: Array[Planet] = []
var priority: Array[Planet] = []
var sector: Sector

func turn() -> void:
	var text: String = "Ships: "
	for ship in getShips():
		ship.turn()
		text += " | " + str(ship) + " - " + ship.getFaction().getTitle()
	get_node("Visuals/ShipCount").text = text
	getCompliance()
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
	pass

func onloadShips():
	pass

func transferShips():
	pass

#t is team
func createPlanetPriority(t: String):
	var test = {}
	planets = getPlanets()
	for planet in planets:
		if !planet.compliance():
			planet.setBalance(t)
			test[planet] = planet.balance
	planets.sort_custom(func(a,b): return a.balance < b.balance)
	#print(test)

func getCompliance() -> bool:
	compliant = true
	for planet in getPlanets():
		if !planet.compliance():
			compliant = false
			return false
	return true

#t is team
func getBalanceSum(t: String) -> int:
	var balanceSum: int = 0
	for planet in getPlanets():
		balanceSum += planet.getBalance(t)
	return balanceSum

func getShips() -> Array[Ship]:
	return ships

func getPlanets() -> Array[Planet]:
	return planets

func generate() -> void:
	generateTitle(Names.planetNames)
	get_node("PlanetSprite/SystemName").text = title
	get_node("Visuals").global_position = Vector2(0,0)
	var positions = [Vector2(478, 863), Vector2(762, 774), Vector2(1079, 754), Vector2(1567, 947), 
					 Vector2(233, 766), Vector2(478, 666), Vector2(998, 601),  Vector2(1404, 655),
					 Vector2(218, 600), Vector2(597, 493), Vector2(937, 462),  Vector2(1385, 496),  
					 Vector2(1706, 595)]
	for x in range(0,randi_range(2,5)):
		var planet = PLANET_SCENE.instantiate()
		var val = positions[randi_range(0,positions.size()-1)]
		planet.get_node("PlanetNode").global_position = val - Vector2(1920/2, 1080/2)
		positions.erase(val)
		get_node("Visuals").add_child(planet)
		planets.append(planet)
		planet.system = self
		planet.setName(title + " " + GlobalFunctions.numToRoman(x+1))
		await planet.generate()
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
	get_node("Visuals/ShipCount").text = text


func _on_button_pressed() -> void:
	var text: String = ""
	for ship in getShips():
		#print(str(ship) + "\n" + str(ship.getRoster()))
		text += " | " + str(ship) + " - " + ship.getFaction().getTitle()
	get_node("Visuals/ShipCount").text = text

func _on_planet_sprite_pressed() -> void:
	get_node("Visuals").visible = true


func _on_close_pressed() -> void:
	get_node("Visuals").visible = false
	for planet in planets:
		planet.get_node("PlanetMenu").visible = false
