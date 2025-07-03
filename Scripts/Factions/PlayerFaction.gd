extends Faction
class_name PlayerFaction

func _init(t: String) -> void:
	title = t
	team = "Imperium"

func start():
	var squad1: Array[Entity] = []
	var squad2: Array[Entity] = []
	var newSquad1: Squad = Squad.new(str(roster.size()+1), [spawnScout(), spawnScout(), spawnScout(), spawnScout(), spawnScout()], 5, self, "Intercession")
	roster.append(newSquad1)
	var newSquad2: Squad = Squad.new(str(roster.size()+1), [spawnScout(), spawnScout(), spawnScout(), spawnScout(), spawnScout()], 5, self, "Scout")
	roster.append(newSquad2)

func customAstartes(val1 : String, val2 : String, val3 : String) -> Entity:
	var arm : Armour = Armour.new(armour.AstartesArmour[val1])
	var wpn1 : Weapon = Weapon.new(weapons.AstartesWeapons[val2])
	var wpn2 : Weapon = Weapon.new(weapons.AstartesWeapons[val3])
	var guy : Soldier = Soldier.new(soldiers.Soldiers["SpaceMarine"], arm, wpn1, wpn2)
	return guy

func spawnScout() -> Entity:
	var arm : Armour = Armour.new(armour.AstartesArmour["Scout"])
	var wpn1 : Weapon = Weapon.new(weapons.AstartesWeapons["Boltgun"])
	var wpn2 : Weapon = Weapon.new(weapons.AstartesWeapons["Bolt Pistol"])
	var guy : Soldier = Soldier.new(soldiers.Soldiers["SpaceMarine"], arm, wpn1, wpn2)
	return guy
