extends Resource
class_name WeaponStats

##Name of the Weapon
@export var title: String
##Number of the weapons attacks. A string because it can be a dice roll.
@export var attacks: String
##Strength of the Weapon
@export var strength: int
##Armour Piercing Value of the weapon
@export var ap: int
##Damage of the Weapon. A string because it can be a dice roll.
@export var damage: String
##Weight, a value used to measure the threat of a unit, sort of a tier system.
@export var weight: int
##A check for if the weapon is two handed. If you're using a two handed weapon, it's the only weapon you're using.
@export var twoHands: bool
##Check for if the weapon is a melee weapon.
@export var melee: bool
##Check for if the weapon is a pistol. Can be used in both ranged and short range melee.
@export var pistol: bool
##Going to be used for abilities like Dev Wounds and Heavy.
@export var modifiers: Array[String]
##Fluff description
@export var bsMod: int
##Fluff description
@export var description: String
