extends VBoxContainer

@export var artifact_display_ui : PackedScene

func _ready():
	for artifact in CacheManager.get_artifact_data():
		var new_artifact_display = artifact_display_ui.instantiate()
		add_child(new_artifact_display)
		new_artifact_display.initialize_from_artifact(artifact)

func refresh_list():
	for child in get_children():
		child.queue_free()
	
	for artifact in CacheManager.get_artifact_data():
		var new_artifact_display = artifact_display_ui.instantiate()
		add_child(new_artifact_display)
		new_artifact_display.initialize_from_artifact(artifact)


func _on_cache_visibility_changed():
	refresh_list()
