extends Location
class_name Planet

var settlements: Array[Settlement]
var exclude: Array[Settlement] = []
var compliant: bool = false

func _ready() -> void:
	get_parent().get_node("BottomBar/Turn").button_down.connect(turn)
	generateTitle(Names.new().planetNames)
	print(title)
	for n in range(0, randi_range(20,20)):
		var newSettlement = load("res://Scenes/Locational/Settlement.tscn").instantiate()
		newSettlement.global_position = Vector2(randi_range(-450, 450), randi_range(-250,250))
		var counter = 0
		while !validateDistance(newSettlement) and counter != 100:
			counter +=1
			newSettlement.global_position = Vector2(randi_range(-450, 450), randi_range(-250,250))
		if counter != 100:
			add_child(newSettlement)
			settlements.append(newSettlement)
		else:
			break
	var guard = get_parent().get_node("Factions/Guard").start()
	var guard1 = get_parent().get_node("Factions/Guard").start()
	var guard2 = get_parent().get_node("Factions/Guard").start()
	var guard3 = get_parent().get_node("Factions/Guard").start()
	var chaos = get_parent().get_node("Factions/Chaos").start()
	settlements[0].appendRoster(guard)
	settlements[1].appendRoster(guard1)
	settlements[2].appendRoster(guard2)
	settlements[3].appendRoster(guard3)
	settlements[settlements.size()-1].appendRoster(chaos)
	
	await createConnections()
	var temp: Array[Settlement]
	var temp2: Array[Settlement]
	for item in settlements:
		temp.append(item)
	temp2.append(temp.pop_front())
	for x in range(0,20):
		for item in temp2:
			for val in item.getConnections():
				if val in temp:
					temp.erase(val)
					temp2.append(val)
	if temp.size() < temp2.size():
		for node in temp:
			if node.line != null:
				node.line.queue_free()
			settlements.erase(node)
			node.queue_free()
	else:
		for node in temp2:
			if node.line != null:
				node.line.queue_free()
			settlements.erase(node)
			node.queue_free()

func compliance():
		var teams: Array[String]
		for settlement in settlements:
			if !teams.has(settlement.team):
				teams.append(settlement.team)
		if teams.size() > 1:
			compliant = false
		else:
			compliant = true

func turn():
	compliance()
	
	#Convoys fight if near eachother
	for settlement in settlements:
		settlement.turn()
	var convoys = get_node("Convoys").get_children()
	for convoy in convoys:
		await convoy.move()
	convoys = get_node("Convoys").get_children()
	for convoy in convoys:
		var alreadyFought: Array[Convoy] = []
		for otherConvoy in convoys:
			if !alreadyFought.has(convoy) and!alreadyFought.has(otherConvoy):
				if distance(convoy, otherConvoy) <= 50.0 and convoy.getTeam() != otherConvoy.getTeam():
					alreadyFought.append(convoy)
					alreadyFought.append(otherConvoy)
					print("[Convoy Fight] Start:")
					var combat = load("res://Scenes/Menus/Combat.tscn").instantiate()
					get_node("/root/Main").add_child(combat)
					print("[Convoy Fight] Old Roster: " + str(convoy.roster))
					print("[Convoy Fight] Old Roster: " + str(otherConvoy.roster))
					
					await combat.populate(convoy.getRoster().duplicate(), otherConvoy.getRoster().duplicate())
					var newRosters = combat.getEnding()
					for unit in range(newRosters[0].size()-1, -1, -1):
						if !is_instance_valid(newRosters[0][unit]) or newRosters[0][unit].getRoster().size() <= 0:
							newRosters[0][unit].queue_free()
							newRosters[0].erase(newRosters[0][unit])
					for unit in range(newRosters[1].size()-1, -1, -1):
						if !is_instance_valid(newRosters[1][unit]) or newRosters[1][unit].getRoster().size() <= 0:
							newRosters[1][unit].queue_free()
							newRosters[1].erase(newRosters[1][unit])
					
					if newRosters[0].front().getTeam() == convoy.getTeam():
						if newRosters[0].is_empty():
							convoy.kill()
						else:
							convoy.roster = newRosters[0]
							convoy.retreatConvoy()
						if newRosters[1].is_empty():
							otherConvoy.kill()
						else:
							otherConvoy.roster = newRosters[1]
							otherConvoy.retreatConvoy()
					else:
						if newRosters[1].is_empty():
							convoy.kill()
						else:
							convoy.roster = newRosters[1]
							convoy.retreatConvoy()
						if newRosters[0].is_empty():
							otherConvoy.kill()
						else:
							otherConvoy.roster = newRosters[0]
							otherConvoy.retreatConvoy()
					print("[Convoy Fight] New Roster: " + str(convoy.roster))
					print("[Convoy Fight] New Roster: " + str(otherConvoy.roster))
					combat.queue_free()

func createConnections():
	for n in settlements:
		for m in settlements:
			var distance: int = n.position.distance_to(m.position)
			if distance <= 200 and n!=m and !n.getConnections().has(m) and !m.getConnections().has(n):
				n.getConnections()[m] = distance
				m.getConnections()[n] = distance
				var newLine = Line2D.new()
				newLine.width = 3
				newLine.add_point(n.position)
				newLine.add_point(m.position)
				add_child(newLine)
				n.line = newLine
	for n in settlements:
		if n.getConnections().size() <= 0:
			settlements.erase(n)
			n.queue_free()
	return

func sortDictByValues(dict: Dictionary) -> Dictionary:
			var temp = {}
			while !dict.is_empty():
				var smallestKey = ""
				var smallestNum = 10000
				for item in dict:
					if dict[item] < smallestNum:
						smallestKey = item
						smallestNum = dict[item]
				dict.erase(smallestKey)
				temp[smallestKey] = smallestNum
			return temp

func validateDistance(val: Settlement) -> bool:
	for n in settlements:
		if val.position.distance_to(n.position) < 120 && n != val:
			return false
	return true
