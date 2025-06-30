extends Control
class_name Weapon

var title : String
var a : int
var bs : int
var s : int
var ap : int
var d : int
var twoHands : bool
var melee : bool
var description : String

func _init(arr : Array):
	title = arr[0]
	a = arr[1]
	s = arr[2]
	ap = arr[3]
	d = arr[4]
	twoHands = arr[5]
	melee = arr[6]
	description = arr[7]

func isTwoHander() -> bool:
	return twoHands

func isMelee() -> bool:
	return melee

#Getters
func getTitle() -> String:
	return title

func getAttacks() -> int:
	return a

func getBS() -> int:
	return bs

func getStrength() -> int:
	return s

func getAP() -> int:
	return ap

func getDmg() -> int:
	return d

func getDescription() -> String:
	return description
