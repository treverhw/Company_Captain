extends Location
class_name Planet

var settlements: Array[Settlement]

func _ready() -> void:
	var rand = RandomNumberGenerator.new()
	for n in range(0, randi_range(20,20)):
		var newSettlement = load("res://Scenes/Locational/Settlement.tscn").instantiate()
		print("Loopin")
		newSettlement.global_position = Vector2(randi_range(-450, 450), randi_range(-250,250))
		var counter = 0
		while !validate_distance(newSettlement) and counter != 100:
			counter +=1
			newSettlement.global_position = Vector2(randi_range(-450, 450), randi_range(-250,250))
		if counter != 100:
			add_child(newSettlement)
			settlements.append(newSettlement)
		else:
			break
		
	create_connections()

func create_connections():
	for n in settlements:
		for m in settlements:
			var distance: int = n.position.distance_to(m.position)
			if distance <= 200 and n!=m and !n.getConnections().has(m) and !m.getConnections().has(n):
				n.getConnections()[m] = distance
				m.getConnections()[n] = distance
				var newLine = Line2D.new()
				newLine.width = 3
				newLine.add_point(n.position)
				newLine.add_point(m.position)
				add_child(newLine)
	for n in settlements:
		if n.getConnections().size() <= 0:
			settlements.erase(n)
			n.queue_free()

func sort_dict_by_values(dict: Dictionary) -> Dictionary:
			var temp = {}
			while !dict.is_empty():
				var smallestKey = ""
				var smallestNum = 10000
				for item in dict:
					if dict[item] < smallestNum:
						smallestKey = item
						smallestNum = dict[item]
				dict.erase(smallestKey)
				temp[smallestKey] = smallestNum
			return temp

func validate_distance(val: Settlement) -> bool:
	for n in settlements:
		if val.position.distance_to(n.position) < 120 && n != val:
			return false
	return true
