extends Faction
class_name Chaos

func _init():
	title = "Death Guard"
	team = "Chaos"

func start():
	spawnScoutSquad()
	spawnScoutSquad()

func customAstartes(val1 : String, val2 : String, val3 : String) -> Entity:
	var arm : Armour = Armour.new(armour.AstartesArmour[val1])
	var wpn1 : Weapon = Weapon.new(weapons.AstartesWeapons[val2])
	var wpn2 : Weapon = Weapon.new(weapons.AstartesWeapons[val3])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.Soldiers["SpaceMarine"], arm, wpn1, wpn2)
	return guy

func spawnScout() -> Entity:
	var arm : Armour = Armour.new(armour.AstartesArmour["Scout"])
	var wpn1 : Weapon = Weapon.new(weapons.AstartesWeapons["Boltgun"])
	var wpn2 : Weapon = Weapon.new(weapons.AstartesWeapons["Bolt Pistol"])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.Soldiers["SpaceMarine"], arm, wpn1, wpn2)
	return guy

func spawnScoutSquad() -> Squad:
	var newSquad : Squad = load("res://Scenes/Entities/Squad.tscn").instantiate()
	newSquad.define("Squad: " + str(roster.size()), 5, self)
	newSquad.roster = [spawnScout(), spawnScout(), spawnScout(), spawnScout(), spawnScout()]
	roster.append(newSquad)
	return newSquad
