extends Control
class_name Faction

const weapons = preload("res://Scripts/Equipment/WeaponArrays.gd")
const armour = preload("res://Scripts/Equipment/ArmourArrays.gd")
const soldiers = preload("res://Scripts/Entities/Foot/SoldierArrays.gd")

var title : String
var team : String
var roster : Array[Unit] = []

func _init(t : String, T : String):
	title = t
	team = T

func createUnit(arr: Array[Entity], RosterCap: int, Type: String) -> Unit:
	var newSquad: Squad = Squad.new(str(roster.size()+1), arr, RosterCap, self, Type)
	roster.append(newSquad)
	return newSquad

func setTitle(t : String):
	title = t
	
func setRoster(arr : Array[Unit]):
	roster = []
	for unit in arr:
		roster.append(unit)

func getTitle() -> String:
	return title

func getTeam() -> String:
	return team

func getRoster() -> Array[Unit]:
	return roster

func getEntities() -> Array[Entity]:
	var arr : Array[Entity] = []
	for unit in getRoster():
		for ent in unit.getRoster():
			arr.append(ent)
	return arr

func _to_string() -> String:
	var str: String = getTitle()
	
	for item in roster:
		str += "\n" + str(item)
	return str
