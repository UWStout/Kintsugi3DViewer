class_name ResetSaveConfig extends Node

@export var config: ArtifactConfigButton
@export var local_controller: LocalArtifactsController
var current_artifact
signal reset_button_pressed



func _on_save_button_pressed() -> void:
	current_artifact = local_controller._get_current_artifact()
	LocalSaveData.overwrite_camera_constraints(current_artifact.localDir, config.min_zoom, config.max_zoom)


func _on_reset_button_pressed() -> void:
	current_artifact = local_controller._get_current_artifact()
	reset_button_pressed.emit(current_artifact.min_distance, current_artifact.max_distance)
