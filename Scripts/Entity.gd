extends Control
class_name Entity

var title : String
var toughness : int
var save : int
var wounds : int
var maxWounds : int
var battlescars : int
var speed: int

func _init(t : String, to : int, s : int, mW : int, bS : int, sp : int):
	title = t
	toughness = to
	save = s
	maxWounds = mW
	wounds = maxWounds
	battlescars = bS
	speed = sp

func takeDamage(val : int):
	wounds -= val
	if wounds <= 0:
		--battlescars
		if battlescars <= 0:
			queue_free()

## Setters and Getters
