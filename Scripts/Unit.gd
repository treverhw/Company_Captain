extends Node
class_name Unit

var title : String
var roster : Array[Node] = []
var rosterCap : int = 5
var faction : Faction

func define(t : String, rC : int, f : Faction):
	title = t
	rosterCap = rC
	faction = f

func setTitle(t : String):
	title = t

func setRosterCap(val : int):
	rosterCap = val

func setFaction(val : Faction):
	faction = val

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

func _to_string() -> String:
	var str: String = getTitle() + " - " + str(getFaction().getTitle())
	
	for item in roster:
		str += "\n" + str(item)
	return str
