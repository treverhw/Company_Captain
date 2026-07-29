extends Node2D
class_name Location
## Base class for anything that holds a roster of Units at a fixed point
## in the world (Settlements, and Convoy while it's in transit).

const SECTOR_SCENE := preload("res://Scenes/Locational/Sector.tscn")
const SYSTEM_SCENE := preload("res://Scenes/Locational/System.tscn")
const PLANET_SCENE := preload("res://Scenes/Locational/Planet.tscn")
const SETTLEMENT_SCENE := preload("res://Scenes/Locational/Settlement.tscn")
const STARPORT_SCENE := preload("res://Scenes/Locational/Starport.tscn")
const COMBAT_SCENE = preload("res://Scenes/Menus/Combat.tscn")

const UNOWNED_TEX := preload("res://Assets/locational/unowned.png")
const IMPERIUM_TEX := preload("res://Assets/locational/Imperium.png")
const HOSTILE_TEX := preload("res://Assets/locational/Bad.png")

var title: String
var roster: Array[Unit]
var team: String = "Unowned"
var presentTeams: Array[String] = []
var compliant: bool = false

func distance(node1: Node, node2: Node) -> float:
	return node1.global_position.distance_to(node2.global_position)

## Picks a random name from `arr` and uses it as both title and node name.
func generateTitle(arr: Array) -> void:
	var chosen = arr.pop_back()
	title = chosen
	name = chosen

func appendRoster(val: Array[Unit]) -> void:
	roster.append_array(val)

## True if no other location in `arr` is within `range` of `val`. Used to
## keep generated settlements/systems from overlapping.
func validateDistance(val: Location, arr, range: int) -> bool:
	for n in arr:
		if val.position.distance_to(n.position) < range and n != val:
			return false
	return true

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
	ModelUtils.pruneInvalid(roster)
	return roster
func getTeam() -> String:
	return team
