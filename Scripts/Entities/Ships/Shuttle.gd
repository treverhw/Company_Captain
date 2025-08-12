extends Ship
class_name Shuttle

var mothership: SpaceShip = null
var destination = null
var used: bool = false
var capacity: int = 20

func turn():
	used = false
	if destination != null:
		destination.getRoster().append_array(getRoster())

func setDestination(location, from: Planet = null):
	destination = location
	if from != null:
		embark(from)

func embark(planet: Planet):
	roster.append_array(planet.getExcess())
