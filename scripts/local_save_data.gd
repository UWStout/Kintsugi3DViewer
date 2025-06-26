extends Node

const _LOCAL_SAVE_FILE : String = "localdata.json"

func _ready():
	print("starting json file check")
	if not _does_save_exist():
		_create_save_file()
		#_init_save()
		_test_init() #currently in testing/prototyping stages, will use init save in final architecture



func _does_save_exist() -> bool:
	var dir = DirAccess.open("user://")
	return dir.file_exists(_LOCAL_SAVE_FILE)

func _create_save_file():
	var save = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.WRITE)
	
func _init_save():
	var json_string = JSON.stringify({"artifacts" : []})
	var json = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.WRITE)
	json.store_string(json_string)
	json.close()
	
func _test_init():
	#This writes and pulls dummy data for testing purposes.
	var data_to_send = {"artifacts" : [{"name": "temp", "localDir": "tempp" }, {"name": "temp1", "localDir": "tempp1" }]}
	var json_string = JSON.stringify(data_to_send)
	var json = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.WRITE)
	json.store_string(json_string)
	json.get_as_text()
	var error = json.parse(json_string)
	if error == OK:
		var data_received = json.data
		print(json_string)
		if typeof(data_received) == TYPE_ARRAY:
			print(data_received) # Prints the array.
		else:
			print("Unexpected data")
			print(data_received) # Prints the array.
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		json.close()
func _save_model(name, dir) -> void:
	var data_to_send = {"name" : name, "localDir" : dir}
