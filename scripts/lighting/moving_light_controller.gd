extends Node3D

class_name MovableLightingController

@export var rig_height : float = 5
@export var rig_radius : float = 3
@export var camera : CameraRig

var selected_light : MovableSpotlight
var slider_button : RotateLightsButton

var movable_spotlight = preload("res://scenes/lighting/spotlight_model.tscn")
var spotlight_models : Array[MovableSpotlight]

# Called when the node enters the scene tree for the first time.
func _ready():
	if not camera == null:
		camera.movable_lights_controller = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func provide_preset(preset : LightingPreset):
	# Clear the currently displayed
	# movable spotlights
	while not spotlight_models.is_empty():
		var obj = spotlight_models.pop_back()
		obj.queue_free()
	
	# if this preset isn't customizable, don't
	# worry about creating new spotlights
	if not preset.is_customizable:
		return
	
	# Add in the movable spotlights for this preset,
	# and set their initial position and color
	for i in range(0, preset.get_lights().size()):
		var new_spotlight_model = movable_spotlight.instantiate()
		add_child(new_spotlight_model)
		spotlight_models.push_back(new_spotlight_model)
		
		# Set initial position
		var rot = preset.get_lights()[i].rotation.y
		new_spotlight_model.radius = rig_radius
		new_spotlight_model.height = rig_height
		new_spotlight_model.update_angle(preset.get_lights()[i].rotation_degrees.y)
		#new_spotlight_model.position = Vector3(sin(rot) * rig_radius, rig_height, cos(rot) * rig_radius)
		
		# Set initial color
		new_spotlight_model.set_color(preset.get_lights()[i].light_color, preset.get_lights()[i].light_energy / 1.0)
		
		# Set dependency
		new_spotlight_model.connected_light = preset.get_lights()[i]
		pass
	pass

func select_light(new_selected_light : MovableSpotlight):
	selected_light = null
	slider_button.disable_slider()
	
	if not new_selected_light == null:
		selected_light = new_selected_light
		
		if not slider_button == null:
			slider_button.enable_slider()
