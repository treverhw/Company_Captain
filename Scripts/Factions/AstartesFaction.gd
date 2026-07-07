extends Faction
class_name AstartesFaction
## Shared base for factions that field Space Marine-pattern Astartes troops
## (loadout data comes from ArmourArrays.astartesArmour / WeaponArrays.astartesWeapons).
## Chaos and PlayerFaction both extend this to avoid duplicating spawn logic.

## Builds a custom Astartes soldier from named loadout pieces.
func customAstartes(armourKey: String, mainWeaponKey: String, offWeaponKey: String) -> Entity:
	var arm: Armour = Armour.new(armour.astartesArmour[armourKey])
	var wpn1: Weapon = Weapon.new(weapons.astartesWeapons[mainWeaponKey])
	var wpn2: Weapon = Weapon.new(weapons.astartesWeapons[offWeaponKey])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.soldiers["SpaceMarine"], arm, wpn1, wpn2, self)
	return guy

## Spawns a basic Astartes scout, kitted with a boltgun and bolt pistol.
func spawnScout() -> Entity:
	var arm: Armour = Armour.new(armour.astartesArmour["Scout"])
	var wpn1: Weapon = Weapon.new(weapons.astartesWeapons["Boltgun"])
	var wpn2: Weapon = Weapon.new(weapons.astartesWeapons["Bolt Pistol"])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.soldiers["SpaceMarine"], arm, wpn1, wpn2, self)
	return guy

## Spawns a 5-model scout squad and adds it to this faction's roster.
## Subclasses can override `_scoutSquadTitle()` to customize naming.
func spawnScoutSquad() -> Squad:
	var newSquad: Squad = load("res://Scenes/Entities/Squad.tscn").instantiate()
	newSquad.define(_scoutSquadTitle(), 5, self)
	var models: Array[Entity] = []
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
