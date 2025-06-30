extends Control
const weapons = preload("res://Scripts/Equipment/WeaponArrays.gd")
const armour = preload("res://Scripts/Equipment/ArmourArrays.gd")
const soldiers = preload("res://Scripts/Entities/Foot/SoldierArrays.gd")
var squad : Squad

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var arm : Armour = Armour.new(armour.AstartesArmour["Tacticus"])
	var arm2 : Armour = Armour.new(armour.AstartesArmour["Gravis"])
	var wpn1 : Weapon = Weapon.new(weapons.AstartesWeapons["Bolt Rifle"])
	var wpn2 : Weapon = Weapon.new(weapons.AstartesWeapons["Bolt Pistol"])
	var guy : Soldier = Soldier.new(soldiers.Soldiers["SpaceMarine"], arm, wpn1, wpn2)
	var guy2 : Soldier = Soldier.new(soldiers.Soldiers["SpaceMarine"], arm, wpn1, wpn2)
	var guy3 : Soldier = Soldier.new(soldiers.Soldiers["SpaceMarine"], arm2, wpn1, wpn2)
	var guy4 : Soldier = Soldier.new(soldiers.Soldiers["SpaceMarine"], arm2, wpn1, wpn2)
	var guy5 : Soldier = Soldier.new(soldiers.Soldiers["SpaceMarine"], arm, wpn1, wpn2)
	var Guys : Array[Entity] = [guy, guy2, guy3, guy4, guy5]
	squad = Squad.new("Acherus", Guys, 5, Faction.new("Imperium", "Imperium"), "Intercession")
