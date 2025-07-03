extends Unit
class_name Squad

var type : String

func _init(Title : String, Roster : Array[Entity], RosterCap : int, Fac : Faction, Type : String):
	title = Title
	rosterCap = RosterCap
	setRoster(Roster)
	faction = Fac
	type = Type

func _to_string() -> String:
	var retstr: String = getTitle() + " - " + str(type)
	
	for item in roster:
		retstr += "\n" + str(item)
	return retstr
