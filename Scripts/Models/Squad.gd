extends Unit
class_name Squad
## A squad is just a Unit with its own combat-UI refresh logic.
## `define()` is inherited unchanged from Unit.

const CHAOS_TEX = preload("res://Assets/combat/chaosCombatLine.png")
const GUARD_TEX = preload("res://Assets/combat/guardCombatLine.png")
const MARINE_TEX = preload("res://Assets/combat/marineCombatLine.png")
const ORK_TEX = preload("res://Assets/combat/orkCombatLine.png")
const TYRANID_TEX = preload("res://Assets/combat/tyranidsCombatLine.png")

func setTex() -> void:
	var fac = getFaction()
	if fac is Chaos:
		texture = CHAOS_TEX
	elif fac is Guard:
		texture = GUARD_TEX
	elif fac is PlayerFaction:
		texture = MARINE_TEX
	elif fac is Orkz:
		texture = ORK_TEX
	else:
		texture = TYRANID_TEX

func combatUpdate() -> void:
	var n: int = getAlive()
	get_node("Roster Size").text = str(n)
	if n <= 0:
		visible = false
