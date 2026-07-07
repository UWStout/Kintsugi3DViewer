class_name LocalVoyagerStory extends GltfModel

func _init(p_artifact: ArtifactData):
	artifact = p_artifact
	is_local = true

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


	var models: Array[GltfModel] = []
	var preview_loaded: Array[bool] = []
	var fully_loaded: Array[bool] = []
	preview_loaded.resize(JsonReader.get_model_count())
	fully_loaded.resize(JsonReader.get_model_count())

	for i in JsonReader.get_model_count():
		var local_gltf_data = ArtifactData.new()
		local_gltf_data.gltfUri = voyager_json_path.get_base_dir() + "/" + JsonReader.get_model_uri(i)

		var model = LocalGltfModel.create(local_gltf_data)
		model.skip_scale = true  # we'll add this flag
		var model_to_meters = JsonReader.get_model_units_to_meters(i)
		var scene_to_meters = JsonReader.get_units_to_meters()
		var unit_scale = model_to_meters/scene_to_meters  
		
		model.scale = Vector3(model_to_meters, model_to_meters, model_to_meters) 
		models.append(model)

		var preview_callback = func():
			preview_loaded[i] = true
			if preview_loaded.all(func(b): return b):
				refresh_aabb()  # this already exists in LoadableArtifact
				preview_load_completed.emit()
		model.preview_load_completed.connect(preview_callback)

		var complete_callback = func():
			
			fully_loaded[i] = true
			if fully_loaded.all(func(b): return b):
				load_completed.emit()
				load_finished = true

		model.load_completed.connect(complete_callback)

	# reconstruct scene graph as specified by Voyager
	var scene_to_meters = JsonReader.get_units_to_meters()
	var display_scale = 0.1 / scene_to_meters
	var nodes: Array[Node3D] = []
	for i in JsonReader.get_voyager_node_count():
		nodes.append(Node3D.new())
		nodes[i].scale = JsonReader.get_voyager_node_scale(i) *display_scale 
		nodes[i].position = JsonReader.get_voyager_node_translation(i) *display_scale
		nodes[i].quaternion = JsonReader.get_voyager_node_quaternion(i)

		if JsonReader.is_voyager_node_model(i):
			nodes[i].add_child(models[JsonReader.get_voyager_node_model_index(i)])
		
		if JsonReader.is_voyager_node_light(i):
			var spotlight = SpotLight3D.new()
			spotlight.global_position = nodes[i].position
			spotlight.global_rotation = nodes[i].rotation 
			spotlight.light_color = JsonReader.get_light_color(0)
			spotlight.spot_range = 10
			add_sibling(spotlight)
			#nodes[i].add_child(spotlight)

	for i in JsonReader.get_voyager_node_count():
		for k in JsonReader.get_voyager_node_child_indices(i):
			nodes[i].add_child(nodes[k])

	
	#self.scale *= display_scale
	for k in JsonReader.get_voyager_root_node_indices(0):
		add_child(nodes[k])
	
	for model in models:
		model.load_artifact()
	
	
