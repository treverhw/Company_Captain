extends Unit
class_name Squad

func define(Title : String, RosterCap : int, Fac : Faction):
	title = Title
	rosterCap = RosterCap
	faction = Fac

func _process(delta: float) -> void:
	sizeCheck()
