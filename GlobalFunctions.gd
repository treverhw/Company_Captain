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

static func compareAttackWeight(arr1: Array[Unit], arr2: Array[Unit]) -> bool:
	var val1: int = 0
	var val2: int = 0
	
	for unit in arr1:
		val1 += unit.getWeight()
	for unit in arr2:
		val2 += unit.getWeight()
	
	return val1 >= val2*1.5

static func numToRoman(num: int) -> String:
	var nums = [1, 4, 5, 9, 10, 40, 50, 90, 100, 400, 500, 900, 1000]
	var sym = ["I", "IV", "V", "IX", "X", "XL", "L", "XC", "C", "CD", "D", "CM", "M"]
	var i = 12
	var ret = ""
	while num:
		var div = num / nums[i]
		num %= nums[i]
		
		while div:
			ret += sym[i]
			div -= 1
		i -= 1
	return ret
