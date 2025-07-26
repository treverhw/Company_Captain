extends Control
const weapons = preload("res://Scripts/Equipment/WeaponArrays.gd")
const armour = preload("res://Scripts/Equipment/ArmourArrays.gd")
const soldiers = preload("res://Scripts/Entities/Foot/SoldierArrays.gd")
var playerFaction = load("res://Scenes/Factions/PlayerFaction.tscn").instantiate()
var guard = load("res://Scenes/Factions/Guard.tscn").instantiate()
var chaos = load("res://Scenes/Factions/Chaos.tscn").instantiate()
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
	add_child(playerFaction)
	add_child(guard)
	add_child(chaos)

func play():
	get_node("BottomBarBack").visible = true
	guard.start()
	chaos.start()
	temp = get_child(8)
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
	guard.roster.clear()
	guard.start()
	chaos.roster.clear()
	chaos.start()
	var combat = load("res://Scenes/Menus/Combat.tscn").instantiate()
	add_child(combat)
	combat.populate(guard.start(), chaos.start())

func _on_turn_pressed() -> void:
	turn += 1
	get_node("TopBar/TurnCounter").text = "Turns: " + str(turn)
