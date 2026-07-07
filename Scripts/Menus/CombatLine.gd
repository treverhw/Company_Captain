extends VBoxContainer
class_name CombatLine
## A single line within a CombatArmy — holds the Entities currently
## occupying that line/rank during combat.

var team: String
var roster: Array[Entity]

func setRoster(val: Array[Entity]) -> void:
	roster = val
func getRoster() -> Array[Entity]:
	return roster
