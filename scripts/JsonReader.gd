extends Node

var sceneData = {}
var light_colors : Array[Color]
var annotation_title
var annotation_text
var artifact_list

# File path used to find specific JSON file to read from
var data_file_path = "res://artifacts/guan-yu-test-voyager/scene.svx.json"

@onready var data_file_path2 = get_node("/root/GlobalFetcher/HTTP Fetcher")

func load_for_artifact(artifactIndex : int):
	# Loads dictionary object so that it could be accessed
	#sceneData = load_json_file(data_file_path)
	sceneData = await get_server_json(artifactIndex)
	update_with_json(sceneData)

func update_with_json(jsonData : Dictionary):
	# Loads dictionary object so that it could be accessed
	#sceneData = load_json_file(data_file_path)
	sceneData = jsonData
	
	if sceneData["lights"] != null:
		# Assigns colors from each light in Voyager Story scene to new light
		for light in sceneData["lights"]:
			light_colors.append(Color(light["color"][0], light["color"][1], light["color"][2], 1))

	# Assigns annotation title and text in Voyager Story scene to new text objects
	#annotation_title = Label.new()
	#annotation_text = Label.new()
	
	#annotation_title.text = sceneData["models"][0]["annotations"][0]["titles"]["EN"]
	#annotation_text.text = sceneData["models"][0]["annotations"][0]["leads"]["EN"]
	
	# Test to make sure items were properly grabbed
	#print(annotation_text.text)
	#print(annotation_title.text)

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
	if sceneData["models"] != null:
		return sceneData["models"].size()
	else:
		return 0

func get_model_uri(modelIndex: int):
	if sceneData["models"] != null:
		# TODO support multiple derivatives, assets
		return sceneData["models"][modelIndex]["derivatives"][0]["assets"][0]["uri"]
	else:
		return null

func get_light_color(light : int):
	if light < light_colors.size():
		return light_colors[light]
	else:
		print("Chosen light doesn't exist!")

func get_voyager_node_count():
	if sceneData["nodes"] != null:
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
		
func get_voyager_node_translation(nodeIndex : int) -> Vector3:
	if sceneData["nodes"] != null and nodeIndex < get_voyager_node_count() \
			and sceneData["nodes"][nodeIndex].has("translation"):
		var x = sceneData["nodes"][nodeIndex]["translation"][0]
		var y = sceneData["nodes"][nodeIndex]["translation"][1]
		var z = sceneData["nodes"][nodeIndex]["translation"][2]
		
		if x != null and y != null and z != null:
			return Vector3(x, y, z) * 0.1 # TODO figure out more robust unit conversion
	
	# default
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
