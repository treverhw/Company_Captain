extends Control
const weapons = preload("res://Scripts/Equipment/WeaponArrays.gd")
const armour = preload("res://Scripts/Equipment/ArmourArrays.gd")
const soldiers = preload("res://Scripts/Entities/Foot/SoldierArrays.gd")
var playerFaction = PlayerFaction.new("Salamanders")
var squad : Squad
var temp

func _ready() -> void:
	temp = load("res://Scenes/MainMenu.tscn").instantiate()
	temp.get_node("VBoxContainer/Play").pressed.connect(play)
	add_child(temp)

func play():
	playerFaction.start()
	temp = get_child(1)
	print(temp)
	temp.settlements[1].roster.append(playerFaction.roster[0])
	temp.settlements[2].roster.append(playerFaction.roster[1])
	print("\nLocation 1 Roster: \n" + str(temp.settlements[1].roster[0]))
	print("Location 2 Roster: \n" + str(temp.settlements[2].roster[0]))
