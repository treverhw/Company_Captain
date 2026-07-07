extends AstartesFaction
class_name Chaos

func _init() -> void:
	title = "Death Guard"
	team = "Chaos"
	id = 2

func start() -> Array[Unit]:
	return [spawnBase()]

## Chaos scout squads get a "Squad: N" title instead of the plain numeric
## title AstartesFaction uses by default.
func _scoutSquadTitle() -> String:
	return "Squad: " + str(roster.size())

## Chaos scouts carry a close combat weapon instead of the bolt pistol
## AstartesFaction's default scout loadout uses.
func spawnScout() -> Entity:
	var arm: Armour = Armour.new(armour.astartesArmour["Scout"])
	var wpn1: Weapon = Weapon.new(weapons.astartesWeapons["Boltgun"])
	var wpn2: Weapon = Weapon.new(weapons.astartesWeapons["Close Combat Weapon"])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.soldiers["SpaceMarine"], arm, wpn1, wpn2, self)
	return guy

func spawnCultist() -> Entity:
	var arm: Armour = Armour.new(armour.chaosArmour["Rags"])
	var wpn1: Weapon = Weapon.new(weapons.chaosWeapons["Autopistol"])
	var wpn2: Weapon = Weapon.new(weapons.chaosWeapons["Brutal Assault Weapon"])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.soldiers["Cultist"], arm, wpn1, wpn2, self)
	return guy

func spawnCultistSquad() -> Squad:
	var newSquad: Squad = load("res://Scenes/Entities/Squad.tscn").instantiate()
	newSquad.define("Squad: " + str(roster.size()), 5, self)
	for x in range(0, 20):
		newSquad.roster.append(spawnCultist())
	roster.append(newSquad)
	newSquad.assignModels()
	add_child(newSquad)
	return newSquad

## Chaos's default spawn is a cultist squad rather than AstartesFaction's
## default scout squad.
func spawnBase() -> Unit:
	return spawnCultistSquad()
