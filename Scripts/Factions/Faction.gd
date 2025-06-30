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
