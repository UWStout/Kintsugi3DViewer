class_name LocalVoyagerStory extends GltfModel

var light_nodes: Array[Node3D] = []

func _init(p_artifact: ArtifactData):
	artifact = p_artifact
	is_local = true

#func _center_lights_on_artifact():
	#if aabb == AABB():
		#return
	#var center = aabb.get_center()
	#print("centering lights on: ", center)
	#for light_node in light_nodes:
		#light_node.position.x += center.x
		#light_node.position.z += center.z
		#print("new light pos: ", light_node.position)
#
#func _offset_lights_in_node(node: Node, center: Vector3):
	#for child in node.get_children():
		#if child is DirectionalLight3D or child is SpotLight3D or child is OmniLight3D:
			## Offset the parent node (which holds position/rotation) by half AABB on X and Z
			#node.position.x += center.x
			#node.position.z += center.z
			#return
		#_offset_lights_in_node(child, center)

func load_artifact():
	#print("=== load_artifact called, instance: ", self)
	var voyager_json_path = artifact.voyagerUri
	if not FileAccess.file_exists(voyager_json_path):
		push_error("Voyager scene file not found: %s" % voyager_json_path)
		return
		
	var file = FileAccess.open(voyager_json_path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		push_error("Failed to parse local Voyager scene: %s" % voyager_json_path)
		return
		
	JsonReader.update_with_json(parsed)
	VoyagerLoader._load_voyager(self, false, voyager_json_path)
	#var models: Array[GltfModel] = []
	#var preview_loaded: Array[bool] = []
	#var fully_loaded: Array[bool] = []
	#preview_loaded.resize(JsonReader.get_model_count())
	#fully_loaded.resize(JsonReader.get_model_count())
#
	#for i in JsonReader.get_model_count():
		#var local_gltf_data = ArtifactData.new()
		#local_gltf_data.gltfUri = voyager_json_path.get_base_dir() + "/" + JsonReader.get_model_uri(i)
#
		#var model = LocalGltfModel.create(local_gltf_data)
		#model.skip_scale = true  # we'll add this flag
		#var model_to_meters = JsonReader.get_model_units_to_meters(i)
#
		#
		#model.scale = Vector3(model_to_meters, model_to_meters, model_to_meters) 
		#models.append(model)
#
		#var preview_callback = func():
			#preview_loaded[i] = true
			#if preview_loaded.all(func(b): return b):
				#refresh_aabb()  # this already exists in LoadableArtifact
				#_center_lights_on_artifact()
				#preview_load_completed.emit()
		#model.preview_load_completed.connect(preview_callback)
#
		#var complete_callback = func():
			#
			#fully_loaded[i] = true
			#if fully_loaded.all(func(b): return b):
				#load_completed.emit()
				#load_finished = true
#
		#model.load_completed.connect(complete_callback)
#
	## reconstruct scene graph as specified by Voyager
	#var scene_to_meters = JsonReader.get_units_to_meters()
	#var display_scale = 0.1 / scene_to_meters
	#var nodes: Array[Node3D] = []
	#light_nodes.clear()
	#var light_count = 0
	#for i in JsonReader.get_voyager_node_count():
		#nodes.append(Node3D.new())
		#nodes[i].scale = JsonReader.get_voyager_node_scale(i) #*display_scale 
		#nodes[i].position = JsonReader.get_voyager_node_translation(i) #*display_scale
		#nodes[i].quaternion = JsonReader.get_voyager_node_quaternion(i)
#
		#if JsonReader.is_voyager_node_model(i):
			#nodes[i].scale *= display_scale
			#nodes[i].position *= display_scale
			#nodes[i].add_child(models[JsonReader.get_voyager_node_model_index(i)])
	#
		#if JsonReader.is_voyager_node_light(i):
			#light_nodes.append(nodes[i])
			#nodes[i].scale = Vector3(1, 1, 1)
			#nodes[i].position = JsonReader.get_voyager_node_translation(i) * display_scale
			#var light_type = JsonReader.get_light_type(light_count)
			#var light_color = JsonReader.get_light_color(light_count)
			#var light_intensity = JsonReader.get_light_intensity(light_count)
			#if light_type == "directional":
				#var light = DirectionalLight3D.new()
				#light.light_color = light_color
				#light.light_energy = light_intensity
				#nodes[i].add_child(light)
			#elif light_type == "spot":
				#
				#var light = SpotLight3D.new()
				#light.rotation_degrees.x = -90
				#light.light_color = light_color
				#light.light_energy = light_intensity * 100
				#var spot_data = JsonReader.get_light_spot_data(light_count)
				#light.spot_angle = spot_data.get("angle", 45.0)
				## penumbra in Voyager is 0-1, Godot uses degrees for spot_angle_attenuation
				#light.spot_angle_attenuation = spot_data.get("penumbra", 0.5) * light.spot_angle
				## distance 0 means infinite in Voyager
				#var distance = spot_data.get("distance", 0)
				#light.spot_range = 1000.0 if distance == 0 else distance * display_scale
				#light.spot_attenuation = spot_data.get("decay", 1.0)
				#
				#nodes[i].add_child(light)
				#
			#elif light_type == "point":
				#var light = OmniLight3D.new()
				#light.light_color = light_color
				#light.light_energy = light_intensity
				#nodes[i].add_child(light)
			#light_count += 1
#
	#for i in JsonReader.get_voyager_node_count():
		#for k in JsonReader.get_voyager_node_child_indices(i):
			#nodes[i].add_child(nodes[k])
#
	#
	##self.scale *= display_scale
	#for k in JsonReader.get_voyager_root_node_indices(0):
		#add_child(nodes[k])
	#
	#for model in models:
		#model.load_artifact()
	
	
