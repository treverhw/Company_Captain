extends Ship
class_name Shuttle

var mothership: SpaceShip = null
var used: bool = false
var currentSpace: int = 20
var capacity: int = 20

func fill():
	print("[" + getTitle() + " Filling]" + mothership.getTitle() + ": " + str(roster))
	var tempRoster = mothership.getRoster()
	for unit in tempRoster:
		if unit.getSize() <= capacity:
			tempRoster.erase(unit)
			roster.append(unit)
			currentSpace -= unit.getSize()
	print("[" + getTitle() + " Filled]" + mothership.getTitle() + ": " + str(roster))

func embark(planet: Planet):
	print("[" + getTitle() + " Embarking]" + planet.getTitle() + ": " + str(roster))
	var excess: Array[Unit] = planet.getExcess(getTeam())
	print("[" + planet.getTitle() + " Excess]: " + str(excess))
	for unit in excess:
		if unit.getSize() <= capacity:
			planet.getRoster().erase(unit)
			roster.append(unit)
			currentSpace -= unit.getSize()
		if currentSpace <= 0:
			break
	print("[" + getTitle() + " Embarked]" + planet.getTitle() + ": " + str(roster))
	used = true

func disembark(planet: Planet):
	print("[" + getTitle() + " Disembarking]" + planet.getTitle() + ": " + str(roster))
	planet.getSettlements().shuffle()
	for settlement in planet.getSettlements():
		if settlement.getTeam() == getTeam() and !settlement.threatened:
			settlement.getRoster().append_array(roster)
		break
	roster.clear()
	currentSpace = capacity
	print("[" + getTitle() + " Disembarked]" + planet.getTitle() + ": " + str(roster))
	used = true
