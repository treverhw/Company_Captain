extends Faction
class_name AstartesFaction

#StatLoads
const BASE_STATS = preload("res://Resources/Models/Astartes/Scout.tres")

#WeaponLoads
const BOLT_RIFLE = preload("res://Resources/Equipment/Astartes/Weapon/BoltRifle.tres")
const BOLTGUN = preload("res://Resources/Equipment/Astartes/Weapon/Boltgun.tres")
const BOLT_PISTOL = preload("res://Resources/Equipment/Astartes/Weapon/BoltPistol.tres")

const CCW = preload("res://Resources/Equipment/Astartes/Weapon/CCW.tres")
const SCOUT_CCW = preload("res://Resources/Equipment/Astartes/Weapon/ScoutCCW.tres")

#ArmourLoads
const SCOUT = preload("res://Resources/Equipment/Astartes/Armour/Scout.tres")


func spawnScout() -> Model:
	return generateSoldier(BASE_STATS, SCOUT, BOLT_RIFLE, SCOUT_CCW)

## Spawns a 5-model scout squad and adds it to this faction's roster.
## Subclasses can override `_scoutSquadTitle()` to customize naming.
func spawnScoutSquad() -> Squad:
	var models: Array[Model] = []
	for i in 5:
		models.append(spawnScout())
	var newSquad = generateSquad(models, _scoutSquadTitle(), 5)
	return newSquad

func spawnBase() -> Unit:
	return spawnScoutSquad()

## Default scout-squad title. Override in a subclass for a different format.
func _scoutSquadTitle() -> String:
	return str(roster.size())
