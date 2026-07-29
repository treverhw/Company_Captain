extends Location
class_name Settlement

var connections: Dictionary = {}
var type: String
var newUnitCounter: int = 0
var threatRatio: float = 1.2
var overwhelmingRatio: float = 1.5
var planet: Planet
var inner: bool
var bubble: Array[Settlement]

## Strategic-AI staging commitment (see Planet._runStrategicAIForTerritory()):
## once this settlement is chosen as a staging point against `committedTarget`,
## it sticks with that target for `commitmentTurnsLeft` more turns rather than
## re-evaluating the weakest-enemy search every turn.
var committedTarget: Settlement = null
var commitmentTurnsLeft: int = 0

func appendRoster(arr: Array[Unit]) -> void:
	for unit in arr:
		if is_instance_valid(unit):
			unit.setLocation(self)
	update()

func _ready() -> void:
	generateTitle(Names.planetNames)
	get_node("Name").text = name

## Picks a reinforcement from the first non-player faction represented in
## this settlement's roster (the player spawns/crews units manually via ships).
func spawn() -> Unit:
	for unit in roster:
		var owner: Faction = unit.getRoster().front().getFaction()
		if owner is not PlayerFaction:
			return owner.spawnBase()
	return null

## Per-turn upkeep: reinforcements, threat assessment, and automatic
## convoy dispatch when this settlement isn't under threat
func turn(precomputedExploreRoute: Array[Settlement] = []) -> void:
	if team != "Unowned":
		newUnitCounter += 1
		if newUnitCounter >= 10:
			spawn().setLocation(self)
			newUnitCounter = 0
		
		#ModelUtils.mergeUnits(getRoster())
		
		var freeze = false
		for convoy in planet.getConvoys():
			if convoy.getTeam() != getTeam() and convoy.destination == self:
				#print(str(title)  + " on planet " + str(planet) + " is frozen.")
				freeze = true
		
		if getRoster().size() > 2 and !freeze:
			if planet.compliant: 
				#print(str(title)  + " on planet " + str(planet) + " is in Export State.")
				exportState()
			elif inner: 
				#print(str(title)  + " on planet " + str(planet) + " is in Explore State.")
				exploreState(precomputedExploreRoute)
			else: 
				#print(str(title)  + " on planet " + str(planet) + " is in Combat State.")
				combatState()
	
	update()

## TODO: Reformat the "Overwhelm check, so that its run before state-setting 
## and then those settlements are excluded from the state rotation. 

## TODO: Right now, each settlement makes a shit ton of repeat calculations
## gonna make a dictionary in Planet that tracks the weakest outer for each team.

## When there are no enemy settlements in the settlements bubble, they're in explore mode.
## In this state, they prioritize populating unowned settlements.
## When this primary function is fulfilled, they then proceed to the combat state.
func exploreState(precomputedRoute: Array[Settlement] = []) -> void:
	var options: Array[Settlement] = []
	var excess: Array[Unit] = PlanetUtils.getSettlementExcess(self)
	for settlement in getConnections():
		if settlement.getTeam() == "Unowned":
			options.append(settlement)

	if options.size() > 1:
		var split = floor(excess.size() / options.size())
		for settlement in options:
			var force: Array[Unit] = []
			for i in range(split):
				force.append(excess.pop_back())
			PlanetUtils.generateConvoy(force, settlement, [self, settlement])
	elif options.size() == 1:
		PlanetUtils.generateConvoy(excess, options[0], [self, options[0]])
	else:
		var route: Array[Settlement] = precomputedRoute if !precomputedRoute.is_empty() else PlanetUtils.shortestPath(self, planet.getSettlements(), 25)
		if !route.is_empty():
			PlanetUtils.generateConvoy(excess, route[route.size() - 1], route)
	if getRoster().size() > 2:
		combatState()

## When there are enemy settlements in the settlements bubble, they're in combat mode.
## In this state, they prioritize fortifying the frontline and then rallying to attack.
func combatState(options: Array[Settlement] = []):
	
	## Check for neighbor to attack
	if planet.targets[team] in getConnections() and shouldIAttack(planet.targets[team]):
		PlanetUtils.generateConvoy(allButTwo(), planet.targets[team], [self, planet.targets[team]])
	
	## Find the weakest outer settlement
	var outer: Array[Settlement] = PlanetUtils.getOuterSettlements(getTeam(), planet.getSettlements())
	var excess = PlanetUtils.getSettlementExcess(self)
	var weakest: Settlement = null
	for settlement in outer:
		if weakest:
			if settlement.threatened() > weakest.threatened():
				weakest = settlement
		else: 
			if settlement.threatened() > 0:
				weakest = settlement
	if weakest:
		var total: int = 0
		var force: Array[Unit] = []
		var toBeat = weakest.threatened()
		while total < toBeat and !excess.is_empty():
			var unit = excess.pop_back()
			total += unit.getWeight()
			force.append(unit)
		var route = PlanetUtils.pathTo(self, weakest, planet.settlements, 25)
		PlanetUtils.generateConvoy(force, weakest, route)
		return
	
	## Check for adjacent unowned settlements
	for settlement in getConnections():
		if settlement.getTeam() == "Unowned":
			options.append(settlement)
	if options.size() > 0:
		options.sort_custom(func(a,b): return a.getThreatWeight() < b.getThreatWeight())
		var route = PlanetUtils.pathTo(self, options[0], planet.getSettlements(), 25)
		PlanetUtils.generateConvoy(excess, options[0], route)
	else: #Rally instead 
		var target = planet.targets[getTeam()]
		#print(title + " Is Rallying to " + str(target))
		if target:
			var route = PlanetUtils.shortestPath(self, planet.settlements, 25, false)
			#print(title + " " + str(route))
			PlanetUtils.generateConvoy(excess, target, route)
		#enemyOuterSettlements = {}
	update()

## Once the whole planet is under control, all settlements go into export state.
## In this state, they prioritize spreading their force across the planet and piling into shuttles
## for the next battle. 
func exportState():
	var route = PlanetUtils.shortestPath(self, planet.settlements, 25, false, true)
	#print(title + " " + str(route))
	PlanetUtils.generateConvoy(allButTwo(), route.back(), route)

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
func allButTwo() -> Array[Unit]:
	var counter: int = 0
	var ret: Array[Unit] = []
	var limit: int = 2
	if self is Starport:
		limit = 4
	for unit in getRoster():
		if unit.getRoster().front().role == "Battleline" and counter < limit:
			counter += 1
		else:
			ret.append(unit)
	return ret

## Resolves a fight for control of this settlement between the incoming
## `attackers` and whatever is currently garrisoned here.
func invade(convoy: Convoy) -> void:
	var defenders: Array[Unit] = getRoster().duplicate()

	var combat = COMBAT_SCENE.instantiate()
	get_node("/root/Main").add_child(combat)
	
	#0 is always the winner of the fight, 1 is always the loser.
	var newRosters = await combat.populate(convoy.getRoster(), defenders)
	
	ModelUtils.pruneEmptyUnits(newRosters[0])
	ModelUtils.pruneEmptyUnits(newRosters[1])
	
	# Any surviving losers retreat to a connected friendly settlement, if one exists.
	# (If not, they've been cornered and destroyed — nothing further to do.)
	if !newRosters[1].is_empty():
		retreat(newRosters[1])
	
	if newRosters[0].front() in convoy.getRoster():
		convoy.unload(self)
	convoy.cleanup()
	
	combat.queue_free()
	update()

func retreat(force: Array[Unit]) -> Convoy:
	var strongest: Settlement
	for settlement in getConnections():
		if settlement.getTeam() == force.front().getTeam():
			if strongest:
				if strongest.getWeight() < settlement.getWeight(): strongest = settlement
			else: strongest = settlement
	var route = PlanetUtils.pathTo(self, strongest, planet.getSettlements())
	return PlanetUtils.generateConvoy(force, strongest, route)

## Returns a value showing how threatened they are by adjacent settlements
func threatened() -> int:
	var threat: int = 0
	for settlement in getConnections():
		if settlement.getTeam() != getTeam():
			threat += settlement.getAttackWeight()
	threat -= getWeight()
	return threat

## Strips any freed unit references from this settlement's roster.
func cleanup() -> void:
	ModelUtils.pruneInvalid(roster)

## Refreshes this settlement's owning team and visuals based on its
## current roster.
func update() -> void:
	get_node("Label").text = str(roster.size())

	if getRoster().is_empty():
		team = "Unowned"
		get_node("TextureRect").set_texture(UNOWNED_TEX)
	else:
		setTeam(getRoster().front().getTeam())
		# All non-Imperium teams currently share the same "hostile" icon.
		var texturePath: String = "res://Assets/locational/Imperium.png" if team == "Imperium" else "res://Assets/locational/Bad.png"
		get_node("TextureRect").set_texture(load(texturePath))

## -- Getters and Setters --
func setType(val: String) -> void:
	type = val

func setBubble():
	for settlement in getConnections():
		bubble.append(settlement)
		for cousin in settlement.getConnections():
			if !bubble.has(cousin):
				bubble.append(cousin)

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
	var units = getRoster()
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

func shouldIAttack(dest: Settlement) -> bool:
	var total = 0
	for convoy: Convoy in planet.getConvoys():
		if convoy.destination == dest:
			total += convoy.getWeight()
	return getAttackWeight() > 1.5 * (total + dest.getWeight())

func _to_string() -> String:
	return title

func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var units = "["
		for unit in getRoster():
			units += "\n" + unit.title + "\n---------------------------------------------------------\n"
			for model: Model in unit.getRoster():
				units += model.to_string() + "\n	"
				var weapons = model.weapons
				units += weapons[0].title + " | " + weapons[1].title + " | " + str(model.armour) + "\n"
		print(units)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		print("---------------------------------------------------------")
		print(title + " Total Attack: " + str(getAttackWeight()))
		print(title + " Total weight: " + str(getWeight()))
