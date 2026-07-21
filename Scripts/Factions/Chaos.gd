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
	return "Cultist Squad: " + str(roster.size())

## Chaos scouts carry a close combat weapon instead of the bolt pistol
## AstartesFaction's default scout loadout uses.
func spawnCultist() -> Model:
	var loadout = loadouts["Base"]
	return generateSoldier(load(loadout[0]), load(loadout[1]), load(loadout[2]), load(loadout[3]))

func spawnDemagogue() -> Model:
	var loadout = loadouts["Demagogue"]
	return generateSoldier(load(loadout[0]), load(loadout[1]), load(loadout[2]), load(loadout[3]))

func spawnCultistSquad() -> Squad:
	var newSquad: Squad = load("res://Scenes/Models/Squad.tscn").instantiate()
	var models: Array[Model] = []
	models.append(spawnDemagogue())
	for i in 9:
		models.append(spawnCultist())
	newSquad = generateSquad(models, "Cultist Squad", 20)
	return newSquad

## Chaos's default spawn is a cultist squad rather than AstartesFaction's
## default scout squad.
func spawnBase() -> Unit:
	return spawnCultistSquad()

func _ready():
	
	loadouts = {
		"Base" = [
			"res://Resources/Models/Chaos/Cultist.tres",
			"res://Resources/Equipment/Chaos/Armour/Rags.tres",
			"res://Resources/Equipment/Chaos/Weapon/Autopistol.tres",
			"res://Resources/Equipment/Chaos/Weapon/BCW.tres"
		],
		"Demagogue" = [
			"res://Resources/Models/Chaos/CultDemagogue.tres",
			"res://Resources/Equipment/Chaos/Armour/Rags.tres",
			"res://Resources/Equipment/Chaos/Weapon/BoltPistol.tres",
			"res://Resources/Equipment/Chaos/Weapon/BCW.tres"
		],
		"Scout" = [
			"res://Resources/Models/Artartes/Scout.tres",
			"res://Resources/Equipment/Astartes/Armour/Scout.tres",
			"res://Resources/Equipment/Astartes/Weapon/Boltgun.tres",
			"res://Resources/Equipment/Astartes/Weapon/ScoutCCW.tres"
		],
	}
