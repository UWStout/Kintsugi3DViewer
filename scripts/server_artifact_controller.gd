class_name ServerArtifactsController extends ArtifactsController

func _ready():
	assign_fetcher()
	
	await refresh_artifacts()
	
	if UrlReader.parameters.has("artifact"):
		for artifact in artifacts:
			if UrlReader.parameters["artifact"] == artifact.gltfUri.get_base_dir():
				display_artifact_data(artifact)
				
func refresh_artifacts() -> Array[ArtifactData]:
	if(Preferences.read_pref("offline mode")):
		artifacts = CacheManager.get_artifact_data()
	else:
		artifacts = await _fetcher.fetch_artifacts()
		artifacts_refreshed.emit(artifacts)
		
		if artifacts.size() == 0:
			artifacts = CacheManager.get_artifact_data()
	return artifacts
	
func open_artifact(data : ArtifactData):
	display_artifact_data(data)
	emit_signal("artifact_loaded")
	


func _on_local_controller_artifact_loaded() -> void:
		if is_instance_valid(loaded_artifact):
			if not loaded_artifact.load_finished:
				loaded_artifact.stop_loading()
