extends Node
class_name Location

var title: String
var roster: Array
var team: String = "Unowned"

func distance(Node1: Node, Node2: Node) -> float:
	return Node1.global_position.distance_to(Node2.global_position)

func setTitle(Title: String):
	title = Title
func generateTitle(val : Array):
	var new = val[randi_range(0, val.size()-1)]
	title = new
	name = new
	

func getTitle() -> String:
	return title
func getRoster() -> Array:
	return roster
