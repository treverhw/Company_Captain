extends Ship
class_name Shuttle

var mothership: SpaceShip = null
var used: bool = false
var currentSpace: int = 20
var capacity: int = 20

func fill():
	var tempRoster = mothership.getRoster()
	for unit in tempRoster:
		if unit.getSize() <= capacity:
			tempRoster.erase(unit)
			roster.append(unit)
			currentSpace -= unit.getSize()

func embark(planet: Planet):
	var excess: Array[Unit] = planet.getExcess(getTeam())
	for unit in excess:
		if unit.getSize() <= capacity:
			planet.getRoster().erase(unit)
			roster.append(unit)
			currentSpace -= unit.getSize()
		if currentSpace <= 0:
			break
	used = true

func disembark(planet: Planet):
	planet.getSettlements().shuffle()
	for settlement in planet.getSettlements():
		if settlement.getTeam() == getTeam() and !settlement.threatened:
			settlement.getRoster().append_array(roster)
		break
	roster.clear()
	currentSpace = capacity
	used = true
