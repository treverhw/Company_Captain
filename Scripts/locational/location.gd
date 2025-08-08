extends Node2D
class_name Location

var title: String
var roster: Array[Unit]
var team: String = "Unowned"

func distance(Node1: Node, Node2: Node) -> float:
	return Node1.global_position.distance_to(Node2.global_position)
func generateTitle(val : Array):
	var new = val[randi_range(0, val.size()-1)]
	title = new
	name = new
func appendRoster(val: Array[Unit]):
	roster.append_array(val)


#Setters and Getters
func setTitle(Title: String):
	title = Title
func setRoster(val: Array[Unit]):
	roster = val
func setTeam(val: String):
	team = val

func getTitle() -> String:
	return title
func getRoster() -> Array[Unit]:
	for unit in range(roster.size()-1,-1,-1):
		if !is_instance_valid(roster[unit]):
			roster.erase(roster[unit])
	return roster
func getTeam() -> String:
	return team
