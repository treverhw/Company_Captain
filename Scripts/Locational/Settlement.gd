extends Location
class_name Settlement

var connections: Dictionary = {}
var type: String
var newUnitCounter: int = 0
var threatened: bool = false
var shuttles: Array[Shuttle] = []
var threatRatio: float = 1.2
var overwhelmingRatio: float = 1.5
var planet: Planet

## Strategic-AI staging commitment (see Planet._runStrategicAIForTerritory()):
## once this settlement is chosen as a staging point against `committedTarget`,
## it sticks with that target for `commitmentTurnsLeft` more turns rather than
## re-evaluating the weakest-enemy search every turn.
var committedTarget: Settlement = null
var commitmentTurnsLeft: int = 0

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
## Finds the shortest connection-graph route (in turns, at the given speed)
## from `source` to a specific `target`, routing only through `source`'s
## own friendly territory along the way -- the final hop onto `target`
## itself is allowed even when `target` isn't ours, since that's often the
## whole point (an attack, or claiming unowned land). Returns an empty
## array if `target` isn't reachable that way.
func pathTo(target: Settlement, allSettlements: Array[Settlement], speed: int = 50, source: Settlement = self) -> Array[Settlement]:
	var dist: Dictionary = {}
	var prev: Dictionary = {}
	var queue: Array[Settlement] = []
	for settlement in allSettlements:
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
		if closestSettlement == null:
			break
		queue.erase(closestSettlement)
		if closestSettlement == target:
			break
		# Only continue routing onward through our own territory -- the
		# final hop onto `target` is still allowed even if it isn't ours.
		if closestSettlement != source and closestSettlement.team != team:
			continue
		for settlement in closestSettlement.getConnections():
			var stepCost: int = floor(distance(closestSettlement, settlement) / speed)
			if dist[settlement] >= 1000 or dist[closestSettlement] + stepCost < dist[settlement]:
				dist[settlement] = dist[closestSettlement] + stepCost
				prev[settlement] = closestSettlement

	if dist.get(target, 1000) >= 1000:
		return []

	var route: Array[Settlement] = []
	var node: Settlement = target
	while node != null:
		route.push_front(node)
		node = prev[node]
	return route

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

	ModelUtils.mergeUnits(getRoster())

	newUnitCounter += 1
	if newUnitCounter >= 10:
		roster.append(spawn())
		newUnitCounter = 0

	# All teams now run the centralized strategic AI (see
	# Planet.runStrategicAI()), which handles defense and offense for the
	# whole team at once each planet turn, so settlements only handle their
	# own reinforcement spawning here.
	update()

func spawnConvoy(destination: Settlement = null) -> Convoy:
	if getRoster().size() <= 2:
		return Convoy.new()

	# Directed movement (e.g. from overwhelmCheck(), or Planet.runStrategicAI()
	# reinforcing a friendly settlement) skips shortestPath(), so an attack
	# on an enemy needs its own copy of the "don't attack an overwhelming
	# target" check. Reinforcing a friendly destination is exempt -- that's
	# not an attack.
	if destination != null:
		if destination.team != team and destination.getWeight() >= getAttackWeight() * 1.5:
			return Convoy.new()
		# Only one convoy at a time between this settlement and a given
		# final destination, so reinforcement doesn't keep restacking a
		# route before the last wave has even arrived.
		if _hasActiveConvoyTo(destination):
			return Convoy.new()

	var convoy: Convoy = load("res://Scenes/Entities/Convoy.tscn").instantiate()
	get_parent().get_node("Convoys").add_child(convoy)
	var toGo: Array[Unit] = defenseForce()
	# NOTE: there was previously a guard here returning early if toGo was
	# empty; it's commented out as of SystemMap, so left disabled here too —
	# flagged separately since a zero-unit convoy looks possible as a result.

	# Convoys travel via the connection graph -- through our own territory
	# on the way, for a directed destination -- rather than flying straight
	# to wherever they're headed.
	var route: Array[Settlement]
	if destination != null:
		route = pathTo(destination, get_parent().get_parent().settlements, convoy.speed)
	else:
		# Automatic movement: send the convoy toward the nearest threat.
		route = shortestPath(get_parent().get_parent().settlements, convoy.speed)
	if route.size() < 2:
		convoy.kill()
		return Convoy.new()

	convoy.setConvoy(toGo, route)
	
	convoy.add_to_group(get_parent().get_parent().title + "_convoy")

	for unit in toGo:
		getRoster().erase(unit)
	update()
	return convoy

## True if there's already a friendly convoy from this settlement en route
## to `dest` as its final destination (not just its current hop) -- used to
## keep spawnConvoy() from stacking a second convoy on the same route
## before the first one has arrived.
func _hasActiveConvoyTo(dest: Settlement) -> bool:
	for convoy in get_parent().get_node("Convoys").get_children():
		var route: Array[Settlement] = convoy.getPath()
		if convoy.getTeam() == team and convoy.getHome() == self and !route.is_empty() and route.back() == dest:
			return true
	return false
	
func defenseForce() -> Array[Unit]:
	var toGo: Array[Unit] = []
	var threatWeight = getThreatWeight()
	if threatWeight == 0:
		toGo = allButTwo()
	else:
		var defenseWeight = 0
		for unit in roster:
			if defenseWeight < threatWeight:
				defenseWeight += unit.getWeight()
			else: toGo.append(unit)
	return toGo

## Every roster unit except the first two "Base" rank units, which stay
## behind to hold the settlement. Shared by spawnConvoy() and
## Planet.getExcess() (for shuttles picking up units to ferry).
func allButTwo() -> Array[Unit]:
	var counter: int = 0
	var ret: Array[Unit] = []
	for unit in getRoster():
		if unit.getRoster().front().role == "Battleline" and counter < 2:
			counter += 1
		else:
			ret.append(unit)
	return ret

## If threatening enemy connections outweigh this settlement, pools available
## units from every such connection into a single combined convoy — so
## several individually-weak neighbors attack together as one force instead
## of arriving piecemeal and losing a series of outnumbered fights.
func overwhelmCheck() -> void:
	var weight: int = getWeight()
	var theirWeight: int = 0
	for settlement in connections:
		if settlement.getTeam() != team:
			theirWeight += settlement.getAttackWeight()
		if theirWeight >= weight:
			_summonOverwhelmingForce()
			break

## Gathers every connected enemy settlement's available units (via
## allButTwo()) into one convoy aimed at this settlement, departing from
## whichever contributing settlement is closest.
func _summonOverwhelmingForce() -> void:
	var pooled: Array[Unit] = []
	var rallyPoint: Settlement = null
	var rallyDist: float = INF
	for connection in connections:
		if connection.getTeam() == team:
			continue
		var contribution: Array[Unit] = connection.allButTwo()
		if contribution.is_empty():
			continue
		pooled.append_array(contribution)
		for unit in contribution:
			connection.getRoster().erase(unit)
		connection.update()
		var d: float = distance(connection, self)
		if d < rallyDist:
			rallyDist = d
			rallyPoint = connection

	if pooled.is_empty() or rallyPoint == null:
		return

	var convoy: Convoy = load("res://Scenes/Entities/Convoy.tscn").instantiate()
	get_parent().get_node("Convoys").add_child(convoy)
	convoy.source = "Overwhelm"
	convoy.setConvoy(pooled, [rallyPoint, self])
	update()

## Resolves a fight for control of this settlement between the incoming
## `attackers` and whatever is currently garrisoned here.
func invade(attackers: Array[Unit]) -> void:
	var defenders: Array[Unit] = getRoster().duplicate()
	appendRoster(attackers)

	var combat = load("res://Scenes/Menus/Combat.tscn").instantiate()
	get_node("/root/Main").add_child(combat)
	var newRosters = await combat.populate(attackers, defenders)

	#0 is always the winner of the fight, 1 is always the loser.
	ModelUtils.pruneEmptyUnits(newRosters[0])
	ModelUtils.pruneEmptyUnits(newRosters[1])
	ModelUtils.mergeUnits(newRosters[0])

	# Any surviving losers retreat to a connected friendly settlement, if one exists.
	# (If not, they've been cornered and destroyed — nothing further to do.)
	if !newRosters[1].is_empty():
		ModelUtils.mergeUnits(newRosters[1])
		for settlement in getConnections():
			if settlement.getTeam() == newRosters[1].front().getTeam():
				var convoy: Convoy = load("res://Scenes/Entities/Convoy.tscn").instantiate()
				get_parent().get_node("Convoys").add_child(convoy)
				convoy.source = "Invasion Retreat"
				convoy.setConvoy(newRosters[1], [self, settlement])
				convoy.move()
				break

	roster = newRosters[0]
	combat.queue_free()
	update()

## Strips any freed unit references from this settlement's roster.
func cleanup() -> void:
	ModelUtils.pruneInvalid(roster)

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
func setType(val: String) -> void:
	type = val
	
func getConnections() -> Dictionary:
	return connections
func getType() -> String:
	return type

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
	
func getThreatWeight() -> int:
	var n = 0
	for settlment in getConnections():
		if settlment.getTeam() != getTeam():
			n += settlment.getWeight()
	return n

func _to_string() -> String:
	return title


func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var units = "["
		for unit in getRoster():
			units += "\n" + unit.title + "\n"
			for model in unit.getRoster():
				units += model.to_string() + "\n	"
				var weapons = model.getActiveWeapons(-1)
				units += model.getActiveWeapons(-1)[0].title + " | " + model.getActiveWeapons(-1)[1].title + "\n"
		units += "]"
		print(units)
