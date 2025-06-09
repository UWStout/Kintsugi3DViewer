# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Node

@export var camera: CameraRig
@export var capture_all_input: bool = false
@export var input_enabled: bool = true
@export var zoom_rate: float = 0.20
@export var drag_rate: float = 0.025
@export var rotation_rate: float = 0.01

var dragCamera: bool
var rotateCamera: bool

var raycast_primes: int = 0

func _ready():
	# If the target camera rig is not manually set, attempt to find one in the scene
	if not is_instance_valid(camera):
		var parent_node = get_parent()
		if parent_node is CameraRig:
			camera = parent_node
		else:
			push_error("Basic Camera Input module at %s could not find, or was not assigned a CameraRig!" % get_path())

func _input(event):
	if capture_all_input:
		_handle_input_event(event)

func _handle_input_event(event):
	if not input_enabled:
		return
		
	var do_raycast = false
	
	if event is InputEventMouseButton:
		# Left Click
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragCamera = false
				rotateCamera = true
				do_raycast = true
			else:
				rotateCamera = false
				
		# Right Click
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				rotateCamera = false
				dragCamera = true
			else:
				dragCamera = false
		
		# Zoom In
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if (camera.get_dolly() <= 3):
				zoom_rate = 0.08
				drag_rate = 0.01
			else:
				zoom_rate = 0.4
				drag_rate = 0.04
			camera.apply_zoom(-zoom_rate)
			print(camera.get_dolly())
			
		
		# Zoom Out
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if (camera.get_dolly() <= 3):
				zoom_rate = 0.1
				drag_rate = 0.01
			else:
				zoom_rate = 0.4
				drag_rate = 0.04
			camera.apply_zoom(zoom_rate)
			print(camera.get_dolly())
	
	if event is InputEventMouseMotion:
		if dragCamera:
			camera.apply_drag((event.relative * Vector2(-1, 1)) * drag_rate)
			AnnotationsManager.change_selected_annotation(null)
		
		if rotateCamera:
			#camera.apply_rotation(Vector3(-event.relative.y, event.relative.x, 0) * rotation_rate)
			camera.apply_yaw(-event.relative.x * rotation_rate)
			camera.apply_pitch(-event.relative.y * rotation_rate)
	
	if do_raycast:
		camera.cast_ray_to_world()
