extends Control

var attackerRoster: Array[Unit] = []
var attackers: Array[Entity] = []

var defenderRoster: Array[Unit] = []
var defenders: Array[Entity] = []

var fullRoster: Array[Entity] = []
var attacker: String
var defender: String
var auto: bool
var winners: Array[Unit]

func _ready() -> void:
	global_position = Vector2((1920/2)-(1170/2), (1080/2)-(780/2))

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

func populate(attack: Array[Unit], defense: Array[Unit]) -> Array[Unit]:
	
	if attack.front().getFaction().id != 0 and defense.front().getFaction().id != 0 :
		print("Fought Automatically")
		self.visible = false
		auto = true
	
	attackerRoster = attack
	defenderRoster = defense
	attacker = attackerRoster.front().getTeam()
	defender = defenderRoster.front().getTeam()
	
	var line = load("res://Scenes/CombatLine.tscn")

	for unit in attackerRoster:
		get_node("Attacker/" + unit.getLine()).add_child(unit)
		for model in unit.roster:
			attackers.append(model)
			fullRoster.append(model)
	for unit in defenderRoster:
		get_node("Defender/" + unit.getLine()).add_child(unit)
		for model in unit.roster:
			defenders.append(model)
			fullRoster.append(model)
	
	
	get_node("Attacker").team = attackerRoster.front().getTeam()
	get_node("Defender").team = defenderRoster.front().getTeam()
	
	return await realFight()

func targetColumn(model: Entity) -> VBoxContainer:
	var friendlyArmy: HBoxContainer = model.getUnit().get_parent().get_parent()
	var enemyArmy: HBoxContainer
	match friendlyArmy.name:
		"Attacker":
			enemyArmy = get_node("Defender")
		"Defender":
			enemyArmy = get_node("Attacker")
	var counter = 0
	#print(friendlyArmy)
	#print(enemyArmy)
	var curr = enemyArmy.get_child(counter)
	while (curr.get_children().size() <= 0):
		counter += 1
		curr = enemyArmy.get_child(counter)
	return curr

func realFight() -> Array[Unit]:
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
			print("Shooter: " + str(model.name))
			
			#Finds the enemy frontline
			targetColumn = targetColumn(model)
			#Sets active weapons based on distance
			weapons = model.getActiveWeapons(distance(model.getUnit().get_parent(), targetColumn))
			#print("At distance [" + str(distance(model.getUnit().get_parent(), targetColumn)) + "]: " + str(weapons))
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
									print("Before:")
									print(get_node("Attacker"))
									print(get_node("Defender"))
									if !target.unit.validate():
										target.unit.get_parent().remove_child(target.unit)
										#check for one army or the other winning.
										print("After:")
										print(get_node("Attacker"))
										print(get_node("Defender"))
										if await endCheck():
											return winners
		
		#Move the attacking army forward one line's length.
		if distance(get_node("Attacker").get_child(5), get_node("Defender").get_child(0)) > 65:
			get_node("Attacker").global_position.x += 65
	queue_free()
	return winners

func endCheck() -> bool:
	var a: int = 0
	var b: int = 0
	for node in get_node("Attacker").get_children():
		for unit in node.get_children():
			a+=1
	for node in get_node("Defender").get_children():
		for unit in node.get_children():
			b+=1
	if a == 0:
		print("Defenders win!")
		await cleanup()
		winners = defenderRoster
		return true
	if b == 0:
		print("Attackers win!")
		await cleanup()
		winners = attackerRoster
		return true
	print("Attackers Left: " + str(a))
	print("Defenders Left: " + str(b))
	return false

func cleanup() -> bool:
	for model in (attackers + defenders):
		if model.getWounds() <= 0:
			model.battlescars += 1
			if model.getBattlescars() >= model.getMaxBattlescars():
				model.KILL()
	print(attackerRoster + defenderRoster)
	return true

func _on_button_pressed() -> void:
	for model in fullRoster:
		print(str(model) + " | " + str(model.unit.faction.title) + ": " + str(model.wounds)+ " Wounds.")
