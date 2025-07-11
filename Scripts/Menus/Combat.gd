extends Control

var friendlyStart: int = 0
var friendlyRoster: Array[Unit] = []
var friendlies: Array[Entity] = []

var enemyStart: int = 0
var enemyRoster: Array[Unit] = []
var enemies: Array[Entity] = []

var fullRoster: Array[Entity] = []

func rolld6() -> int:
	return randi_range(1,6)

func populate(group1: Array[Unit], group2: Array[Unit], Attacking: bool):
	print("Friendly Roster: \n" + str(friendlyRoster))
	print("Enemy Roster: \n" + str(enemyRoster))
	
	friendlyRoster = group1
	enemyRoster = group2
	
	for unit in friendlyRoster:
		for model in unit.roster:
			friendlies.append(model)
			fullRoster.append(model)
	for unit in enemyRoster:
		for model in unit.roster:
			enemies.append(model)
			fullRoster.append(model)
	
	friendlyStart = friendlies.size()
	enemyStart = enemies.size()
	
	
	if Attacking == true:
		for unit in friendlyRoster:
			get_node("ColumnContainer/1").add_child(unit)
		for unit in enemyRoster:
			get_node("ColumnContainer/14").add_child(unit)
	else: 
		for unit in friendlyRoster:
			get_node("ColumnContainer/14").add_child(unit)
		for unit in enemyRoster:
			get_node("ColumnContainer/1").add_child(unit)
	
	realFight()

func endCheck() -> bool:
	if friendlies.size() <= friendlyStart:
		return false
	if enemies.size() <= enemyStart:
		return false
	return true

func targetContainer(fac: Faction) -> VBoxContainer:
	var closest: Array[VBoxContainer] = []
	for VBox in get_node("ColumnContainer"):
		if VBox.get_children().size > 1:
			if VBox.get_child(1).faction != fac:
				options.append(VBox)

func realFight():
	var queue = fullRoster
	queue.sort_custom(func(a,b): return a.getSpeed() > b.getSpeed())
	
	while(endCheck()):
		
		fTargetContainer = 
		
		for model in queue:
			for cont in 
			for model.getAttacks():
				
