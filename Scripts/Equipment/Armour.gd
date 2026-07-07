extends Node
class_name Armour
## Data-holder for an armour set's stats. Built from an array taken from
## ArmourArrays.gd (see that file for the field order).

var title: String
var speed: int
var toughness: int
var save: int
var weight: int
var wounds: int
var description: String
var size: int

func _init(arr: Array) -> void:
	name = arr[0]
	title = arr[0]
	speed = arr[1]
	toughness = arr[2]
	save = arr[3]
	weight = arr[4]
	wounds = arr[5]
	size = arr[6]
	description = arr[7]

## -- Getters --
func getTitle() -> String:
	return title
func getSpeed() -> int:
	return speed
func getToughness() -> int:
	return toughness
func getSave() -> int:
	return save
func getWounds() -> int:
	return wounds
func getDescription() -> String:
	return description
func getWeight() -> int:
	return weight
func getSize() -> int:
	return size

func _to_string() -> String:
	return getTitle()
