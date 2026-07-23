extends Control
#const weapons = preload("res://Scripts/Equipment/WeaponArrays.gd")
#const armour = preload("res://Scripts/Equipment/ArmourArrays.gd")
var playerFaction
var guard
var chaos
var squad : Squad
var turn: int = 0
var temp
var sector: Sector
var testing: bool = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Escape"):
		get_tree().quit()

func _ready() -> void:
	var counter = 0
	for node in get_node("GridContainer").get_children():
		counter+=1
		if counter % 3 == 0:
			node.flip_v = true
		if counter % 4 == 0:
			node.flip_h = true
	
	temp = load("res://Scenes/Menus/MainMenu.tscn").instantiate()
	temp.get_node("VBoxContainer/Play").pressed.connect(play)
	add_child(temp)
	playerFaction = get_node("Factions/PlayerFaction")
	guard = get_node("Factions/Guard")
	chaos = get_node("Factions/Chaos")

func play():
	sector = load("res://Scenes/Locational/Sector.tscn").instantiate()
	add_child(sector)
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
	combat.populate(playerFaction.start(), chaos.start())

func _on_turn_pressed() -> void:
	turn += 1
	get_node("TopBar/TurnCounter").text = "Turns: " + str(turn)
	get_node("BottomBar/Turn").disabled = true
	await get_tree().create_timer(.1).timeout
	get_node("BottomBar/Turn").disabled = false

func getPlayer() -> Faction:
	return playerFaction

func resetFactions() -> bool:
	for child in guard.get_children():
		guard.remove_child(child)
		guard.getRoster().clear()
		guard.ships.clear()
	for child in chaos.get_children():
		chaos.remove_child(child)
		chaos.getRoster().clear()
		chaos.ships.clear()
	for child in playerFaction.get_children():
		playerFaction.remove_child(child)
		playerFaction.getRoster().clear()
		playerFaction.ships.clear()
	return true

#Default is Player Faction
func getFaction(faction: String) -> Faction:
	match faction:
		"guard":
			return get_node("Factions/Guard")
		"chaos":
			return get_node("Factions/Chaos")
		"tyranids":
			return get_node("Factions/Tyranids")
		"orkz":
			return get_node("Factions/Orkz")
		_:
			return get_node("Factions/PlayerFaction")

func _on_planet_test_pressed() -> void:
	testing = !testing
	#var counter = 1
	while(testing):
		await get_tree().create_timer(.5).timeout
		_on_turn_pressed()
		var system = sector.getSystems().front()
		sector.turn()
		if system.getCompliance():
			#counter += 1
			resetFactions()
			remove_child(system)
			system.queue_free()
			system = load("res://Scenes/Locational/System.tscn").instantiate()
			add_child(system)
	print("It works!")

func _on_new_system_pressed() -> void:
	resetFactions()
	remove_child(sector.getSystems().front())
	sector.getSystems().front().queue_free()
	sector.getSystems().append(load("res://Scenes/Locational/System.tscn").instantiate())
	add_child(sector.getSystems().front())
