extends Control
class_name Unit

var title : String
var roster : Array[Entity] = []
var rosterCap : int = 5
var faction : Faction

func _init(t : String, r : Array[Entity], rC : int, f : Faction):
	title = t
	rosterCap = rC
	setRoster(r)
	faction = f

func setTitle(t : String):
	title = t

func setRoster(arr : Array[Entity]):
	for i in range(rosterCap):
		roster.append(arr[i])
		arr[i].setFaction(faction)

func addToRoster(val: Entity) -> bool:
	if roster.size() >= rosterCap:
		return false
	else:
		roster.append(val)
		return true

func setRosterCap(val : int):
	rosterCap = val

func setFaction(val : Faction):
	faction = val

func getTitle() -> String:
	return title

func getRoster() -> Array[Entity]:
	return roster

func getRosterCap() -> int:
	return rosterCap

func getFaction() -> Faction:
	return faction
