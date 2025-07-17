extends Node

const _LOCAL_SAVE_FILE : String = "localdata.json"

func _ready():
	if not _does_save_exist():
		_create_save_file()
	#Check that all file paths are valid if a JSON file already exists
	else:
		print("Local save file exists, checking entries...")
		var file = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.READ_WRITE)
		#parse the file to pull the exisitng data
		var json = JSON.new()
		var parse_check = json.parse(file.get_as_text())
		var data = {}
		if parse_check == OK:
			if typeof(json.data) == TYPE_DICTIONARY:
				data = json.data
			else:
				#failsafe: reset the file with no data
				print("Parsed JSON is not a dictionary.")
				data = { "artifacts": [] }
		else:
			#failsafe: reset the file with no data
			print("JSON parse error: ", json.get_error_message())
			data = { "artifacts": [] }
			
		file = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.WRITE)
		var valid_artifacts = []
		for artifact in data["artifacts"]:
			if typeof(artifact) != TYPE_DICTIONARY:
				continue
			var file_path = artifact.get("localDir", "")
			var name = artifact.get("name", "Unnamed")
			if not FileAccess.file_exists(file_path):
				print("Missing file at path: %s (for %s)" % [file_path, name])
			else:
				print("Valid file path for: %s" % name)
				valid_artifacts.append(artifact)
		#rewrite file only using data with valid file paths
		#future thing: have extra workflow to either delete or reassign broken file paths
		var json_string = JSON.stringify({ "artifacts": valid_artifacts }, "\t")
		file.store_string(json_string)
		file.close()



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
	
func _save_model(name, dir) -> bool:
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
			print("Parsed JSON is not a dictionary. Resetting file")
			data = { "artifacts": [] }
	else:
		print("JSON parse error: ", json.get_error_message())
		data = {}  # fallback to empty dictionary
	
	# Merge and stringify
	#check artifacts array exists, then append into array
	if not data.has("artifacts"):
		data["artifacts"] = []
	
	#this checks for duplicates; returns true if saved, false if a duplicate was detected
	#note: currently no other edge cases, this assumes that it either saved successfully or it's a duplicate
	if not check_for_duplicates(data, data_to_send):
		data["artifacts"].append(data_to_send)
		var new_string = JSON.stringify(data, "\t")
		file.store_string(new_string)
		test_new_file_text(file, new_string)
		print("File successfully saved!")
		file.close()
		return true
	print("Model not saved; duplicate file path detected.")
	file.close()
	return false

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
			print("File stable")
		else:
			print("Error: File not recognized as a dictionary")
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
	
func overwrite_exisitng_filename(filepath, new_name) -> void:
	var file = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.READ_WRITE)
	
	var json = JSON.new()
	var parse_check = json.parse(file.get_as_text())
	var data = {}
	
	#check the data was parsed into a dictionary
	if parse_check == OK:
		if typeof(json.data) == TYPE_DICTIONARY:
			data = json.data
		else:
			print("Parsed JSON is not a dictionary. Resetting file")
			data = { "artifacts": [] }
	else:
		print("JSON parse error: ", json.get_error_message())
		data = {}  # fallback to empty dictionary
	
	# Merge and stringify
	#check artifacts array exists, then append into array
	if not data.has("artifacts"):
		data["artifacts"] = []
	for i in data["artifacts"].size():
		if data["artifacts"][i]["localDir"] == filepath:
			data["artifacts"][i]["name"] = new_name
	var new_string = JSON.stringify(data, "\t")
	file.store_string(new_string)
	test_new_file_text(file, data)
	print("Overwrite sucessful!")
	file.close()
