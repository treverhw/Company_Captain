extends Faction
class_name Guard

#StatLoads
const BASE_STATS = preload("res://Resources/Models/Guard/Guardsman.tres")
const SGT_STATS = preload("res://Resources/Models/Guard/Sergeant.tres")

#WeaponLoads
const LASGUN = preload("res://Resources/Equipment/Guard/Weapon/Lasgun.tres")
const DRUM_FED_AUTOGUN = preload("res://Resources/Equipment/Guard/Weapon/DrumFedAutogun.tres")
const LASPISTOL = preload("res://Resources/Equipment/Guard/Weapon/Laspistol.tres")
const BOLTPISTOL = preload("res://Resources/Equipment/Guard/Weapon/BoltPistol.tres")
const MELTAGUN = preload("res://Resources/Equipment/Guard/Weapon/Meltagun.tres")
const FLAMER = preload("res://Resources/Equipment/Guard/Weapon/Flamer.tres")
const PLASMA_GUN = preload("res://Resources/Equipment/Guard/Weapon/PlasmaGun.tres")
const GRENADE_LAUNCHER = preload("res://Resources/Equipment/Guard/Weapon/GrenadeLauncher.tres")

const CCW = preload("res://Resources/Equipment/Guard/Weapon/CCW.tres")
const CHAINSWORD = preload("res://Resources/Equipment/Guard/Weapon/Chainsword.tres")

#ArmourLoads
const FLAK = preload("res://Resources/Equipment/Guard/Armour/Flak.tres")

func _init() -> void:
	title = "Astra Militarum"
	team = "Imperium"
	id = 1

func start() -> Array[Unit]:
	return [spawnBase(), spawnBase()]

## Spawns a basic Guardsman, kitted with a lasgun and close combat weapon.
func spawnGuardsmen() -> Model:
	return generateSoldier(BASE_STATS, FLAK, LASGUN, CCW)
	
func spawnHeavyGuardsmen() -> Model:
	var heavyWeapons = [MELTAGUN, FLAMER, GRENADE_LAUNCHER, PLASMA_GUN]
	return generateSoldier(BASE_STATS, FLAK, heavyWeapons[randi_range(0,2)], CCW)
	
func spawnSergeant() -> Model:
	var loadout = randi_range(0, 2)
	match loadout:
		1:
			return generateSoldier(SGT_STATS, FLAK, BOLTPISTOL, CHAINSWORD)
		2:
			return generateSoldier(SGT_STATS, FLAK, DRUM_FED_AUTOGUN, CCW)
		_:
			return generateSoldier(SGT_STATS, FLAK, LASPISTOL, CHAINSWORD)

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
