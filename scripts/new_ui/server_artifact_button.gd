class_name ServerArtifactButton extends ArtifactToggleButton


func _on_pressed() -> void:
	artifacts_manager.toggle_to_server()
