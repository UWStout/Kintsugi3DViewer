extends Node3D

class_name EnvironmentController

@export var scene_camera : CameraRig

@export var environment_scenes : Array[PackedScene]
var loaded_scenes : Array[DisplayEnvironment]

@export var connected_button : SelectEnvironmentButton
@export var connected_customize_lighting_button : CustomizeLightingButton

@export var connected_color_picker : LightColorPicker

var selected_index : int = -1
var selected_light : NewLightWidget

# Called when the node enters the scene tree for the first time.
func _ready():
	# Give the camera this object as a reference
	if not scene_camera == null:
		scene_camera.environment_controller = self
	
	preload_all_scenes()
	connected_button.connected_controller = self
	
	# Make the first scene current
	open_scene(0)
	connected_button.select(0)

func preload_all_scenes():
	for scene in environment_scenes:
		# Load the scene in, and change it's type
		var loaded_scene = scene.instantiate()
		loaded_scene = loaded_scene as DisplayEnvironment
		
		# Add the scene as a child of this object, and add it to the array
		add_child(loaded_scene)
		loaded_scenes.push_back(loaded_scene)
		
		# Make the scene invisible
		loaded_scene.visible = false
		
		# Add the scene to the button's dropdown list
		connected_button.add_item(loaded_scene.environment_name, loaded_scenes.find(loaded_scene))
		
		# Let all the dynamic lights in the scene know that this object is their controller,
		# and hide them all
		for dynamic_light in loaded_scene.get_dynamic_lighting().get_children():
			dynamic_light = dynamic_light as NewLightWidget
			dynamic_light.controller = self
			dynamic_light.make_immaterial()
			dynamic_light.init_widget()

func open_scene(index : int):
	# Hide the current scene
	if selected_index >= 0 and selected_index < loaded_scenes.size():
		loaded_scenes[selected_index].visible = false
		select_light(null)
		connected_customize_lighting_button.override_stop_customizing()
		hide_scene_lighting(selected_index)
	
	# Show the new scene
	if index >= 0 and index < loaded_scenes.size():
		selected_index = index
		
		loaded_scenes[selected_index].visible = true

func show_scene_lighting(index : int):
	if index < 0 or index >= loaded_scenes.size():
		return
	
	for dynamic_light in loaded_scenes[selected_index].get_dynamic_lighting().get_children():
		dynamic_light = dynamic_light as NewLightWidget
		dynamic_light.make_material()
	
func hide_scene_lighting(index : int):
	if index < 0 or index >= loaded_scenes.size():
		return
	
	for dynamic_light in loaded_scenes[selected_index].get_dynamic_lighting().get_children():
		dynamic_light = dynamic_light as NewLightWidget
		dynamic_light.make_immaterial()

func begin_customizing_lights():
	show_scene_lighting(selected_index)
	
func stop_customizing_lights():
	force_hide_lights()
	
	if not connected_customize_lighting_button == null:
		connected_customize_lighting_button.override_stop_customizing()

func select_light(light : NewLightWidget):
	if light == null:
		if not connected_color_picker == null:
			connected_color_picker.visible = false
		
		if not selected_light == null:
			selected_light.unselect_widget()
			
		selected_light = null
		return
	
	selected_light = light
	if not connected_color_picker == null:
		connected_color_picker.visible = true

func get_active_artifact_root() -> Node3D:
	return loaded_scenes[selected_index].get_artifact_root()
	pass

func force_hide_lights():
	select_light(null)
	hide_scene_lighting(selected_index)
