extends RefCounted
class_name EntityUtils

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
