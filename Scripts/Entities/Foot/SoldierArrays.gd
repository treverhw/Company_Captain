extends Control
class_name SoldierArrays

var rand : RandomNumberGenerator = RandomNumberGenerator.new()

#stats of a soldier: ballisticSkill, weaponSkill, maxWounds, battlescars
static var soldiers = {
	#name                       bs ws  mW battlescars
	"SpaceMarine" : 			[3, 3, 2, 2],
	"Guardsman" : 				[4, 4, 1, 0],
	"ChaosSpaceMarine" : 		[3, 3, 2, 1],
}

func getSoldiers() -> Dictionary:
	return soldiers
