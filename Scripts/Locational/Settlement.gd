extends Location
class_name Settlement

var connections: Dictionary = {}
var type: String
var newUnitCounter: int = 0
var threatened: bool = false
var shuttles: Array[Shuttle] = []
var threatRatio: float = 1.2
var overwhelmingRatio: float = 1.5

func appendRoster(arr: Array[Unit]) -> void:
	for unit in arr:
		if is_instance_valid(unit):
			getRoster().append(unit)
			unit.setLocation(self)
	update()

func _ready() -> void:
	generateTitle(Names.new().planetNames)
	get_node("Name").text = name

## Finds the shortest path (measured in turns at the given speed) from
## `source` to the nearest settlement that isn't already ours, using
## Dijkstra's algorithm over the settlement connection graph.
func shortestPath(settlements: Array[Settlement], speed: int = 50, source: Settlement = self) -> Array[Settlement]:
	var dist: Dictionary = {}
	var prev: Dictionary = {}
	var queue: Array[Settlement] = []
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
			# Convoys move `speed` px per turn.
			var stepCost: int = floor(distance(closestSettlement, settlement) / speed)
			if dist[settlement] >= 1000 or dist[closestSettlement] + stepCost < dist[settlement]:
				dist[settlement] = dist[closestSettlement] + stepCost
				prev[settlement] = closestSettlement

	# Find the nearest settlement that isn't already ours.
	var path: Array[Settlement] = []
	var target: Settlement = self
	var bestDistance: int = 1000
	for settlement in settlements:
		if dist[settlement] < bestDistance and settlement.team != team:
			target = settlement
			bestDistance = dist[settlement]
	# If the destination has too many enemies, rally at the node before it instead.
	if target.getWeight() >= getAttackWeight() * overwhelmingRatio:
		target = prev[target]
	while target != null:
		path.push_front(target)
		target = prev[target]
	return path

## Picks a reinforcement from the first non-player faction represented in
## this settlement's roster (the player spawns/crews units manually via ships).
func spawn() -> Unit:
	for unit in roster:
		var owner: Faction = unit.getRoster().front().getFaction()
		if owner is not PlayerFaction:
			return owner.spawnLocational(self)
	return null

## Per-turn upkeep: reinforcements, threat assessment, and automatic
## convoy dispatch when this settlement isn't under threat.
func turn() -> void:
	threatened = false
	if team == "Unowned" or getRoster().is_empty():
		return

	newUnitCounter += 1
	if newUnitCounter >= 10:
		roster.append(spawn())
		newUnitCounter = 0

	var threatWeight: int = 0
	for settlement in connections:
		if !settlement.getRoster().is_empty() and settlement.team != team:
			threatWeight += settlement.getAttackWeight()
	for convoy in get_parent().get_node("Convoys").get_children():
		if convoy.getTeam() != team and (convoy.destination == self or connections.has(convoy.destination)):
			threatWeight += convoy.getWeight()

	if threatWeight * threatRatio >= getWeight():
		threatened = true

	if !threatened and !get_parent().get_parent().compliant and roster.size() > 2:
		var guy: Convoy = spawnConvoy()
		guy.source = "Normal Move"
	if threatened:
		overwhelmCheck()
	update()

func spawnConvoy(destination: Settlement = null) -> Convoy:
	if getRoster().size() <= 2:
		return Convoy.new()
	if destination != null and destination.getWeight() >= getAttackWeight() * overwhelmingRatio:
		return Convoy.new()
		
	var convoy: Convoy = load("res://Scenes/Entities/Convoy.tscn").instantiate()
	get_parent().get_node("Convoys").add_child(convoy)

	var toGo: Array[Unit] = allButTwo()
	# NOTE: there was previously a guard here returning early if toGo was
	# empty; it's commented out as of SystemMap, so left disabled here too —
	# flagged separately since a zero-unit convoy looks possible as a result.
	if destination != null:
		# Directed movement: send the convoy to a specific settlement.
		convoy.setConvoy(toGo, self, destination)
	else:
		# Automatic movement: send the convoy toward the nearest threat.
		var tempPath: Array[Settlement] = shortestPath(get_parent().get_parent().settlements, convoy.speed)
		var nextStop: Settlement = tempPath[1] if tempPath.size() >= 2 else self
		convoy.setConvoy(toGo, self, nextStop)

	for unit in toGo:
		getRoster().erase(unit)
	update()
	return convoy

## Every roster unit except the first two "Base" rank units, which stay
## behind to hold the settlement. Shared by spawnConvoy() and
## Planet.getExcess() (for shuttles picking up units to ferry).
func allButTwo() -> Array[Unit]:
	var counter: int = 0
	var ret: Array[Unit] = []
	for unit in getRoster():
		if unit.getRoster().front().rank == "Base" and counter < 2:
			counter += 1
		else:
			ret.append(unit)
	return ret

## If threatening enemy connections outweigh this settlement, calls in
## reinforcement convoys from all connected enemy settlements.
func overwhelmCheck() -> void:
	var weight: int = getWeight()
	var theirWeight: int = 0
	for settlement in connections:
		if settlement.getTeam() != team:
			theirWeight += settlement.getAttackWeight()
		if theirWeight >= weight:
			for connection in connections:
				if connection.getTeam() != team:
					var guy: Convoy = connection.spawnConvoy(self)
					guy.source = "Overwhelm"
			update()
			break

## Resolves a fight for control of this settlement between the incoming
## `attackers` and whatever is currently garrisoned here.
func invade(attackers: Array[Unit]) -> void:
	var defenders: Array[Unit] = getRoster().duplicate()
	appendRoster(attackers)

	var combat = load("res://Scenes/Menus/Combat.tscn").instantiate()
	get_node("/root/Main").add_child(combat)
	var newRosters = await combat.populate(attackers, defenders)

	EntityUtils.pruneEmptyUnits(newRosters[0])
	EntityUtils.pruneEmptyUnits(newRosters[1])

	# Any surviving losers retreat to a connected friendly settlement, if one exists.
	# (If not, they've been cornered and destroyed — nothing further to do.)
	if !newRosters[1].is_empty():
		for settlement in getConnections():
			if settlement.getTeam() == newRosters[1].front().getTeam():
				var convoy: Convoy = load("res://Scenes/Entities/Convoy.tscn").instantiate()
				get_parent().get_node("Convoys").add_child(convoy)
				convoy.source = "Invasion Retreat"
				convoy.setConvoy(newRosters[1], self, settlement)
				convoy.move()
				break

	roster = newRosters[0]
	combat.queue_free()
	update()

## Strips any freed unit references from this settlement's roster.
func cleanup() -> void:
	EntityUtils.pruneInvalid(roster)

## Refreshes this settlement's owning team and visuals based on its
## current roster.
func update() -> void:
	for unit in getRoster():
		unit.setLocation(self)
	get_node("Label").text = str(roster.size())

	if getRoster().is_empty():
		team = "Unowned"
		get_node("TextureRect").set_texture(load("res://Assets/locational/unowned.png"))
	else:
		setTeam(getRoster().front().getTeam())
		# All non-Imperium teams currently share the same "hostile" icon.
		var texturePath: String = "res://Assets/locational/Imperium.png" if team == "Imperium" else "res://Assets/locational/Bad.png"
		get_node("TextureRect").set_texture(load(texturePath))

## -- Getters and Setters --
func getConnections() -> Dictionary:
	return connections
func getType() -> String:
	return type
func setType(val: String) -> void:
	type = val

func getWeight() -> int:
	var n: int = 0
	for unit in getRoster():
		n += unit.getWeight()
	return n

## Attack weight excludes the first two roster units (the "Base" garrison
## units spawnConvoy()/allButTwo() always leave behind), since those don't leave to attack.
func getAttackWeight() -> int:
	var units := getRoster()
	var n: int = 0
	for i in range(2, units.size()):
		n += units[i].getWeight()
	return n

func _to_string() -> String:
	return title
