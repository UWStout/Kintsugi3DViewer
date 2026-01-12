# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

@tool
extends Node3D

class_name NewLightWidget

@export_range(0, 10) var distance : float = 2 : set = _set_distance_UTIL
@export_range(0, 360) var horizontal_angle : float = 0 : set = _set_horizontal_angle_UTIL
@export_range(-90, 90) var vertical_angle : float = 0 : set = _set_vertical_angle_UTIL
@export var color : Color = Color(1,1,1,1) : set = _set_color_UTIL

var widget_distance : float = 0
var widget_horizontal_angle : float = 0
var widget_vertical_angle : float = 0

var was_grabbed : bool = false

@export var target_point : MovableLightWidgetAxis

@export var distance_axis : MovableLightWidgetAxis
@export var horizontal_axis : MovableLightWidgetAxis
@export var vertical_axis : MovableLightWidgetAxis

@export var target_point_mesh : GeometryInstance3D
@export var distance_mesh : GeometryInstance3D
@export var horizontal_mesh : GeometryInstance3D
@export var vertical_mesh : GeometryInstance3D

@export var distance_track : GeometryInstance3D
@export var horizontal_track : GeometryInstance3D
@export var vertical_track : GeometryInstance3D

@export var light : Light3D

signal environment_scale_changed(range : float, old_scale : float)
var _environment_scale : float = 1

var max_distance : float = 20

# 0 = Target Point
# 1 = Distance Axis
# 2 = Horizontal Axis
# 3 = Vertical Axis
#
# -1 = None
var selected_widget_part : int = -1

var is_dragging : bool

# TODO: This whole MovableLightingController class should be redone, into a 
# global LightController class. That would eliminate the need for this variable
@export var controller : EnvironmentController

# The selected widget part's world position
# when the part was first selected
var selected_widget_part_initial_position_world : Vector3
# The screen position of the point where the widget was clicked
# when a new manipulation began
var selected_initial_position_screen : Vector2 = Vector2(-1, -1)

# Called when a part of this object is selected by a raycast
func select_widget(clicked_object : Object, clicked_position : Vector3):
	controller.select_light(self)
	
	update_direction_track()
	update_horizontal_track()
	update_vertical_track()
	
	select_widget_part(clicked_object)
	
	was_grabbed = true
	is_dragging = true
	
	controller.scene_camera.rig_enabled = false
	
	selected_initial_position_screen = controller.scene_camera.camera.unproject_position(clicked_position)

# Called when another widget is selected, or some other action is taken
# that causes this widge to be unselected
func unselect_widget():
	target_point_mesh.visible = true
	distance_axis.visible = true
	horizontal_axis.visible = true
	vertical_axis.visible = true
	
	distance_track.visible = false
	horizontal_track.visible = false
	vertical_track.visible = false
	
	controller.scene_camera.rig_enabled = true

# Select a part of this widget to be manipulated by the user
func select_widget_part(selected_object : Object):
	if selected_object == target_point:
		selected_widget_part = 0
		selected_widget_part_initial_position_world = target_point.global_position
		
		target_point_mesh.visible = true
		distance_axis.visible = false
		horizontal_axis.visible = false
		vertical_axis.visible = false
	elif selected_object == distance_axis:
		selected_widget_part = 1
		selected_widget_part_initial_position_world = distance_axis.global_position
		
		distance_axis.visible = true
		distance_track.visible = true
		horizontal_axis.visible = false
		vertical_axis.visible = false
	elif selected_object == horizontal_axis:
		selected_widget_part = 2
		selected_widget_part_initial_position_world = horizontal_axis.global_position
		
		horizontal_axis.visible = true
		horizontal_track.visible = true
		distance_axis.visible = false
		vertical_axis.visible = false
	elif selected_object == vertical_axis:
		selected_widget_part = 3
		selected_widget_part_initial_position_world = vertical_axis.global_position
		
		vertical_axis.visible = true
		vertical_track.visible = true
		distance_axis.visible = false
		horizontal_axis.visible = false
	else:
		selected_widget_part = -1

# Returns the (Object) widget part that was selected
func get_selected_widget_part():
	if selected_widget_part == 0:
		return target_point
	elif selected_widget_part == 1:
		return distance_axis
	elif selected_widget_part == 2:
		return horizontal_axis
	elif selected_widget_part == 3:
		return vertical_axis
	else:
		return null

func _input(event):
	# if this widget is not selected, do nothing
	if controller == null or not controller.selected_light == self:
		return
		
	if controller.scene_camera == null:
		return
	
	# if the selected part of this widget is outside of the camera's view, do nothing
	#if not controller.scene_camera.camera.is_position_in_frustum(get_selected_widget_part().global_position):
		#print("The selected part is outside of the screen view. It cannot be manipulated!")
		#update_distance(widget_distance - 0.01)
		#controller.select_light(null)
		#return
		#pass
	
	# We only want to manipulate the widget if the cursor is being dragged
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):# or event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = true
			selected_initial_position_screen = event.position
			
			selected_widget_part_initial_position_world = get_selected_widget_part().global_position
			controller.scene_camera.rig_enabled = false
		else:
			is_dragging = false
			target_point_mesh.visible = true
			distance_axis.visible = true
			horizontal_axis.visible = true
			vertical_axis.visible = true
			
			distance_track.visible = false
			horizontal_track.visible = false
			vertical_track.visible = false
			
			was_grabbed = false
			
			controller.scene_camera.rig_enabled = true
	
	# If the event is a mouse movement, and the mouse is being dragged, manipulate the widget
	if (event is InputEventMouseMotion) and is_dragging and was_grabbed:
		# If we are manipulating the widget we don't want the camera to rotate or move
		#controller.scene_camera.do_move_in_frame = false
		
		if selected_widget_part == 0:
			handle_target_point(event.position)
		if selected_widget_part == 1:
			handle_distance_axis(event.position)
		if selected_widget_part == 2:
			handle_horizontal_axis(event.position)
		if selected_widget_part == 3:
			handle_vertical_axis(event.position)

func handle_target_point(event_pos : Vector2):
	
	# The vector pointing from the initial selected position to the mouse cursor
	var delta_vec = event_pos - selected_initial_position_screen
	
	#get_snapped_world_position(event_pos)
	
	var target_one_screen_pos = controller.scene_camera.camera.unproject_position(selected_widget_part_initial_position_world)
	# The world position of a point one meter to the right of the target_point
	# (relative to the camera). Used to get a scale for moving the point
	var one_meter_screen_pos = controller.scene_camera.camera.unproject_position(selected_widget_part_initial_position_world + controller.scene_camera.camera.global_transform.basis.x)
	
	# The ratio of pixels to meters. (How many pixels in screen space make up one meter of world space)
	var scale_factor = one_meter_screen_pos.distance_to(target_one_screen_pos)
	
	var world_offset = ((controller.scene_camera.camera.global_transform.basis.x * delta_vec.x) + (controller.scene_camera.camera.global_transform.basis.y * -delta_vec.y)) / scale_factor
	
	# commented out since snapping is broken
	var snapped_world_pos = null;  # get_snapped_world_position(event_pos)
	
	if snapped_world_pos != null:
		target_point.global_position = snapped_world_pos
	else:
		target_point.global_position = selected_widget_part_initial_position_world + world_offset

func get_snapped_world_position(event_pos : Vector2):
	var space_state = get_world_3d().direct_space_state
	var mouse_pos_world = controller.scene_camera.camera.project_ray_origin(event_pos)
	var ray_end = mouse_pos_world + controller.scene_camera.camera.project_ray_normal(event_pos) * 30
	var ray_query = PhysicsRayQueryParameters3D.create(mouse_pos_world, ray_end, 1)
	var ray_result = space_state.intersect_ray(ray_query)
	
	# TODO: for this to actually work, we need to replace collider based picking
	# with depth buffer picking (according to ChatGPT, requires a 2nd viewport and custom shader)
	
	if(ray_result):
		return ray_result["position"]
	else:
		return null

func handle_distance_axis(event_pos : Vector2):
	# The vector pointing from the initial selected position to the mouse cursor
	var delta_vec = event_pos - selected_initial_position_screen
	
	var direction_axis_screen_pos = controller.scene_camera.camera.unproject_position(selected_widget_part_initial_position_world)
	# The screen space position of a point one meter infront of the direction axis
	# (the vector from the direction axis position to this position points towards the target point)
	var one_meter_screen_pos = controller.scene_camera.camera.unproject_position(selected_widget_part_initial_position_world - distance_axis.global_transform.basis.z)
	
	# The vector pointing from the direction axis' positon to the 
	# target point (in screen space)
	var axis_vector = (one_meter_screen_pos - direction_axis_screen_pos).normalized()
	var scale_factor = one_meter_screen_pos.distance_to(direction_axis_screen_pos)
	
	var target_point_screen_pos = controller.scene_camera.camera.unproject_position(target_point.global_position)
	var vector_from_target_point = event_pos - target_point_screen_pos
	
	# 1 if the cursor is on the same side of the screen as the axis
	# -1 if not
	var cursor_side = -sign(axis_vector.dot(vector_from_target_point))
	
	# if the cursor is on the wrong side of the screen, don't allow the axis
	# to move
	if cursor_side == -1:
		return
	
	# The delta_vec projected onto the axis vector
	var projected_delta_vec = delta_vec.project(axis_vector)
	
	# The direction of the axis' movement
	var movement_direction = -sign(axis_vector.dot(projected_delta_vec))
	var movement_distance = movement_direction * (projected_delta_vec.length() / scale_factor)

	var new_world_pos = selected_widget_part_initial_position_world + (distance_axis.global_transform.basis.z * movement_distance)
	
	var new_dist = target_point.global_position.distance_to(new_world_pos)
	
	update_distance(new_dist)
	update_direction_track()

func handle_horizontal_axis(event_pos : Vector2):
	# The distance of the horizontal plane to the target point on the Y-axis
	var y_dist = horizontal_axis.global_position.y - target_point.global_position.y
	
	# The position of the target_point in screen space
	var target_point_screen_pos = controller.scene_camera.camera.unproject_position(target_point.global_position + Vector3(0, y_dist, 0))
	# The position of the target_point, offset by 1 meter in the world forward direction,
	# in screen space
	var target_point_world_forward_screen_pos = controller.scene_camera.camera.unproject_position(target_point.global_position + Vector3(0, y_dist, 0) + Vector3.FORWARD)
	
	# The vector pointing from the target_point_screen_pos to the forward direction
	var vector_to_forward = (target_point_world_forward_screen_pos - target_point_screen_pos).normalized()
	
	# The angle we would need to rotate the screen by to face world forward. This will
	# be added to our rotation amount to get the correct position
	var angle_to_forward = atan2(vector_to_forward.x, -vector_to_forward.y) #+ (PI/2)
	
	# The vector from the target_point to the mouse cursor in screen space
	var vector_to_event_pos = (event_pos - target_point_screen_pos).normalized()
	
	# 1 if the camera has a negative x angle, -1 if it has a positive x angle
	var scale_var = sign(controller.scene_camera.rotationPoint.rotation_degrees.x)
	
	# The angle of the mouse cursor on the screen (where 0 would point straight up)
	var angle_to_event_pos = atan2(scale_var * vector_to_event_pos.x, -vector_to_event_pos.y) + PI
	
	# The adjusted angle to calculate the world rotation of the axis
	var adjusted_angle = angle_to_event_pos + angle_to_forward
	
	update_rotation(adjusted_angle, widget_vertical_angle)
	update_horizontal_track()

func handle_vertical_axis(event_pos : Vector2):
	# The position of the target_point in screen space
	var target_point_screen_pos = controller.scene_camera.camera.unproject_position(target_point.global_position)
	
	# The vector from the target_point to the mouse cursor in screen space
	var vector_to_event_pos = (event_pos - target_point_screen_pos).normalized()
	
	var vertical_axis_screen_pos = controller.scene_camera.camera.unproject_position(vertical_axis.global_position)
	
	# 1 is the axis is on the right side of the target point, -1 if it's on the left.
	# Usec to ensure that the axis always rotates on the correct side of the axis
	var axis_screen_side = sign(vertical_axis_screen_pos.x - target_point_screen_pos.x)
	
	var vectors_dot_product = sign(vector_to_event_pos.dot(Vector2(axis_screen_side * 100, 0)))
	
	# If the dot product is -1, then the cursor is on the opposite side of the screen from
	# the vertical axis, would would mean the user is trying to rotate the axis' upside down, which
	# is not allowed
	if(vectors_dot_product == -1):
		return
	
	# The angle of the mouse cursor on the screen (where 0 would point straight to the right)
	var angle_to_event_pos = -atan2(-vector_to_event_pos.y, axis_screen_side * vector_to_event_pos.x) #+ PI
	
	update_rotation(widget_horizontal_angle, angle_to_event_pos)
	update_vertical_track()

func update_distance(new_distance : float):
	widget_distance = clampf(new_distance, 0, max_distance)
	
	distance_axis.position = Vector3(0, 0, widget_distance)
	horizontal_axis.position = Vector3(0, 0, widget_distance)
	vertical_axis.position = Vector3(0, 0, widget_distance)
	light.position = Vector3(0, 0, widget_distance)

# TODO: Add clamping to vertical angles
func update_rotation(new_horizontal_angle : float, new_vertical_angle : float):
	widget_horizontal_angle = fmod(new_horizontal_angle, 2*PI)
	widget_vertical_angle = fmod(new_vertical_angle, 2*PI)
	widget_vertical_angle = clampf(widget_vertical_angle, deg_to_rad(-89), deg_to_rad(89))
	target_point.rotation = Vector3(widget_vertical_angle, widget_horizontal_angle, 0)

func update_direction_track():
	distance_track.position = Vector3(0,0,50 - widget_distance)

func update_horizontal_track():
	var y_dist = horizontal_axis.global_position.y - target_point.global_position.y
	var planar_distance = cos(widget_vertical_angle) * widget_distance
	
	horizontal_track.outer_radius = planar_distance
	horizontal_track.inner_radius = planar_distance - .005
	horizontal_track.global_position = target_point.global_position + Vector3(0, y_dist, 0)
	horizontal_track.global_rotation = Vector3(0,0,0)
	pass
	
func update_vertical_track():
	vertical_track.outer_radius = widget_distance
	vertical_track.inner_radius = widget_distance - .005
	vertical_track.global_position = target_point.global_position
	vertical_track.global_rotation = target_point.global_rotation + Vector3(0, 0, PI/2)

func change_color(new_color : Color):
	light.light_color = new_color
	#
	#var adjusted_color = Color(new_color.r, new_color.g, new_color.b, 1)
	#
	#adjusted_color.v = max(adjusted_color.v, 0.5)
	#
	#var new_material = StandardMaterial3D.new()
	#new_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	#new_material.albedo_color = adjusted_color
	#new_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	#
	#var target_mat = new_material.duplicate() as BaseMaterial3D
	#target_mat.no_depth_test = true
	##target_mat.emission_enabled = false
	##target_mat.emission_operator = BaseMaterial3D.EMISSION_OP_ADD
	#
	#$target_point/mesh.material = target_mat
	#
	#var distance = $target_point/distance/mesh
	#var horizontal = $target_point/horizontal/mesh
	#var vertical = $target_point/horizontal/mesh
	#if distance != null:
		#distance.set_surface_override_material(0, new_material)
	#if horizontal != null:
		#horizontal.set_surface_override_material(0, new_material)
	#if vertical != null:
		#vertical.set_surface_override_material(0, new_material)

func hide_widget():
	target_point_mesh.visible = false
	
	distance_axis.visible = false
	horizontal_axis.visble = false
	vertical_axis.visible = false

func show_widget():
	target_point_mesh.visible = true
	distance_axis.visible = true
	horizontal_axis.visible = true
	vertical_axis.visible = true

func _set_distance_UTIL(dist : float):
	distance = dist
	update_distance(dist)

func _set_horizontal_angle_UTIL(angle : float):
	horizontal_angle = angle
	update_rotation(deg_to_rad(angle), widget_vertical_angle)

func _set_vertical_angle_UTIL(angle : float):
	vertical_angle = angle
	update_rotation(widget_horizontal_angle, deg_to_rad(angle))

func _set_color_UTIL(col : Color):
	color = col
	change_color(col)

# Make it so this widget is invisible and cannot be clicked
func make_immaterial():
	target_point_mesh.visible = false
	distance_axis.visible = false
	horizontal_axis.visible = false
	vertical_axis.visible = false
	
	target_point.collision_layer = 0
	target_point.collision_mask = 0
	
	distance_axis.collision_layer = 0
	distance_axis.collision_mask = 0
	
	horizontal_axis.collision_layer = 0
	horizontal_axis.collision_mask = 0
	
	vertical_axis.collision_layer = 0
	vertical_axis.collision_mask = 0

# Make it so this widget is visible and can be clicked
func make_material():
	target_point_mesh.visible = true
	distance_axis.visible = true
	horizontal_axis.visible = true
	vertical_axis.visible = true
	
	target_point.collision_layer = 2
	target_point.collision_mask = 2
	
	distance_axis.collision_layer = 2
	distance_axis.collision_mask = 2
	
	horizontal_axis.collision_layer = 2
	horizontal_axis.collision_mask = 2
	
	vertical_axis.collision_layer = 2
	vertical_axis.collision_mask = 2

func init_widget():
	_set_distance_UTIL(distance)
	_set_horizontal_angle_UTIL(horizontal_angle)
	_set_vertical_angle_UTIL(vertical_angle)
	_set_color_UTIL(color)

func get_color_strength():
	return light.light_energy / 10.0

func get_light_angle():
	return light.spot_angle

func set_color_strength(new_strength : float):
	light.light_energy = new_strength * 10.0

func set_light_angle(new_angle : float):
	light.spot_angle = new_angle

func set_environment_scale(scale : float):
	var old_scale = _environment_scale
	_environment_scale = scale
	self.distance *= scale / old_scale
	environment_scale_changed.emit(scale, old_scale)
