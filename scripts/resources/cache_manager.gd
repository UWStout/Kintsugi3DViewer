# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Node

signal cache_item_deleted

const _CACHE_ROOT_DIR : String = "user://cache/"
const _CACHE_META_FILE : String = "cache.manifest"

enum REDUCE_CACHE_MODE {LARGEST = 0, SMALLEST = 1, NEWEST = 2, OLDEST = 3}

# 2 gigs
var cache_size_limit : int = 2000000000

var outsized_folders : Array[String] = []

var cache_mode : REDUCE_CACHE_MODE = REDUCE_CACHE_MODE.OLDEST

var worker_threads : Array[Thread] = []
var worker_thread_mutex : Mutex

func _ready():
	worker_thread_mutex = Mutex.new()
	
	var pref_cache_size = Preferences.read_pref("cache size")
	if not pref_cache_size == null:
		cache_size_limit = mb_to_bytes(pref_cache_size)
	
	var pref_cache_mode = Preferences.read_pref("cache mode")
	if not pref_cache_mode == null:
		cache_mode = pref_cache_mode
	
	create_cache_directory()
	
	show_cache_info()
	
	reduce_cache(cache_mode)

func _process(delta):
	worker_thread_mutex.lock()
	# Need to explicitly close threads on web
	for i in range(0, worker_threads.size()):
		var thread = worker_threads[i]
		if thread.is_started() and !thread.is_alive():
			thread.wait_to_finish()
			worker_threads.remove_at(i)
			break # catch any other threads that need to be closed on the next _update()
	worker_thread_mutex.unlock()

func create_cache_directory():
	var dir = DirAccess.open("user://")
	dir.make_dir(_CACHE_ROOT_DIR.trim_prefix("user://"))
	
	if not FileAccess.file_exists(_CACHE_ROOT_DIR + "cache.manifest"):
		var manifest = FileAccess.open(_CACHE_ROOT_DIR + "cache.manifest", FileAccess.WRITE_READ)

func open_dir(dir_name : String):
	var dir = DirAccess.open(_CACHE_ROOT_DIR)
	
	if dir == null:
		#printerr("could not access the cache at directory " + _CACHE_ROOT_DIR)
		return
	
	if not dir.dir_exists(dir_name):
		#print("directory " + _CACHE_ROOT_DIR + dir_name + "/ does not exist")
		
		var error = dir.make_dir(dir_name)
		
		if error:
			#var err_message = "there was an error while trying to creat the directory "
			#err_message += _CACHE_ROOT_DIR + dir_name + "/. error " + error_string(error)
			#printerr(err_message)
			return
		else:
			#print("created directory " + _CACHE_ROOT_DIR + dir_name + "/")
			return


func import_gltf(dir_name : String, name : String):
	var file_name = name + ".glb"
	var dir_path = _CACHE_ROOT_DIR + dir_name + "/"
	
	#open_dir(dir_name)
	var dir = DirAccess.open(_CACHE_ROOT_DIR + dir_name)
	
	if dir == null:
		#print("directory " + dir_path + " does not exist")
		return null
	
	if not dir.file_exists(file_name):
		#print("could not locate file " + file_name + " in directory " + dir_path)
		return null
	
	# Import the GLTF
	var file_path = dir_path + file_name
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	var buffer = file.get_buffer(file.get_length())
	
	var gltf = GLTFDocument.new()
	var state = GLTFState.new()
	
	var error = gltf.append_from_buffer(buffer, "", state, 0x20)
	
	if error:
		#var err_message = "there was an error while attempting to import file "
		#err_message += file_name + " from directory " + dir_path  + ". error " + error_string(error)
		#print(err_message)
		return null
	
	# Import the JSON
	file_name = name + ".json"
	if not dir.file_exists(file_name):
		#print("could not locate file " + file_name + " in directory " + dir_path)
		return null
	
	file_path = dir_path + file_name
	
	file = FileAccess.open(file_path, FileAccess.READ)
	
	state.json = JSON.parse_string(file.get_as_text())
	
	#print("imported file " + name + ".glb from directory " + dir_path)
	#print("imported file " + name + ".json from directory " + dir_path)
	
	return {"doc" : gltf, "state" : state}

func export_gltf(dir_name : String, name : String, doc : GLTFDocument, state : GLTFState):
	#if outsized_folders.has(dir_name):
		#return
	
	if UrlReader.parameters.has("locked") and UrlReader["locked"]:
		return
	
	var buffer = doc.generate_buffer(state.duplicate())
	var file_size = buffer.size()
	if not should_add_to_cache(file_size):
		reduce_cache_for_size(file_size, cache_mode)
		#print("could not export " + name + ".glb to directory " + _CACHE_ROOT_DIR + dir_name + "/ because it would overflow the cache")
		#print("\tcurrent cache size: " + str(get_cache_size()) + ", max cache size: " + str(cache_size_limit))
		#print("\tpercent cache used: " + str(get_cache_size() / (cache_size_limit as float) * 100) + "%")
#	if not should_add_to_cache(file_size):
#		if not outsized_folders.has(dir_name):
#			outsized_folders.push_back(dir_name)
#			remove_from_cache(dir_name)
#		return
	
	open_dir(dir_name)
	
	var file_name = name + ".glb"
	var dir_path = _CACHE_ROOT_DIR + dir_name + "/"

	# Export the json of the GLTFState
	if not state.json == null:
		var file = FileAccess.open(dir_path + name + ".json", FileAccess.WRITE)
		
		if file == null:
			#printerr("could not export the file " + name + ".json to directory " + dir_path)
			pass
		else:
			file.store_line(JSON.stringify(state.json))
			#print("exported file " + name + ".json to directory " + dir_path)

	# Export the .glb file
	doc.write_to_filesystem(state, dir_path + file_name)
	print("exported file " + file_name + " to directory " + dir_path)
	#print("\tcurrent cache size: " + str(get_cache_size()) + ", max cache size: " + str(cache_size_limit))
	#print("\tpercent cache used: " + str(get_cache_size() / (cache_size_limit as float) * 100) + "%")

func export_gltf_async(dir_name : String, name : String, doc : GLTFDocument, state : GLTFState):
	var thread = Thread.new()
	thread.start(self.export_gltf.bind(dir_name, name, doc, state))
	
	worker_thread_mutex.lock()
	worker_threads.append(thread)
	worker_thread_mutex.unlock()

func import_png(dir_name : String, name : String) -> Image:
	var file_name = name + ".png"
	var dir_path = _CACHE_ROOT_DIR + dir_name + "/"
	
	#open_dir(dir_name)
	var dir = DirAccess.open(_CACHE_ROOT_DIR + dir_name)
	
	if dir == null:
		#print("directory " + dir_path + " does not exist")
		return null
	
	if not dir.file_exists(file_name):
		#print("could not locate file " + file_name + " in directory " + dir_path)
		return null
	
	var file_path = dir_path + file_name
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	var buffer = file.get_buffer(file.get_length())
	
	var image = Image.new()
	
	var error = image.load_png_from_buffer(buffer)
	
	if error:
		#var err_message = "there was an error while attempting to import file "
		#err_message += file_name + " from directory " + dir_path + ". error " + error_string(error)
		#print(err_message)
		return null
	
	#print("imported file " + file_name + " from directory " + dir_path)
	
	return image

func export_png(dir_name : String, name : String, image : Image):
#	if outsized_folders.has(dir_name):
#		return
	
	if UrlReader.parameters.has("locked") and UrlReader["locked"]:
		return
	
	var file_size = image.save_png_to_buffer().size()
	if not should_add_to_cache(file_size):
		reduce_cache_for_size(file_size, cache_mode)
		#print("could not export " + name + ".png to directory " + _CACHE_ROOT_DIR + dir_name + "/ because it would overflow the cache")
		#print("\tcurrent cache size: " + str(get_cache_size()) + ", max cache size: " + str(cache_size_limit))
		#print("\tpercent cache used: " + str(get_cache_size() / (cache_size_limit as float) * 100) + "%")
#	if not should_add_to_cache(file_size):
#		if not outsized_folders.has(dir_name):
#			outsized_folders.push_back(dir_name)
#			remove_from_cache(dir_name)
#		return
	
	open_dir(dir_name)
	
	var file_name = name + ".png"
	var dir_path = _CACHE_ROOT_DIR + dir_name + "/"
	
	var dir = DirAccess.open(_CACHE_ROOT_DIR)
	
	var error = image.save_png(dir_path + file_name)
	
	if error:
		#var err_message = "there was an error while exporting the file " + file_name
		#err_message + " to directory " + dir_path
		#err_message += ". error " + error_string(error)
		#printerr(err_message)
		return
	
	print("exported file " + file_name + " to directory " + dir_path)
	#print("\tcurrent cache size: " + str(get_cache_size()) + ", max cache size: " + str(cache_size_limit))
	#print("\tpercent cache used: " + str(get_cache_size() / (cache_size_limit as float) * 100) + "%")

func export_png_async(dir_name : String, name : String, image : Image):
	var thread = Thread.new()
	thread.start(self.export_png.bind(dir_name, name, image))
	
	worker_thread_mutex.lock()
	worker_threads.append(thread)
	worker_thread_mutex.unlock()

func png_cached(dir_name: String, name: String) -> bool:
	var file_name = name + ".png"
	var dir_path = _CACHE_ROOT_DIR + dir_name + "/"
	
	#open_dir(dir_name)
	var dir = DirAccess.open(_CACHE_ROOT_DIR + dir_name)
	
	if dir == null:
		return false
	
	return dir.file_exists(file_name)


func import_artifact_data(dir_name : String):
	var dir = DirAccess.open(_CACHE_ROOT_DIR + dir_name)
	
	if not dir:
		return
	
	var lines = get_lines_in_file(dir.get_current_dir() + "/data.txt")
	var data = ArtifactData.new()
	
	if lines.size() <= 0:
		#print("data.txt not located in directory " + dir.get_current_dir())
		return data
	
	for line in lines:
		var parts = line.split(":")
		if parts.size() > 1:
			if parts[0] == "name":
				data.name = parts[1]
			if parts[0] == "uri":
				data.gltfUri = parts[1]
	
	#print("imported data.txt from directory " + dir.get_current_dir())
	
	return data

func export_artifact_data(dir_name : String, data : ArtifactData):
	
	open_dir(dir_name) # directory might not exist yet
	var dir = DirAccess.open(_CACHE_ROOT_DIR + dir_name)
	
	if UrlReader.parameters.has("locked") and UrlReader["locked"]:
		return
	
	if not dir:
		return
	
	var file = FileAccess.open(dir.get_current_dir() + "/data.txt", FileAccess.WRITE)
	
	if not file:
		return
	
	file.store_line("name:" + data.name)
	file.store_line("uri:" + data.gltfUri)
	
	print("exported data.txt to directory " + dir.get_current_dir())


func get_artifacts_in_cache(include_peristent : bool) -> Array[String]:
	var dir = DirAccess.open(_CACHE_ROOT_DIR)
	if dir == null:
		return []
	
	var artifacts : Array[String] = []
	
	var folders = dir.get_directories()
	for folder in folders:
		dir = DirAccess.open(_CACHE_ROOT_DIR + folder)
		
		if (not include_peristent) and is_persistent(folder):
			continue
		
		if dir:
			var files = dir.get_files()
			for file in files:
				if file.ends_with(".glb") or file.ends_with(".gltf"):
					artifacts.push_back(folder)
		
	return artifacts

func get_artifacts_size_in_cache(include_persistent : bool):
	var dir = DirAccess.open(_CACHE_ROOT_DIR)
	if dir == null:
		return
	
	var sizes = []
	
	var artifacts = get_artifacts_in_cache(include_persistent)
	for artifact in artifacts:
		var folder_size = get_size(artifact)
		sizes.push_back([artifact, folder_size])

	return sizes

func get_cache_size() -> int:
	var artifact_sizes = get_artifacts_size_in_cache(true)
	var cache_size = 0
	
	for artifact_size in artifact_sizes:
		cache_size += artifact_size[1]
	
	return cache_size

func is_cache_oversized() -> bool:
	return get_cache_size() > cache_size_limit

func should_add_to_cache(file_size : int) -> bool:
	return get_cache_size() + file_size < cache_size_limit

func show_cache_info():
	print("<=====> (CACHE) <=====>")
	print("\tdirectory: " + _CACHE_ROOT_DIR + "\n")
	
	var mode_var = ""
	if cache_mode == REDUCE_CACHE_MODE.LARGEST:
		mode_var = "largest"
	if cache_mode == REDUCE_CACHE_MODE.SMALLEST:
		mode_var = "smallest"
	if cache_mode == REDUCE_CACHE_MODE.NEWEST:
		mode_var = "newest"
	if cache_mode == REDUCE_CACHE_MODE.OLDEST:
		mode_var = "oldest"
	
	print("\tcache mode: " + mode_var + "\n")
	
	print("\tcache limit: " + str(bytes_to_mb(cache_size_limit)) + " mb\n")
	
	print("\tcache used: " + str(bytes_to_mb(get_cache_size())) + " mb")
	
	var percent_cache_used = bytes_to_mb(get_cache_size()) / (bytes_to_mb(cache_size_limit) as float) * 100
	print("\tpercent cache used: " + str(percent_cache_used) + "%\n")
	
	print("\tcache remaining: " + str(bytes_to_mb(cache_size_limit) - bytes_to_mb(get_cache_size())) + " mb")
	print("\tpercent cache remaining: " + str(100 - percent_cache_used) + "%\n")
	
	print("\tfiles in cache:")
	
	for artifact in get_artifacts_size_in_cache(true):
		print("\t\t" + artifact[0] + " -> " + str(bytes_to_mb(artifact[1])) + " mb")
	
	print("<=====> (CACHE) <=====>\n")

func clear_cache():
	var dir = DirAccess.open(_CACHE_ROOT_DIR)
	if dir == null:
		return
	
	for artifact in get_artifacts_in_cache(true):
		remove_from_cache(artifact)
	
	outsized_folders.clear()
	
	print("cleared cache")


func remove_from_cache(folder_name : String):
	var dir = DirAccess.open(_CACHE_ROOT_DIR + "/" + folder_name)
	
	if not dir:
		return
	
	make_not_persistent(folder_name)
	update_open_time(folder_name, true)
	
	for file in dir.get_files():
		dir.remove(file)
	
	dir = DirAccess.open(_CACHE_ROOT_DIR)
	dir.remove(folder_name)
	
	print("removed folder " + folder_name + " from the cache")
	cache_item_deleted.emit()

func remove_largest():
	var artifact_size_pairs = get_artifacts_size_in_cache(false)
	
	var largest_size : int = -9223372036854775807
	var largest_index : int = -1
	
	for i in range(0, artifact_size_pairs.size()):
		if artifact_size_pairs[i][1] > largest_size:
			largest_size = artifact_size_pairs[i][1]
			largest_index = i
	
	if largest_index >= 0:
		remove_from_cache(artifact_size_pairs[largest_index][0])
		return true
	else:
		return false

func remove_smallest():
	var artifact_size_pairs = get_artifacts_size_in_cache(false)
	
	var smallest_size : int = 9223372036854775807
	var smallest_index : int = -1
	
	for i in range(0, artifact_size_pairs.size()):
		if artifact_size_pairs[i][1] < smallest_size:
			smallest_size = artifact_size_pairs[i][1]
			smallest_index = i
	
	if smallest_index >= 0:
		remove_from_cache(artifact_size_pairs[smallest_index][0])
		return true
	else:
		return false

func remove_newest():
	var artifacts = get_artifacts_in_cache(false)
	
	var newest_time : int = -9223372036854775807
	var newest_index = -1
	
	for i in range(0, artifacts.size()):
		var modified_time = get_open_time(artifacts[i])
		if modified_time == -1:
			continue
		
		if modified_time > newest_time:
			newest_time = modified_time
			newest_index = i
	
	if newest_index >= 0:
		remove_from_cache(artifacts[newest_index])
		return true
	else:
		return false

func remove_oldest():
	var artifacts = get_artifacts_in_cache(false)
	
	var oldest_time : int = 9223372036854775807
	var oldest_index = -1
	
	for i in range(0, artifacts.size()):
		var modified_time = get_open_time(artifacts[i])
		if modified_time == -1:
			continue
		
		if modified_time < oldest_time:
			oldest_time = modified_time
			oldest_index = i
	
	if oldest_index >= 0:
		remove_from_cache(artifacts[oldest_index])
		return true
	else:
		return false

func reduce_cache(mode : REDUCE_CACHE_MODE):
	var tries = 0
	var max_tries = 5
	while is_cache_oversized():
		if mode == REDUCE_CACHE_MODE.LARGEST:
			if not remove_largest():
				tries += 1
		elif mode == REDUCE_CACHE_MODE.SMALLEST:
			if not remove_smallest():
				tries += 1
		elif mode == REDUCE_CACHE_MODE.NEWEST:
			if not remove_newest():
				tries += 1
		elif mode == REDUCE_CACHE_MODE.OLDEST:
			if not remove_oldest():
				tries += 1
		
		if tries >= max_tries:
			break
	
	outsized_folders.clear()

func reduce_cache_for_size(size : int, mode : REDUCE_CACHE_MODE):
	if get_cache_size() - size > cache_size_limit:
		return
	
	var tries = 0
	var max_tries = 5
	while get_cache_size() + size >= cache_size_limit:
		if mode == REDUCE_CACHE_MODE.LARGEST:
			if not remove_largest():
				tries += 1
		elif mode == REDUCE_CACHE_MODE.SMALLEST:
			if not remove_smallest():
				tries += 1
		elif mode == REDUCE_CACHE_MODE.NEWEST:
			if not remove_newest():
				tries += 1
		elif mode == REDUCE_CACHE_MODE.OLDEST:
			if not remove_oldest():
				tries += 1
		
		if tries >= max_tries:
			break
	
	outsized_folders.clear()

func is_in_cache(artifact : String) -> bool:
	for folder in get_artifacts_in_cache(true):
		if folder == artifact:
			return true
	
	return false


func is_persistent(artifact : String) -> bool:
	var manifest = FileAccess.open(_CACHE_ROOT_DIR + _CACHE_META_FILE, FileAccess.READ)
	
	if manifest == null:
		return false
	
	while not manifest.eof_reached():
		var line = manifest.get_line()
		if artifact == line:
			return true
	
	return false

func make_persistent(artifact : String) -> bool:
	if not is_in_cache(artifact):
		return false
	
	if is_persistent(artifact):
		return false
	
	var lines = get_lines_in_file(_CACHE_ROOT_DIR + _CACHE_META_FILE)
	
	var manifest = FileAccess.open(_CACHE_ROOT_DIR + _CACHE_META_FILE, FileAccess.WRITE)
	
	if manifest == null:
		return false
	
	var found_split : bool = false
	for line in lines:
		if not line.is_empty():
			if line == "#" and not found_split:
				manifest.store_line(artifact)
				manifest.store_line("#")
				found_split = true
			else:
				manifest.store_line(line)
	
	if not found_split:
		manifest.store_line(artifact)
		manifest.store_line("#")
	
	
	return true

func make_not_persistent(artifact : String) -> bool:
	if not is_in_cache(artifact):
		return false
	
	if not is_persistent(artifact):
		return false
	
	var lines = get_lines_in_file(_CACHE_ROOT_DIR + _CACHE_META_FILE)
	
	var manifest = FileAccess.open(_CACHE_ROOT_DIR + _CACHE_META_FILE, FileAccess.WRITE)
	
	if manifest == null:
		return false
	
	for line in lines:
		if not line == artifact and not line.is_empty():
			manifest.store_line(line)
	
	return true


func get_lines_in_file(file_path : String) -> Array[String]:
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	var lines : Array[String] = []
	while not file.eof_reached():
		lines.push_back(file.get_line())
	
	return lines

func bytes_to_mb(bytes : int):
	return bytes / 1000000

func mb_to_bytes(mb : int):
	return mb * 1000000

func update_folder_date(artifact : String):
	var dir = DirAccess.open(_CACHE_ROOT_DIR + artifact)
	
	if not dir:
		return false
	
	var err = dir.rename(_CACHE_ROOT_DIR + artifact, _CACHE_ROOT_DIR + artifact + "_old")
	dir = DirAccess.open(_CACHE_ROOT_DIR + artifact + "_old")
	if err:
		return false
	if not dir:
		return false
	
	var dir2 = DirAccess.open(_CACHE_ROOT_DIR)
	err = dir2.make_dir(artifact)
	if err:
		return false
	
	dir2 = DirAccess.open(_CACHE_ROOT_DIR + artifact)
	if not dir2:
		return false
	
	for file in dir.get_files():
		err = DirAccess.copy_absolute(_CACHE_ROOT_DIR + artifact + "_old/" + file, _CACHE_ROOT_DIR + artifact + "/" + file)
		
		if err:
			print(error_string(err))
		else:
			#print("file " + file + " copied from " + dir.get_current_dir() + " to " + dir2.get_current_dir())
			err = dir.remove(file)
			
			if err:
				print(error_string(err))
	
	DirAccess.remove_absolute(_CACHE_ROOT_DIR + artifact + "_old")
	return true

func update_open_time(artifact : String, clear_time : bool):
	if not is_in_cache(artifact):
		return
	
	var lines = get_lines_in_file(_CACHE_ROOT_DIR + _CACHE_META_FILE)
	
	var manifest = FileAccess.open(_CACHE_ROOT_DIR + _CACHE_META_FILE, FileAccess.WRITE)
	
	var found_artifact : bool = false
	var found_split : bool = false
	
	for line in lines:
		if line == "#":
			found_split = true
			manifest.store_line("#")
			continue
		
		var line_parts = line.split("->", false)
		if line_parts.size() > 1:
			if line_parts[0] == artifact:
				if not clear_time:
					manifest.store_line(artifact + "->" + str(Time.get_unix_time_from_system() as int))
				found_artifact = true
			else:
				manifest.store_line(line_parts[0] + "->" + line_parts[1])
			pass
		elif not line.is_empty():
			manifest.store_line(line)
	
	if not found_split:
		manifest.store_line("#")
	
	if not found_artifact:
		manifest.store_line(artifact + "->" + str(Time.get_unix_time_from_system() as int))

func get_open_time(artifact : String):
	if not is_in_cache(artifact):
		return -1
	
	var lines = get_lines_in_file(_CACHE_ROOT_DIR + _CACHE_META_FILE)
	
	for line in lines:
		var line_parts = line.split("->", false)
		if line_parts.size() > 1:
			if line_parts[0] == artifact:
				return line_parts[1] as int
	
	return -1

func get_artifact_data() -> Array[ArtifactData]:
	var artifacts = get_artifacts_in_cache(true)
	
	var artifacts_data : Array[ArtifactData] = []
	
	for artifact in artifacts:
		artifacts_data.push_back(import_artifact_data(artifact))
	
	return artifacts_data

func get_size(artifact : String):
	var dir = DirAccess.open(_CACHE_ROOT_DIR + "/" + artifact)
	var folder_size = 0
	if dir:
		var files = dir.get_files()
		for file_name in files:
			var file = FileAccess.open(dir.get_current_dir() + "/" + file_name, FileAccess.READ)
			if not file == null:
				folder_size += file.get_length()

	return folder_size

func get_size_in_mb(artifact : String):
	var size_bytes = get_size(artifact)
	return bytes_to_mb(size_bytes)

func is_empty():
	return get_cache_size() <= 0


func get_artifacts_in_cache_ordered():
	var artifacts = get_artifacts_in_cache(true)
	
	var ordered : Array[String]
	
	while artifacts.size() > 0:
		if cache_mode == REDUCE_CACHE_MODE.LARGEST:
			var largest_size : int = -9223372036854775807
			var target_index : int = -1
			for i in range(0, artifacts.size()):
				var artifact_size = get_size(artifacts[i])
				if artifact_size >= largest_size:
					largest_size = artifact_size
					target_index = i
			
			ordered.push_back(artifacts[target_index])
			artifacts.remove_at(target_index)
		
		if cache_mode == REDUCE_CACHE_MODE.SMALLEST:
			var smallest_size : int = 9223372036854775807
			var target_index : int = -1
			for i in range(0, artifacts.size()):
				var artifact_size = get_size(artifacts[i])
				if artifact_size <= smallest_size:
					smallest_size = artifact_size
					target_index = i
			
			ordered.push_back(artifacts[target_index])
			artifacts.remove_at(target_index)
		
		if cache_mode == REDUCE_CACHE_MODE.OLDEST:
			var oldest_time : int = 9223372036854775807
			var target_index : int = -1
			for i in range(0, artifacts.size()):
				var artifact_time = get_open_time(artifacts[i])
				if artifact_time <= oldest_time:
					oldest_time = artifact_time
					target_index = i
			
			ordered.push_back(artifacts[target_index])
			artifacts.remove_at(target_index)
		
		if cache_mode == REDUCE_CACHE_MODE.NEWEST:
			var newest_time : int = -9223372036854775807
			var target_index : int = -1
			for i in range(0, artifacts.size()):
				var artifact_time = get_open_time(artifacts[i])
				if artifact_time >= newest_time:
					newest_time = artifact_time
					target_index = i
			
			ordered.push_back(artifacts[target_index])
			artifacts.remove_at(target_index)
	
	return ordered

func get_artifact_data_in_cache_ordered() -> Array[ArtifactData]:
	var ordered_artifacts = get_artifacts_in_cache_ordered()
	
	var data : Array[ArtifactData] = []
	
	for artifact in ordered_artifacts:
		data.push_back(import_artifact_data(artifact))
	
	return data

func set_cache_size_bytes(bytes : int):
	var mb = bytes_to_mb(bytes)
	cache_size_limit = bytes
	Preferences.write_pref("cache size", mb)

func set_cache_size_mb(mb : int):
	var bytes = mb_to_bytes(mb)
	cache_size_limit = bytes
	Preferences.write_pref("cache size", mb)

func set_cache_mode(mode : REDUCE_CACHE_MODE):
	cache_mode = mode
	Preferences.write_pref("cache mode", cache_mode)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		reduce_cache(cache_mode)

func get_number_images_in_artifact(artifact : String) -> int:
	var dir  = DirAccess.open(_CACHE_ROOT_DIR + artifact)
	
	if dir == null:
		return -1
	
	var count = 0
	for file in dir.get_files():
		if file.ends_with(".png"):
			count += 1
	
	return count

func get_image_names(artifact : String) -> Array[String]:
	var dir = DirAccess.open(_CACHE_ROOT_DIR + artifact)
	
	if dir == null:
		return []
	
	var arr : Array[String] = []
	for file in dir.get_files():
		if file.ends_with(".png"):
			arr.append(file.trim_suffix(".png"))
	
	return arr
