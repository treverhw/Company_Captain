extends Node2D
class_name Convoy

var roster: Array[Unit]
var path: Array[Settlement]
var home: Settlement
var destination: Settlement

func move():
	print("Home: " + str(home) + " | Destination: " + str(destination) + " | Army: " + str(roster))
	var team
	if getRoster().is_empty():
		queue_free()
		get_parent().remove_child(self)
		return
	else: team = roster.front().getTeam()
	var direction = (destination.global_position - self.global_position).normalized()
	global_position += direction * 50
	
	var convoys: Array[Node] = destination.get_parent().get_node("Convoys").get_children()
	
	if destination.distance(self, destination) < 50.0:
		match(destination.team):
			"Unowned":
				destination.getRoster().append_array(getRoster())
				destination.setTeam(team)
			team:
				destination.getRoster().append_array(getRoster())
			_:
				if destination.getRoster().size() <= 0:
					print("BLAM")
					destination.getRoster().append_array(getRoster())
				else:
					destination.invade(getRoster())
		destination.update()
		kill()

func kill():
		queue_free()
		get_parent().remove_child(self)

func retreatConvoy():
	destination = home
	move()

func setConvoy(army: Array[Unit] = roster, hm: Settlement = home, dst: Settlement = destination):
	if !army.is_empty():
		home = hm
		destination = dst
		roster = army
		global_position = hm.global_position
		look_at(destination.global_position)
	else:
		kill()

func setRoster(arr: Array[Unit]):
	roster = arr
func setPath(arr: Array[Settlement]):
	path = arr
	home = path[0]
	if path.size() <= 1:
		setDestination(path[0])
	else:
		setDestination(path[1])
func setDestination(dest: Settlement):
	destination = dest
	look_at(destination.global_position)

func getRoster() -> Array[Unit]:
	return roster
func getPath() -> Array[Settlement]:
	return path
func getDestination() -> Settlement:
	return destination
func getTeam() -> String:
	#print("Home: " + str(home) + " | Destination: " + str(destination) + " | Army: " + str(roster))
	return getRoster().front().getTeam()
func getWeight() -> int:
	var n: int = 0
	for unit in getRoster():
		n += unit.getWeight()
	return n
