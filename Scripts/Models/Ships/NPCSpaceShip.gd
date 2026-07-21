extends SpaceShip
class_name NPCSpaceShip

func turn():
	for shuttle in getShuttles():
		shuttle.used = false
	for planet in location.getPlanets():
		pass
