extends Faction
class_name Orkz

func _init() -> void:
	title = "Orkz"
	team = "Orkz"
	id = 2

func start() -> Array[Unit]:
	return [spawnBase()]

## Spawns a basic Orkzsman, kitted with a lasgun and close combat weapon.
func spawnBoy() -> Model:
	var loadout = loadouts["Base"]
	return generateSoldier(load(loadout[0]), load(loadout[1]), load(loadout[2]), load(loadout[3]))
	
func spawnHeavyBoy() -> Model:
	var loadout = loadouts["Heavy"]
	return generateSoldier(load(loadout[0]), load(loadout[1]), load(loadout[2]), load(loadout[3]))
	
func spawnBossNob() -> Model:
	var loadout = loadouts["Sergeant"]
	return generateSoldier(load(loadout[0]), load(loadout[1]), load(loadout[2]), load(loadout[3]))

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

var loadouts: Dictionary = {
	#stats, arm, wpn1, wpn2
	"Base" = [
		"res://Resources/Models/Orkz/Boy.tres",
		"res://Resources/Equipment/Orkz/Armour/OrkMuscle.tres",
		"res://Resources/Equipment/Orkz/Weapon/Slugga.tres",
		"res://Resources/Equipment/Orkz/Weapon/Choppa.tres"
	],
	"Heavy" = [
		"res://Resources/Models/Orkz/Boy.tres",
		"res://Resources/Equipment/Orkz/Armour/OrkMuscle.tres",
		"res://Resources/Equipment/Orkz/Weapon/BigShoota.tres",
		"res://Resources/Equipment/Orkz/Weapon/CCW.tres"
	],
	"Boss Nob" = [
		"res://Resources/Models/Orkz/BossKnob.tres",
		"res://Resources/Equipment/Orkz/Armour/OrkMuscle.tres",
		"res://Resources/Equipment/Orkz/Weapon/Slugga.tres",
		"res://Resources/Equipment/Orkz/Weapon/PowerKlaw.tres"
	]
}
