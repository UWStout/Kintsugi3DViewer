extends Node

var sceneData = {}
var light_colors : Array[Color]
var light_int : Array[float]
var light_type : Array[String]
var annotation_title
var annotation_text
var artifact_list
# File path used to find specific JSON file to read from
var data_file_path = "res://artifacts/guan-yu-test-voyager/scene.svx.json"
const ANNO_TEXT_BOX = preload("res://scenes/annotations/annotation_textbox.tscn")
const ANNO_MARKER = preload("res://scenes/annotations/annotation_marker.tscn")
const ANNO_FOCUS_POINT = preload("res://scenes/annotations/annotation_focuspoint.tscn")
@onready var data_file_path2 = get_node("/root/GlobalFetcher/HTTP Fetcher")

func load_for_artifact(artifactIndex : int):
	# Loads dictionary object so that it could be accessed
	#ICATION_ENABLEDNOTIFsceneData = load_json_file(data_file_path)
	sceneData = await get_server_json(artifactIndex)
	update_with_json(sceneData)

func update_with_json(jsonData : Dictionary):
	# Loads dictionary object so that it could be accessed
	#sceneData = load_json_file(data_file_path)
	sceneData = jsonData
	light_colors.clear() 
	light_type.clear()
	light_int.clear()
	if sceneData["lights"] != null:
		# Assigns colors from each light in Voyager Story scene to new light
		for light in sceneData["lights"]:
			light_type.append(light["type"])
			light_int.append(light["intensity"])
			if not light.has("color"):
				print("Light missing color key: ", light)
				print(light["type"])
				light_colors.append(Color.BLACK)
			else:	
				light_colors.append(Color(light["color"][0], light["color"][1], light["color"][2], 1))
				

	# Assigns annotation title and text in Voyager Story scene to new text objects
	
	# Test to make sure items were properly grabbed


func get_server_json(artifactIndex : int) -> Dictionary:
	artifact_list = await data_file_path2.force_fetch_artifacts()
	
	if artifactIndex < artifact_list.size():
		var voyager_json_uri = artifact_list[artifactIndex].voyagerUri
		
		if voyager_json_uri != null:
			var voyager_json = await data_file_path2.force_fetch_json(voyager_json_uri)
			return voyager_json
			
	return {} # if invalid index or no Voyager URI
	
	#return data_file_path2.artifacts_cache

func get_model_count():
	if sceneData.has("models") && sceneData["models"] != null:
		return sceneData["models"].size()
	else:
		return 0

func get_model_uri(modelIndex: int):
	if sceneData["models"] != null:
		# TODO support multiple derivatives, assets
		return sceneData["models"][modelIndex]["derivatives"][0]["assets"][0]["uri"]
	else:
		return null
		
func get_light_spot_data(light: int) -> Dictionary:
	if sceneData.has("lights") and light < sceneData["lights"].size():
		return sceneData["lights"][light].get("spot", {})
	return {}

func get_light_type(light : int):
	if light < light_type.size():
		return light_type[light]
	else:
		print("Chosen light doesn't exist!")
		
func get_light_intensity(light : int):
	if light < light_int.size():
		return light_int[light]
	else:
		print("Chosen light doesn't exist!")
		
func get_light_color(light : int):
	if light < light_colors.size():
		return light_colors[light]
	else:
		print("Chosen light doesn't exist!")

func get_voyager_node_count():
	if sceneData.has("nodes") && sceneData["nodes"] != null:
		return sceneData["nodes"].size()
	else:
		return 0
		
func is_voyager_node_light(nodeIndex: int) -> bool:
	return sceneData["nodes"] != null and nodeIndex < get_voyager_node_count() \
		and sceneData["nodes"][nodeIndex].has("light") 
		
func is_voyager_node_camera(nodeIndex: int) -> bool:
	return sceneData["nodes"] != null and nodeIndex < get_voyager_node_count() \
		and sceneData["nodes"][nodeIndex].has("camera")
		
func is_voyager_node_model(nodeIndex: int) -> bool:
	return sceneData["nodes"] != null and nodeIndex < get_voyager_node_count() \
		and sceneData["nodes"][nodeIndex].has("model")
		
func get_voyager_node_model_index(nodeIndex: int) -> int:
	if (is_voyager_node_model(nodeIndex)):
		return sceneData["nodes"][nodeIndex]["model"]
	else:
		return -1
	
func get_voyager_node_scale (nodeIndex : int) -> Vector3:
	if sceneData["nodes"] != null and nodeIndex < get_voyager_node_count() \
			and sceneData["nodes"][nodeIndex].has("scale"):
		var x = sceneData["nodes"][nodeIndex]["scale"][0]
		var y = sceneData["nodes"][nodeIndex]["scale"][1]
		var z = sceneData["nodes"][nodeIndex]["scale"][2]
		
		if x != null and y != null and z != null:
			return Vector3(x, y, z)
	
	# default
	return Vector3(1, 1, 1)
		
		
func get_snapshot_display_scale(modelIndex: int) -> float:
	return get_units_to_meters() / get_model_units_to_meters(modelIndex)
	
func get_setup_units_to_meters(setupIndex: int = 0) -> float:
	var setups = sceneData.get("setups", [])
	if setups.is_empty() or setupIndex >= setups.size():
		return get_units_to_meters()  # fallback
	var units = setups[setupIndex].get("units", "mm")
	match units:
		"mm": return 0.001
		"cm": return 0.01
		"dm": return 0.1
		"m":  return 1.0
		"km": return 1000.0
		"in": return 0.0254
		"ft": return 0.3048
		"yd": return 0.9144
		_:
			push_error("Unknown unit type in Voyager setup: %s" % units)
			return get_units_to_meters()
			
func get_model_units_to_meters(modelIndex: int) -> float:
	if sceneData["models"] == null or modelIndex >= sceneData["models"].size():
		return get_units_to_meters()  # fall back to scene units
	
	var units = sceneData["models"][modelIndex].get("units", "")
	
	if units.is_empty():
		return get_units_to_meters()  # fall back to scene units
	
	match units:
		"mm":
			return 0.001
		"cm":
			return 0.01
		"dm":
			return 0.1
		"m":
			return 1.0
		"km":
			return 1000.0
		"in":
			return 0.0254
		"ft":
			return 0.3048
		"yd":
			return 0.9144
		_:
			push_error("Unknown unit type in Voyager model %s: %s" % [modelIndex, units])
			return get_units_to_meters()  # fall back to scene units

func get_units_to_meters() -> float:
	var scenes = sceneData.get("scenes", [])
	if scenes.is_empty():
		return 0.001  # fallback to mm
	var units = scenes[0].get("units", "mm")
	match units:
		"mm":
			return 0.001
		"cm":
			return 0.01
		"dm":
			return 0.1
		"m":
			return 1.0
		"km":
			return 1000.0
		"in":
			return 0.0254
		"ft":
			return 0.3048
		"yd":
			return 0.9144
		_:
			push_error("Unknown unit type in Voyager scene: %s" % units)
			return 0.001  # fallback

func has_annotation()-> bool:
	for model in sceneData["models"]:
		if model.has("annotations"):
			return true
	return false
	
func get_annotation_count()-> int:
	var anno_count = 0
	for model in sceneData["models"]:
		if model.has("annotations"):
			anno_count +=  model["annotations"].size()
	return anno_count
	
func setup_annotations() -> Array[AnnotationMarker]:
	var markers : Array[AnnotationMarker]
	var model_index = -1
	for model in sceneData["models"]:
		model_index += 1
		if  model.has("annotations"):
			
			for x in model["annotations"]:
				annotation_title = x["titles"]["EN"]
				annotation_text = x["leads"]["EN"]
				
							
				var marker = ANNO_MARKER.instantiate()
				var focuspoint = ANNO_FOCUS_POINT.instantiate()
				if x.has("viewId"):
					var snapshots = sceneData["setups"][0]["snapshots"]["states"]
					for snaps in snapshots:
						if x["viewId"] == snaps["id"]:
							focuspoint.view_position = Vector3(snaps["values"][snaps["values"].size() - 1][0],
							snaps["values"][snaps["values"].size() - 1][1], 
							snaps["values"][snaps["values"].size() - 1][2]) 
							focuspoint.view_angle =Vector3(snaps["values"][snaps["values"].size() - 2][0],
							snaps["values"][snaps["values"].size() - 2][1], 
							snaps["values"][snaps["values"].size() - 2][2])
							focuspoint.do_pan_to_annotation = true
							focuspoint.voyager_scale = get_snapshot_display_scale(model_index)
				marker.textbox.annotation_name = annotation_title
				marker.textbox.annotation_text = annotation_text
				marker.textbox.recalc_text(true)
				marker.focus_point = focuspoint
				marker.global_position = Vector3(x["position"][0],x["position"][1],x["position"][2])
				marker.add_child(focuspoint)
				marker.viewing_angle = Vector3(x["direction"][0], x["direction"][1], x["direction"][2])
				AnnotationsManager.register_new_annotation(marker)
				markers.append(marker)
	return markers

func get_voyager_node_translation(nodeIndex : int) -> Vector3:
	if sceneData["nodes"] != null and nodeIndex < get_voyager_node_count() \
			and sceneData["nodes"][nodeIndex].has("translation"):
		var x = sceneData["nodes"][nodeIndex]["translation"][0]
		var y = sceneData["nodes"][nodeIndex]["translation"][1]
		var z = sceneData["nodes"][nodeIndex]["translation"][2]
		
		if x != null and y != null and z != null:
			return Vector3(x, y, z) * get_units_to_meters() # TODO figure out more robust unit conversion
		
	elif is_voyager_node_model(nodeIndex):
		var modelIndex : int = int(sceneData["nodes"][nodeIndex]["model"])
		var x = sceneData["models"][modelIndex]["translation"][0]
		var y = sceneData["models"][modelIndex]["translation"][1]
		var z = sceneData["models"][modelIndex]["translation"][2]
		if x != null and y != null and z != null:
			#print("getting units to meters: ",get_model_units_to_meters(modelIndex))
			return Vector3(x, y, z) * get_model_units_to_meters(modelIndex) 
			
	return Vector3(0, 0, 0)

func get_voyager_node_quaternion(nodeIndex : int) -> Quaternion:
	if sceneData["nodes"] != null and nodeIndex < get_voyager_node_count() \
			and sceneData["nodes"][nodeIndex].has("rotation"):
		var x = sceneData["nodes"][nodeIndex]["rotation"][0]
		var y = sceneData["nodes"][nodeIndex]["rotation"][1]
		var z = sceneData["nodes"][nodeIndex]["rotation"][2]
		var w = sceneData["nodes"][nodeIndex]["rotation"][3]
		
		if x != null and y != null and z != null and w != null:
			return Quaternion(x, y, z, w)
			
	elif is_voyager_node_model(nodeIndex):
		var modelIndex : int = int(sceneData["nodes"][nodeIndex]["model"])
		if  sceneData["models"][modelIndex].has("rotation"):
			var x = sceneData["models"][modelIndex]["rotation"][0]
			var y = sceneData["models"][modelIndex]["rotation"][1]
			var z = sceneData["models"][modelIndex]["rotation"][2]
			var w = sceneData["models"][modelIndex]["rotation"][3]
			if x != null and y != null and z != null and w != null:
				return Quaternion(x, y, z, w)
	# default
	return Quaternion()

func get_voyager_node_child_indices(nodeIndex: int) -> Array:
	if sceneData["nodes"] != null and nodeIndex < get_voyager_node_count() \
			and sceneData["nodes"][nodeIndex].has("children"):
		return sceneData["nodes"][nodeIndex]["children"]
	else:
		return []
		
func get_voyager_root_node_indices(sceneIndex: int) -> Array:
	if sceneData["scenes"] != null and sceneIndex < sceneData["scenes"].size() \
			and sceneData["scenes"][sceneIndex].has("nodes"):
		return sceneData["scenes"][sceneIndex]["nodes"]
	else:
		return []
		
func load_json_file(filePath : String):
	if FileAccess.file_exists(filePath):
		# Reads JSON file and parses it into dictionary
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		
		if parsedResult is Dictionary:
			return parsedResult
		else:
			print("Error reading file")
		
		
	else:
		print("File doesn't exist!")
