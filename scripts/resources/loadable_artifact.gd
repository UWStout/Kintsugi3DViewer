# Copyright (c) 2024 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name LoadableArtifact extends Node3D

signal preview_load_completed
signal load_completed
signal load_progress(estimation : float)

var load_finished : bool = false
var is_local : bool = false

var artifact: ArtifactData = null
var aabb : AABB

func load_artifact():
	pass
	
static func apply_scale_adjustment(root : Node3D):
	# Most environments seem to be authored with a scale assumption of 1 unit = 50cm
	# since 1 unit = 1m is more typical, just scale up imported models.
	# This function must be called explicitly on the root of each object when loaded.
	root.scale = Vector3(2.0, 2.0, 2.0)
	
func refresh_aabb():
	var meshes = find_children("*", "MeshInstance3D", true, false)
	
	if meshes.size() == 0:
		aabb = global_transform * AABB()
		return -1
		
	aabb = meshes[0].global_transform * meshes[0].get_aabb()
	
	# merge AABBs of all meshes
	for mesh : MeshInstance3D in meshes:
		aabb = aabb.merge(mesh.global_transform * mesh.get_aabb())
	
	return 0
