extends Node2D
class_name Convoy

var roster: Array[Unit]
var path: Array[Settlement]
var destination: Settlement

func move():
	var direction = (destination.global_position - self.global_position).normalized()
	global_position += direction * 50
	
	var team = roster.front().getTeam()
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
		self.queue_free()

func setRoster(arr: Array[Unit]):
	for x in range(2, arr.size()):
		roster.append(arr.pop_back())
func setPath(arr: Array[Settlement]):
	path = arr
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
