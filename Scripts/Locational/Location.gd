extends Node2D
class_name Location
## Base class for anything that holds a roster of Units at a fixed point
## in the world (Settlements, and Convoy while it's in transit).

var title: String
var roster: Array[Unit]
var team: String = "Unowned"

func distance(node1: Node, node2: Node) -> float:
	return node1.global_position.distance_to(node2.global_position)

## Picks a random name from `val` and uses it as both title and node name.
func generateTitle(val: Array) -> void:
	var chosen = val[randi_range(0, val.size() - 1)]
	title = chosen
	name = chosen

func appendRoster(val: Array[Unit]) -> void:
	roster.append_array(val)

## -- Setters and Getters --
func setTitle(Title: String) -> void:
	title = Title
func setRoster(val: Array[Unit]) -> void:
	roster = val
func setTeam(val: String) -> void:
	team = val

func getTitle() -> String:
	return title
func getRoster() -> Array[Unit]:
	EntityUtils.pruneInvalid(roster)
	return roster
func getTeam() -> String:
	return team
