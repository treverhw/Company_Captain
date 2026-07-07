extends Faction
class_name Guard

func _init() -> void:
	title = "Astra Militarum"
	team = "Imperium"
	id = 1

func start() -> Array[Unit]:
	return [spawnBase(), spawnBase(), spawnBase(), spawnBase()]

## Builds a custom Guardsman from named loadout pieces.
func customGuard(armourKey: String, mainWeaponKey: String, offWeaponKey: String) -> Entity:
	var arm: Armour = Armour.new(armour.guardArmour[armourKey])
	var wpn1: Weapon = Weapon.new(weapons.guardWeapons[mainWeaponKey])
	var wpn2: Weapon = Weapon.new(weapons.guardWeapons[offWeaponKey])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.soldiers["Guardsman"], arm, wpn1, wpn2, self)
	return guy

## Spawns a basic Guardsman, kitted with a lasgun and close combat weapon.
func spawnModel() -> Entity:
	var arm: Armour = Armour.new(armour.guardArmour["Flak"])
	var wpn1: Weapon = Weapon.new(weapons.guardWeapons["Lasgun"])
	var wpn2: Weapon = Weapon.new(weapons.guardWeapons["Close Combat Weapon"])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.soldiers["Guardsman"], arm, wpn1, wpn2, self)
	return guy

## Spawns a 10-model Guard squad and adds it to this faction's roster.
func spawnSquad() -> Squad:
	var newSquad: Squad = load("res://Scenes/Entities/Squad.tscn").instantiate()
	newSquad.define(str(roster.size()), 10, self)
	var models: Array[Entity] = []
	for i in 10:
		models.append(spawnModel())
	newSquad.roster = models
	roster.append(newSquad)
	newSquad.assignModels()
	add_child(newSquad)
	return newSquad

func spawnBase() -> Unit:
	return spawnSquad()
