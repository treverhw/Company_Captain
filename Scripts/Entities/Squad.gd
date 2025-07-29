extends Unit
class_name Squad

func define(Title : String, RosterCap : int, Fac : Faction):
	title = Title
	rosterCap = RosterCap
	faction = Fac

func combatUpdate():
	var n = getAlive()
	get_node("Roster Size").text = str(n)
	if n <= 0:
		visible = false
