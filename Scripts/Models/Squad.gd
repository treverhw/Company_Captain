extends Unit
class_name Squad
## A squad is just a Unit with its own combat-UI refresh logic.
## `define()` is inherited unchanged from Unit.

func combatUpdate() -> void:
	var n: int = getAlive()
	get_node("Roster Size").text = str(n)
	if n <= 0:
		visible = false
