extends Faction
class_name Guard

func _init():
	title = "Astra Militarum"
	team = "Imperium"

func start():
	spawnSquad()
	spawnSquad()

func customGuard(val1 : String, val2 : String, val3 : String) -> Entity:
	var arm : Armour = Armour.new(armour.GuardArmour[val1])
	var wpn1 : Weapon = Weapon.new(weapons.GuardWeapons[val2])
	var wpn2 : Weapon = Weapon.new(weapons.GuardWeapons[val3])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.Soldiers["Guardsman"], arm, wpn1, wpn2)
	return guy

func spawnBase() -> Entity:
	var arm : Armour = Armour.new(armour.GuardArmour["FlakShit"])
	var wpn1 : Weapon = Weapon.new(weapons.GuardWeapons["Lasgun"])
	var wpn2 : Weapon = Weapon.new(weapons.GuardWeapons["Close Combat Weapon"])
	var guy = load("res://Scenes/Entities/Soldier.tscn").instantiate()
	guy.define(soldiers.Soldiers["Guardsman"], arm, wpn1, wpn2)
	return guy

func spawnSquad() -> Squad:
	var newSquad : Squad = load("res://Scenes/Entities/Squad.tscn").instantiate()
	newSquad.define(str(roster.size()), 5, self)
	newSquad.roster = [spawnBase(), spawnBase(), spawnBase(), spawnBase(), spawnBase()]
	roster.append(newSquad)
	return newSquad
