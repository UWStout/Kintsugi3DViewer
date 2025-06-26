extends Node

const _LOCAL_SAVE_FILE : String = "localdata.json"

func _ready():
	print("starting json file check")
	if not _does_save_exist():
		_create_save_file()
		_init_save()



func _does_save_exist() -> bool:
	var dir = DirAccess.open("user://")
	return dir.file_exists(_LOCAL_SAVE_FILE)

func _create_save_file():
	var save = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.WRITE)
	
func _init_save():
	var data_to_send = {"artifacts" : [{"name": "temp", "dir": "tempp" }, {"name": "temp1", "dir": "tempp1" }]}
	var json_string = JSON.stringify(data_to_send)
	var json = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.WRITE)
	json.store_string(json_string)
	json.close()
	var jsonr = JSON.new()
	var error = jsonr.parse(json_string)
	if error == OK:
		var data_received = jsonr.data
		print(json_string)
		if typeof(data_received) == TYPE_ARRAY:
			print(data_received) # Prints the array.
		else:
			print("Unexpected data")
			print(data_received) # Prints the array.
	else:
		print("JSON Parse Error: ", jsonr.get_error_message(), " in ", json_string, " at line ", jsonr.get_error_line())
