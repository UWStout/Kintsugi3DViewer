extends Button

@export var target_artifact_path : NodePath

@onready var artifacts_controller : ArtifactsController = $"../../../artifacts_controller"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	if not artifacts_controller == null:
		artifacts_controller.display_this_artifact(target_artifact_path)
	
	pass
