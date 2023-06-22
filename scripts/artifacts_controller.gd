extends Node3D
class_name ArtifactsController

signal artifacts_refreshed(artifacts: Array[ArtifactData])

@export var _fetcher: ResourceFetcher

var current_index : int = 0
var artifacts: Array[ArtifactData]

var loaded_artifact: RemoteGltfModel

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_instance_valid(_fetcher):
		_fetcher = GlobalFetcher
		if not is_instance_valid(_fetcher):
			push_error("Artifacts Controller at node %s could not find a valid resource fetcher!" % get_path())
			return
	
	await refresh_artifacts()
	if not artifacts.is_empty():
		display_artifact(0)


func refresh_artifacts():
	artifacts = await _fetcher.fetch_artifacts()
	artifacts_refreshed.emit(artifacts)
	return artifacts


func display_artifact(index : int):
	if index < artifacts.size():
		display_artifact_data(artifacts[index])
	pass


func display_artifact_data(artifact: ArtifactData):
	if is_instance_valid(loaded_artifact):
		loaded_artifact.queue_free()
	
	loaded_artifact = RemoteGltfModel.create(artifact)
	add_child(loaded_artifact)
	loaded_artifact.load_artifact()


func display_next_artifact():
	current_index = (current_index + 1) % artifacts.size()
	display_artifact(current_index)
	pass


func display_previous_artifact():
	current_index -= 1
	if current_index < 0:
		current_index = artifacts.size() - 1
	
	display_artifact(current_index)
	pass
