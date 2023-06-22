extends Node3D
class_name ArtifactsController

signal artifacts_refreshed(artifacts: Array[ArtifactData])

@export var _fetcher: ResourceFetcher

var current_index : int = 0
var artifacts: Array[ArtifactData]

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_instance_valid(_fetcher):
		_fetcher = GlobalFetcher
		if not is_instance_valid(_fetcher):
			push_error("Artifacts Controller at node %s could not find a valid resource fetcher!" % get_path())
			return
	
	print("Loading artifacts listing...") #TODO: Remove
	refresh_artifacts()


func refresh_artifacts():
	print("Refreshing artifacts")
	artifacts = await _fetcher.fetch_artifacts()
	artifacts_refreshed.emit(artifacts)
	return artifacts


func display_artifact(index : int):
	print("display_artifact id=%s" % index)
	pass


func display_next_artifact():
	print("display_next_artifact")
	pass


func display_previous_artifact():
	print("display_previous_artifact")
	pass


func display_this_artifact(artifact_node_path : NodePath):
	print("display_this_artifact")
	pass


func display_artifact_data(artifact: ArtifactData):
	print("display_artifact_data name=%s" % artifact.name)
