extends Location
class_name Convoy
## A moving group of Units en route between two Settlements. Convoys are
## transient nodes: they free themselves once they arrive or lose their roster.

var path: Array[Settlement]
var home: Settlement
var destination: Settlement
var source: String = ""
var speed: int = 25

## Advances the convoy toward its destination each tick, and resolves
## arrival once it's within `speed` of the target.
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

## Claims an unowned settlement, reinforces a friendly one, or invades an
## enemy one — then frees the convoy.
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

func kill() -> void:
	if get_parent() != null:
		get_parent().remove_child(self)
	queue_free()

## Turns the convoy around and sends it back to its home settlement.
func retreatConvoy() -> void:
	if getRoster().is_empty():
		kill()
		return
	destination = home
	look_at(destination.global_position)
	for unit in getRoster():
		unit.setLocation(self)
	move()

func setConvoy(army: Array[Unit] = roster, hm: Settlement = home, dst: Settlement = destination) -> void:
	if army.is_empty():
		kill()
		return
	home = hm
	destination = dst
	roster = army
	team = army.front().getTeam()
	for unit in army:
		unit.setLocation(self)
	global_position = hm.global_position
	look_at(destination.global_position)

func cleanup() -> bool:
	EntityUtils.pruneInvalid(roster)
	if getRoster().is_empty():
		kill()
	return true

func setRoster(arr: Array[Unit]) -> void:
	roster = arr
func setPath(arr: Array[Settlement]) -> void:
	path = arr
	home = path[0]
	setDestination(path[0] if path.size() <= 1 else path[1])
func setDestination(dest: Settlement) -> void:
	destination = dest
	look_at(destination.global_position)

func getRoster() -> Array[Unit]:
	EntityUtils.pruneInvalid(roster)
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
