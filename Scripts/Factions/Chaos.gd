extends Faction
class_name Chaos

func _init():
	title = "Death Guard"
	team = "Chaos"
	id = 2
func start() -> Array[Unit]:
	var arr: Array[Unit] = [spawnBase(), spawnBase()]
	return arr

func customAstartes(val1 : String, val2 : String, val3 : String) -> Entity:
	var arm : Armour = Armour.new(armour.astartesArmour[val1])
	var wpn1 : Weapon = Weapon.new(weapons.astartesWeapons[val2])
	var wpn2 : Weapon = Weapon.new(weapons.astartesWeapons[val3])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.soldiers["SpaceMarine"], arm, wpn1, wpn2, self)
	return guy

func spawnScout() -> Entity:
	var arm : Armour = Armour.new(armour.astartesArmour["Scout"])
	var wpn1 : Weapon = Weapon.new(weapons.astartesWeapons["Boltgun"])
	var wpn2 : Weapon = Weapon.new(weapons.astartesWeapons["Bolt Pistol"])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.soldiers["SpaceMarine"], arm, wpn1, wpn2, self)
	return guy

func spawnScoutSquad() -> Squad:
	var newSquad : Squad = load("res://Scenes/Entities/Squad.tscn").instantiate()
	newSquad.define("Squad: " + str(roster.size()), 5, self)
	newSquad.roster = [spawnScout(), spawnScout(), spawnScout(), spawnScout(), spawnScout()]
	roster.append(newSquad)
	newSquad.assignModels()
	return newSquad

func spawnHurtSquad() -> Squad:
	var newSquad : Squad = load("res://Scenes/Entities/Squad.tscn").instantiate()
	newSquad.define("Squad: " + str(roster.size()), 5, self)
	newSquad.roster = [spawnScout(), spawnScout(), spawnScout()]
	roster.append(newSquad)
	newSquad.assignModels()
	return newSquad

func spawnBase() -> Unit:
	return spawnScoutSquad()
