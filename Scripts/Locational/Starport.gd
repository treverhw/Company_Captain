extends Settlement
class_name Starport

var exportLimit : int = 200

func _ready() -> void:
	generateTitle(Names.planetNames)
	get_node("Name").text = "Starport\n" + name

func exportState():
	var ships = planet.system.getShips()
	var force = getExport()
	for ship: SpaceShip in ships:
		if ship.getTeam() == getTeam():
			#print(planet.title + " " + self.title)
			#print(ship.getRemainingCapacity())
			#print(!force.is_empty())
			while ship.getRemainingCapacity() > 0 and !force.is_empty():
				#print("Should move")
				var unit = force.pop_back()
				if unit.getSize() <= ship.getRemainingCapacity():
					unit.setLocation(ship)

func getExport() -> Array[Unit]:
	if planet.compliant:
		var unitExport: Array[Unit] = []
		var currLoad: int = 0
		for unit: Unit in allButTwo():
			if currLoad == exportLimit:
				break
			var unitSize = unit.getSize()
			if currLoad + unitSize < exportLimit:
				unitExport.append(unit)
				currLoad += unitSize
		return unitExport
	return []
