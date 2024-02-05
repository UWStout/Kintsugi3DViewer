extends Node3D

func _on_artifact_bounds_changed(aabb : AABB):
	var scale = aabb.get_longest_axis_size()
	
	# set range scale for dynamic lights
	var dynamic_lights = find_child("dynamics").get_children()
	for light in dynamic_lights:
		if light is NewLightWidget:
			light.set_environment_scale(aabb.get_longest_axis_size())
