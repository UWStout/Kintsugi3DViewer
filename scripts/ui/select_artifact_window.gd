extends Window

@export var artifacts_controller : ArtifactsController
@onready var select_artifact_button = $ScrollContainer/VBoxContainer/select_artifact_button
@onready var v_box_container = $ScrollContainer/VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	populate_list()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_close_requested():
	hide()
	pass

func populate_list():
	var count : int = 0
	
	for artifact in artifacts_controller.artifacts:
		var new_button = select_artifact_button.duplicate()
		
		new_button.artifacts_controller = artifacts_controller
		new_button.target_artifact_path = artifact
		new_button.parent_window = self
		new_button.text = artifact.get_name(artifact.get_name_count() - 1)
		new_button.visible = true
		
		v_box_container.add_child(new_button)
		pass
	pass
