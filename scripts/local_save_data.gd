extends Node

const _LOCAL_SAVE_FILE : String = "localdata.json"

func _ready():
	if not _does_save_exist():
		_create_save_file()
	#TODO: Check that all file paths are valid if a JSON file already exists


func _does_save_exist() -> bool:
	var dir = DirAccess.open("user://")
	return dir.file_exists(_LOCAL_SAVE_FILE)

func _create_save_file():
	var save = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.WRITE)
	_init_save()
	
func _init_save():
	var json_string = JSON.stringify({"artifacts" : []})
	var json = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.WRITE)
	json.store_string(json_string)
	json.close()
	
func _save_model(name, dir) -> void:
	var data_to_send = {"name" : name, "localDir" : dir}
	var file = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.READ_WRITE)
	
	var json = JSON.new()
	var parse_check = json.parse(file.get_as_text())
	var data = {}
	
	#check the data was parsed into a dictionary
	if parse_check == OK:
		if typeof(json.data) == TYPE_DICTIONARY:
			data = json.data
		else:
			print("Parsed JSON is not a dictionary.")
	else:
		print("JSON parse error: ", json.get_error_message())
		data = {}  # fallback to empty dictionary
	
	# Merge and stringify
	#check artifacts array exists, then append into array
	if not data.has("artifacts"):
		data["artifacts"] = []
	
	#TODO: This currently doesn't save the model if a duplicate file path is detected.
		#One potential modification would be to prompt to not save or overwrite.
	if not check_for_duplicates(data, data_to_send):
		data["artifacts"].append(data_to_send)
		#data["artifacts"].sort()
		var new_string = JSON.stringify(data, "\t")
		file.store_string(new_string)
		test_new_file_text(file, new_string)
		print("File successfully saved!")
	else:
		print("Model not saved; duplicate file path detected.")
	file.close()

func check_for_duplicates(data: Dictionary, new_data) -> bool:
	if not data.has("artifacts"):
		return false

	for artifact in data["artifacts"]:
		if typeof(artifact) == TYPE_DICTIONARY and artifact.has("localDir"):
			if artifact["localDir"] == new_data["localDir"]:
				return true
	return false

func test_new_file_text(file, new_string):
	var json_test = JSON.new()
	var error_test = json_test.parse(file.get_as_text())
	if error_test == OK:
		var data_received = json_test.data
		if typeof(data_received) == TYPE_DICTIONARY:
			print("Successfully saved model")
		else:
			print("Error: Not recognized as a dictionary")
	else:
		print("JSON Parse Error: ", json_test.get_error_message(), " in ", new_string, " at line ", json_test.get_error_line())

func get_dict() -> Dictionary:
	var file = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.READ_WRITE)
	
	var json = JSON.new()
	var parse_check = json.parse(file.get_as_text())
	var data = {}
	
	#check the data was parsed into a dictionary
	if parse_check == OK:
		if typeof(json.data) == TYPE_DICTIONARY:
			data = json.data
		else:
			print("Parsed JSON is not a dictionary.")
	else:
		print("JSON parse error: ", json.get_error_message())
		data = {}  # fallback to empty dictionary
	return data
