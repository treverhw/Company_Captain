extends Control
const weapons = preload("res://Scripts/Equipment/WeaponArrays.gd")
const armour = preload("res://Scripts/Equipment/ArmourArrays.gd")
const soldiers = preload("res://Scripts/Entities/Foot/SoldierArrays.gd")
var playerFaction = load("res://Scenes/PlayerFaction.tscn").instantiate()
var guard = load("res://Scenes/Guard.tscn").instantiate()
var chaos = load("res://Scenes/Chaos.tscn").instantiate()
var squad : Squad
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
	guard.start()
	chaos.start()
	var combat = load("res://Scenes/Menus/Combat.tscn").instantiate()
	add_child(combat)
	combat.global_position = Vector2((1920/2)-(1170/2), (1080/2)-(780/2))
	combat.populate(guard.roster, chaos.roster, true)
	#temp = get_child(4)
	#print(temp)
	#temp.settlements[1].roster.append(guard.roster[0])
	#temp.settlements[1].roster.append(guard.roster[1])
	#temp.settlements[4].roster.append(chaos.roster[0])
	#temp.settlements[4].roster.append(chaos.roster[1])
	#temp.settlements[1].team = "Imperium"
	#temp.settlements[4].team = "Chaos"
	#print("\nLocation 1 Roster: \n" + str(temp.settlements[1].roster))
	#print("Location 2 Roster: \n" + str(temp.settlements[4].roster))
