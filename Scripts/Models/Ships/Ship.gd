extends Model
class_name Ship

var roster: Array[Unit] = []
var capacity: int = 250
var assaultLimit: int = 100
var acted = false

func turn():
	acted = false

func disembark():
	if acted or roster.is_empty():
		return
	acted = true
	
	var priorityPlanets: Array[Planet] = []
	var assaultPlanet = null
	for loc in location.getPlanets():
		if loc.presentTeams.has(getTeam()) and !loc.compliant:
			priorityPlanets.append(loc)
		elif !loc.compliant:
			if assaultPlanet:
				if assaultPlanet.getBalance(getTeam()) < loc.getBalance(getTeam()):
					assaultPlanet = loc
			else:
				assaultPlanet = loc
	
	var targetPlanet: Planet
	if !priorityPlanets.is_empty():
		var mostNeed: int = 999999999
		for loc in priorityPlanets:
			var val = loc.getBalance(getTeam())
			if val < mostNeed and !loc.compliant:
				targetPlanet = loc
				mostNeed = val
	else:
		targetPlanet = assaultPlanet
	
	var targetSettlement = pickStarport(targetPlanet)
	if targetSettlement.getTeam() == getTeam():
		for unit in getRoster():
			unit.setLocation(targetSettlement)
	else:
		var force = []
		var forceSize = 0
		for unit in getRoster():
			var unitSize = unit.getSize()
			if unitSize + forceSize <= assaultLimit:
				forceSize += unitSize
				force.append(unit)
		location.assaultUnits[getTeam()].append_array(force)
		location.assaultTarget[getTeam()] = targetSettlement

func embark():
	if acted:
		return
	acted = true
	
	var rCap = getRemainingCapacity()
	for unit in location.availableUnits[getTeam()]:
		var size = unit.getSize()
		if size + rCap <= getCapacity():
			location.availableUnits[getTeam()].erase(unit)
			unit.setLocation(self)
			rCap += size
		if rCap == getCapacity():
			break

func pickStarport(planet: Planet) -> Settlement:
	var target: Settlement
	for starport in planet.starports:
		if starport.getTeam() == getTeam():
			return starport
		else: target = starport
	return target

func _ready() -> void:
	generateTitle(Names.shipNames)

func setLocation(val) -> void:
	if location:
		location.getRoster().erase(self)
	val.getShips().append(self)
	location = val

func getRoster() -> Array[Unit]:
	for guy in range(roster.size() -1,-1,-1):
		if !is_instance_valid(roster[guy]):
			roster.erase(roster[guy])
	return roster

func getCapacity() -> int:
	return capacity

func getRemainingCapacity() -> int:
	var total: int = 0
	for guy in getRoster():
		total += guy.getSize()
	return capacity - total

func _to_string() -> String:
	return title + " (" + str(capacity-getRemainingCapacity()) + "/" + str(capacity) + ")" 
