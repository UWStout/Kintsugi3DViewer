# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

@tool
extends Node3D

class_name DisplayEnvironment

@export var environment_name : String

var light_widget_scene : PackedScene = ResourceLoader.load("res://scenes/lighting/new_light_widget.tscn")

signal artifact_bounds_changed(aabb : AABB)

func set_artifact_bounds(aabb : AABB):
	# responsive objects
	artifact_bounds_changed.emit(aabb)

# Add required nodes whenever this tree is entered
func _enter_tree():
	
	if get_artifact_root() == null:
		var root = Node3D.new()
		root.name = "artifact_root"
		
		add_child(root)
		root.set_owner(self)
	
	if get_lighting() == null:
		var lighting = Node3D.new()
		lighting.name = "lighting"
		
		add_child(lighting)
		lighting.set_owner(self)
		
	if get_static_lighting() == null:
		var statics = Node3D.new()
		statics.name = "statics"
		
		get_lighting().add_child(statics)
		statics.set_owner(self)
		
	if get_dynamic_lighting() == null:
		var dynamics = Node3D.new()
		dynamics.name = "dynamics"
		
		get_lighting().add_child(dynamics)
		dynamics.set_owner(self)

func get_artifact_root() -> Node3D:
	return find_child("artifact_root") as Node3D

func get_lighting():
	return find_child("lighting")

func get_static_lighting():
	if get_lighting() == null:
		return null
	
	return get_lighting().find_child("statics")

func get_dynamic_lighting():
	if get_lighting() == null:
		return null
		
	return get_lighting().find_child("dynamics")

func show_light(light_index : int):
	if light_index < 0 or light_index >= get_dynamic_lighting().get_children().size():
		return
	
	if get_dynamic_lighting().get_children()[light_index] is NewLightWidget:
		get_dynamic_lighting().get_children()[light_index].make_material()

func add_dynamic_light():
	var new_light = light_widget_scene.instantiate()
	get_dynamic_lighting().add_child(new_light)
	new_light.init_widget()
	new_light.make_immaterial()
	return new_light
