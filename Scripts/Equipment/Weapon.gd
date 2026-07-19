extends Node
class_name Weapon
## Data-holder for a weapon's stats

var title: String
var attacks: String
var strength: int
var ap: int
var damage: String
var twoHands: bool
var melee: bool
var pistol: bool
var modifiers: Array[String]
var description: String

func define(res: WeaponStats) -> void:
	title = res.title
	attacks = res.attacks
	strength = res.strength
	ap = res.ap
	damage = res.damage
	twoHands = res.twoHands
	melee = res.melee
	pistol = res.pistol
	modifiers = res.modifiers
	description = res.description

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
	if "d" in attacks:
		return GlobalFunctions.rollStringd6(attacks)
	else: return int(attacks)
func getStrength() -> int:
	return strength
func getAP() -> int:
	return ap
func getDmg() -> int:
	if "d" in damage:
		return GlobalFunctions.rollStringd6(damage)
	else: return int(damage)
func getModifiers() -> Array[String]:
	return modifiers
func getDescription() -> String:
	return description

func _to_string() -> String:
	return getTitle()
