extends Button

@export var camera : CameraRig

@onready var flashlight_off_icon = preload("res://assets/ui/flashlight_off.png")
@onready var flashlight_on_icon = preload("res://assets/ui/flashlight_on.png")

var is_on : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	is_on = not is_on
	
	if(is_on):
		icon = flashlight_on_icon
		camera.enable_flashlight()
	else:
		icon = flashlight_off_icon
		camera.disable_flashlight()
