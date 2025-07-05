extends Location
class_name Settlement

var connections: Array[Settlement]

func getConnections() -> Array[Settlement]:
	return connections

func _process(delta: float) -> void:
	get_node("Label").text = str(roster.size())
