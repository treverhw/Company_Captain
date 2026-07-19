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

	team = roster.front().getTeam()
	var direction: Vector2 = (destination.global_position - self.global_position).normalized()
	global_position += direction * speed

	get_node("Node2D/Label").text = str(int(floor(distance(self, destination) / speed)))
	get_node("Node2D/Label2").text = team.split()[0]
	get_node("Node2D/Label3").text = str(getRoster().size())
	get_node("Node2D").global_rotation = 0.0

	if destination.distance(self, destination) < speed:
		_resolveArrival()

## Handles arrival at `destination`: continues on to the next hop if this
## is an intermediate stop on a still-friendly route, otherwise
## claims/reinforces/invades depending on ownership, then frees the convoy.
func _resolveArrival() -> void:
	match destination.team:
		"Unowned":
			destination.getRoster().append_array(getRoster())
			destination.setTeam(team)
		team:
			destination.getRoster().append_array(getRoster())
		_:
			if destination.getRoster().size() <= 0:
				destination.getRoster().append_array(getRoster())
			else:
				destination.invade(getRoster())
	queue_free()
	destination.update()

## If `destination` is an intermediate (not final) hop on `path` and is
## still friendly, advances to the next hop instead of resolving here. If
## it's no longer friendly (e.g. captured by the enemy since the route was
## planned), resolves here instead of continuing blindly onward.
func _advanceToNextHop() -> bool:
	if path.is_empty() or destination == path.back():
		return false
	if destination.team != team:
		return false
	var hopIndex: int = path.find(destination)
	if hopIndex == -1 or hopIndex + 1 >= path.size():
		return false
	setDestination(path[hopIndex + 1])
	return true

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
	for unit in getRoster():
		unit.setLocation(self)
	move()

## Sets up this convoy to carry `army` along `route` (a sequence of
## Settlements from home to final destination, inclusive), traveling
## hop-by-hop through any intermediate settlements.
func setConvoy(army: Array[Unit], route: Array[Settlement]) -> void:
	if army.is_empty() or route.size() < 2:
		kill()
		return
	path = route
	home = route[0]
	roster = army
	team = army.front().getTeam()
	for unit in army:
		unit.setLocation(self)
	global_position = home.global_position
	setDestination(route[1])

func cleanup() -> bool:
	ModelUtils.pruneInvalid(roster)
	if getRoster().is_empty():
		kill()
	return true

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
