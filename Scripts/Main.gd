extends Control
const weapons = preload("res://Scripts/Equipment/WeaponArrays.gd")
const armour = preload("res://Scripts/Equipment/ArmourArrays.gd")
const soldiers = preload("res://Scripts/Entities/Foot/SoldierArrays.gd")
var playerFaction
var guard
var chaos
var squad : Squad
var turn: int = 0
var temp

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Escape"):
		get_tree().quit()

func _ready() -> void:
	temp = load("res://Scenes/Menus/MainMenu.tscn").instantiate()
	temp.get_node("VBoxContainer/Play").pressed.connect(play)
	add_child(temp)
	playerFaction = get_node("Factions/PlayerFaction")
	guard = get_node("Factions/Guard")
	chaos = get_node("Factions/Chaos")

func play():
	temp = load("res://Scenes/Locational/Planet.tscn").instantiate()
	add_child(temp)
	get_node("BottomBarBack").visible = true
	get_node("BottomBar").visible = true
	guard.start()
	chaos.start()
	#temp.settlements[1].roster.append(guard.roster[0])
	#temp.settlements[1].roster.append(guard.roster[1])
	#temp.settlements[1].roster.append(guard.roster[2])
	#temp.settlements[1].roster.append(guard.roster[3])
	#temp.settlements[5].roster.append(chaos.roster[0])
	#temp.settlements[1].team = "Imperium"
	#temp.settlements[1].update()
	#temp.settlements[5].team = "Chaos"
	#temp.settlements[5].update()
	#print("\nLocation 1 Roster: \n" + str(temp.settlements[1].roster))
	#print("Location 2 Roster: \n" + str(temp.settlements[5].roster))


func _on_button_pressed() -> void:
	var combat = load("res://Scenes/Menus/Combat.tscn").instantiate()
	add_child(combat)
	combat.populate(guard.start(), chaos.start())

func _on_turn_pressed() -> void:
	turn += 1
	get_node("TopBar/TurnCounter").text = "Turns: " + str(turn)
	get_node("BottomBar/Turn").disabled = true
	await get_tree().create_timer(.2).timeout
	get_node("BottomBar/Turn").disabled = false

func getPlayer() -> Faction:
	return playerFaction

func _on_planet_test_pressed() -> void:
	remove_child(temp)
	temp.queue_free()
	temp = load("res://Scenes/Locational/Planet.tscn").instantiate()
	add_child(temp)
