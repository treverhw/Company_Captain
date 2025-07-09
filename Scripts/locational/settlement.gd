extends Location
class_name Settlement

var connections: Dictionary = {}
var newCounter: int = 0

func getConnections() -> Dictionary:
	return connections

func _ready() -> void:
	get_parent().get_node("Button").button_down.connect(turn)

func turn():
	match team:
		"Imperium":
			newCounter += 1
			if newCounter >= 2:
				roster.append(get_parent().get_parent().guard.spawnSquad())
		#"Chaos":
		#	newCounter += 1
		#	if newCounter >= 2:
		#		roster.append(get_parent().get_parent().chaos.spawnSquad())
		_:
			pass
	print("ran")
	if roster.size() > 1:
		var distance: int = 10000
		var destination: Settlement
		for settlement in connections:
			if connections[settlement] < distance and settlement.team != team:
				destination = settlement
				distance = connections[settlement]
		if is_instance_valid(destination):
			destination.change([roster.pop_back()])

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
