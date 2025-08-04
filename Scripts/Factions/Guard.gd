extends Faction
class_name Guard

func _init():
	title = "Astra Militarum"
	team = "Imperium"
	id = 1

func start() -> Array[Unit]:
	var arr: Array[Unit] = [spawnBase(),spawnBase(),spawnBase(),spawnBase()]
	return arr

func customGuard(val1 : String, val2 : String, val3 : String) -> Entity:
	var arm : Armour = Armour.new(armour.guardArmour[val1])
	var wpn1 : Weapon = Weapon.new(weapons.guardWeapons[val2])
	var wpn2 : Weapon = Weapon.new(weapons.guardWeapons[val3])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.soldiers["Guardsman"], arm, wpn1, wpn2, self)
	return guy

func spawnModel() -> Entity:
	var arm : Armour = Armour.new(armour.guardArmour["Flak"])
	var wpn1 : Weapon = Weapon.new(weapons.guardWeapons["Lasgun"])
	var wpn2 : Weapon = Weapon.new(weapons.guardWeapons["Close Combat Weapon"])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.soldiers["Guardsman"], arm, wpn1, wpn2, self)
	return guy

func spawnSquad() -> Squad:
	var newSquad : Squad = load("res://Scenes/Entities/Squad.tscn").instantiate()
	newSquad.define(str(roster.size()), 5, self)
	newSquad.roster = [spawnModel(),spawnModel(),spawnModel(),spawnModel(),spawnModel()]
	roster.append(newSquad)
	newSquad.assignModels()
	add_child(newSquad)
	return newSquad

func spawnBase() -> Unit:
	return spawnSquad()
