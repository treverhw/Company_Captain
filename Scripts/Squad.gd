extends Unit
class_name Squad

func _init(Title : String, Roster : Array[Entity], RosterCap : int, Fac : Faction):
	title = Title
	rosterCap = RosterCap
	setRoster(Roster)
	faction = Fac

func _to_string() -> String:
	var retstr: String = getTitle()
	
	for item in roster:
		retstr += "\n" + str(item)
	return retstr
