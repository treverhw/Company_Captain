extends Entity
class_name Ship

var roster: Array[Unit] = []

func getRoster() -> Array[Unit]:
	for unit in range(roster.size() -1,-1,-1):
		if !is_instance_valid(roster[unit]):
			roster.erase(roster[unit])
	return roster

func _ready() -> void:
	var names = Names.new().shipNames
	generateTitle(names)

func _to_string() -> String:
	return getTitle()
