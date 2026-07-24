extends Location
class_name Convoy
## A moving group of Units en route between two Settlements, hop-by-hop
## along `path`. Convoys are transient nodes: they free themselves once
## they arrive at their final destination, get diverted mid-route, or
## lose their roster.

var path: Array[Settlement]
var home: Settlement
var destination: Settlement
var source: String = ""
var speed: int = 25

## Advances the convoy toward its current hop (`destination`) each tick,
## and resolves arrival once it's within `speed` of it.
func move() -> void:
	if getRoster().is_empty():
		kill()
		return

	var direction: Vector2 = (destination.global_position - self.global_position).normalized()
	global_position += direction * speed

	get_node("Node2D/Label").text = str(int(floor(distance(self, destination) / speed)))
	get_node("Node2D/Label2").text = team.split()[0]
	get_node("Node2D/Label3").text = str(getRoster().size())
	get_node("Node2D").global_rotation = 0.0

	#print("distance to " + str(destination) + " = " + str(destination.distance(self, destination)))
	if destination.distance(self, destination) < speed:
		resolveArrival()

## Handles arrival at `destination`: continues on to the next hop if this
## is an intermediate stop on a still-friendly route, otherwise
## claims/reinforces/invades depending on ownership, then frees the convoy.
func resolveArrival() -> void:
	if destination.team == "Unowned" or destination.team == team or destination.getRoster().size() <= 0:
		#print("Before: " + str(getRoster()))
		unload(destination)
		#print("After: " + str(getRoster()))
	else:
		destination.invade(self)
	cleanup()
	destination.update()

func unload(location: Settlement) -> void:
	for unit in getRoster().duplicate():
		unit.setLocation(location)
	destination.setTeam(team)

func cleanup():
	ModelUtils.pruneInvalid(roster)
	if getRoster().is_empty():
		kill()

func kill() -> void:
	if get_parent() != null:
		get_parent().remove_child(self)
	queue_free()

## Turns the convoy around and sends it directly back to its home
## settlement (not re-routed hop-by-hop -- retreating is an emergency
## maneuver, not a supply run).
func retreatConvoy() -> void:
	if getRoster().is_empty():
		kill()
		return
	path = [home]
	destination = home
	look_at(destination.global_position)
	for unit in getRoster().duplicate():
		unit.setLocation(self)
	move()

## Sets up this convoy to carry `army` along `route` (a sequence of
## Settlements from home to final destination, inclusive), traveling
## hop-by-hop through any intermediate settlements.
func setConvoy(force: Array[Unit], route: Array[Settlement]) -> void:
	if force.is_empty() or route.size() < 2:
		kill()
		return
	path = route
	home = route[0]
	team = force.front().getTeam()
	for unit in force.duplicate():
		unit.setLocation(self)
	global_position = home.global_position
	setDestination(route[1])

func setRoster(arr: Array[Unit]) -> void:
	roster = arr
func setDestination(dest: Settlement) -> void:
	destination = dest
	look_at(destination.global_position)
	move()

func getRoster() -> Array[Unit]:
	ModelUtils.pruneInvalid(roster)
	return roster
func getPath() -> Array[Settlement]:
	return path
func getHome() -> Settlement:
	return home
func getDestination() -> Settlement:
	return destination
func getTeam() -> String:
	return team
func getWeight() -> int:
	var n: int = 0
	for unit in getRoster():
		n += unit.getWeight()
	return n
