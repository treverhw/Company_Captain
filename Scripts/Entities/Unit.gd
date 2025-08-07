extends TextureRect
class_name Unit

var title : String
var roster : Array[Entity] = []
var rosterCap : int = 5
var faction : Faction
var location: Location
var line: int = 1

func define(t : String, rC : int, f : Faction):
	title = t
	rosterCap = rC
	faction = f

func validate():
	if getAlive() <= 0: return false
	else: 			return true

func assignModels():
	for model in getRoster():
		model.unit = self

func removeEntity(model: Entity):
	getFaction().removeEntity(model)

func getAlive() -> int:
	var counter: int = 0
	for model in getRoster():
		if model.alive():
			counter += 1
	return counter

func clean():
	print("Cleaning!")
	for model in range(getRoster().size() - 1, -1, -1):
		print(str(getRoster()[model]))
		if getRoster()[model].getWounds() <= 0:
			getRoster()[model].battlescars += 1
			if getRoster()[model].getBattlescars() > getRoster()[model].getMaxBattlescars():
				print("Killing!")
				getRoster()[model].kill()
			else:
				print("Scarring!")
				getRoster()[model].setWounds(1)
	if getRoster().is_empty():
		get_parent().remove_child(self)
		getFaction().getRoster().erase(self)
		queue_free()

func combatUpdate():
	pass

##Setters and Getters
func setTitle(t : String):
	title = t
func setRosterCap(val : int):
	rosterCap = val
func setFaction(val : Faction):
	faction = val
func setLocation(val: Location):
	location = val

func getTitle() -> String:
	return title
func getRoster() -> Array[Entity]:
	return roster
func getRosterCap() -> int:
	return rosterCap
func getFaction() -> Faction:
	return faction
func getTeam() -> String:
	return getFaction().getTeam()
func getLine() -> String:
	return str(line)
func getLocation() -> Location:
	return location
func getWeight() -> int:
	var n: int = 0
	for model in getRoster():
		n += model.getWeight()
	return n

func _to_string() -> String:
	var ret: String = str(getFaction().getTitle()) + " " + getTitle()
	ret += str(roster)
	return ret

func _to_string_combat() -> String:
	var ret: String = str(getFaction().getTitle()) + " " + getTitle()
	var temp = "["
	for unit in roster:
		for model in unit.getRoster():
			if model.alive():
				temp += model + ", "
		
	ret += str(roster)
	return ret
