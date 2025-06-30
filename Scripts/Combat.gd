extends Node

var rand : RandomNumberGenerator = RandomNumberGenerator.new()
var fRoster : Array[Entity] = []
var eRoster : Array[Entity] = []
var wholeRoster : Array[Entity] = [] 
var queue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startCombat([get_parent().squad,get_parent().squad,get_parent().squad,get_parent().squad], [get_parent().squad,get_parent().squad,get_parent().squad,get_parent().squad], true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func rolld6() -> int:
	return randi_range(1,6)

func wound(s : Weapon, t : Entity, roll : int):
	if s.getStrength() >= 2*t.getToughness() and roll >= 2:
		return true
	elif s.getStrength() > t.getToughness() and roll >= 3:
		return true
	elif s.getStrength() == t.getToughness() and roll >= 4:
		return true
	elif s.getStrength() < t.getToughness() and roll >= 5:
		return true
	elif s.getStrength()*2 <= t.getToughness() and roll >= 6:
		return true
	else: return false

func shoot(entity, target, friendly):
	var wpn = entity.main
	for i in range(wpn.getAttacks()):
		if rolld6() >= entity.getBallisticSkill():
			if wound(wpn, target, rolld6()):
				if rolld6() < target.getSave():
					target.wounds -= wpn.getDmg()
					if target.checkWounds():
						queue.erase(target)
						if friendly == true:
							eRoster.erase(target)
						else:
							fRoster.erase(target)

func startCombat(friendly : Array[Unit], enemy : Array[Unit], attacker : bool):
	
	for unit in friendly:
		fRoster += unit.getRoster()
	var fStartingSize = fRoster.size()
	
	for unit in enemy:
		eRoster += unit.getRoster()
	var eStartingSize = eRoster.size()
	
	wholeRoster = fRoster + eRoster
	
	#Imperium fights first
	if attacker == true:
		while fRoster.size() >= fStartingSize/4 and eRoster.size() >= eStartingSize/4:
			queue = (fRoster + eRoster)
			print(str(fRoster.size()) + " vs " + str(eRoster.size()))
			queue.sort_custom(func(a,b): return a.getSpeed() > b.getSpeed())
			for entity in queue:
				queue.pop_front()
				var target : Entity 
				
				if entity.team == "Imperium":
					target = eRoster[rand.randi_range(0, eRoster.size()-1)]
					shoot(entity, target, true)
				
				else:
					target = eRoster[rand.randi_range(0, eRoster.size()-1)]
					shoot(entity, target, false)
	
	for entity in wholeRoster:
		if entity.battlescars <= 0:
			wholeRoster.erase(entity)
			entity.queue_free()
	
