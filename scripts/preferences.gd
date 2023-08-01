extends Node

const _PREFERENCES_FILE : String = "preferences.pref"

var signals_dict = {
	"preference_name" : "signal"
}

func _ready():
	if not _does_pref_exist():
		_create_pref_file()
		_init_prefs()
	
	#write_pref("cache size", 1000)

func _does_pref_exist() -> bool:
	var dir = DirAccess.open("user://")
	return dir.file_exists(_PREFERENCES_FILE)

func _create_pref_file():
	var pref = FileAccess.open("user://" + _PREFERENCES_FILE, FileAccess.WRITE)

func _init_prefs():
	write_pref("cache size", 2000)
	write_pref("cache mode", CacheManager.REDUCE_CACHE_MODE.OLDEST)
	write_pref("allow ip change", true)
	write_pref("ip", "https://chviewer.jbuelow.com/")
	write_pref("offline mode", false)
	write_pref("low res only", false)
	write_pref("shadows", GraphicsController.SHADOWS.SOFT_MEDIUM)
	write_pref("aa", Viewport.MSAA_4X)
	write_pref("gi", GraphicsController.GLOBAL_ILLUMINATION.DISABLED)
	write_pref("ssao", GraphicsController.SSAO.MEDIUM)
	write_pref("ssil", GraphicsController.SSIL.DISABLED)
	write_pref("ssr", GraphicsController.SSR.DISABLED)
	write_pref("subsurface scattering", GraphicsController.SUBSURFACE.MEDIUM)

func write_pref(name : String, value):
	var formatted_name = get_formatted_name(name)
	
	var target_line = formatted_name + ":" + var_to_str(value)
	
	var lines = get_lines_in_file("user://" + _PREFERENCES_FILE)
	
	var pref = FileAccess.open("user://" + _PREFERENCES_FILE, FileAccess.WRITE)
	
	var found_line : bool = false
	for line in lines:
		if line.is_empty():
			continue
			
		var parts = line.split(":")
		if parts.size() > 1:
			# If this is the line to be replaced with a new value
			if parts[0] == formatted_name:
				pref.store_line(target_line)
				found_line = true
			else:
				pref.store_line(line)
		else:
			pref.store_line(line)
	
	if not found_line:
		pref.store_line(target_line)
		found_line = true

func read_pref(name : String):
	var formatted_name = get_formatted_name(name)
	
	var lines = get_lines_in_file("user://" + _PREFERENCES_FILE)
	
	for line in lines:
		var parts = line.split(":", false, 1)
		if parts.size() > 1 and parts[0] == formatted_name:
				return str_to_var(parts[1].strip_edges())
	
	return null

func get_formatted_name(name : String) -> String:
	var formatted_name = name.to_lower()
	formatted_name = formatted_name.strip_edges()
	formatted_name = formatted_name.replace(" ", "-")
	formatted_name = formatted_name.replace("\n", "-")
	formatted_name = formatted_name.replace("\t", "-")
	return formatted_name

func get_lines_in_file(file_path : String) -> Array[String]:
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	var lines : Array[String] = []
	while not file.eof_reached():
		lines.push_back(file.get_line())
	
	return lines

func has_pref(name : String) -> bool:
	var formatted_name = get_formatted_name(name)
	
	var lines = get_lines_in_file("user://" + _PREFERENCES_FILE)
	
	for line in lines:
		if line.begins_with(formatted_name):
			return true
	
	return false
