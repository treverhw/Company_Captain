extends HBoxContainer
class_name CombatArmy

var team: String

func _to_string() -> String:
	var retstr = (str(name) + "\n"  +
	str(get_child(0).name) + str(get_child(0).get_children()) + "\n" +
	str(get_child(1).name) + str(get_child(1).get_children()) + "\n" +
	str(get_child(2).name) + str(get_child(2).get_children()) + "\n" +
	str(get_child(3).name) + str(get_child(3).get_children()) + "\n" +
	str(get_child(4).name) + str(get_child(4).get_children()) + "\n" +
	str(get_child(5).name) + str(get_child(5).get_children()) + "\n")
	return retstr
