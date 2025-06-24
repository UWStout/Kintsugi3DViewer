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
	var data_to_send = {"artifacts" : [{"name": "temp", "dir": "tempp" }]}
	var json_string = JSON.stringify(data_to_send)
	var json = FileAccess.open("user://" + _LOCAL_SAVE_FILE, FileAccess.WRITE)
	json.store_string(json_string)
	json.close()
