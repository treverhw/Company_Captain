extends Node
class_name Armour

var title : String
var speed : int
var toughness : int
var save : int
var wounds : int
var weight : int
var description : String

func _init(arr : Array):
	name = arr[0]
	title = arr[0]
	speed = arr[1]
	toughness = arr[2]
	save = arr[3]
	wounds = arr[4]
	weight = arr[5]
	description = arr[6]

#Getters
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

func _to_string() -> String:
	return getTitle()
