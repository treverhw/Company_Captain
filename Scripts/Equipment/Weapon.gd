extends Node
class_name Weapon
## Data-holder for a weapon's stats. Built from an array taken from
## WeaponArrays.gd (see that file for the field order).

var title: String
var attacks: int
var strength: int
var ap: int
var damage: int
var twoHands: bool
var melee: bool
var pistol: bool
var description: String

func _init(arr: Array) -> void:
	name = arr[0]
	title = arr[0]
	attacks = arr[1]
	strength = arr[2]
	ap = arr[3]
	damage = arr[4]
	twoHands = arr[5]
	melee = arr[6]
	pistol = arr[7]
	description = arr[8]

func isTwoHander() -> bool:
	return twoHands
func isMelee() -> bool:
	return melee
func isPistol() -> bool:
	return pistol

## -- Getters --
func getTitle() -> String:
	return title
func getAttacks() -> int:
	return attacks
func getStrength() -> int:
	return strength
func getAP() -> int:
	return ap
func getDmg() -> int:
	return damage
func getDescription() -> String:
	return description

func _to_string() -> String:
	return getTitle()
