extends Unit
class_name Squad

func define(Title : String, RosterCap : int, Fac : Faction):
	title = Title
	rosterCap = RosterCap
	faction = Fac

func _to_string() -> String:
	var retstr: String = getTitle()
	
	for model in roster:
		retstr += "\n" + str(model)
	return retstr
