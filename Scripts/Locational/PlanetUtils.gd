extends RefCounted
class_name PlanetUtils
## A utility script for Planets and locations within

static func checkInner(val: Settlement) -> bool:
	var check: bool = true
	for settlement in val.bubble:
		if settlement.faction != val.faction:
			check = false 
	val.inner = check
	return check

static func getSettlementExcess(val: Settlement) -> Array[Unit]:
	var excess: Array[Unit] = []
	var reserve: Array[Unit] = []
	if val.getRoster().size() <= 2:
		return excess
	
	for unit in val.getRoster():
		if unit.role == "Battleline" and reserve.size() < 2:
			reserve.append(unit)
		else: excess.append(unit)
	if reserve.size() < 2:
		while reserve.size() < 2:
			reserve.append(excess.pop_back())
	return excess
	
static func generateConvoy(force: Array[Unit] = [], destination: Settlement = null, route: Array[Settlement] = []) -> Convoy:
	if force.size() <= 0 or route == []:
		return Convoy.new()
	var exampleUnit: Unit = force[0]
	
	if destination != null:
		if destination.team != exampleUnit.getTeam() and destination.getWeight() >= exampleUnit.getLocation().getAttackWeight() * 1.5:
			return Convoy.new()
			
		if hasActiveConvoyTo(exampleUnit.getLocation(), destination):
			return Convoy.new()

	var convoy: Convoy = load("res://Scenes/Models/Convoy.tscn").instantiate()
	destination.getParent().get_node("Convoys").add_child(convoy)
	convoy.setConvoy(force, route)
	return convoy

static func hasActiveConvoyTo(from: Settlement, dest: Settlement) -> bool:
	for convoy in dest.get_parent().get_node("Convoys").get_children():
		var route: Array[Settlement] = convoy.getPath()
		if convoy.getTeam() == from.getTeam() and convoy.getHome() == from and !route.is_empty() and route.back() == dest:
			return true
	return false


#region Finding Weakest Settlements
## Finds the weakest settlements for every team present on a planet. 
## Returns A dictionary of [Team: Settlement]
static func generateWeakestSettlements(planet: Planet = null):
	var weakestSettlements: Dictionary[String, Settlement] = {}
	var weakestEnemies: Dictionary[String, Settlement] = {}
	if planet:
		for team in planet.presentTeams:
			weakestSettlements[team] = getWeakestOuter(team, planet.settlements)
			weakestEnemies[team] = getWeakestOuter(team, planet.settlements, true)
	planet.weakest = weakestSettlements
	planet.targets = weakestEnemies

## Please finish me
## Takes the team and planets settlements and finds the weakest settlement of that team. 
## Takes a bool that can be set to true if you want it to find the teams, enemies, weakest settlement
static func getWeakestOuter(team: String, settlements: Array[Settlement], enemy: bool = false) -> Settlement:
	var weakestSettlement: Settlement = null
	var weakestWeight: int = 9223372036854775807
	var outerSettlements: Array[Settlement] = []
	
	if !enemy: 	outerSettlements = getOuterSettlements(team, settlements)
	else:		outerSettlements = getEnemyOuterSettlements(team, settlements)
	
	for settlement in outerSettlements:
		if settlement.getWeight() < weakestWeight:
			weakestSettlement = settlement
	
	return weakestSettlement
	#sort_custom(func(a, b): return )

static func getOuterSettlements(team: String, settlements: Array[Settlement]) -> Array[Settlement]:
	var ret: Array[Settlement] = []
	for settlement in settlements:
		if settlement.getTeam() == team and !settlement.inner: 
			ret.append(settlement)
	return ret

static func getEnemyOuterSettlements(team: String, settlements: Array[Settlement]) -> Array[Settlement]:
	var ret: Array[Settlement] = []
	for settlement in settlements:
		var enemyValid: bool = false
		#Check if the enemy outer settlement actually has a neighbor to us.
		for neighbor in settlement.getConnections():
			if settlement.getTeam() != team and neighbor.getTeam() == team:
				enemyValid = true
				break
		if !settlement.inner and settlement.getConnections() and enemyValid: 
			ret.append(settlement)
	return ret

#region end

#region Pathfinding
## Finds the shortest path (measured in turns at the given speed) from
## `source` to the nearest settlement that isn't already ours, using
## Dijkstra's algorithm over the settlement connection graph.
## Finds the shortest connection-graph route (in turns, at the given speed)
## from `source` to a specific `target`, routing only through `source`'s
## own friendly territory along the way -- the final hop onto `target`
## itself is allowed even when `target` isn't ours, since that's often the
## whole point (an attack, or claiming unowned land). Returns an empty
## array if `target` isn't reachable that way.
static func pathTo(source: Settlement, dest: Settlement, allSettlements: Array[Settlement], speed: int = 50) -> Array[Settlement]:
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
		if closestSettlement == dest:
			break
		# Only continue routing onward through our own territory -- the
		# final hop onto `target` is still allowed even if it isn't ours.
		if closestSettlement != source and closestSettlement.team != source.getTeam():
			continue
		for settlement in closestSettlement.getConnections():
			var stepCost: int = floor(settlement.distance(closestSettlement, settlement) / speed)
			if dist[settlement] >= 1000 or dist[closestSettlement] + stepCost < dist[settlement]:
				dist[settlement] = dist[closestSettlement] + stepCost
				prev[settlement] = closestSettlement

	if dist.get(source, 1000) >= 1000:
		return []

	var route: Array[Settlement] = []
	var node: Settlement = source
	while node != null:
		route.push_front(node)
		node = prev[node]
	return route

static func shortestPath(source: Settlement, settlements: Array[Settlement], speed: int = 50) -> Array[Settlement]:
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
			var stepCost: int = floor(settlement.distance(closestSettlement, settlement) / speed)
			if dist[settlement] >= 1000 or dist[closestSettlement] + stepCost < dist[settlement]:
				dist[settlement] = dist[closestSettlement] + stepCost
				prev[settlement] = closestSettlement

	# Find the nearest settlement that isn't already ours.
	var path: Array[Settlement] = []
	var target: Settlement = source
	var bestDistance: int = 1000
	for settlement in settlements:
		if dist[settlement] < bestDistance and settlement.team == "Unowned":
			target = settlement
			bestDistance = dist[settlement]
	
	while target != null:
		path.push_front(target)
		target = prev[target]
	return path

#region end
