extends Control
class_name Entity

var rand : RandomNumberGenerator = RandomNumberGenerator.new()

#Informational
var title : String
var faction: Faction

#Stats
var ballisticSkill : int
var weaponSkill : int
var wounds : int
var battlescars : int
var maxBattlescars : int
var maxWounds : int

func checkWounds() -> bool:
	if wounds <= 0:
		battlescars -= 1
		return true
	return false


## Setters
func setTitle(val : String):
	title = val
func generateTitle(val : Array):
	title = val[rand.randi_range(0, val.size()-1)]
func setFaction(val : Faction):
	faction = val

func setBallisticSkill(val : int):
	ballisticSkill = val
func setWeaponSkill(val : int):
	weaponSkill = val
func setWounds(val : int):
	wounds = val
func setBattlescars(val : int):
	battlescars = val
func setMaxBattlescars(val : int):
	maxBattlescars =val

func setMaxWounds(val : int):
	maxWounds = val


## Getters
func getTitle() -> String:
	return title
func getFaction() -> Faction:
	return faction
func getTeam() -> String:
	return faction.getTeam()

func getBallisticSkill() -> int:
	return ballisticSkill
func getWeaponSkill() -> int:
	return weaponSkill
func getWounds() -> int:
	return wounds
func getMaxWounds() -> int:
	return maxWounds
func getBattlescars() -> int:
	return battlescars
func getMaxBattlescars() -> int:
	return maxBattlescars
