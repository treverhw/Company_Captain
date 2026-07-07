extends HBoxContainer
class_name CombatArmy
## One side's army in combat — an HBoxContainer whose children are the
## CombatLines (front line through rear).

var team: String

func getSize() -> int:
	var n: int = 0
	for node in get_children():
		n += node.getRoster().size()
	return n

func _to_string() -> String:
	var ret: String = str(name) + "\n"
	for child in get_children():
		ret += str(child.name) + str(child.get_children()) + "\n"
	return ret
