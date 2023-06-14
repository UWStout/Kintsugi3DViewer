extends Node3D

class_name LightingPreset

@export var preset_name : String = "Unnamed Lighting Preset"
@export var is_customizable : bool = false

func get_lights():
	var lights = []
	for child in get_children():
		if child is DirectionalLight3D:
			lights.push_back(child)
	
	return lights
