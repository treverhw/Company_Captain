extends Control
const weapons = preload("res://Scripts/Equipment/WeaponArrays.gd")
const armour = preload("res://Scripts/Equipment/ArmourArrays.gd")
const soldiers = preload("res://Scripts/Entities/Foot/SoldierArrays.gd")
var playerFaction = PlayerFaction.new("Salamanders")
var squad : Squad

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerFaction.start()
	print(playerFaction)
