extends Location
class_name Planet

var settlements: Array[Settlement]
var exclude: Array[Settlement] = []
var compliant: bool = false

func _ready() -> void:
	global_position = Vector2((1920/2), (1080/2))
	get_parent().get_node("BottomBar/Turn").button_down.connect(turn)
	generateTitle(Names.new().planetNames)
	print(title)
	get_node("Label").text = title
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
	var guard4 = get_parent().get_node("Factions/Guard").start()
	var guard5 = get_parent().get_node("Factions/Guard").start()
	var chaos = get_parent().get_node("Factions/Chaos").start()
	settlements[0].appendRoster(guard)
	settlements[1].appendRoster(guard1)
	settlements[2].appendRoster(guard2)
	settlements[3].appendRoster(guard3)
	settlements[4].appendRoster(guard4)
	settlements[5].appendRoster(guard5)
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
	print(temp2.size())
	if temp.size() > 1:
		var distances: Dictionary = {}
		for x in temp:
			distances[x] = [x,4000]
			for y in temp2:
				var length: float = distance(x,y) 
				if length < distances[x][1]:
					distances[x] = [y, length]
		var shortest: Array = [null, null, 4000]
		for x in distances:
			if distances[x][1] < shortest[2]:
				shortest[0] = x
				shortest[1] = distances[x][0]
				shortest[2] = distances[x][1]
		shortest[0].getConnections()[shortest[1]] = shortest[2]
		shortest[1].getConnections()[shortest[0]] = shortest[2]
		var newLine = Line2D.new()
		newLine.width = 3
		newLine.add_point(shortest[0].position)
		newLine.add_point(shortest[1].position)
		add_child(newLine)
		print("Connected " + str(shortest[0]) + " " + str(shortest[1]))


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
	await cleanup()
	compliance()
	
	
	#Convoys fight if near eachother
	for settlement in settlements:
		settlement.turn()
		await cleanup()
	var convoys = get_node("Convoys").get_children()
	for convoy in convoys:
		await convoy.move()
		await cleanup()
	convoys = get_node("Convoys").get_children()
	for convoy in convoys:
		var alreadyFought: Array[Convoy] = []
		for otherConvoy in convoys:
			if !alreadyFought.has(convoy) and!alreadyFought.has(otherConvoy):
				if distance(convoy, otherConvoy) <= 50.0 and convoy.getTeam() != otherConvoy.getTeam():
					await cleanup()
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
					

func cleanup() -> bool:
	for settlement in settlements:
		var temp = settlement.getRoster()
		for unit in temp:
			if !is_instance_valid(unit):
				temp.erase(unit)
	for convoy in get_node("Convoys").get_children():
		var temp = convoy.getRoster()
		for unit in temp:
			if !is_instance_valid(unit):
				temp.erase(unit)
		if convoy.getRoster().is_empty():
			convoy.kill()
	return true

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
