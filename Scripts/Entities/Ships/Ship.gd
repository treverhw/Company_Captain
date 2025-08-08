extends Entity
class_name Ship

var roster: Array[Unit] = []

func getRoster() -> Array[Unit]:
	for unit in range(roster.size() -1,-1,-1):
		if !is_instance_valid(roster[unit]):
			roster.erase(roster[unit])
	return roster
