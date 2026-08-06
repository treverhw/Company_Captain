extends Node
class_name Faction

var title: String
var team: String
var roster: Array[Unit] = []
var ships: Array[Ship] = []
var id: int

const SOLDIER = preload("res://Scenes/Models/Soldier.tscn")
const SQUAD = preload("res://Scenes/Models/Squad.tscn")
const SHIP = preload("res://Scenes/Models/Ships/SpaceShip.tscn")

#region Ships

#add ship classes later
func spawnShip(shipClass: String, system: Location):
	var ship = SHIP.instantiate()
	add_child(ship)
	ships.append(ship)
	ship.setLocation(system)
	ship.setFaction(self)
	match shipClass:
		"Bigun":
			pass
		_:
			"Error: not a real shipclass"

func removeShip(ship: Ship):
	for unit in ship.getRoster():
		removeUnit(unit)
	ships.erase(ship)
	ship.location.ships.erase(ship)
	remove_child(ship)
	ship.queue_free()

#Move a ship from one faction to another. Deletes the current roster! Optional roster setting.
func transferShip(ship: Ship, faction: Faction, tempRoster: Array[Unit] = []):
	for unit in ship.getRoster():
		removeUnit(unit)
	ships.erase(ship)
	ship.reparent(faction)
	faction.ships.append(ship)
	ship.roster = tempRoster

#endregion

#region Units & Models

func generateSoldier(stats: ModelStats, arm: ArmourStats, wpn1: WeaponStats, wpn2: WeaponStats) -> Model:
	var model: Soldier = SOLDIER.instantiate()
	var slot1: Armour = Armour.new()
	slot1.define(arm)
	var slot2: Weapon = Weapon.new()
	slot2.define(wpn1)
	var slot3: Weapon = Weapon.new()
	slot3.define(wpn2)
	add_to_group(title + "_models")
	model.define(stats, slot1, slot2, slot3, self)
	#print(str(model) + " " + str(slot1) + " " + str(slot2) + " " + str(slot3))
	return model

func refitSoldier(model: Soldier, arm: ArmourStats, wpn1: WeaponStats, wpn2: WeaponStats) -> Model:
	var slot1: Armour = Armour.new()
	slot1.define(arm)
	var slot2: Weapon = Weapon.new()
	slot2.define(wpn1)
	var slot3: Weapon = Weapon.new()
	slot3.define(wpn2)
	add_to_group(title + "_models")
	model.define(model.stats, slot1, slot2, slot3, self)
	#print(str(model) + " " + str(slot1) + " " + str(slot2) + " " + str(slot3))
	return model

func generateSquad(models: Array[Model], STitle: String, size: int) -> Squad:
	var newSquad: Squad = SQUAD.instantiate()
	newSquad.define(STitle, size, self, models)
	roster.append(newSquad)
	newSquad.assignModels()
	newSquad.setTex()
	add_child(newSquad)
	return newSquad

## Spawns a starting unit at the given location. All factions currently spawn
## the same base unit regardless of location; override in a subclass if a
## faction should vary its spawn based on where it's spawning.
func spawnLocational(_location: Location) -> Unit:
	return spawnBase()

## Returns this faction's default starting unit. Overridden by subclasses.
func spawnBase() -> Unit:
	return null

## Removes an Model from play: pulls it out of its unit, and if that empties
## the unit, pulls the unit out of its location and this faction's roster too.
func removeModel(model: Model) -> void:
	var unit: Unit = model.getUnit()
	unit.getRoster().erase(model)
	if unit.getRoster().size() <= 0:
		if is_instance_valid(unit.getLocation()):
			unit.getLocation().getRoster().erase(unit)
		roster.erase(unit)
		unit.queue_free()
	model.queue_free()

func removeUnit(unit: Unit):
	for model in unit.getRoster():
		removeModel(model)

#endregion

#region Setters & Getters

func setTitle(t: String) -> void:
	title = t
func setRoster(arr: Array[Unit]) -> void:
	roster = arr.duplicate()

func getTitle() -> String:
	return title
func getTeam() -> String:
	return team
func getRoster() -> Array[Unit]:
	ModelUtils.pruneInvalid(roster)
	return roster

#endregion

func _to_string() -> String:
	var ret: String = getTitle()
	for item in roster:
		ret += "\n" + str(item)
	return ret
