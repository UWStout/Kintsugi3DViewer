extends Node

var light_nodes: Array[Node3D] = []

func _load_voyager(loadable : LoadableArtifact, is_server : bool, voyager_json_path: String):
	
	var models: Array[GltfModel] = []
	var preview_loaded: Array[bool] = []
	var fully_loaded: Array[bool] = []
	preview_loaded.resize(JsonReader.get_model_count())
	fully_loaded.resize(JsonReader.get_model_count())
	
	AnnotationsManager.annotation_markers_array.clear()
	
	for i in JsonReader.get_model_count():
		var local_gltf_data = ArtifactData.new()
		local_gltf_data.gltfUri = voyager_json_path.get_base_dir() + "/" + JsonReader.get_model_uri(i)

		var model 
		if is_server:
			model = RemoteGltfModel.create(local_gltf_data)
		else:
			model = LocalGltfModel.create(local_gltf_data)
		model.preserve_scale = true
		
		var meters_per_model_unit = JsonReader.get_meters_per_model_unit(i)
		model.scale = Vector3(meters_per_model_unit, meters_per_model_unit, meters_per_model_unit) 
		
		# Setup annotations per model
		if JsonReader.has_annotations(i):
			var anno = JsonReader.setup_annotations(i)
			for annotation in anno:
				model.add_child(annotation)
		
		models.append(model)

		var preview_callback = func():
			preview_loaded[i] = true
			if preview_loaded.all(func(b): return b):
				loadable.refresh_aabb()  
				loadable.preview_load_completed.emit()
		model.preview_load_completed.connect(preview_callback)

		var complete_callback = func():
			fully_loaded[i] = true
			if fully_loaded.all(func(b): return b):
				loadable.load_completed.emit()
				loadable.load_finished = true

		model.load_completed.connect(complete_callback)

	# reconstruct scene graph as specified by Voyager
	
	var nodes: Array[Node3D] = []
	light_nodes.clear()
	var light_count = 0
	
	# Create root node with scale to transform to Godot's meter standard
	var root = Node3D.new()
	loadable.add_child(root)
	LoadableArtifact.apply_scale_adjustment(root) # 2x scale to account for mis-scaling of Kintsugi environments
	var meters_per_scene_unit = JsonReader.get_meters_per_scene_unit()
	
	# Multiply the initial scale adjustment by whatever Voyager specifies 
	# to convert from Voyager scene units to meters.
	root.scale *= Vector3(meters_per_scene_unit, meters_per_scene_unit, meters_per_scene_unit)
	
	# Model has its own scale to meters, 
	# so we need to go model units -> meters -> Voyager scene units -> meters.
	# scene_units_per_meter handles meters -> Voyager scene units
	var scene_units_per_meter = 1 / meters_per_scene_unit
	
	for i in JsonReader.get_voyager_node_count():
		nodes.append(Node3D.new())
		nodes[i].scale = JsonReader.get_voyager_node_scale(i) 
		nodes[i].position = JsonReader.get_voyager_node_translation(i) 
		nodes[i].quaternion = JsonReader.get_voyager_node_quaternion(i)

		if JsonReader.is_voyager_node_model(i):
			nodes[i].scale *= scene_units_per_meter
			nodes[i].add_child(models[JsonReader.get_voyager_node_model_index(i)])
	
		if JsonReader.is_voyager_node_light(i):
			light_nodes.append(nodes[i])
			var light_type = JsonReader.get_light_type(light_count)
			var light_color = JsonReader.get_light_color(light_count)
			var light_intensity = JsonReader.get_light_intensity(light_count)
			if light_type == "directional":
				var light = DirectionalLight3D.new()
				light.light_color = light_color
				light.light_energy = light_intensity
				nodes[i].add_child(light)
			elif light_type == "spot":
				var light = SpotLight3D.new()
				var spot_data = JsonReader.get_light_spot_data(light_count)
				var decay = spot_data.get("decay", 1.0)
				light.rotation_degrees.x = -90
				light.light_color = light_color
				
				# Division by PI needed when physical light units are disabled in Godot.
				# Need to also scale to account for differences in unit scale for Godot vs. Voyager.
				light.light_energy = light_intensity * pow(meters_per_scene_unit, decay) / PI
				
				# distance 0 means infinite in Voyager
				var distance = spot_data.get("distance", 0)
				light.spot_range = 1000.0 if distance == 0 else distance * meters_per_scene_unit
				light.spot_attenuation = decay
				
				light.spot_angle = spot_data.get("angle", 45.0)
				
				# Voyager uses a penumbra setting which maps to the more typical "inner cone angle"
				# via the formula inner angle = (1 - penumbra) * outer angle
				# Unfortunately, Godot has a weird spot light attenuation formula
				# and doesn't support explicitly setting the inner angle.
				# The following mapping ensures that the the spotlight hits half intensity
				# at the same point it would in Voyager.
				# The resulting spot_angle_attenuation should always be between 0 and 1.
				# When penumbra is 0, spot_angle_attenuation should also be 0.
				# When penumbra is 1, it is slightly less than 1 depending on spot_angle
				# to compensate for differences in how Godot evaluates spot light falloff.
				#
				# Details: Godot uses the spot light falloff formula:
				# 1 - ((1 - cos(light angle)) / (1 - cos(spot_angle)))^(1 / spot_angle_attenuation)
				# Setting the above expression equal to 0.5 and solving for spot_angle_attenuation yields:
				# 1 - ((1 - cos(light angle)) / (1 - cos(spot_angle)))^(1 / spot_angle_attenuation) = 0.5
				# ((1 - cos(light angle)) / (1 - cos(spot_angle)))^(1 / spot_angle_attenuation) = 0.5
				# (1 - cos(light angle)) / (1 - cos(spot_angle)) = 0.5^spot_angle_attenuation
				# (1 - cos(spot_angle)) / (1 - cos(light angle)) = 2^spot_angle_attenuation
				# spot_angle_attenuation = log2((1 - cos(spot_angle)) / (1 - cos(light angle)))
				if light.spot_angle > 0:
					var penumbra = clamp(spot_data.get("penumbra", 0.5), 0.0, 1.0)
					# Half intensity angle = 0.5 * spot_angle + 0.5 * spot_angle * (1 - penumbra)
					# = spot_angle - 0.5 * spot_angle * penumbra
					# = spot_angle * (1 - 0.5 * penumbra)
					var half_intensity_angle = light.spot_angle * (1.0 - 0.5 * penumbra)
					light.spot_angle_attenuation = \
						log((1.0 - cos(deg_to_rad(light.spot_angle))) / (1.0 - cos(deg_to_rad(half_intensity_angle)))) \
						/ log(2.0) 
					
				nodes[i].add_child(light)
				
			elif light_type == "point":
				var light = OmniLight3D.new()
				var point_data = JsonReader.get_light_point_data(light_count)
				var decay = point_data.get("decay", 1.0)
				light.light_color = light_color
				
				# Division by PI needed when physical light units are disabled in Godot.
				# Need to also scale to account for differences in unit scale for Godot vs. Voyager.
				light.light_energy = light_intensity * pow(meters_per_scene_unit, decay) / PI
				
				# distance 0 means infinite in Voyager
				var distance = point_data.get("distance", 0)
				light.omni_range = 1000.0 if distance == 0 else distance * meters_per_scene_unit
				light.omni_attenuation = decay
				
				nodes[i].add_child(light)
			light_count += 1
			
	for i in JsonReader.get_voyager_node_count():
		for k in JsonReader.get_voyager_node_child_indices(i):
			nodes[i].add_child(nodes[k])

	for k in JsonReader.get_voyager_root_node_indices(0):
		root.add_child(nodes[k])
	
	for model in models:
		model.load_artifact()
