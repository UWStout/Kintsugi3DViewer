extends Window

@export var artifacts_controller : ArtifactsController
@export var artifacts_controller_node_path : NodePath
@export var select_artifact_button = preload("res://scenes/ui/select_artifact_button.tscn")
@onready var v_box_container = $ScrollContainer/VBoxContainer

func on_open():
	populate_list()


func _on_close_requested():
	hide()
	pass


func populate_list():
	# Refresh artifacts to make sure ui is up to date
	await artifacts_controller.refresh_artifacts()
	
	# Remove all buttons
	for child in v_box_container.get_children():
		child.queue_free()
		pass
	
	for artifact in artifacts_controller.artifacts:
		var new_button = select_artifact_button.instantiate()
		
		new_button.artifacts_controller = artifacts_controller
		new_button.target_artifact = artifact
		new_button.parent_window = self
		new_button.visible = true
		
		v_box_container.add_child(new_button)
		pass
	pass
