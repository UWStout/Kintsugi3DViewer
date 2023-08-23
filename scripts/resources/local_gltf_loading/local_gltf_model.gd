# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name LocalGltfModel extends GltfModel

var mat_loader : LocalGltfMaterial
var obj : GLTFObject
var aabb: AABB

func _load_artifact() -> int:
	if obj == null:
		return -1
	
	var scene = obj.generate_scene()
	add_child(scene)
	
	var mesh = scene.get_child(0, true)
	
	if mesh.get_aabb() != null:
		aabb = mesh.get_aabb()
	else:
		aabb = AABB()
	
	mat_loader = LocalGltfMaterial.new(obj)
	
	# Connect Material Load Progress
	# Connect Material Load Complete
	
	mesh.set_surface_override_material(0, mat_loader)
	mat_loader.load(mesh)
	
	load_completed.emit()
	load_finished = true
	return 0

static func create(p_obj : GLTFObject):
	var model = LocalGltfModel.new()
	model.obj = p_obj
	model.is_local = true
	return model
