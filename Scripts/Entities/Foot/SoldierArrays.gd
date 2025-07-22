extends Control
class_name SoldierArrays

var rand : RandomNumberGenerator = RandomNumberGenerator.new()

#stats of a soldier: ballisticSkill, weaponSkill, maxWounds, battlescars
static var soldiers = {
	#name                       bs ws  mW battlescars
	"SpaceMarine" : 			[3, 3, 2, 3],
	"Guardsman" : 				[4, 4, 1, 1],
	"ChaosSpaceMarine" : 		[3, 3, 2, 1],
}

func getSoldiers() -> Array:
	return soldiers
