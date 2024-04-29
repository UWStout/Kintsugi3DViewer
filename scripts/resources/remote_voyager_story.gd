extends LoadableArtifact
class_name RemoteVoyagerStory

@export var fetcher: ResourceFetcher

func _init(p_artifact: ArtifactData):
	artifact = p_artifact

func _ready():
	# Ensure the resource fetcher is avaliable
	if not is_instance_valid(fetcher):
		fetcher = GlobalFetcher
		if not is_instance_valid(fetcher):
			push_error("Remote Voyager Story loader at node %s could not find a valid resource fetcher!" % get_path())
			return

func load_artifact():
	# TODO: Implement loading voyager story artifact
	var voyager_data = await fetcher.fetch_voyager(artifact.voyagerUri)
	print(voyager_data.keys())
	JsonReader.update_with_json(voyager_data)
	
	var models : Array[GltfModel] = []
	
	# keep track of if models are loaded
	var preview_loaded : Array[bool] = []
	var fully_loaded : Array[bool] = []
	preview_loaded.resize(JsonReader.get_model_count())
	fully_loaded.resize(JsonReader.get_model_count())
	
	for i in JsonReader.get_model_count():
		var voyagergltfdata = ArtifactData.new()
		voyagergltfdata.gltfUri = artifact.gltfUri.get_base_dir() +"/"+ JsonReader.get_model_uri(i)
		var model = RemoteGltfModel.create(voyagergltfdata)
		models.append(model)
		
		var preview_callback = func():
			preview_loaded[i] = true
			if (preview_loaded.all(func(b): return b)):
				# all models have geometry fully downloaded, time to update AABB
				refresh_aabb()
				preview_load_completed.emit()
			
		model.preview_load_completed.connect(preview_callback)
		
		var complete_callback = func():
			fully_loaded[i] = true
			if (fully_loaded.all(func(b): return b)):
				# all models are fully loaded
				load_completed.emit()
				load_finished = true
				
		model.load_completed.connect(complete_callback)
		
		model.load_artifact()
	
	# reconstruct scene graph as specified by Voyager
	# first pass: create nodes, set scale/translation/rotation and attach models
	var nodes : Array[Node3D] = []
	for i in JsonReader.get_voyager_node_count():
		# create a node to represent this instance
		nodes.append(Node3D.new())
		nodes[i].scale = JsonReader.get_voyager_node_scale(i)
		nodes[i].position = JsonReader.get_voyager_node_translation(i)
		nodes[i].quaternion = JsonReader.get_voyager_node_quaternion(i)
			
		if JsonReader.is_voyager_node_model(i):
			# attach the loaded model as a child
			nodes[i].add_child(models[JsonReader.get_voyager_node_model_index(i)])

	# second pass: attach children
	for i in JsonReader.get_voyager_node_count():
		for k in JsonReader.get_voyager_node_child_indices(i):
			nodes[i].add_child(nodes[k])
	
	# finally, add children of "root"
	for k in JsonReader.get_voyager_root_node_indices(0): # TODO hardcoding single scene (0) for now
		add_child(nodes[k])
		
	# actually start loading the models
	for model in models:
		model.load_artifact()
