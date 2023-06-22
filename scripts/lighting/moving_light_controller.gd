extends Node3D

class_name MovableLightingController

# The height of the displayed spotlights above the world origin
@export var rig_height : float = 5
# The radius of the displayed spotlights around the world origin
@export var rig_radius : float = 5
# The cameraRig in this scene
@export var camera : CameraRig

var selected_light : MovableSpotlight

var selected_widget : MovableLightWidget

var selected_new_widget : NewLightWidget

@onready var csg_torus_3d = $CSGTorus3D

var movable_spotlight = preload("res://scenes/lighting/spotlight_model.tscn")
var spotlight_models : Array[MovableSpotlight]

# If there is a camera connected, let it know that this exists
func _ready():
	#if not camera == null:
		#camera.movable_lights_controller = self
		
	csg_torus_3d.position = get_rig_center()
	
	end_customizing()

# Select a preset to modify lighting for
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
		new_spotlight_model.controller = self
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
		
		# Let the spotlight display know which light to modify
		new_spotlight_model.connected_light = preset.get_lights()[i]
		pass
	pass

# Select a spotlight display to modify
func select_light(new_selected_light : MovableSpotlight):
	# In case nothing was selected, clear all selections
	selected_light = null
	
	if not new_selected_light == null:
		selected_light = new_selected_light

func get_rig_center():
	return global_position + Vector3(0, rig_height, 0)

func get_rig_forward():
	return get_rig_center() + Vector3(0, 0, 1)

func begin_customizing():
	csg_torus_3d.visible = true
	
	for spotlight in spotlight_models:
		spotlight.make_visible()
	
func end_customizing():
	csg_torus_3d.visible = false
	
	for spotlight in spotlight_models:
		spotlight.make_not_visible()

func select_widget(widget : MovableLightWidget):
	selected_widget = widget

func clear_selected_widget():
	if not selected_widget == null:
		selected_widget.reset_axis_displays()
	selected_widget = null

func select_new_widget(widget : NewLightWidget):
	if not selected_new_widget == null:
		# if the new widget is the same as the old one, do nothing
		# otherwise, unselect the current widget
		if not widget == null and selected_new_widget == widget:
			return
		selected_new_widget.unselect_widget()
	
	if widget == null:
		selected_new_widget = null
		return
	
	# Select the new widget
	selected_new_widget = widget
