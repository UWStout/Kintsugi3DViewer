class_name CacheUI extends VBoxContainer

@export var artifact_display_ui : PackedScene
@export var confirmation_panel : ConfirmationPanel

func _ready():
	for artifact in CacheManager.get_artifact_data():
		var new_artifact_display = artifact_display_ui.instantiate()
		add_child(new_artifact_display)
		new_artifact_display.initialize_from_artifact(artifact)

func refresh_list():
	for child in get_children():
		child.queue_free()
	
	for artifact in CacheManager.get_artifact_data_in_cache_ordered():
		var new_artifact_display = artifact_display_ui.instantiate()
		add_child(new_artifact_display)
		new_artifact_display.initialize_from_artifact(artifact)
		new_artifact_display.confirmation_panel = confirmation_panel


func _on_cache_visibility_changed():
	refresh_list()
