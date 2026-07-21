extends RefCounted
class_name SectorUtils
## A utility script for the whole Sector

## Gathers explore-route candidates across every planet in the batch,
## computes them all in one parallel pass, then hands back a dictionary
## keyed by settlement. Same read-only safety argument as before, just
## applied sector-wide instead of per-planet.
class RouteResult:
	var route: Array[Settlement] = []

static func precomputeAllExploreRoutes(allPlanets: Array[Planet]) -> Dictionary:
	var candidates: Array[Settlement] = []
	var searchSpaces: Array[Array] = [] # candidate[i]'s own planet's settlement list

	for planet in allPlanets:
		if planet.compliant:
			continue
		for settlement in planet.settlements:
			if settlement.team == "Unowned" or !settlement.inner:
				continue
			if settlement.getRoster().size() <= 2:
				continue
			var hasUnownedNeighbor := false
			for neighbor in settlement.getConnections():
				if neighbor.getTeam() == "Unowned":
					hasUnownedNeighbor = true
					break
			if !hasUnownedNeighbor:
				candidates.append(settlement)
				searchSpaces.append(planet.settlements)

	if candidates.is_empty():
		return {}

	var boxes: Array[RouteResult] = []
	for i in candidates.size():
		boxes.append(RouteResult.new())

	var groupId := WorkerThreadPool.add_group_task(
		func(i): boxes[i].route = PlanetUtils.shortestPath(candidates[i], searchSpaces[i], 50),
		candidates.size()
	)
	WorkerThreadPool.wait_for_group_task_completion(groupId)

	var routes: Dictionary = {}
	for i in candidates.size():
		routes[candidates[i]] = boxes[i].route
	return routes
