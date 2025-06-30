extends Unit
class_name Squad

var type : String

func _init(t : String, r : Array[Entity], rC : int, f : Faction, ty : String):
	title = t
	rosterCap = rC
	setRoster(r)
	faction = f
	type = ty
