extends Button

class_name SelectArtifactButton

var target_artifact: ArtifactData
@export var parent_window : Window

@onready var artifacts_controller : ArtifactsController = $"../../../../artifacts_controller"

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_instance_valid(target_artifact):
		return
	text = target_artifact.name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	if not artifacts_controller == null:
		artifacts_controller.display_artifact_data(target_artifact)
		parent_window.close_requested.emit()
	
	pass
