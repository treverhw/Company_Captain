extends TextureRect
class_name Unit

var title : String
var roster : Array[Node] = []
var rosterCap : int = 5
var faction : Faction
var line: int = 1
var location: Location

func define(t : String, rC : int, f : Faction):
	title = t
	rosterCap = rC
	faction = f

func validate():
	if size() <= 0: return false
	else: 			return true

func assignModels():
	for model in roster:
		model.unit = self

func removeEntity(model: Entity):
	faction.removeEntity(model)

func size():
	var counter: int = 0
	for model in roster:
		if model.alive():
			counter += 1
	return counter

func sizeCheck():
	scale.x = size()*.2


##Setters and Getters
func setTitle(t : String):
	title = t

func setRosterCap(val : int):
	rosterCap = val

func setFaction(val : Faction):
	faction = val

func setLocation(val: Location):
	location = val

func getTitle() -> String:
	return title

func getRoster() -> Array[Node]:
	return roster

func getRosterCap() -> int:
	return rosterCap

func getFaction() -> Faction:
	return faction

func getTeam() -> String:
	return getFaction().getTeam()

func getLine() -> String:
	return str(line)

func getLocation() -> Location:
	return location

func _to_string() -> String:
	var ret: String = str(getFaction().getTitle()) + " " + getTitle()
	ret += str(roster)
	return ret

func _to_string_combat() -> String:
	var ret: String = str(getFaction().getTitle()) + " " + getTitle()
	var temp = "["
	for unit in roster:
		for model in unit.getRoster():
			if model.alive():
				temp += model + ", "
		
	ret += str(roster)
	return ret
