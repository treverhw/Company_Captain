extends Node2D
class_name Combat
## Runs a single combat encounter between two armies of Units, animating
## shots line-by-line until one side is wiped out.

var attackerRoster: Array[Unit] = []
var defenderRoster: Array[Unit] = []
var fullRoster: Array[Model] = []
var auto: bool
var end: Dictionary = {0: [], 1: []}

func _ready() -> void:
	pass
	# Center the combat panel in a 1920x1080 viewport.
	global_position = Vector2((1920 / 2) - (1170 / 2), (1080 / 2) - (780 / 2))

## Deploys one side's units into the given combat-army node ("Attacker" or
## "Defender"), reparenting each unit into its assigned line.
func _deployArmy(units: Array[Unit], sideName: String) -> void:
	for unit in units:
		unit.combatUpdate()
		unit.visible = true
		var line: CombatLine = get_node(sideName + "/" + unit.getLine())
		unit.reparent(line)
		line.roster.append_array(unit.getRoster())
		fullRoster.append_array(unit.getRoster())

## Sets up both armies and runs the fight to completion.
func populate(attack: Array[Unit], defense: Array[Unit]) -> Dictionary:
	# Faction id 0 is always the player; if neither side is the player,
	# resolve combat instantly without showing the UI.
	if attack.front().getFaction().id != 0 and defense.front().getFaction().id != 0:
		visible = false
		auto = true

	attackerRoster = attack
	defenderRoster = defense

	_deployArmy(attackerRoster, "Attacker")
	_deployArmy(defenderRoster, "Defender")

	get_node("Attacker").team = attackerRoster.front().getTeam()
	get_node("Defender").team = defenderRoster.front().getTeam()

	return await realFight()

func realFight() -> Dictionary:
	var weapons: Array[Weapon]
	visible = true

	var queue: Array[Model] = fullRoster.duplicate()
	while !endCheck():
		# Drop anyone who's already dead before this round starts.
		for i in range(queue.size() - 1, -1, -1):
			if queue[i].getWounds() <= 0:
				queue.remove_at(i)
		queue.shuffle()
		# Fastest models act first.
		queue.sort_custom(func(a, b): return a.getSpeed() < b.getSpeed())

		# Only pause between rounds when a human is actually watching.
		if !auto:
			await get_tree().create_timer(1).timeout

		for model in queue:
			if model.getWounds() <= 0:
				continue

			var frontLine: VBoxContainer = targetColumn(model)
			weapons = model.getActiveWeapons(distance(model.getUnit().get_parent(), frontLine))

			for weapon in weapons:
				for attack in range(1, weapon.getAttacks()):
					# Pick a random model from the enemy's frontline to shoot at.
					var target: Model = frontLine.getRoster()[randi_range(0, frontLine.getRoster().size() - 1)]

					if GlobalFunctions.rolld6() >= model.getBallisticSkill() or "Torrent" in weapon.getModifiers():
						if wound(weapon, target, GlobalFunctions.rolld6()):
							var save: int = GlobalFunctions.rolld6()
							if save < target.getSave():
								# Roll succeeded and the save failed: target takes damage.
								# The shooter gains xp on a hit, and again if it's a kill.
								target.wounds -= weapon.getDmg()
								model.xp += 1

								if target.getWounds() <= 0:
									model.xp += 1
									frontLine.getRoster().erase(target)
									target.getUnit().combatUpdate()

									if endCheck():
										cleanup()
										return end

		# Move the attacking army forward once the armies are close enough.
		# TODO: this always compares Attacker's line 6 against Defender's
		# line 1, rather than the armies' actual current front lines.
		if distance(get_node("Attacker").get_child(5), get_node("Defender").get_child(0)) > 65:
			get_node("Attacker").global_position.x += 65
	cleanup()
	return end

func endCheck() -> bool:
	var att: int = get_node("Attacker").getSize()
	var def: int = get_node("Defender").getSize()
	if att <= 0:
		end[0] = defenderRoster
		end[1] = attackerRoster
		return true
	if def <= 0:
		end[0] = attackerRoster
		end[1] = defenderRoster
		return true
	return false

func _returnArmy(units: Array[Unit]) -> void:
	for unit in units:
		if unit.get_parent() != null:
			unit.reparent(unit.getFaction())
		unit.visible = false
		unit.clean()

func cleanup() -> bool:
	_returnArmy(attackerRoster)
	_returnArmy(defenderRoster)
	return true

## -- Utilities --

## Standard wound-roll table: compares attacker strength to target toughness.
func wound(s: Weapon, t: Model, roll: int) -> bool:
	if s.getStrength() >= 2 * t.getToughness() and roll >= 2:
		return true
	elif s.getStrength() > t.getToughness() and roll >= 3:
		return true
	elif s.getStrength() == t.getToughness() and roll >= 4:
		return true
	elif s.getStrength() < t.getToughness() and roll >= 5:
		return true
	elif s.getStrength() * 2 <= t.getToughness() and roll >= 6:
		return true
	else:
		return false

func distance(Node1: Node, Node2: Node) -> float:
	return Node1.global_position.distance_to(Node2.global_position)

## Finds the nearest non-empty enemy combat line to shoot at.
func targetColumn(model: Model) -> VBoxContainer:
	var friendlyArmy: HBoxContainer = model.getUnit().get_parent().get_parent()
	var enemyArmy: HBoxContainer = get_node("Defender") if friendlyArmy.name == "Attacker" else get_node("Attacker")

	var counter: int = 0
	var curr = enemyArmy.get_child(counter)
	while curr.getRoster().size() <= 0:
		counter += 1
		if counter > 5:
			break
		curr = enemyArmy.get_child(counter)
	return curr

func getEnding() -> Dictionary:
	endCheck()
	return end

func getFullSize() -> int:
	return get_node("Attacker").getSize() + get_node("Defender").getSize()
