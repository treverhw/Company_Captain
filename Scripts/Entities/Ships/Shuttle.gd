extends Ship
class_name Shuttle

var mothership: SpaceShip = null
var used: bool = false
var currentSpace: int = 20
var capacity: int = 20

func fill(source = mothership):
	#print("[" + getTitle() + " Filling]From: " + mothership.getTitle() + ": " + str(roster))
	for unit in source.getRoster():
		if unit.getSize() <= currentSpace:
			source.getRoster().erase(unit)
			roster.append(unit)
			currentSpace -= unit.getSize()
		if currentSpace <= 0:
			break
	#print("[" + getTitle() + " Filled]From: " + mothership.getTitle() + ": " + str(roster))

func embark(planet: Planet):
	#print("[" + getTitle() + " Embarking]From: " + planet.getTitle() + ": " + str(roster))
	var excess: Array[Unit] = planet.getExcess(getTeam())
	#print("[" + planet.getTitle() + " Excess]: " + str(excess))
	for unit in excess:
		if unit.getSize() <= currentSpace:
			planet.getRoster().erase(unit)
			roster.append(unit)
			currentSpace -= unit.getSize()
		if currentSpace <= 0:
			break
	#print("[" + getTitle() + " Embarked]From: " + planet.getTitle() + ": " + str(roster))
	mothership.getRoster().append_array(getRoster())
	getRoster().clear()
	used = true

func disembark(planet: Planet):
	#print("[" + getTitle() + " Disembarking]" + planet.getTitle() + ": " + str(roster))
	planet.settlements.shuffle()
	var empty = false
	for settlement in planet.settlements:
		if settlement.getTeam() == getTeam() and !settlement.threatened:
			empty = true
			settlement.getRoster().append_array(roster)
			roster.clear()
			break
	if empty == false:
		mothership.getRoster().append_array(roster)
		roster.clear()
	currentSpace = capacity
	#print("[" + getTitle() + " Disembarked]" + planet.getTitle() + ": " + str(roster))
	used = true
