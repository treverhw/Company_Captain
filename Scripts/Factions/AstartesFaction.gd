extends Faction
class_name AstartesFaction
## Shared base for factions that field Space Marine-pattern Astartes troops
## (loadout data comes from ArmourArrays.astartesArmour / WeaponArrays.astartesWeapons).
## Chaos and PlayerFaction both extend this to avoid duplicating spawn logic.

## Spawns a basic Astartes scout, kitted with a boltgun and bolt pistol.
func spawnScout() -> Model:
	var loadout = loadouts["Scout"]
	return generateSoldier(load(loadout[0]), load(loadout[1]), load(loadout[2]), load(loadout[3]))

## Spawns a 5-model scout squad and adds it to this faction's roster.
## Subclasses can override `_scoutSquadTitle()` to customize naming.
func spawnScoutSquad() -> Squad:
	var newSquad: Squad = load("res://Scenes/Entities/Squad.tscn").instantiate()
	newSquad.define(_scoutSquadTitle(), 5, self)
	var models: Array[Model] = []
	for i in 5:
		models.append(spawnScout())
	newSquad.roster = models
	roster.append(newSquad)
	newSquad.assignModels()
	add_child(newSquad)
	return newSquad

func spawnBase() -> Unit:
	return spawnScoutSquad()

## Default scout-squad title. Override in a subclass for a different format.
func _scoutSquadTitle() -> String:
	return str(roster.size())


var loadouts: Dictionary = {
	"Scout" = [
		"res://Resources/Models/Artartes/Scout.tres",
		"res://Resources/Equipment/Astartes/Armour/Scout.tres",
		"res://Resources/Equipment/Astartes/Weapon/Boltgun.tres",
		"res://Resources/Equipment/Astartes/Weapon/ScoutCCW.tres"
	],
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
}
