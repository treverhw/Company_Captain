extends Control
class_name Faction

var title : String
var roster : Array[Unit] = []

func _init(t : String):
	title = t

func setTitle(t : String):
	title = t
	
func setRoster(arr : Array[Unit]):
	roster = []
	for unit in arr:
		roster.append(unit)

func getTitle() -> String:
	return title

func getRoster() -> Array[Unit]:
	return roster

func getEntities() -> Array[Entity]:
	var arr : Array[Entity] = []
	for unit in getRoster():
		for ent in unit.getRoster():
			arr.append(ent)
	return arr
