extends Button

@export var config: ArtifactConfigButton
@export var local_controller: LocalArtifactsController
var current_artifact: ArtifactData

func _on_pressed() -> void:
	current_artifact = local_controller._get_current_artifact()
	LocalSaveData.overwrite_camera_constraints(current_artifact.localDir, config.min_zoom, config.max_zoom)
