extends Location
class_name Planet
## One planet within a System: generates a field of settlements, links them
## into a connected graph, and runs the per-turn simulation loop.

var settlements: Array[Settlement]
var balance: int
var weakest: Dictionary[String, Settlement] = {} # Team -> Weakest Settlement
var targets: Dictionary[String, Settlement] = {} # Team -> Weakest Enemy Settlement

func _ready() -> void:
	global_position = Vector2((1920 / 2), (1080 / 2))
	generateTitle(Names.new().planetNames)
	get_node("PlanetMenu/Label").text = title
	get_node("PlanetNode/Label").text = title

	_generateSettlements()
	_spawnStartingForces()
	await createConnections()
	_connectRemainingSettlements()
	update()

func _generateSettlements() -> void:
	for n in range(randi_range(16, 25)):
		var newSettlement = load("res://Scenes/Locational/Settlement.tscn").instantiate()
		newSettlement.global_position = Vector2(randi_range(-450, 450), randi_range(-250, 250))
		var counter := 0
		while !validateDistance(newSettlement, settlements, 125) and counter != 100:
			counter += 1
			newSettlement.global_position = Vector2(randi_range(-450, 450), randi_range(-250, 250))
		if counter == 100:
			break
		get_node("PlanetMenu").add_child(newSettlement)
		settlements.append(newSettlement)
		newSettlement.planet = self

## Scatters starting Guard garrisons across 3-7 random settlements, and
## Chaos garrisons across 2-5 random non-Imperium-owned settlements.
func _spawnStartingForces() -> void:
	var main = get_node("/root/Main/")
	for n in randi_range(3, 7):
		var guardForce: Array[Unit] = main.getFaction("guard").start()
		var settlement: Settlement = settlements[randi_range(0, settlements.size() - 1)]
		settlement.appendRoster(guardForce)
	for n in randi_range(2, 5):
		var chaosForce: Array[Unit] = main.getFaction("chaos").start()
		var num := randi_range(0, settlements.size() - 1)
		while settlements[num].getTeam() == "Imperium":
			num = randi_range(0, settlements.size() - 1)
		settlements[num].appendRoster(chaosForce)

## Ensures every settlement is reachable: repeatedly finds whichever
## disconnected settlement is nearest to the already-connected group and
## links it in, until the whole graph is connected.
func _connectRemainingSettlements() -> void:
	var unconnected: Array[Settlement] = []
	var connected: Array[Settlement] = []
	while connected.size() != settlements.size():
		unconnected = settlements.duplicate()
		connected = [unconnected.pop_front()]

		# Flood-fill outward from `connected` along existing connections.
		for i in 20:
			for settlement in connected:
				for neighbor in settlement.getConnections():
					if neighbor in unconnected:
						unconnected.erase(neighbor)
						connected.append(neighbor)

		if unconnected.size() > 1:
			# Find the closest (unconnected, connected) settlement pair.
			var nearestConnected: Dictionary = {}
			for candidate in unconnected:
				nearestConnected[candidate] = [candidate, 4000.0]
				for target in connected:
					var length: float = distance(candidate, target)
					if length < nearestConnected[candidate][1]:
						nearestConnected[candidate] = [target, length]

			var bestLink: Array = [null, null, 4000.0]
			for candidate in nearestConnected:
				if nearestConnected[candidate][1] < bestLink[2]:
					bestLink[0] = candidate
					bestLink[1] = nearestConnected[candidate][0]
					bestLink[2] = nearestConnected[candidate][1]

			bestLink[0].getConnections()[bestLink[1]] = bestLink[2]
			bestLink[1].getConnections()[bestLink[0]] = bestLink[2]

			var newLine := Line2D.new()
			newLine.width = 3
			newLine.add_point(bestLink[0].position)
			newLine.add_point(bestLink[1].position)
			get_node("PlanetMenu").add_child(newLine)
			generateBubbles()

func generateBubbles() -> void:
	for settlement in settlements:
		var neighbors: Array[Settlement] = settlement.getNeighbors()
		var bubble: Array[Settlement] = neighbors
		for cousin in neighbors:
			bubble += cousin.getNeighbors()
		settlement.bubble = bubble
		 

## True (and cached in `compliant`) when every settlement is owned by the same team.
func compliance() -> bool:
	var teams: Array[String] = []
	for settlement in settlements:
		if !teams.has(settlement.team):
			teams.append(settlement.team)
	compliant = teams.size() <= 1
	return compliant

func turn() -> void:
	await cleanup()
	update()
	compliance()

	for settlement in settlements:
		PlanetUtils.checkInner(settlement)
		await settlement.turn()
		await cleanup()
	var convoys = get_node("PlanetMenu/Convoys").get_children()
	for convoy in convoys:
		await convoy.move()
		await cleanup()

	# Convoys fight if they end up near each other.
	convoys = get_node("PlanetMenu/Convoys").get_children()
	var alreadyFought: Array[Convoy] = []
	for convoy in convoys:
		var bodies: Array[Node2D] = convoy.get_node("VisionRange").get_overlapping_bodies()
		for body in bodies:
			var otherConvoy = body.get_parent()
			if convoy == otherConvoy or (alreadyFought.has(convoy) and alreadyFought.has(otherConvoy)):
				continue
			await cleanup()
			var facingOff: bool = convoy.getTeam() != otherConvoy.getTeam() and convoy.getDestination() == otherConvoy.getHome()
			if facingOff and !convoy.getRoster().is_empty() and !otherConvoy.getRoster().is_empty():
				alreadyFought.append(convoy)
				alreadyFought.append(otherConvoy)
				await convoyFight(convoy, otherConvoy)
	await cleanup()

	# Run the strategic AI for every team that currently owns territory.
	var activeTeams: Array[String] = []
	for settlement in settlements:
		if settlement.team != "Unowned" and !activeTeams.has(settlement.team):
			activeTeams.append(settlement.team)
	for team in activeTeams:
		runStrategicAI(team)

## Strategic AI for `team`: first tries to bring every settlement bordering
## an enemy up to at least that enemy's combined adjacent weight (pulling
## reinforcements from interior settlements, which have no defensive need
## of their own and so ship out everything beyond their base garrison).
## Once every border settlement meets its target, masses any surplus
## toward whichever border settlement neighbors the enemy's weakest
## settlement, attacking once it can do so with overwhelming force.
## Strategic AI for `team`, run independently per connected chunk of
## territory -- two settlements only coordinate if a friendly-owned path
## connects them (the same reachability a convoy can actually travel), so
## separated pockets each defend their own border and push their own
## weakest adjacent enemy without waiting on or reinforcing each other.
func runStrategicAI(team: String) -> void:
	var owned: Array[Settlement] = []
	for settlement in settlements:
		if settlement.team == team:
			owned.append(settlement)
	if owned.is_empty():
		return

	for territory in _splitIntoTerritories(owned):
		_runStrategicAIForTerritory(team, territory)

## Splits `owned` into independent connected chunks, using only
## friendly-to-friendly connections as edges (matching what pathTo() can
## actually route through). Two settlements land in the same chunk only
## if a friendly-owned path connects them.
func _splitIntoTerritories(owned: Array[Settlement]) -> Array:
	var remaining: Array[Settlement] = owned.duplicate()
	var territories: Array = []
	while !remaining.is_empty():
		var chunk: Array[Settlement] = [remaining.pop_front()]
		var frontier: Array[Settlement] = [chunk[0]]
		while !frontier.is_empty():
			var current: Settlement = frontier.pop_back()
			for neighbor in current.getConnections():
				if neighbor in remaining:
					remaining.erase(neighbor)
					chunk.append(neighbor)
					frontier.append(neighbor)
		territories.append(chunk)
	return territories

func _runStrategicAIForTerritory(team: String, owned: Array[Settlement]) -> void:
	# Classify: border settlements have at least one enemy-owned neighbor,
	# and want enough weight to match that neighbor's combined weight.
	# Interior settlements have no such need (target 0) and exist purely to
	# reinforce the border. `threatened` (used elsewhere, e.g. by Shuttle's
	# landing-site choice) marks border settlements currently under target.
	var border: Array[Settlement] = []
	var targets: Dictionary = {}
	for settlement in owned:
		var need: int = 0
		for neighbor in settlement.getConnections():
			if neighbor.team != team and neighbor.team != "Unowned":
				need += neighbor.getWeight()
		targets[settlement] = need
		if need > 0:
			border.append(settlement)
			settlement.threatened = settlement.getWeight() < need

	# Defense first: reinforce any border settlement under its target.
	var allSecure := true
	for settlement in border:
		if settlement.getWeight() < targets[settlement]:
			allSecure = false
			_pullReinforcement(settlement, owned, targets)

	# Aggressively capture adjacent unowned territory -- that's where new
	# recruits come from -- using only genuine spare capacity (weight
	# beyond this settlement's own defensive target, if it has one), so
	# this never comes at the expense of an unmet defensive need. Runs
	# regardless of overall defensive status; at most one attempt per
	# settlement per turn.
	for settlement in owned:
		if settlement.getWeight() <= targets[settlement]:
			continue
		for neighbor in settlement.getConnections():
			if neighbor.team == "Unowned":
				settlement.spawnConvoy(neighbor)
				break

	if !allSecure:
		return

	# Defensively secure: stick with an existing staging commitment if this
	# territory still has one active and its target hasn't been resolved
	# (captured or lost) since -- otherwise pick the weakest enemy
	# settlement adjacent to this territory's own border and commit to it
	# for a few turns, so reinforcement has time to actually accumulate
	# there instead of re-targeting (and re-routing convoys) every turn.
	var weakestEnemy: Settlement = null
	var stagingPoint: Settlement = null
	for settlement in border:
		if settlement.commitmentTurnsLeft > 0:
			var committed: Settlement = settlement.committedTarget
			if is_instance_valid(committed) and committed.team != team and committed.team != "Unowned":
				stagingPoint = settlement
				weakestEnemy = committed
				settlement.commitmentTurnsLeft -= 1
				break
			settlement.commitmentTurnsLeft = 0

	if stagingPoint == null:
		for settlement in border:
			for neighbor in settlement.getConnections():
				if neighbor.team != team and neighbor.team != "Unowned":
					if weakestEnemy == null or neighbor.getWeight() < weakestEnemy.getWeight():
						weakestEnemy = neighbor
						stagingPoint = settlement
		if weakestEnemy == null:
			return
		stagingPoint.committedTarget = weakestEnemy
		stagingPoint.commitmentTurnsLeft = 20

	if stagingPoint.getAttackWeight() >= weakestEnemy.getWeight() * 1.5:
		stagingPoint.spawnConvoy(weakestEnemy)
	else:
		_pullReinforcement(stagingPoint, owned, targets)

## Sends a convoy from the nearest settlement in `candidates` (other than
## `target`) with spare capacity -- weight beyond its own entry in
## `targets`, plus at least one unit beyond the mandatory 2-unit garrison
## -- toward `target`. Does nothing if no candidate has anything to spare.
func _pullReinforcement(target: Settlement, candidates: Array[Settlement], targets: Dictionary) -> void:
	var donor: Settlement = null
	var donorDist: float = INF
	for settlement in candidates:
		if settlement == target:
			continue
		var need: int = targets.get(settlement, 0)
		if settlement.getWeight() <= need or settlement.allButTwo().is_empty():
			continue
		var d: float = distance(settlement, target)
		if d < donorDist:
			donorDist = d
			donor = settlement
	if donor != null:
		donor.spawnConvoy(target)

func convoyFight(val1: Convoy, val2: Convoy) -> void:
	await cleanup()
	var combat = load("res://Scenes/Menus/Combat.tscn").instantiate()
	get_node("/root/Main").add_child(combat)

	var newRosters = await combat.populate(val1.getRoster(), val2.getRoster())
	ModelUtils.pruneEmptyUnits(newRosters[0])
	ModelUtils.pruneEmptyUnits(newRosters[1])

	val1.source = "Convoy Fight Retreat"
	val2.source = "Convoy Fight Retreat"

	if val1.getRoster().is_empty():
		val1.kill()
	else:
		await val1.retreatConvoy()
	if val2.getRoster().is_empty():
		val2.kill()
	else:
		await val2.retreatConvoy()
	combat.queue_free()

func cleanup() -> bool:
	for settlement in settlements:
		settlement.getRoster()  # prunes freed units as a side effect
	for convoy in get_node("PlanetMenu/Convoys").get_children():
		if convoy.getRoster().is_empty():
			await convoy.kill()
	return true

## Recomputes ownership: `balance` is the Imperium-vs-everyone-else weight
## difference across settlements and convoys, and drives both the team and
## the displayed icon (positive = Imperium, negative = hostile, 0 = unowned).
func update() -> void:
	#Reset the teams on the planet
	presentTeams.clear()
	for settlement in settlements:
		var currTeam = settlement.getRoster()[0].getTeam()
		if currTeam not in presentTeams:
			presentTeams.append(currTeam)
	weakest = PlanetUtils.generateWeakestSettlements(self)
	for team in presentTeams:
		PlanetUtils.getWeakestOuter(team, settlements, true)
		
	var result = setControl()
	setBalance("Imperium")
	get_node("PlanetNode/Balance").text = str(balance)
	
	match result:
		"Unowned":
			get_node("PlanetNode/PlanetSprite").texture_normal = load("res://Assets/locational/unowned.png")
			setTeam("Unowned")
		"Imperium":
			get_node("PlanetNode/PlanetSprite").texture_normal = load("res://Assets/locational/Imperium.png")
			setTeam("Imperium")
		"Chaos":
			get_node("PlanetNode/PlanetSprite").texture_normal = load("res://Assets/locational/Bad.png")
			setTeam("Chaos")

func setControl() -> String:
	var teams: Array = []
	
	for settlement in settlements:
		var currTeam = settlement.getTeam()
		if currTeam not in teams:
			teams.append(currTeam)
		if teams.size() > 1:
			return "Unowned"
	return teams[0]

func setBalance(team: String) -> int:
	var total: int = 0
	for settlement in settlements:
		total += settlement.getWeight() if settlement.getTeam() == team else -settlement.getWeight()
	for convoy in get_node("PlanetMenu/Convoys").get_children():
		total += convoy.getWeight() if convoy.getTeam() == team else -convoy.getWeight()
	balance = total
	return total

## Links any two settlements within 200px of each other, then removes any
## settlement left with zero connections (too isolated to reach or defend).
func createConnections() -> void:
	for n in settlements:
		for m in settlements:
			var dist: float = n.position.distance_to(m.position)
			if dist <= 200 and n != m and !n.getConnections().has(m) and !m.getConnections().has(n):
				n.getConnections()[m] = dist
				m.getConnections()[n] = dist
				var newLine := Line2D.new()
				newLine.width = 3
				newLine.add_point(n.position)
				newLine.add_point(m.position)
				get_node("PlanetMenu").add_child(newLine)

	for i in range(settlements.size() - 1, -1, -1):
		if settlements[i].getConnections().is_empty():
			var orphan := settlements[i]
			settlements.remove_at(i)
			orphan.queue_free()

## Every unit across all settlements on this planet, except each
## settlement's two garrison-holding "Base" units — i.e. what's available
## for a shuttle to pick up.
func getExcess(tempTeam: String) -> Array[Unit]:
	var ret: Array[Unit] = []
	for settlement in settlements:
		ret.append_array(settlement.allButTwo())
	return ret

func getBalance(team: String) -> int:
	return setBalance(team)

func _on_sprite_2d_pressed() -> void:
	get_node("PlanetMenu").visible = !get_node("PlanetMenu").visible

func _on_button_pressed() -> void:
	get_node("PlanetMenu").visible = !get_node("PlanetMenu").visible
