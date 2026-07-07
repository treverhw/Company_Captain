extends Location
class_name Planet
## One planet within a System: generates a field of settlements, links them
## into a connected graph, and runs the per-turn simulation loop.

var settlements: Array[Settlement]
var balance: int

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

## Scatters starting Guard garrisons across 4-8 random settlements, and
## Chaos garrisons across 4-5 random non-Imperium-owned settlements.
func _spawnStartingForces() -> void:
	var main = get_node("/root/Main/")
	for n in randi_range(4, 8):
		var guardForce: Array[Unit] = main.getFaction("guard").start()
		var settlement: Settlement = settlements[randi_range(0, settlements.size() - 1)]
		settlement.appendRoster(guardForce)
	for n in randi_range(4, 5):
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

func convoyFight(val1: Convoy, val2: Convoy) -> void:
	await cleanup()
	var combat = load("res://Scenes/Menus/Combat.tscn").instantiate()
	get_node("/root/Main").add_child(combat)

	var newRosters = await combat.populate(val1.getRoster(), val2.getRoster())
	EntityUtils.pruneEmptyUnits(newRosters[0])
	EntityUtils.pruneEmptyUnits(newRosters[1])

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
	setBalance("Imperium")
	get_node("PlanetNode/Balance").text = str(balance)
	if balance > 0:
		get_node("PlanetNode/PlanetSprite").texture_normal = load("res://Assets/locational/Imperium.png")
		setTeam("Imperium")
	elif balance < 0:
		get_node("PlanetNode/PlanetSprite").texture_normal = load("res://Assets/locational/Bad.png")
		setTeam("Chaos")
	else:
		get_node("PlanetNode/PlanetSprite").texture_normal = load("res://Assets/locational/unowned.png")
		setTeam("Unowned")

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
