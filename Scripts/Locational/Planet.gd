extends Location
class_name Planet

var settlements: Array[Settlement]
var exclude: Array[Settlement] = []
var balance: int

func _ready() -> void:
	var main = get_node("/root/Main/")
	global_position = Vector2((1920/2), (1080/2))
	main.get_node("BottomBar/Turn").button_down.connect(turn)
	generateTitle(Names.new().planetNames)
	print(title)
	get_node("PlanetMenu/Label").text = title
	get_node("PlanetNode/Label").text = title
	for n in range(0, randi_range(16,25)):
		var newSettlement = load("res://Scenes/Locational/Settlement.tscn").instantiate()
		newSettlement.global_position = Vector2(randi_range(-450, 450), randi_range(-250,250))
		var counter = 0
		while !validateDistance(newSettlement, settlements, 125) and counter != 100:
			counter +=1
			newSettlement.global_position = Vector2(randi_range(-450, 450), randi_range(-250,250))
		if counter != 100:
			get_node("PlanetMenu").add_child(newSettlement)
			settlements.append(newSettlement)
		else:
			break
	
	for n in randi_range(4, 8):
		var guard1 = main.get_node("Factions/Guard").start()
		var settlement = settlements[randi_range(0, settlements.size()-1)]
		settlement.appendRoster(guard1)
	for n in randi_range(4, 5):
		var chaos1 = main.get_node("Factions/Chaos").start()
		var num = randi_range(0, settlements.size()-1)
		while settlements[num].getTeam() == "Imperium":
			num = randi_range(0, settlements.size()-1)
		var settlement = settlements[num]
		settlement.appendRoster(chaos1)
	
	await createConnections()
	var temp: Array[Settlement]
	var temp2: Array[Settlement]
	while temp2.size() != settlements.size():
		temp = []
		temp2 = []
		for item in settlements:
			temp.append(item)
		temp2.append(temp.pop_front())
		for settlement in settlements:
			for x in range(0,20):
				for item in temp2:
					for val in item.getConnections():
						if val in temp:
							temp.erase(val)
							temp2.append(val)
			#print(temp2.size())
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
				get_node("PlanetMenu").add_child(newLine)
				#print("Connected " + str(shortest[0]) + " " + str(shortest[1]))
	update()


func compliance():
	var teams: Array[String]
	for settlement in settlements:
		if !teams.has(settlement.team):
			teams.append(settlement.team)
	if teams.size() > 1:
		compliant = false
	else:
		compliant = true
	return compliant

func turn():
	await cleanup()
	update()
	compliance()
	
	for settlement in settlements:
		await settlement.turn()
		await cleanup()
	var convoys = get_node("PlanetMenu/Convoys").get_children()
	for convoy in convoys:
		await convoy.move()
		await cleanup()
	
	#Convoys fight if near eachother
	convoys = get_node("PlanetMenu/Convoys").get_children()
	var alreadyFought: Array[Convoy] = []
	for convoy in range(convoys.size()-1,-1,-1):
		var bodies: Array[Node2D] = convoys[convoy].get_node("VisionRange").get_overlapping_bodies()
		if !bodies.is_empty():
			for body in bodies:
				var otherConvoy = body.get_parent()
				if (!alreadyFought.has(convoys[convoy]) or !alreadyFought.has(otherConvoy)) and convoys[convoy] != otherConvoy:
					await cleanup()
					#print("Bodies Size: " + str(bodies.size()))
					#print("Source: " + convoys[convoy].source + " | Home: " + str(convoys[convoy].getHome()) + " | Destination: " + str(convoys[convoy].getDestination()) + " | Team: " + convoys[convoy].getTeam() +  " | Size: " + str(convoys[convoy].getRoster().size()))
					#print("Source: " + otherConvoy.source + " | Home: " + str(otherConvoy.getHome()) + " | Destination: " +  str(otherConvoy.getDestination()) + " | Team: " + otherConvoy.getTeam() + " | Size: " + str(otherConvoy.getRoster().size()))
					if convoys[convoy].getTeam() != otherConvoy.getTeam() and convoys[convoy].getDestination() == otherConvoy.getHome() and !convoys[convoy].getRoster().is_empty() and !otherConvoy.getRoster().is_empty():
						alreadyFought.append(convoys[convoy])
						alreadyFought.append(otherConvoy)
						await convoyFight(convoys[convoy], otherConvoy)
	await cleanup()


func convoyFight(val1: Convoy, val2: Convoy):
	await cleanup()
	#print("[Convoy Fight] Start:")
	var combat = load("res://Scenes/Menus/Combat.tscn").instantiate()
	get_node("/root/Main").add_child(combat)
	
	var newRosters = await combat.populate(val1.getRoster(), val2.getRoster())
	for unit in range(newRosters[0].size()-1, -1, -1):
		if !is_instance_valid(newRosters[0][unit]) or newRosters[0][unit].getRoster().size() <= 0:
			newRosters[0][unit].queue_free()
			newRosters[0].erase(newRosters[0][unit])
	for unit in range(newRosters[1].size()-1, -1, -1):
		if !is_instance_valid(newRosters[1][unit]) or newRosters[1][unit].getRoster().size() <= 0:
			newRosters[1][unit].queue_free()
			newRosters[1].erase(newRosters[1][unit])
	
	val1.source = "Convoy Fight Retreat"
	val2.source = "Convoy Fight Retreat"
	
	if val1.getRoster().is_empty():
		val1.kill()
	else:
		await val1.retreatConvoy()
	if val2.getRoster().is_empty():
		val2.kill()
	else:
		await val2.retreatConvoy()
	combat.queue_free()

func cleanup() -> bool:
	for settlement in settlements:
		var temp = settlement.getRoster()
		for unit in range(temp.size()-1,-1,-1):
			if !is_instance_valid(temp[unit]):
				temp.erase(temp[unit])
	for convoy in get_node("PlanetMenu/Convoys").get_children():
		var temp = convoy.getRoster()
		for unit in range(temp.size()-1,-1,-1):
			if !is_instance_valid(temp[unit]):
				temp.erase(temp[unit])
		if convoy.getRoster().is_empty():
			await convoy.kill()
	return true

func update():
	setBalance("Imperium")
	get_node("PlanetNode/Balance").text = str(balance)
	if balance > 0:
		get_node("PlanetNode/PlanetSprite").texture_normal = load("res://Assets/locational/Imperium.png")
	elif balance < 0:
		get_node("PlanetNode/PlanetSprite").texture_normal = load("res://Assets/locational/Bad.png")
	else:
		get_node("PlanetNode/PlanetSprite").texture_normal = load("res://Assets/locational/unowned.png")

func setBalance(team: String):
	var temp = 0
	for settlement in settlements:
		if settlement.getTeam() == team:
			temp += settlement.getWeight()
		else: temp -= settlement.getWeight()
	for convoy in get_node("PlanetMenu/Convoys").get_children():
		if convoy.getTeam() == team:
			temp += convoy.getWeight()
		else: temp -= convoy.getWeight()
	balance = temp
	return temp

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
				get_node("PlanetMenu").add_child(newLine)
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

func getExcess(team: String) -> Array[Unit]:
	var ret: Array[Unit] = []
	for settlement in settlements:
		for unit in settlement:
			if unit.getTeam() == team:
				ret.append(unit)
	return ret

func getBalance(team: String) -> int:
	return setBalance(team)

func _on_sprite_2d_pressed() -> void:
	get_node("PlanetMenu").visible = !get_node("PlanetMenu").visible

func _on_button_pressed() -> void:
	get_node("PlanetMenu").visible = !get_node("PlanetMenu").visible
