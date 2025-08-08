extends Ship
class_name Shuttle

var mothership: SpaceShip = null
var destination = null
var used: bool = false
var capacity: int = 2

func turn():
	used = false
	if destination != null:
		destination.getRoster().append_array(getRoster())
			

func setDestination(location, from: Planet = null):
	destination = location
	if from != null:
		setRoster(from)

func setRoster(planet: Planet):
	for settlement in planet.getSettlements():
		pass
