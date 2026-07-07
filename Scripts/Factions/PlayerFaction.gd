extends AstartesFaction
class_name PlayerFaction

func _init() -> void:
	title = "Mar's Marauders" # Determined by player
	team = "Imperium"
	id = 0

func start() -> Array[Unit]:
	return [spawnBase(), spawnBase()]
