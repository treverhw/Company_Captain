extends Node2D

var attackerRoster: Array[Unit] = []
var attackers: Array[Entity] = []

var defenderRoster: Array[Unit] = []
var defenders: Array[Entity] = []

var fullRoster: Array[Entity] = []
var auto: bool
var winners: Array[Unit]
var losers: Array[Unit]
var end: Dictionary = {0: winners, 1: losers}

func _ready() -> void:
	global_position = Vector2((1920/2)-(1170/2), (1080/2)-(780/2))

##Combat in order
func populate(attack: Array[Unit], defense: Array[Unit]) -> Dictionary:
	
	if attack.front().getFaction().id != 0 and defense.front().getFaction().id != 0 :
		#print("[Combat]: Fought Automatically")
		self.visible = false
		auto = true
	
	attackerRoster = attack
	defenderRoster = defense
	
	var line = load("res://Scenes/CombatLine.tscn")

	for unit in attackerRoster:
		unit.combatUpdate()
		unit.visible = true
		unit.reparent(get_node("Attacker/" + unit.getLine()))
		get_node("Attacker/" + unit.getLine()).roster.append_array(unit.getRoster())
		for model in unit.roster:
			fullRoster.append(model)
	for unit in defenderRoster:
		unit.combatUpdate()
		unit.visible = true
		unit.reparent(get_node("Defender/" + unit.getLine()))
		get_node("Defender/" + unit.getLine()).roster.append_array(unit.getRoster())
		for model in unit.roster:
			fullRoster.append(model)
	
	get_node("Attacker").team = attackerRoster.front().getTeam()
	get_node("Defender").team = defenderRoster.front().getTeam()
	
	return await realFight()

func realFight() -> Dictionary:
	var targetColumn: VBoxContainer
	var weapons: Array[Weapon]
	visible = true
	
	var queue = fullRoster.duplicate()
	#Combat loop starts
	while(!endCheck()):
		for model in range(queue.size()-1,-1,-1):
			if queue[model].getWounds() <= 0:
				queue.erase(queue[model])
		queue.shuffle()
		#sort by speed backwards
		queue.sort_custom(func(a,b): return a.getSpeed() < b.getSpeed())
		
		#only process by shooting round if combat isn't automatic
		if !auto:
			await get_tree().create_timer(1).timeout
		#For model in the whole roster
		for model in queue:
			if model.getWounds() <= 0:
				continue
			#print("Shooter: " + str(model) + " " + str(model.getTeam()))
			
			#Finds the enemy frontline
			targetColumn = targetColumn(model)
			#print(targetColumn)
			#Sets active weapons based on distance
			weapons = model.getActiveWeapons(distance(model.getUnit().get_parent(), targetColumn))
			#print("At distance [" + str(distance(model.getUnit().get_parent(), targetColumn)) + "]: " + str(weapons))
			for weapon in weapons:
				#print(weapon.getTitle())
				for attack in weapon.getAttacks():
					#print(attack + 1)
					
					#select a random model in the frontline
					var rand = RandomNumberGenerator.new()
					var target: Entity = targetColumn.getRoster()[rand.randi_range(0, targetColumn.getRoster().size()-1)]
					#print("Target: " + str(target) + " " + str(target.getTeam()))
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
								#print("Hit!")
								model.xp += 1
								
								#If mortally wounded, remove the model from the battle
								if target.getWounds() <= 0:
									model.xp += 1
									targetColumn.getRoster().erase(target)
									target.getUnit().combatUpdate()
									
									#check for one army or the other winning.
									if endCheck():
										cleanup()
										return end
		
		#Move the attacking army forward one line's length based on the distance between their front lines.
		#Needs to be changed to be the distance between their currently no
		if distance(get_node("Attacker").get_child(5), get_node("Defender").get_child(0)) > 65:
			get_node("Attacker").global_position.x += 65
	cleanup()
	return end

func endCheck() -> bool:
	var att = get_node("Attacker").getSize()
	var def = get_node("Defender").getSize()
	if att <= 0:
		#print("Defenders win!")
		end[0] = defenderRoster
		end[1] = attackerRoster
		#print("[Combat] Winners: \n" + str(end[0]))
		#print("[Combat] Losers: \n" + str(end[1]))
		return true
	if def <= 0:
		#print("Attackers win!")
		end[0] = attackerRoster
		end[1] = defenderRoster
		#print("[Combat] Winners: \n" + str(end[0]))
		#print("[Combat] Losers: \n" + str(end[1]))
		return true
	return false

func cleanup() -> bool:
	for unit in range(attackerRoster.size() -1, -1, -1):
		if attackerRoster[unit].get_parent() != null:
			attackerRoster[unit].reparent(attackerRoster[unit].getFaction())
		attackerRoster[unit].visible = false
		attackerRoster[unit].clean()
	for unit in range(defenderRoster.size() -1, -1, -1):
		if defenderRoster[unit].get_parent() != null:
			defenderRoster[unit].reparent(defenderRoster[unit].getFaction())
		defenderRoster[unit].visible = false
		defenderRoster[unit].clean()
	return true


#Utilities
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
	while (curr.getRoster().size() <= 0):
		counter += 1
		if counter > 5:
			break
		curr = enemyArmy.get_child(counter)
	return curr

func getEnding() -> Dictionary:
	endCheck()
	return end

func getFullSize() -> int:
	return get_node("Attacker").getSize() + get_node("Defender").getSize()
