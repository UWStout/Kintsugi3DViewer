extends Node

const _LOCAL_SAVE_FILE : String = "localdata.json"

func _ready():
	print("starting json file check")
	if not _does_save_exist():
		_create_save_file()
		_init_save()
		#_test_init() #only for testing purposes
		_save_model("dummy", "data")



func _does_save_exist() -> bool:
	var dir = DirAccess.open("user://")
	return dir.file_exists(_LOCAL_SAVE_FILE)

func _create_save_file():
	var save = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.WRITE)
	
func _init_save():

	var json_string = JSON.stringify({"artifacts" : [{"name" : "Temp", "localDir" : "temp"}]})
	var json = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.WRITE)
	json.store_string(json_string)
	json.close()
	
func _test_init():
	#This writes and pulls dummy data for testing purposes.
	var data_to_send = {"artifacts" : [{"num" : 1, "num2" : 2}, {"other num1" : 3, "other num2" : 4}]}
	var json_string = JSON.stringify(data_to_send, "\t")
	var file = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.READ_WRITE)
	file.store_string(json_string)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	print(json.data)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			print("success")
			print(data_received) # Prints the array.
		else:
			print("Unexpected data")
			print(data_received) # Prints the array.
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	file.close()
	
func _save_model(name, dir) -> void:
	var data_to_send = {"name" : name, "localDir" : dir}
	var file = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.READ_WRITE)
	var original_json = JSON.new()
	var parse = original_json.parse(file.get_as_text())
	#TODO
		#turn current file into dictionary
		#add data_to_send to dictionary
	var json_string #stringify new dictionary
	file.store_string(json_string)
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	print(json.data)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			print("success")
		else:
			print("not recognized as a dictionary")
			print(typeof(data_received))
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	file.close()
