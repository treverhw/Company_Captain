extends AstartesFaction
class_name Chaos

#StatLoads
const CULT_STATS = preload("res://Resources/Models/Chaos/Cultist.tres")
const DEMA_STATS = preload("res://Resources/Models/Chaos/CultDemagogue.tres")

#WeaponLoads
const AUTOPISTOL = preload("res://Resources/Equipment/Chaos/Weapon/Autopistol.tres")
const BOLTPISTOL = preload("res://Resources/Equipment/Chaos/Weapon/BoltPistol.tres")

const BCW = preload("res://Resources/Equipment/Chaos/Weapon/BCW.tres")
#ArmourLoads

const RAGS = preload("res://Resources/Equipment/Chaos/Armour/Rags.tres")

func _init() -> void:
	title = "Death Guard"
	team = "Chaos"
	id = 2

func start() -> Array[Unit]:
	return [spawnBase(), spawnBase(), spawnBase(), spawnBase()]

## Chaos scout squads get a "Squad: N" title instead of the plain numeric
## title AstartesFaction uses by default.
func _scoutSquadTitle() -> String:
	return "Cultist Squad: " + str(roster.size())

## Chaos scouts carry a close combat weapon instead of the bolt pistol
## AstartesFaction's default scout loadout uses.
func spawnCultist() -> Model:
	return generateSoldier(CULT_STATS, RAGS, AUTOPISTOL, BCW)

func spawnDemagogue() -> Model:
	var options = [BOLTPISTOL, AUTOPISTOL]
	return generateSoldier(DEMA_STATS, RAGS, options[randi_range(0, 1)], BCW)

func spawnCultistSquad() -> Squad:
	var models: Array[Model] = []
	models.append(spawnDemagogue())
	for i in 9:
		models.append(spawnCultist())
	var newSquad = generateSquad(models, "Cultist Squad", 20)
	return newSquad

## Chaos's default spawn is a cultist squad rather than AstartesFaction's
## default scout squad.
func spawnBase() -> Unit:
	return spawnCultistSquad()
