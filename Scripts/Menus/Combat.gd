extends Control

var friendlyRoster: Array[Unit] = []
var friendlies: Array[Entity] = []

var enemyRoster: Array[Unit] = []
var enemies: Array[Entity] = []

var fullRoster: Array[Entity] = []
var attacker: String
var defender: String
var auto: bool

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

func populate(group1: Array[Unit], group2: Array[Unit], Attacking: bool, automatic: bool):
	
	if automatic: 
		self.visible = false
		auto = true
	
	friendlyRoster = group1
	enemyRoster = group2
	attacker = friendlyRoster.front().getTeam()
	defender = enemyRoster.front().getTeam()
	
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
	
	#Combat loop starts
	while(true):
		var queue = fullRoster
		queue.shuffle()
		#sort by speed
		queue.sort_custom(func(a,b): return a.getSpeed() > b.getSpeed())
		
		#only process by shooting round if combat isn't automatic
		if !auto:
			await get_tree().create_timer(1).timeout
		
		#For model in the whole roster
		for model in queue:
			
			#Finds the enemy frontline
			targetColumn = targetColumn(model)
			#Sets active weapons based on distance
			weapons = model.getActiveWeapons(distance(model.getUnit().get_parent(), targetColumn))
			print("At distance [" + str(distance(model.getUnit().get_parent(), targetColumn)) + "]: " + str(weapons))
			for weapon in weapons:
				for attack in weapon.getAttacks():
					
					#select a random unit in the frontline
					var num = randi_range(0, targetColumn.get_children().size()-1)
					var targetUnit: Unit = targetColumn.get_child(num)
					#select a random model in that unit
					var target: Entity = targetUnit.getRoster()[randi_range(0, targetUnit.roster.size()-1)]
					
					#Hit
					if rolld6() >= model.getBallisticSkill():
						#Wound
						if wound(weapon, target, rolld6()):
							#Save
							var save = rolld6()
							if save < target.getSave():
								#If all rolls succeed and the save fails, the target takes damage
								#The shooter gains 1 xp on hits and another if the shot kills
								target.wounds -= weapon.getDmg()
								model.xp += 1
								
								#If mortally wounded, remove the model from the battle
								if target.getWounds() <= 0:
									fullRoster.erase(target)
									model.xp += 1
									#If the models unit is now empty, remove the unit from the battle.
									if !target.unit.validate():
										target.unit.get_parent().remove_child(target.unit)
										#check for one army or the other winning.
										if await endCheck():
											return
		
		#Move the attacking army forward one line's length.
		if distance(get_node("Attacker").get_child(5), get_node("Defender").get_child(0)) > 65:
			get_node("Attacker").global_position.x += 65

func endCheck() -> bool:
	var attackers: int = 0
	var defenders: int = 0
	for node in get_node("Attacker").get_children():
		for unit in node.get_children():
			attackers+=1
	for node in get_node("Defender").get_children():
		for unit in node.get_children():
			defenders+=1
	if attackers == 0:
		print("Defenders win!")
		await cleanup()
		self.queue_free()
		return true
	if defenders == 0:
		print("Attackers win!")
		await cleanup()
		self.queue_free()
		return true
	return false

func cleanup() -> bool:
	for model in (friendlies + enemies):
		if model.getWounds() <= 0:
			model.battlescars += 1
			if model.getBattlescars() <= 0:
				model.KILL()
	return true

func _on_button_pressed() -> void:
	for model in fullRoster:
		print(str(model) + " | " + str(model.unit.faction.title) + ": " + str(model.wounds)+ " Wounds.")
