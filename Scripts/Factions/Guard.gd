extends Faction
class_name Guard

func _init() -> void:
	title = "Astra Militarum"
	team = "Imperium"
	id = 1

func start() -> Array[Unit]:
	return [spawnBase(), spawnBase(), spawnBase(), spawnBase()]

## Spawns a basic Guardsman, kitted with a lasgun and close combat weapon.
func spawnGuardsmen() -> Model:
	var loadout = loadouts["Base"]
	return generateSoldier(load(loadout[0]), load(loadout[1]), load(loadout[2]), load(loadout[3]))
	
func spawnHeavyGuardsmen() -> Model:
	var loadout = loadouts["Heavy"]
	return generateSoldier(load(loadout[0]), load(loadout[1]), load(loadout[2]), load(loadout[3]))
	
func spawnSergeant() -> Model:
	var loadout = loadouts["Sergeant"]
	return generateSoldier(load(loadout[0]), load(loadout[1]), load(loadout[2]), load(loadout[3]))

func assignSergeant() -> Model:
	return Model.new()

## Spawns a 10-model Guard squad and adds it to this faction's roster.
func spawnGuardsmanSquad() -> Squad:
	var models: Array[Model] = []
	models.append(spawnSergeant())
	for i in 2:
		models.append(spawnHeavyGuardsmen())
	for i in 7:
		models.append(spawnGuardsmen())
	var newSquad = generateSquad(models, "Guardsmen", 20)
	return newSquad

func spawnBase() -> Unit:
	return spawnGuardsmanSquad()

var loadouts: Dictionary = {
	#stats, arm, wpn1, wpn2
	"Base" = [
		"res://Resources/Models/Guard/Guardsman.tres",
		"res://Resources/Equipment/Guard/Armour/Flak.tres",
		"res://Resources/Equipment/Guard/Weapon/Lasgun.tres",
		"res://Resources/Equipment/Guard/Weapon/CCW.tres"
	],
	"Heavy" = [
		"res://Resources/Models/Guard/Guardsman.tres",
		"res://Resources/Equipment/Guard/Armour/Flak.tres",
		"res://Resources/Equipment/Guard/Weapon/Meltagun.tres",
		"res://Resources/Equipment/Guard/Weapon/CCW.tres"
	],
	"Sergeant" = [
		"res://Resources/Models/Guard/Sergeant.tres",
		"res://Resources/Equipment/Guard/Armour/Flak.tres",
		"res://Resources/Equipment/Guard/Weapon/Laspistol.tres",
		"res://Resources/Equipment/Guard/Weapon/Chainsword.tres"
	]
}
