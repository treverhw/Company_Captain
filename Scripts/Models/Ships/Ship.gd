extends Model
class_name Ship

var roster: Array[Unit] = []

func _ready() -> void:
	generateTitle(Names.shipNames)

func setLocation(val) -> void:
	if location:
		location.getRoster().erase(self)
	val.getShips().append(self)
	location = val

func getRoster() -> Array[Unit]:
	for guy in range(roster.size() -1,-1,-1):
		if !is_instance_valid(roster[guy]):
			roster.erase(roster[guy])
	return roster

func _to_string() -> String:
	return getTitle()
