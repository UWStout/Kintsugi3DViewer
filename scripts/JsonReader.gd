extends Node

var sceneData = {}
#var lighting_controller = preload("res://lighting_controller_preset.tscn")
#var light = preload("res://lighting_controller_light_preset.tscn")

var data_file_path = "res://artifacts/Eremotherium/scene.svx.json"


func _ready():
	sceneData = load_json_file(data_file_path)
	#var light_controller = get_node("/root/viewer_scene/light_controller")
	#var lighting_control = lighting_controller.instantiate()
	#var light4 = light.instantiate()
	
	#light_controller.add_child(lighting_control, false, Node.INTERNAL_MODE_DISABLED)
	#lighting_control.add_child(light4, false, Node.INTERNAL_MODE_DISABLED)
	
	var parent = get_node("/root/viewer_scene")
	var light1 = DirectionalLight3D.new()
	var light2 = DirectionalLight3D.new()
	var light3 = DirectionalLight3D.new()
	var light4 = DirectionalLight3D.new()
	
	light1.light_color = Color(sceneData["lights"][0]["color"][0], sceneData["lights"][0]["color"][1], sceneData["lights"][0]["color"][2], 1)
	light2.light_color = Color(sceneData["lights"][1]["color"][0], sceneData["lights"][1]["color"][1], sceneData["lights"][1]["color"][2], 1)
	light3.light_color = Color(sceneData["lights"][2]["color"][0], sceneData["lights"][2]["color"][1], sceneData["lights"][2]["color"][2], 1)
	light4.light_color = Color(sceneData["lights"][3]["color"][0], sceneData["lights"][3]["color"][1], sceneData["lights"][3]["color"][2], 1)
	
	parent.add_child(light1)
	parent.add_child(light2)
	parent.add_child(light3)
	parent.add_child(light4)
	




func load_json_file(filePath : String):
	if FileAccess.file_exists(filePath):
		
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		
		if parsedResult is Dictionary:
			return parsedResult
		else:
			print("Error reading file")
		
		
	else:
		print("File doesn't exist!")
				
