extends Node

const _MOBILE_FLAG : bool = false

const _CACHE_ROOT_DIR : String = "user://cache/"

func _ready():
	create_cache_directory()

func create_cache_directory():
	if _MOBILE_FLAG:
		return
	
	var dir = DirAccess.open("user://")
	dir.make_dir("cache/")

func open_dir(dir_name : String):
	if _MOBILE_FLAG:
		return
	
	var dir = DirAccess.open(_CACHE_ROOT_DIR)
	print(dir.get_current_dir(false))
	
	if dir == null:
		printerr("could not access the cache at directory " + _CACHE_ROOT_DIR)
	
	if not dir.dir_exists(dir_name):
		print("directory " + _CACHE_ROOT_DIR + dir_name + "/ does not exist")
		
		var error = dir.make_dir(dir_name)
		
		if error:
			var err_message = "there was an error while trying to creat the directory "
			err_message += _CACHE_ROOT_DIR + dir_name + "/. error " + error_string(error)
			printerr(err_message)
		else:
			print("created directory " + _CACHE_ROOT_DIR + dir_name + "/")

func import_gltf(dir_name : String, name : String):
	var file_name = name + ".glb"
	var dir_path = _CACHE_ROOT_DIR + dir_name + "/"
	
	if _MOBILE_FLAG:
		return null
	
	var dir = DirAccess.open(_CACHE_ROOT_DIR + dir_name)
	
	if not dir.file_exists(file_name):
		print("could not locate file " + file_name + " in directory " + dir_path)
		return null
	
	# Import the GLTF
	var file_path = dir_path + file_name
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	var buffer = file.get_buffer(file.get_length())
	
	var gltf = GLTFDocument.new()
	var state = GLTFState.new()
	
	var error = gltf.append_from_buffer(buffer, "", state, 0x20)
	
	if error:
		var err_message = "there was an error while attempting to import file "
		err_message += file_name + " from directory " + dir_path  + ". error " + error_string(error)
		print(err_message)
		return null
	
	# Import the JSON
	file_name = name + ".json"
	if not dir.file_exists(file_name):
		print("could not locate file " + file_name + " in directory " + dir_path)
		return null
	
	file_path = dir_path + file_name
	
	file = FileAccess.open(file_path, FileAccess.READ)
	
	state.json = JSON.parse_string(file.get_as_text())
	
	print("imported file " + name + ".glb from directory " + dir_path)
	print("imported file " + name + ".json from directory " + dir_path)
	return {"doc" : gltf, "state" : state}

func export_gltf(dir_name : String, name : String, doc : GLTFDocument, state : GLTFState):
	var file_name = name + ".glb"
	var dir_path = _CACHE_ROOT_DIR + dir_name + "/"
	
	if _MOBILE_FLAG:
		return

	# Export the json of the GLTFState
	if not state.json == null:
		var file = FileAccess.open(dir_path + name + ".json", FileAccess.WRITE)
		
		if file == null:
			printerr("could not export the file " + name + ".json to directory " + dir_path)
		else:
			file.store_line(JSON.stringify(state.json))
			print("exported file " + name + ".json to directory " + dir_path)

	# Export the .glb file
	doc.write_to_filesystem(state, dir_path + file_name)
	print("exported file " + file_name + " to directory " + dir_path)

func import_png(dir_name : String, name : String) -> Image:
	var file_name = name + ".png"
	var dir_path = _CACHE_ROOT_DIR + dir_name + "/"
	
	if _MOBILE_FLAG:
		return null
	
	var dir = DirAccess.open(_CACHE_ROOT_DIR + dir_name)
	
	if not dir.file_exists(file_name):
		print("could not locate file " + file_name + " in directory " + dir_path)
		return null
	
	var file_path = dir_path + file_name
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	var buffer = file.get_buffer(file.get_length())
	
	var image = Image.new()
	
	var error = image.load_png_from_buffer(buffer)
	
	if error:
		var err_message = "there was an error while attempting to import file "
		err_message += file_name + " from directory " + dir_path + ". error " + error_string(error)
		print(err_message)
		return null
	
	print("imported file " + file_name + " from directory " + dir_path)
	return image

func export_png(dir_name : String, name : String, image : Image):
	var file_name = name + ".png"
	var dir_path = _CACHE_ROOT_DIR + dir_name + "/"
	
	if _MOBILE_FLAG:
		return
	
	var error = image.save_png(dir_path + file_name)
	
	if error:
		var err_message = "there was an error while exporting the file " + file_name
		err_message + " to directory " + dir_path
		err_message += ". error " + error_string(error)
		printerr(err_message)
		return
	
	print("exported file " + file_name + " to directory " + dir_path)
