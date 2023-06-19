extends Button

@export var main_light : DirectionalLight3D
@export var backlight : DirectionalLight3D
@export var world_environment : WorldEnvironment

@onready var full_light_icon = preload("res://assets/ui/light_full.png")
@onready var ambient_light_icon = preload("res://assets/ui/light_ambient.png")
@onready var no_light_icon = preload("res://assets/ui/light_none.png")

# state 0 is full lighting (only main and backlight on)
# state 1 is ambient lighting (only ambient light in)
# state 2 is no lighting (no lights on)
var state : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	state = (state + 1) % 3
	
	if state == 0:
		main_light.visible = true
		backlight.visible = true
		world_environment.environment.ambient_light_energy = 0
		icon = full_light_icon
	elif state == 1:
		main_light.visible = false
		backlight.visible = false
		world_environment.environment.ambient_light_energy = 1
		icon = ambient_light_icon
	else:
		main_light.visible = false
		backlight.visible = false
		world_environment.environment.ambient_light_energy = 0
		icon = no_light_icon
