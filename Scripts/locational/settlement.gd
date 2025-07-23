extends Location
class_name Settlement

var connections: Dictionary = {}
var newCounter: int = 0
var line

func getConnections() -> Dictionary:
	return connections

func _ready() -> void:
	get_parent().get_node("Button").button_down.connect(turn)
	generateTitle(Names.new().planetNames)
	get_node("Name").text = name
	

func shortestPath(settlements: Array[Settlement], source: Settlement = self):
	var dist = {}
	var prev = {}
	var queue: Array[Settlement]
	for settlement in settlements:
		dist[settlement] = 1000
		prev[settlement] = null
		queue.append(settlement)
	dist[source] = 0
	
	while !queue.is_empty():
		var closestSettlement: Settlement = null
		var shortest: int = 1001
		for settlement in queue:
			if dist[settlement] < shortest:
				closestSettlement = settlement
				shortest = dist[settlement]
		queue.erase(closestSettlement)
		for settlement in closestSettlement.getConnections():
			var temp = floor(distance(closestSettlement, settlement)/50)
			#convoys move 50px a turn.
			if dist[settlement] >= 1000:
				dist[settlement] = dist[closestSettlement] + temp
				prev[settlement] = closestSettlement
			elif dist[closestSettlement] + temp < dist[settlement]:
				dist[settlement] = dist[closestSettlement] + temp
				prev[settlement] = closestSettlement
	
	#find nearest unowned node
	var path = []
	var target: Settlement
	var distance: int = 1000
	for settlement in settlements:
		if dist[settlement] < distance and settlement.team != self.team:
			target = settlement
			distance = dist[settlement]
	while target != null:
		path.push_front(target)
		target = prev[target]
	print(path)
	return 

func turn():
	shortestPath(get_parent().settlements)
	if roster.size() > 2:
		pass

func change(array: Array):
	team = array[0].getTeam()
	roster = array

func _process(delta: float) -> void:
	get_node("Label").text = str(roster.size())
	if !roster.is_empty():
		match team:
			"Imperium":
				get_node("TextureRect").set_texture(load("res://Assets/locational/Imperium.png"))
			"Chaos":
				get_node("TextureRect").set_texture(load("res://Assets/locational/Bad.png"))

func _to_string() -> String:
	return title
