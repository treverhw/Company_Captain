extends VBoxContainer
class_name CombatLine

var team: String
var roster: Array[Entity]

func setRoster(val: Array[Entity]):
	roster = val
func getRoster() -> Array[Entity]:
	return roster
