extends Button

@export var connected_lighting_controller : MovableLightingController

var is_pressed : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	if connected_lighting_controller == null:
		return
	
	is_pressed = not is_pressed
	
	if is_pressed:
		text = "Stop Customizing"
		connected_lighting_controller.begin_customizing()
		pass
	else:
		text = "Customize Lights"
		connected_lighting_controller.end_customizing()
		pass
