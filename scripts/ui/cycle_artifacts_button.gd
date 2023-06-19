extends Button

@export var move_forward : bool = true

@onready var artifacts_controller: ArtifactsController = $"../../artifacts_controller" 


func _pressed():
	pass
	
	if artifacts_controller == null:
		return
	
	if move_forward:
		artifacts_controller.display_next_artifact()
		pass
	else:
		artifacts_controller.display_previous_artifact()
		pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
