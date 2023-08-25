# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Node

@export var camera: CameraRig
@export var keyboard_input_provider: Node
@export var capture_all_input: bool = false
@export var input_enabled: bool = true
@export var rotation_rate: float = 0.005
@export var drag_rate: float = 0.01
@export var zoom_rate: float = 0.01
@export var grace_period: float = 1000

var fingers = {}
var primary_finger: int

class FingerData:
	var os_index: int
	var initial_position: Vector2
	var current_position: Vector2

enum Mode {NONE, ROTATE, DRAG, ZOOM, DRAGZOOM_UNDECIDED}
var current_mode = Mode.NONE

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
	
	if event is InputEventScreenTouch:
		if event.pressed:
			var data = FingerData.new()
			data.os_index = event.index
			data.initial_position = event.position
			data.current_position = event.position
			if fingers.is_empty():
				primary_finger = event.index
			fingers[event.index] = data
			
			do_raycast = true
		else:
			fingers.erase(event.index)
		
		if is_instance_valid(keyboard_input_provider):
			keyboard_input_provider.input_enabled = fingers.size() <= 0
		
		match fingers.size():
			1:
				current_mode = Mode.ROTATE
			2:
				current_mode = Mode.DRAGZOOM_UNDECIDED
			_:
				current_mode = Mode.NONE
	
	if event is InputEventScreenDrag:
		if fingers.has(event.index):
			fingers[event.index].current_position = event.position
	
		if primary_finger == event.index and not fingers.is_empty():
			if current_mode == Mode.ROTATE:
				camera.apply_yaw(-event.relative.x * rotation_rate)
				camera.apply_pitch(-event.relative.y * rotation_rate)
			
			if current_mode == Mode.DRAG:
				camera.apply_drag((event.relative * Vector2(-1, 1)) * drag_rate)
		
		if current_mode == Mode.ZOOM:
			var other: FingerData
			for fingeridx in fingers:
				if fingeridx != event.index:
					other = fingers[fingeridx]
					break
			
			var dist_diff = (event.position.distance_to(other.current_position)) - ((event.position - event.relative).distance_to(other.current_position))
			camera.apply_zoom(-dist_diff * zoom_rate)
		
		if current_mode == Mode.DRAGZOOM_UNDECIDED:
			var keys = fingers.keys()
			var fingerA = fingers[keys[0]]
			var fingerB = fingers[keys[1]]
			var move_grade = (fingerA.current_position - fingerA.initial_position).dot(fingerB.current_position - fingerB.initial_position)
			if move_grade >= grace_period:
				current_mode = Mode.DRAG
			elif move_grade <= -grace_period:
				current_mode = Mode.ZOOM
				
	if do_raycast:
		camera.cast_ray_to_world()
