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

func distance(Node1: Node, Node2: Node) -> int:
	return Node1.global_position.distance_to(Node2.global_position)

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

func targetContainer(curr: VBoxContainer, fac: Faction) -> VBoxContainer:
	var closest: VBoxContainer = null
	for VBox in get_node("ColumnContainer").get_children():
		if VBox.get_children().size() > 1:
			if VBox.get_child(1).faction != fac && (distance(VBox, curr) < distance(closest, curr) || closest == null):
				closest = VBox
	return closest

func realFight():
	var targetColumn: VBoxContainer
	var weapons: Array[Weapon]
	
	while(endCheck()):
		var queue = fullRoster
		queue.sort_custom(func(a,b): return a.getSpeed() > b.getSpeed())
		
		for model in queue:
			await get_tree().create_timer(1).timeout
			var currColumn = model.findColumn()
			targetColumn = targetContainer(currColumn, model.faction)
			weapons = model.weapons(distance(currColumn, targetColumn))
			
			for weapon in weapons:
				for attack in weapon.get_attacks():
					var targetUnit: Unit = targetColumn.get_child(randi_range(1, targetColumn.get_children().size()))
					var target: Entity = targetUnit.get_child(randi_range(0, targetUnit.get_children().size()))
					if rolld6() >= model.getBallisticSkill():
						if wound(weapon, target, rolld6()):
							if rolld6() < target.getSave():
								target.wounds -= weapon.getDmg()
								if target.seatbelt():
									fullRoster.erase(target)
	
	for model in (friendlies + enemies):
		if model.checkWounds():
			if model.getBattlescars() <= 0:
				model.KILL()
	await get_tree().create_timer(1).timeout
	for unit in friendlyRoster + enemyRoster:
		unit.validate()
