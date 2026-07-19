extends RefCounted
class_name ModelUtils

const soldier = preload("res://Scenes/Entities/Soldier.tscn")

static func generateSoldier(res: Resource) -> Model:
	var model: Soldier = soldier.instantiate()
	model.stats = res
	return model

## Removes any freed/invalid instances from the given array, in place.
static func pruneInvalid(arr: Array) -> void:
	for i in range(arr.size() - 1, -1, -1):
		if not is_instance_valid(arr[i]):
			arr.remove_at(i)

## Removes any invalid OR empty-rostered units from the given array, in
## place, freeing valid-but-empty units as it goes. Used to clean up combat
## results before they're handed back to the caller.
static func pruneEmptyUnits(units: Array[Unit]) -> void:
	for i in range(units.size() - 1, -1, -1):
		var unit: Unit = units[i]
		if not is_instance_valid(unit):
			units.remove_at(i)
		elif unit.getRoster().is_empty():
			unit.queue_free()
			units.remove_at(i)
			
static func mergeUnits(units: Array[Unit]) -> void:
	if !units:
		return
	units.sort_custom(func(a, b): return a.getRoster().size() > b.getRoster().size())
	for unit in units:
		var sucker = units[units.size()-1]
		if unit == sucker:
			return
		while(unit.getNeededModels() != 0):
			unit.addModel(sucker.popModel())
			if sucker.getRoster().size() <= 0:
				sucker.clean()
				units.erase(sucker)
				sucker = units[units.size()-1]

#for later implementation
static func findLeader(unit: Unit) -> Model:
	var leader: Model = unit.getRoster()[0]
	for i in range(1, unit.getRoster().size()-1):
		if unit.getRoster()[i].xp > leader.xp:
			leader = unit.getRoster()[i]
	return leader
