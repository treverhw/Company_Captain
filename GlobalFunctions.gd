extends RefCounted
class_name GlobalFunctions

##Rolls n d6 and returns the result
static func rolld6(n: int = 1) -> int:
	if !n:
		n = 1
	var result: int = 0
	for i in range(0, n):
		result += randi_range(1,6)
	return result
	
static func rollStringd6(roll: String) -> int:
	
	var val = roll.split("d")
	if !val[0] or val[0] == "":
		val[0] = "1"
	
	var n = int(val[0])
	var result: int = 0
	for i in range(0, n):
		result += randi_range(1,6)
	
	if "+" in val[1]:
		result += int(val[1].split("+")[1])
	return result
