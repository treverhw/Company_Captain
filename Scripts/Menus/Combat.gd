extends Control

var friendlyRoster: Array[Unit] = []
var friendlies: Array[Entity] = []

var enemyRoster: Array[Unit] = []
var enemies: Array[Entity] = []

var fullRoster: Array[Entity] = []
var attacker: String
var defender: String

func rolld6() -> int:
	return randi_range(1,6)

func wound(s : Weapon, t : Entity, roll : int):
	if s.getStrength() >= 2*t.getToughness() and roll >= 2:
		return true
	elif s.getStrength() > t.getToughness() and roll >= 3:
		return true
	elif s.getStrength() == t.getToughness() and roll >= 4:
		return true
	elif s.getStrength() < t.getToughness() and roll >= 5:
		return true
	elif s.getStrength()*2 <= t.getToughness() and roll >= 6:
		return true
	else: return false

func distance(Node1: Node, Node2: Node) -> float:
	return Node1.global_position.distance_to(Node2.global_position)

func populate(group1: Array[Unit], group2: Array[Unit], Attacking: bool):
	
	friendlyRoster = group1
	enemyRoster = group2
	attacker = friendlyRoster.front().getTeam()
	defender = enemyRoster.front().getTeam()
	print("Friendly Roster: \n" + str(friendlyRoster))
	print("Enemy Roster: \n" + str(enemyRoster))
	
	var line = load("res://Scenes/CombatLine.tscn")

	for unit in friendlyRoster:
		get_node("Attacker/" + unit.getLine()).add_child(unit)
		for model in unit.roster:
			friendlies.append(model)
			fullRoster.append(model)
	for unit in enemyRoster:
		get_node("Defender/" + unit.getLine()).add_child(unit)
		for model in unit.roster:
			enemies.append(model)
			fullRoster.append(model)
	
	
	get_node("Attacker").team = friendlyRoster.front().getTeam()
	get_node("Defender").team = enemyRoster.front().getTeam()
	
	realFight()

func endCheck() -> bool:
	var attackers: int = 0
	var defenders: int = 0
	for node in get_node("Attacker").get_children():
		for unit in node.get_children():
			attackers+=1
	for node in get_node("Defender").get_children():
		for unit in node.get_children():
			defenders+=1
	if attackers == 0 or defenders == 0:
		return true
	return false

func targetColumn(model: Entity) -> VBoxContainer:
	var friend: HBoxContainer = model.getUnit().get_parent().get_parent()
	var enemy: HBoxContainer
	match friend.name:
		"Attacker":
			enemy = get_node("Defender")
		"Defender":
			enemy = get_node("Attacker")
	var counter = 0
	var curr = enemy.get_child(counter)
	while (curr.get_children().size() <= 0):
		counter += 1
		curr = enemy.get_child(counter)
	return curr

func realFight():
	var targetColumn: VBoxContainer
	var weapons: Array[Weapon]
	
	while(true):
		print(distance(targetColumn(friendlies.front()), targetColumn(enemies.front())))
		var queue = fullRoster
		queue.sort_custom(func(a,b): return a.getSpeed() > b.getSpeed())
		
		await get_tree().create_timer(1).timeout
		for model in queue:
			#print(currColumn)
			targetColumn = targetColumn(model)
			#print(targetColumn)
			weapons = model.getActiveWeapons(distance(model.getUnit().get_parent(), targetColumn))
			
			for weapon in weapons:
				for attack in weapon.getAttacks():
					#print("Shot!")
					var num = randi_range(0, targetColumn.get_children().size()-1)
					var targetUnit: Unit = targetColumn.get_child(num)
					#print(targetColumn.get_children())
					#print(str(num) + " " + str(targetUnit))
					#print("Shooter: " + str(model.unit.faction.title)  + " " + str(model))
					var target: Entity = targetUnit.getRoster()[randi_range(0, targetUnit.roster.size()-1)]
					#print("Target: " + str(target.unit.faction.title)  + " " + str(target))
					#print(target)
					if rolld6() >= model.getBallisticSkill():
						#print("Hit!")
						if wound(weapon, target, rolld6()):
							#print("Wound!")
							var save = rolld6()
							#print(save)
							#print(target.getSave())
							if save < target.getSave():
								target.wounds -= weapon.getDmg()
								#print(str(target) + " Wounds: " + str(target.wounds))
								if !target.alive():
									fullRoster.erase(target)
									if !target.unit.validate():
										target.unit.get_parent().remove_child(target.unit)
										await endCheck()
		print(distance(targetColumn(friendlies.front()), targetColumn(enemies.front())))
		if distance(targetColumn(friendlies.front()), targetColumn(enemies.front())) > 65:
			get_node("Attacker").global_position.x += 65

func win() -> bool:
	if friendlies.size() <= 0:
		print("You Lose!")
	if enemies.size() <= 0:
		print("You Win!")
	await cleanup()
	self.queue_free()
	return true

func cleanup() -> bool:
	for model in (friendlies + enemies):
		if await model.checkWounds():
			if model.getBattlescars() <= 0:
				model.KILL()
	return true
	

func _on_button_pressed() -> void:
	for model in fullRoster:
		print(str(model) + " | " + str(model.unit.faction.title) + ": " + str(model.wounds)+ " Wounds.")
