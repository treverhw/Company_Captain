extends Model
class_name Ship

var roster: Array[Unit] = []

func _ready() -> void:
	var names = Names.shipNames
	generateTitle(names)

func setLocation(val) -> void:
	if location:
		location.getRoster().erase(self)
	val.getShips().append(self)
	location = val

func getRoster() -> Array[Unit]:
	for unit in range(roster.size() -1,-1,-1):
		if !is_instance_valid(roster[unit]):
			roster.erase(roster[unit])
	return roster

func _to_string() -> String:
	return getTitle()
