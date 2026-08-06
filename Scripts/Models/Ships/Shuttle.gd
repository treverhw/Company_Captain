extends Ship
class_name Shuttle

var mothership: SpaceShip = null
var used: bool = false
var currentSpace: int = 20
var capacity: int = 20

func embark(source = mothership):
	var army: Array[Unit]
	#print("[" + getTitle() + " Filling]From: " + source.getTitle() + ": " + str(source.getRoster()))
	if source is Planet:
		army = source.getExcess(getTeam())
	else:
		army = source.getRoster()
	for guy in army:
		if guy.getSize() <= currentSpace:
			guy.setLocation(self)
			currentSpace -= guy.getSize()
		if currentSpace <= 0:
			break
	#print("[" + getTitle() + " Filled]From: " + source.getTitle() + ": " + str(roster))

func disembark(destination = mothership):
	#print("[" + getTitle() + " Disembarking]To: " + destination.getTitle() + ": " + str(roster))
	if destination is Planet:
		destination.settlements.shuffle()
		var empty = false
		for settlement in destination.settlements:
			if settlement.getTeam() == getTeam() and !settlement.threatened:
				empty = true
				destination = settlement
				destination.getRoster().append_array(roster)
				break
		#return roster to ship if the planet has no viable landing points
		if empty == false:
			mothership.getRoster().append_array(roster)
	else:
		destination.getRoster().append_array(roster)
	for guy in roster:
		if destination as Ship:
			if destination.getCapacity() < destination.getRemainingCapacity() + guy.getSize():
				guy.setLocation(destination)
			else: break
		else: guy.setLocation(destination)
	currentSpace = capacity
	#print("[" + getTitle() + " Disembarked]To: " + destination.getTitle() + ": " + str(destination.getRoster()))
	used = true
