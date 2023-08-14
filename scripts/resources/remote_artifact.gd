extends Node3D
class_name RemoteArtifact

signal load_completed
signal load_progress(estimation: float)

var artifact: ArtifactData
var load_finished : bool = false

var _model_loader: RemoteGltfModel
var _voyager_loader: RemoteVoyagerStory

func _init(p_artifact: ArtifactData):
	artifact = p_artifact


func load_artifact():
	if artifact.voyagerUri:
		# Voyager Story artifact, init a voyager loader and begin loading
		_voyager_loader = RemoteVoyagerStory.new(artifact)
		add_child(_voyager_loader)
		setup_signals(_voyager_loader)
		_voyager_loader.load_scene()
	
	elif artifact.gltfUri:
		# Gltf model artifact, init Remote glTF loader and start loading
		_model_loader = RemoteGltfModel.create(artifact)
		add_child(_model_loader)
		setup_signals(_model_loader)
		_model_loader.load_artifact()
	
	else:
		push_error("Failed to load artifact: no loadable resources")


func get_aabb() -> AABB:
	if is_instance_valid(_model_loader):
		return _model_loader.aabb
	elif is_instance_valid(_voyager_loader):
		#TODO: Implement AABB for voyager scenes
		return AABB()
	else:
		return AABB()


func setup_signals(loader: Node):
	if (loader.has_signal("load_completed")):
		loader.load_completed.connect(_on_model_load_completed)
	
	# Pass through the progress signal
	if (loader.has_signal("load_progress")):
		loader.load_progress.connect(func(p): load_progress.emit(p))


func _on_model_load_completed():
	load_finished = true
	load_completed.emit()
