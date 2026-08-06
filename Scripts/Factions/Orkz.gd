extends Faction
class_name Orkz

#StatLoads
const BASE_STATS = preload("res://Resources/Models/Orkz/Boy.tres")
const NOB_STATS = preload("res://Resources/Models/Orkz/BossNob.tres")

#WeaponLoads
const SLUGGA = preload("res://Resources/Equipment/Orkz/Weapon/Slugga.tres")
const BIGSHOOTA = preload("res://Resources/Equipment/Orkz/Weapon/BigShoota.tres")

const CHOPPA = preload("res://Resources/Equipment/Orkz/Weapon/Choppa.tres")
const CCW = preload("res://Resources/Equipment/Orkz/Weapon/CCW.tres")
const POWERKLAW = preload("res://Resources/Equipment/Orkz/Weapon/PowerKlaw.tres")

#ArmourLoads
const ORK_MUSCLE = preload(
		"res://Resources/Equipment/Orkz/Armour/OrkMuscle.tres",)

func _init() -> void:
	title = "Orkz"
	team = "Orkz"
	id = 3

func start() -> Array[Unit]:
	return [spawnBase(), spawnBase()]

## Spawns a basic Orkzsman, kitted with a lasgun and close combat weapon.
func spawnBoy() -> Model:
	return generateSoldier(BASE_STATS, ORK_MUSCLE, SLUGGA, CHOPPA)
	
func spawnHeavyBoy() -> Model:
	return generateSoldier(BASE_STATS, ORK_MUSCLE, BIGSHOOTA, CCW)
	
func spawnBossNob() -> Model:
	return generateSoldier(NOB_STATS, ORK_MUSCLE, SLUGGA, POWERKLAW)

func assignBossNob() -> Model:
	return Model.new()

## Spawns a 10-model Orkz squad and adds it to this faction's roster.
func spawnBoyzSquad() -> Squad:
	var models: Array[Model] = []
	models.append(spawnBossNob())
	models.append(spawnHeavyBoy())
	for i in 8:
		models.append(spawnBoy())
	var newSquad = generateSquad(models, "Boyz", 20)
	return newSquad

func spawnBase() -> Unit:
	return spawnBoyzSquad()
