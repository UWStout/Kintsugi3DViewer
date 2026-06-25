extends Button

@export var local_controller: LocalArtifactsController
var current_artifact
signal reset_button_pressed

func _on_pressed() -> void:
	current_artifact = local_controller._get_current_artifact()
	reset_button_pressed.emit(current_artifact.min_zoom, current_artifact.max_zoom)
