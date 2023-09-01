extends Node

var sceneData = {}
var light_color1
var light_color2
var light_color3
var annotation_title
var annotation_text

# File path used to find specific JSON file to read from
var data_file_path = "res://artifacts/guan-yu-test-voyager/scene.svx.json"


func _ready():
	# Loads dictionary object so that it could be accessed
	sceneData = load_json_file(data_file_path)
	
	# Assigns colors from each light in Voyager Story scene to new light
	light_color1 = Color(sceneData["lights"][0]["color"][0], sceneData["lights"][0]["color"][1], sceneData["lights"][0]["color"][2], 1)
	light_color2 = Color(sceneData["lights"][1]["color"][0], sceneData["lights"][1]["color"][1], sceneData["lights"][1]["color"][2], 1)
	light_color3 = Color(sceneData["lights"][2]["color"][0], sceneData["lights"][2]["color"][1], sceneData["lights"][2]["color"][2], 1)

	# Assigns annotation title and text in Voyager Story scene to new text objects
	annotation_title = Label.new()
	annotation_text = Label.new()
	
	annotation_title.text = sceneData["models"][0]["annotations"][0]["titles"]["EN"]
	annotation_text.text = sceneData["models"][0]["annotations"][0]["leads"]["EN"]
	
	# Test to make sure items were properly grabbed
	print(annotation_text.text)
	print(annotation_title.text)
	

func get_light_color(light : int):
	if light == 1:
		return light_color1
	elif light == 2:
		return light_color2
	elif light == 3:
		return light_color3
	else:
		print("Chosen light doesn't exist!")
		
		
func get_model_scale():
	var x = sceneData["nodes"][6]["scale"][0]
	var y = sceneData["nodes"][6]["scale"][1]
	var z = sceneData["nodes"][6]["scale"][2]
	
	#print(x)
	#print(y)
	#print(z)
	
	var model_scale = Vector3(x, y, z)
	
	return model_scale


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
				
