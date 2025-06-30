extends Faction
class_name PlayerFaction

func _init(t: String) -> void:
	title = t
	team = "Imperium"

func customAstartes(val1 : String, val2 : String, val3 : String):
	var arm : Armour = Armour.new(armour.AstartesArmour[val1])
	var wpn1 : Weapon = Weapon.new(weapons.AstartesWeapons[val2])
	var wpn2 : Weapon = Weapon.new(weapons.AstartesWeapons[val3])
	var guy : Soldier = Soldier.new(soldiers.Soldiers["SpaceMarine"], arm, wpn1, wpn2)

func spawnScout():
	var arm : Armour = Armour.new(armour.AstartesArmour["Scout"])
	var wpn1 : Weapon = Weapon.new(weapons.AstartesWeapons["Boltgun"])
	var wpn2 : Weapon = Weapon.new(weapons.AstartesWeapons["Bolt Pistol"])
	var guy : Soldier = Soldier.new(soldiers.Soldiers["SpaceMarine"], arm, wpn1, wpn2)
