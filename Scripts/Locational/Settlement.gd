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
	generateTitle(Names.new().planetNames)
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
			roster.append(spawn())
			newUnitCounter = 0

		ModelUtils.mergeUnits(getRoster())

		if getRoster().size() > 2:
			if planet.compliant: exportState()
			elif inner: exploreState(precomputedExploreRoute)
			else: combatState()

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
		var route: Array[Settlement] = precomputedRoute if !precomputedRoute.is_empty() else PlanetUtils.shortestPath(self, planet.getSettlements(), 50)
		if !route.is_empty():
			PlanetUtils.generateConvoy(excess, route[route.size() - 1], route)
	if getRoster().size() > 2:
		combatState()

## When there are enemy settlements in the settlements bubble, they're in combat mode.
## In this state, they prioritize fortifying the frontline and then rallying to attack.
func combatState(options: Array[Settlement] = []):
	
	if planet.targets[team] in getConnections() and planet.targets[team].getWeight() * 1.5 < getAttackWeight():
		PlanetUtils.generateConvoy(allButTwo(), planet.targets[team], [self, planet.targets[team]])
	
	## Find the weakest outer settlement
	var weakest: Settlement = planet.weakest[getTeam()]
	var excess = PlanetUtils.getSettlementExcess(self)
	if weakest:
		var route = PlanetUtils.pathTo(self, weakest, planet.settlements, 50)
		PlanetUtils.generateConvoy(excess, weakest, route)
		return
	
	## Check for adjacent unowned settlements
	for settlement in getConnections():
		if settlement.getTeam() == "Unowned":
			options.append(settlement)
	if options.size() > 0:
		options.sort_custom(func(a,b): return a.getThreatWeight() < b.getThreatWeight())
		var route = PlanetUtils.pathTo(self, options[0], planet.getSettlements(), 50)
		PlanetUtils.generateConvoy(excess, options[0], route)
	else: #Rally instead 
		var target = planet.targets[getTeam()]
		if target:
			var route = PlanetUtils.shortestPath(self, planet.settlements, 50)
			PlanetUtils.generateConvoy(excess, target, route)
		#enemyOuterSettlements = {}
	update()

## Once the whole planet is under control, all settlements go into export state.
## In this state, they prioritize spreading their force across the planet and piling into shuttles
## for the next battle. 
func exportState():
	pass
	
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

	var convoy: Convoy = load("res://Scenes/Models/Convoy.tscn").instantiate()
	get_parent().get_parent().get_node("Convoys").add_child(convoy)
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
				var convoy: Convoy = load("res://Scenes/Models/Convoy.tscn").instantiate()
				get_parent().get_parent().get_node("Convoys").add_child(convoy)
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
				units += weapons[0].title + " | " + weapons[1].title + "\n"
		units += "]"
		print(units)
