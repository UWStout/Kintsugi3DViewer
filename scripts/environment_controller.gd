# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Node3D

class_name EnvironmentController

@export var scene_camera : CameraRig

@export var environment_scenes : Array[PackedScene]
var loaded_scenes : Array[DisplayEnvironment]

@export var light_selection_ui : LightSelectionUI
@export var environment_selection_ui : EnvironmentSelectionUI

#OLD CODE @export var artifact_controller : ArtifactsController


var selected_index : int = -1
var selected_light : NewLightWidget

# Called when the node enters the scene tree for the first time.
func _ready():
	# Give the camera this object as a reference
	if not scene_camera == null:
		scene_camera.environment_controller = self
	
	preload_all_scenes()
	#connected_button.connected_controller = self
	
	# Make the first scene current
	#open_scene(0)
	#connected_button.select(0)

func preload_all_scenes():
	for scene in environment_scenes:
		# Load the scene in, and change it's type
		var loaded_scene = await scene.instantiate()
		loaded_scene = loaded_scene as DisplayEnvironment
		
		# Add the scene as a child of this object, and add it to the array
		add_child(loaded_scene)
		loaded_scenes.push_back(loaded_scene)
		
		# Make the scene invisible
		loaded_scene.visible = false
		
		# Add the scene to the button's dropdown list
		#connected_button.add_item(loaded_scene.environment_name, loaded_scenes.find(loaded_scene))
		
		# Let all the dynamic lights in the scene know that this object is their controller,
		# and hide them all
		for dynamic_light in loaded_scene.get_dynamic_lighting().get_children():
			dynamic_light = dynamic_light as NewLightWidget
			dynamic_light.controller = self
			dynamic_light.make_immaterial()
			dynamic_light.init_widget()
		
	environment_selection_ui.initialize_list(loaded_scenes)

func open_scene(index : int):
	# Hide the current scene
	if selected_index >= 0 and selected_index < loaded_scenes.size():
		loaded_scenes[selected_index].visible = false
		select_light(null)
		#connected_customize_lighting_button.override_stop_customizing()
		hide_scene_lighting(selected_index)
		light_selection_ui.clear_buttons()
	
	# Show the new scene
	if index >= 0 and index < loaded_scenes.size():
		selected_index = index
		
		loaded_scenes[selected_index].visible = true
		
		for dynamic_light in loaded_scenes[selected_index].get_dynamic_lighting().get_children():
			if dynamic_light is NewLightWidget:
				light_selection_ui.create_button_for_light(dynamic_light as NewLightWidget)

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
	
	#if not connected_customize_lighting_button == null:
		#connected_customize_lighting_button.override_stop_customizing()

func select_light(light : NewLightWidget):
	if light == null:
		#if not connected_color_picker == null:
			#connected_color_picker.visible = false

		if not selected_light == null:
			selected_light.unselect_widget()
			
		selected_light = null
		return
	
	selected_light = light
	#if not connected_color_picker == null:
		#connected_color_picker.visible = true

func get_active_artifact_root() -> Node3D:
	if selected_index < 0 or selected_index >= loaded_scenes.size():
		return null
	#if selected_index == 0: #OLD CODE
		#set_environment_lights()
		
	return loaded_scenes[selected_index].get_artifact_root()
	pass

func force_hide_lights():
	select_light(null)
	hide_scene_lighting(selected_index)
	
func set_environment_lights():
	#print("Hello There Again")
	self.get_node("demo_environment").get_dynamic_lighting().get_child(0).change_color(get_node("/root/JsonReader").get_light_color(1))
	self.get_node("demo_environment").get_dynamic_lighting().get_child(1).change_color(get_node("/root/JsonReader").get_light_color(2))
	self.get_node("demo_environment").get_dynamic_lighting().get_child(2).change_color(get_node("/root/JsonReader").get_light_color(3))

func show_light(light_index : int):
	var lights = loaded_scenes[selected_index].get_dynamic_lighting().get_children()
	
	for i in range(0, lights.size()):
		if i == light_index:
			lights[i].make_material()
		pass
	pass

func get_current_environment():
	if selected_index >= 0 and selected_index < loaded_scenes.size():
		return loaded_scenes[selected_index]
	
	return null

func add_light_to_scene():
	var current_environment = get_current_environment()
	
	if not current_environment == null:
		var light = current_environment.add_dynamic_light()
		light.controller = self
		return light
	
	return null
