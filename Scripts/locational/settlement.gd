extends Location
class_name Settlement

var connections: Dictionary = {}
var type: String
var newUnitCounter: int = 0
var line

func appendRoster(arr: Array[Unit]):
	for unit in arr:
		getRoster().append(unit)
		unit.setLocation(self)
	update()

func _ready() -> void:
	#get_parent().get_node("Button").button_down.connect(turn)
	generateTitle(Names.new().planetNames)
	get_node("Name").text = name

func shortestPath(settlements: Array[Settlement], source: Settlement = self) -> Array[Settlement]:
	var dist = {}
	var prev = {}
	var queue: Array[Settlement]
	for settlement in settlements:
		dist[settlement] = 1000
		prev[settlement] = null
		queue.append(settlement)
	dist[source] = 0
	
	while !queue.is_empty():
		var closestSettlement: Settlement = null
		var shortest: int = 1001
		for settlement in queue:
			if dist[settlement] < shortest:
				closestSettlement = settlement
				shortest = dist[settlement]
		queue.erase(closestSettlement)
		for settlement in closestSettlement.getConnections():
			var temp = floor(distance(closestSettlement, settlement)/50)
			#convoys move 50px a turn.
			if dist[settlement] >= 1000:
				dist[settlement] = dist[closestSettlement] + temp
				prev[settlement] = closestSettlement
			elif dist[closestSettlement] + temp < dist[settlement]:
				dist[settlement] = dist[closestSettlement] + temp
				prev[settlement] = closestSettlement
	
	#find nearest unowned node
	var path: Array[Settlement] = []
	var options: Array[Settlement] =  settlements.duplicate()
	var target: Settlement
	var distance: int = 1000
	for settlement in options:
		if dist[settlement] < distance and settlement.team != self.team:
			#print("[Settlement] " + settlement.getTitle() + ": " + str(settlement.getWeight()) + " " + str(getAttackWeight()))
			target = settlement
			distance = dist[settlement]
	#if destination has too many enemies, rally to node before destination.
	if target.getWeight() >= getAttackWeight() * 1.5:
		target = prev[target]
	while target != null:
		path.push_front(target)
		target = prev[target]
	return path

func spawn() -> Unit:
	var unit = roster.front().getFaction().spawnLocational(self)
	return unit

func turn():
	#print(getTitle() + ": " + str(getRoster()))
	var threatened: bool = false
	if team != "Unowned" and getRoster().size() > 0:
		newUnitCounter += 1
		if newUnitCounter >= 5:
			roster.append(await spawn())
			newUnitCounter = 0
		var threatWeight: int = 0
		for settlement in connections:
			if !settlement.getRoster().is_empty():
				if settlement.team != self.team:
					threatWeight += settlement.getAttackWeight()
		for convoy in get_parent().get_node("Convoys").get_children():
			if convoy.getTeam() != self.team:
				if convoy.destination == self or connections.has(convoy.destination):
					threatWeight += convoy.getWeight()
		#print("[" + str(self) + "] Weight: " + str(getWeight()) + " | ThreatWeight: " + str(threatWeight))
		if threatWeight >= getWeight():
			#print("[Threatened] " + str(self))
			threatened = true
		if !threatened and !get_parent().compliant and roster.size() > 2:
			#print("Spawning Convoy: " + str(self))
			await spawnConvoy()
		if threatened == true:
			overwhelmCheck()
		update()

func spawnConvoy(destination:Settlement = null) -> Convoy:
	var convoy: Convoy = load("res://Scenes/Entities/Convoy.tscn").instantiate()
	get_parent().get_node("Convoys").add_child(convoy)
	var leftBehind: Array[Unit]
	var counter = 0
	#Leave behind two base units
	for unit in getRoster():
		if unit.getRoster().front().rank == "Base" and counter < 2:
			counter += 1
			leftBehind.append(unit)
	for unit in getRoster():
		if !leftBehind.has(unit):
			convoy.roster.append(unit)
	#Directed Movement
	if destination != null:
		#print("Directed") 
		convoy.setConvoy(convoy.roster, self, destination)
		roster = leftBehind
	#Automatic
	else:
		var tempPath: Array[Settlement] = shortestPath(get_parent().settlements)
		if tempPath.size() >= 2:
			#print("Auto") 
			convoy.setConvoy(convoy.roster, self, tempPath[1])
		else:
			#print("Too Small") 
			convoy.setConvoy(convoy.roster, self, self)
		roster = leftBehind
	update()
	return convoy

func overwhelmCheck():
	print("Overhelm Check for " + str(self))
	var overwhelm = false
	var weight: int = getWeight()
	var theirWeight: int = 0
	for settlement in connections:
		#print(weight)
		#print(theirWeight)
		if settlement.getTeam() != getTeam():
			theirWeight += settlement.getAttackWeight()
		#print(weight)
		#print(theirWeight)
		if theirWeight >= weight:
			overwhelm = true
			for connection in connections:
				if connection.getTeam() != getTeam():
					#print("Overwhleming Convoy")
					connection.spawnConvoy(self)
			update()
			break

func invade(attackers: Array[Unit]):
	print("------------------INVASION-START------------------")
	print("->LOCATION:" + getTitle())
	##Set locations and divide the fight.
	var defenders: Array[Unit] = []
	for unit in getRoster():
		defenders.append(unit)
	appendRoster(attackers)
	#print("Attackers: " + str(attackers))
	#print("Defenders: " + str(defenders))
	##Initiate Combat
	var combat = load("res://Scenes/Menus/Combat.tscn").instantiate()
	get_node("/root/Main").add_child(combat)
	var newRosters = await combat.populate(attackers, defenders)
	##Post-Combat
	var retreat = false
	#print("Winners: \n" + str(newRosters[0]))
	#print("Losers: \n" + str(newRosters[1]))
	#Safety Cleanup
	for unit in range(newRosters[0].size()-1, -1, -1):
		if !is_instance_valid(newRosters[0][unit]) or newRosters[0][unit].getRoster().size() <= 0:
			newRosters[0][unit].queue_free()
			newRosters[0].erase(newRosters[0][unit])
	for unit in range(newRosters[1].size()-1, -1, -1):
		if !is_instance_valid(newRosters[1][unit]) or newRosters[1][unit].getRoster().size() <= 0:
			newRosters[1][unit].queue_free()
			newRosters[1].erase(newRosters[1][unit])
	#Retreat living units
	if !newRosters[1].is_empty():
		for settlement in getConnections():
			if settlement.getTeam() == newRosters[1].front().getTeam():
				retreat = true
				var convoy: Convoy = load("res://Scenes/Entities/Convoy.tscn").instantiate()
				get_parent().get_node("Convoys").add_child(convoy)
				convoy.setConvoy(newRosters[1], self, settlement)
				convoy.move()
				break
	#or not
	if retreat == false:
		#print("Cornered and Slaughtered.")
		pass
	roster = newRosters[0]
	combat.queue_free()
	update()
	print("------------------INVASION-OVER------------------")

func cleanup():
	for unit in range(getRoster().size()-1, -1, -1):
		if !is_instance_valid(getRoster()[unit]):
			getRoster().erase(getRoster()[unit])

func update():
	for unit in range(getRoster().size()-1, -1, -1):
		if !is_instance_valid(getRoster()[unit]):
			getRoster().erase(getRoster()[unit])
		getRoster()[unit].setLocation(self)
	get_node("Label").text = str(roster.size())
	if !roster.is_empty():
		setTeam(roster.front().getTeam())
		match team:
			"Imperium":
				get_node("TextureRect").set_texture(load("res://Assets/locational/Imperium.png"))
			"Chaos":
				get_node("TextureRect").set_texture(load("res://Assets/locational/Bad.png"))
			"Aeldari":
				get_node("TextureRect").set_texture(load("res://Assets/locational/Bad.png"))
			"Ork":
				get_node("TextureRect").set_texture(load("res://Assets/locational/Bad.png"))
			"Tyranid":
				get_node("TextureRect").set_texture(load("res://Assets/locational/Bad.png"))
			"Tau":
				get_node("TextureRect").set_texture(load("res://Assets/locational/Bad.png"))


##Getters and Setters
func getConnections() -> Dictionary:
	return connections
func getType() -> String:
	return type
func getWeight() -> int:
	#print(getTitle() + ": " + str(getRoster()))
	var n: int = 0
	for unit in getRoster():
		n += unit.getWeight()
	return n

func getAttackWeight() -> int:
	var n: int = 0
	for unit in range(2, getRoster().size()):
		n += getRoster()[unit].getWeight()
	return n

func setConnections(val: Dictionary):
	pass
func setType(val: String):
	type = val

func _to_string() -> String:
	return title
