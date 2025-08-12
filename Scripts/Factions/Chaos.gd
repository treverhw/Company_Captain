extends Faction
class_name Chaos

func _init():
	title = "Death Guard"
	team = "Chaos"
	id = 2
func start() -> Array[Unit]:
	var arr: Array[Unit] = [spawnBase(), spawnBase(), spawnBase(), spawnBase()]
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
	var wpn2 : Weapon = Weapon.new(weapons.astartesWeapons["Close Combat Weapon"])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.soldiers["SpaceMarine"], arm, wpn1, wpn2, self)
	return guy

func spawnCultist() -> Entity:
	var arm : Armour = Armour.new(armour.chaosArmour["Rags"])
	var wpn1 : Weapon = Weapon.new(weapons.chaosWeapons["Autopistol"])
	var wpn2 : Weapon = Weapon.new(weapons.chaosWeapons["Brutal Assault Weapon"])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.soldiers["Cultist"], arm, wpn1, wpn2, self)
	return guy

func spawnScoutSquad() -> Squad:
	var newSquad : Squad = load("res://Scenes/Entities/Squad.tscn").instantiate()
	newSquad.define("Squad: " + str(roster.size()), 5, self)
	newSquad.roster = [spawnScout(), spawnScout(), spawnScout(), spawnScout(), spawnScout()]
	roster.append(newSquad)
	newSquad.assignModels()
	add_child(newSquad)
	return newSquad

func spawnCultistSquad() -> Squad:
	var newSquad : Squad = load("res://Scenes/Entities/Squad.tscn").instantiate()
	newSquad.define("Squad: " + str(roster.size()), 5, self)
	for x in range(0,20):
		newSquad.roster.append(spawnCultist())
	roster.append(newSquad)
	newSquad.assignModels()
	add_child(newSquad)
	return newSquad

func spawnBase() -> Unit:
	return spawnCultistSquad()
