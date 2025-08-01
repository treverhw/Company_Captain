extends Node2D
class_name Convoy

var roster: Array[Unit]
var path: Array[Settlement]
var home: Settlement
var destination: Settlement

func move():
	var direction = (destination.global_position - self.global_position).normalized()
	global_position += direction * 50
	
	var team
	if getRoster().is_empty():
		queue_free()
	else: team = roster.front().getTeam()
	var convoys: Array[Node] = destination.get_parent().get_node("Convoys").get_children()
	
	if destination.distance(self, destination) < 50.0:
		match(destination.team):
			"Unowned":
				destination.getRoster().append_array(getRoster())
				destination.setTeam(team)
				destination.update()
			team:
				destination.getRoster().append_array(getRoster())
			_:
				if destination.getRoster().size() <= 0:
					print("BLAM")
					destination.getRoster().append_array(getRoster())
				else:
					destination.invade(getRoster())
		queue_free()

func retreatConvoy():
	destination = home
	move()

func direct(army: Array[Unit] = roster, hm: Settlement = home, dst: Settlement = destination):
	home = hm
	destination = dst
	roster = army
	global_position = hm.global_position

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
	print(roster)
	return getRoster().front().getTeam()
