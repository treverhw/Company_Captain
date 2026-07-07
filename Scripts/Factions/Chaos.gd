extends AstartesFaction
class_name Chaos

func _init() -> void:
	title = "Death Guard"
	team = "Chaos"
	id = 2

func start() -> Array[Unit]:
	return [spawnBase(), spawnBase()]

## Chaos scout squads get a "Squad: N" title instead of the plain numeric
## title AstartesFaction uses by default.
func _scoutSquadTitle() -> String:
	return "Squad: " + str(roster.size())
