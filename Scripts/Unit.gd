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
		roster[i] = arr[i]

func setRosterCap(rC : int):
	rosterCap = rC

func setFaction(fac : Faction):
	faction = fac

func getTitle() -> String:
	return title

func getRoster() -> Array[Entity]:
	return roster

func getRosterCap() -> int:
	return rosterCap

func getFaction() -> Faction:
	return faction
