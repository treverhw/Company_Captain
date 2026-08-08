extends Settlement
class_name Starport

var exportLimit : int = 200

func _ready() -> void:
	generateTitle(Names.planetNames)
	get_node("Name").text = "Starport\n" + name

func exportState():
	var ships = planet.system.getShips()
	var force = getExport()
	planet.system.availableUnits[getTeam()].append_array(force)

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
