class_name Utility

const MINUTE = 60
const HOUR = MINUTE * 60

static func randi_string(range: String):
	var range_array = range.split("-")
	
	if range.contains("-"):
		return randi_range(int(range_array[0]), int(range_array[1]))
	else: return int(range)

static func flatten(array: Array):
	var result = []
	
	for sub_array in array:
		result.append_array(sub_array)
	
	return result


static func get_seconds() -> int:
	return floor(Time.get_unix_time_from_system())

static func not_null(number) -> int:
	if number == null: return 0
	return number
