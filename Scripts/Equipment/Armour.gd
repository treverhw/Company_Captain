extends Node
class_name Armour
## Data-holder for an armour set's stats

var title: String
var speed: int
var toughness: int
var save: int
var weight: int
var wounds: int
var description: String
var size: int

func define(res: ArmourStats) -> void:
	title = res.title
	speed = res.speed
	toughness = res.toughness
	save = res.save
	weight = res.weight
	wounds = res.wounds
	size = res.size
	description = res.description

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
