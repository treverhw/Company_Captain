extends RefCounted
class_name PlanetUtils
## A utility script for Planets and locations within

static func checkInner(val: Settlement) -> bool:
	var check: bool = true
	for settlement in val.bubble:
		if settlement.team != val.team:
			check = false 
	val.inner = check
	return check

static func getSettlementExcess(val: Settlement) -> Array[Unit]:
	var excess: Array[Unit] = []
	var reserve: Array[Unit] = []
	if val.getRoster().size() <= 2:
		return excess
	
	for unit in val.getRoster():
		if unit.getRole() == "Battleline" and reserve.size() < 2:
			reserve.append(unit)
		else: excess.append(unit)
	if reserve.size() < 2:
		while reserve.size() < 2:
			reserve.append(excess.pop_back())
	return excess
	
static func generateConvoy(force: Array[Unit] = [], destination: Settlement = null, route: Array[Settlement] = []) -> Convoy:
	if force.size() <= 0 or route == []:
		return null
	var exampleUnit: Unit = force[0]
	
	if destination != null:
		if destination.team != exampleUnit.getTeam() and destination.getWeight() >= exampleUnit.getLocation().getAttackWeight() * 1.5:
			return null
			
		if hasActiveConvoyTo(exampleUnit.getLocation(), destination):
			return null

		var convoy: Convoy = load("res://Scenes/Models/Convoy.tscn").instantiate()
		destination.planet.get_node("PlanetMenu/Convoys").add_child(convoy)
		convoy.setConvoy(force, route)
		return convoy
	return null

static func hasActiveConvoyTo(from: Settlement, dest: Settlement) -> bool:
	for convoy in dest.get_parent().get_parent().get_node("Convoys").get_children():
		var route: Array[Settlement] = convoy.getPath()
		if convoy.getTeam() == from.getTeam() and convoy.getHome() == from and !route.is_empty() and route.back() == dest:
			return true
	return false


#region Finding Weakest Settlements
## Finds the weakest settlements for every team present on a planet. 
## Returns A dictionary of [Team: Settlement]
static func updateSettlementTargets(planet: Planet = null):
	updateTeams(planet)
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

static func updateTeams(planet: Planet) -> void:
	planet.presentTeams.clear()
	for settlement in planet.settlements:
		var currTeam = settlement.getTeam()
		if currTeam not in planet.presentTeams and currTeam != "Unowned":
			planet.presentTeams.append(currTeam)

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
	var visited: Dictionary = {}
	for settlement in allSettlements:
		dist[settlement] = 1000
		prev[settlement] = null
	dist[source] = 0

	var heap := MinHeap.new()
	heap.push(0, source)

	while !heap.isEmpty():
		var closestSettlement: Settlement = heap.pop()
		if visited.get(closestSettlement, false):
			continue # stale entry from an earlier relaxation
		visited[closestSettlement] = true

		if closestSettlement == dest:
			break

		# Only continue routing onward through our own territory -- the
		# final hop onto `target` is still allowed even if it isn't ours.
		if closestSettlement != source and closestSettlement.team != source.getTeam():
			continue

		for settlement in closestSettlement.getConnections():
			var stepCost: int = floor(settlement.distance(closestSettlement, settlement) / speed)
			var newDist: int = dist[closestSettlement] + stepCost
			if newDist < dist.get(settlement, 1000):
				dist[settlement] = newDist
				prev[settlement] = closestSettlement
				heap.push(newDist, settlement)

	if dist.get(source, 1000) >= 1000:
		return []

	var route: Array[Settlement] = []
	var node: Settlement = dest
	while node != null:
		route.push_front(node)
		node = prev[node]
	return route

static func shortestPath(source: Settlement, settlements: Array[Settlement], speed: int = 50) -> Array[Settlement]:
	var dist: Dictionary = {}
	var prev: Dictionary = {}
	var visited: Dictionary = {}
	for settlement in settlements:
		dist[settlement] = 1000
		prev[settlement] = null
	dist[source] = 0

	var heap := MinHeap.new()
	heap.push(0, source)

	while !heap.isEmpty():
		var closestSettlement: Settlement = heap.pop()
		if visited.get(closestSettlement, false):
			continue
		visited[closestSettlement] = true

		for settlement in closestSettlement.getConnections():
			var stepCost: int = floor(settlement.distance(closestSettlement, settlement) / speed)
			var newDist: int = dist[closestSettlement] + stepCost
			if newDist < dist.get(settlement, 1000):
				dist[settlement] = newDist
				prev[settlement] = closestSettlement
				heap.push(newDist, settlement)

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
