extends Location
class_name Settlement

var connections: Dictionary = {}
var type: String
var newUnitCounter: int = 0
var line

func appendRoster(arr: Array[Unit]):
	roster.append_array(arr)
	print(roster)
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
	var path: Array[Settlement]= []
	var target: Settlement
	var distance: int = 1000
	for settlement in settlements:
		if dist[settlement] < distance and settlement.team != self.team and settlement.getWeight() <= getAttackWeight():
			print("[Settlement] " + settlement.getTitle() + ": " + str(settlement.getWeight()) + " " + str(getAttackWeight()))
			target = settlement
			distance = dist[settlement]
	while target != null:
		path.push_front(target)
		target = prev[target]
	return path

func spawn() -> Unit:
	print(self)
	var unit = roster.front().getFaction().spawnLocational(self)
	return unit

func turn():
	print(getTitle() + ": " + str(getRoster()))
	if team != "Unowned":
		newUnitCounter += 1
	if newUnitCounter >= 5:
		roster.append(await spawn())
		newUnitCounter = 0
	if roster.size() > 2 and get_parent().compliant == false:
		var tempPath: Array[Settlement] = shortestPath(get_parent().settlements)
		if tempPath.size() < 2:
			return 
		var convoy: Convoy = load("res://Scenes/Entities/Convoy.tscn").instantiate()
		get_parent().get_node("Convoys").add_child(convoy)
		convoy.global_position = self.global_position
		convoy.setRoster(roster)
		convoy.setPath(tempPath)
	update()

func invade(arr: Array[Unit]):
	print("------------------INVASION-START------------------")
	var defenders: Array[Unit] = []
	for unit in getRoster():
		defenders.append(unit)
	appendRoster(arr)
	print("Attackers: " + str(arr))
	print("Defenders: " + str(defenders))
	var combat = load("res://Scenes/Menus/Combat.tscn").instantiate()
	get_node("/root/Main").add_child(combat)
	var newRoster = await combat.populate(arr, defenders)
	roster = newRoster
	print(getRoster())
	await combat.cleanup()
	combat.queue_free()
	print(getRoster())
	update()
	print(getRoster())
	print("------------------INVASION-OVER------------------")

func update():
	for unit in getRoster():
		unit.setLocation(self)
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
