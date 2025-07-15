extends Node
class_name Location

var title: String
var roster: Array
var team: String = "Unowned"

func setTitle(Title: String):
	title = Title
func generateTitle(val : Array):
	title = val[randi_range(0, val.size()-1)]

func getTitle() -> String:
	return title

func getRoster() -> Array:
	return roster
