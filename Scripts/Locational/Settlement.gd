extends Location
class_name Settlement

var connections: Dictionary = {}
var type: String
var newUnitCounter: int = 0
var line
var threatened: bool = false
var shuttles: Array[Shuttle] = []


func appendRoster(arr: Array[Unit]):
	for unit in arr:
		if is_instance_valid(unit):
			getRoster().append(unit)
			unit.setLocation(self)
	update()

func _ready() -> void:
	#get_parent().get_node("Button").button_down.connect(turn)
	generateTitle(Names.new().planetNames)
	get_node("Name").text = name

func shortestPath(settlements: Array[Settlement], speed: int = 50, source: Settlement = self) -> Array[Settlement]:
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
			var temp = floor(distance(closestSettlement, settlement)/speed)
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
	var target: Settlement = self
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
	var ret: Unit
	for unit in roster:
		var temp = unit.getRoster().front().getFaction()
		if temp is not PlayerFaction:
			ret = temp.spawnLocational(self)
			break
	return ret

func turn():
	threatened = false
	#print(getTitle() + ": " + str(getRoster()))
	if team != "Unowned" and getRoster().size() > 0:
		newUnitCounter += 1
		if newUnitCounter >= 10:
			roster.append(spawn())
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
		if threatWeight*1.2 >= getWeight():
			#print("[Threatened] " + str(self))
			threatened = true
		if !threatened and !get_parent().get_parent().compliant and roster.size() > 2:
			#print("Spawning Convoy: " + str(self))
			var guy = spawnConvoy()
			guy.source = "Normal Move"
		if threatened == true:
			overwhelmCheck()
		update()

func spawnConvoy(destination:Settlement = null) -> Convoy:
	#print("Spawn Convoy Happened")
	if getRoster().size() <= 2:
		return Convoy.new()
	var convoy: Convoy = load("res://Scenes/Entities/Convoy.tscn").instantiate()
	get_parent().get_node("Convoys").add_child(convoy)
	var toGo: Array[Unit] = allButTwo()
	#if convoy.getRoster().size() <= 0:
	#	return Convoy.new()
	#Directed Movement
	if destination != null:
		#print("Directed") 
		convoy.setConvoy(toGo, self, destination)
	#Automatic
	else:
		var tempPath: Array[Settlement] = shortestPath(get_parent().get_parent().settlements, convoy.speed)
		if tempPath.size() >= 2:
			#print("Auto") 
			convoy.setConvoy(toGo, self, tempPath[1])
		else:
			#print("Too Small") 
			#print(get_parent().get_parent())
			#print(tempPath)
			convoy.setConvoy(toGo, self, self)
	for unit in toGo:
		getRoster().erase(unit)
	update()
	return convoy

func allButTwo() -> Array[Unit]:
	var counter: int = 0
	var ret: Array[Unit] = []
	for unit in getRoster():
		if unit.getRoster().front().rank == "Base" and counter < 2:
			counter +=1
		else:
			ret.append(unit)
	#print(str(getRoster().size()) + " | " + str(ret.size()))
	return ret

func overwhelmCheck():
	#print("Overhelm Check for " + str(self))
	var weight: int = getWeight()
	var theirWeight: int = 0
	for settlement in connections:
		if settlement.getTeam() != getTeam():
			theirWeight += settlement.getAttackWeight()
		if theirWeight >= weight:
			for connection in connections:
				if connection.getTeam() != getTeam():
					#print("Overwhleming Convoy")
					var guy = connection.spawnConvoy(self)
					guy.source = "Overwhelm"
			update()
			break

func invade(attackers: Array[Unit]):
	#print("------------------INVASION-START------------------")
	#print("->LOCATION:" + getTitle())
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
				convoy.source = "Invasion Retreat"
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
	#print("------------------INVASION-OVER------------------")

func cleanup():
	for unit in range(getRoster().size()-1, -1, -1):
		if !is_instance_valid(getRoster()[unit]):
			getRoster().erase(getRoster()[unit])

func update():
	for unit in range(getRoster().size()-1, -1, -1):
		getRoster()[unit].setLocation(self)
	get_node("Label").text = str(roster.size())
	if !getRoster().is_empty():
		setTeam(getRoster().front().getTeam())
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
	else:
		team = "Unowned"
		get_node("TextureRect").set_texture(load("res://Assets/locational/unowned.png"))

#region Getters and Setters
func getConnections() -> Dictionary:
	return connections
func getType() -> String:
	return type
func getWeight() -> int:
	#print(getTitle() + ": " + str(getRoster()))
	var n: int = 0
	for unit in getRoster():
		if is_instance_valid(unit):
			n += unit.getWeight()
	return n

func getAttackWeight() -> int:
	var n: int = 0
	for unit in range(2, getRoster().size()):
		if is_instance_valid(getRoster()[unit]):
			n += getRoster()[unit].getWeight()
	return n

func setConnections(val: Dictionary):
	pass
func setType(val: String):
	type = val
#endregion

func _to_string() -> String:
	return title
