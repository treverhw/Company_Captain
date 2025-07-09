extends Control

func rolld6() -> int:
	return randi_range(1,6)

func populate(friendlyRoster: Array[Unit], enemyRoster: Array[Unit], Attacking: bool):
	print("Friendly Roster: \n" + str(friendlyRoster))
	print("Enemy Roster: \n" + str(enemyRoster))
	
	if Attacking == true:
		for unit in friendlyRoster:
			get_node("ColumnContainer/1").add_child(unit)
		for unit in enemyRoster:
			get_node("ColumnContainer/14").add_child(unit)
		print("Column 1 ("+ str(get_node("ColumnContainer/1").get_children().size()) +"): " + str(get_node("ColumnContainer/1").get_children()))
	else: 
		for unit in friendlyRoster:
			get_node("ColumnContainer/14").add_child(unit)
		for unit in enemyRoster:
			get_node("ColumnContainer/1").add_child(unit)
