extends Location
class_name System

var ships: Array[Ship] = []
var planets: Array[Planet] = []
var priority: Array[Planet] = []
var compliant: bool

func turn():
	for planet in planets:
		await planet.turn()
		if planet.
	if system.co

func createPlanetPriority(team: String):
	var test = {}
	planets = getPlanets()
	for planet in planets:
		if !planet.compliance():
			planet.setBalance(team)
			test[planet] = planet.balance
	planets.sort_custom(func(a,b): return a.balance < b.balance)
	print(test)

func getCompliance() -> bool:
	for planet in getPlanets():
		if !planet.compliance():
			return false
	return true

func getPlanets() -> Array[Planet]:
	return planets

func _ready() -> void:
	get_node("SystemSprite").global_position = Vector2(1920/2,1080/2 - 52)
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
		print(str(planet.get_node("PlanetNode").global_position))
	getPlanetPriority("Imperium")
