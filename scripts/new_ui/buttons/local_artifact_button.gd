class_name LocalArtifactButton extends ArtifactToggleButton


func _on_pressed() -> void:
	artifacts_manager.toggle_to_local()
