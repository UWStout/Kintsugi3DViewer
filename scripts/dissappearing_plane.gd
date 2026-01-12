# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Node3D

@export var camera : CameraRig
@export var distance_threshold : float = 2
@export var csg_mesh_3d : GeometryInstance3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var new_mat = StandardMaterial3D.new()
	new_mat.render_priority = -100
	new_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	new_mat.albedo_color = Color(0, 0, 0, 1)
	#new_mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	
	csg_mesh_3d.set_material(new_mat)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(camera.camera.global_position.y < global_position.y):
		return
	
	var dist_to_plane = camera.camera.global_position.y - global_position.y
	
	if dist_to_plane <= distance_threshold:
		var alpha = (dist_to_plane / distance_threshold)
		csg_mesh_3d.material.albedo_color = Color(0,0,0,alpha)
	else:
		csg_mesh_3d.material.albedo_color = Color(0,0,0,1)
