## ballisticSkill, weaponSkill, maxWounds, battlescars
extends Control
class_name SoldierArrays

var rand : RandomNumberGenerator = RandomNumberGenerator.new()

static var Soldiers = {
	"SpaceMarine" : 			[3, 3, 2, 3],
	"Guardsman" : 				[4, 4, 1, 1],
	"ChaosSpaceMarine" : 		[3, 3, 2, 1],
}

func getSoldiers() -> Array:
	return Soldiers
