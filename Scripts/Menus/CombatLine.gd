extends VBoxContainer
class_name CombatLine
## A single line within a CombatArmy — holds the Entities currently
## occupying that line/rank during combat.

var team: String
var roster: Array[Model]

func setRoster(val: Array[Model]) -> void:
	roster = val
func getRoster() -> Array[Model]:
	return roster
