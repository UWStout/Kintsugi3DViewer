extends Node3D

class_name MovableLightWidget

@export var controller : MovableLightingController
@export var camera : CameraRig
@export var focus_point : Node3D
@export var connected_light : SpotLight3D

var selected_obj
var is_dragging : bool = false

# -1 	=> NO AXIS
# 0 	=> In / Out
# 1 	=> Horizontal
# 2 	=> Vertical
# 3 	=> Focus Point
var selected_axis : int = -1

var axis_vector : Vector2
var axis_unit_vector : Vector2
var selected_initial_position : Vector2
var initial_world_pos : Vector3

var horizontal_angle : float = 0
var vertical_angle : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if not focus_point == null:
		$focus.global_position = focus_point.global_position
		
		$widget_root.global_position = focus_point.global_position
		
		$widget_root/in_out.position += Vector3(0, 0, 5)
		$widget_root/vertical.position += Vector3(0, 0, 5)
		$widget_root/horizontal.position += Vector3(0, 0, 5)
		
	update_rotation(0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if not focus_point == null:
		#look_at(focus_point.global_position)
	pass

func grab(obj : Object, pos : Vector3):
	if not controller == null:
		controller.select_widget(self)
		
	if obj == $widget_root/in_out:
		selected_axis = 0
		
		$widget_root/in_out/track.visible = true
		$widget_root/horizontal.visible = false
		$widget_root/vertical.visible = false
		$focus.visible = false
	if obj == $widget_root/horizontal:
		selected_axis = 1
		
		$widget_root/horizontal/track.visible = true
		$widget_root/in_out.visible = false
		$widget_root/vertical.visible = false
		$focus.visible = false
		
		set_up_horizontal_track()
	if obj == $widget_root/vertical:
		selected_axis = 2
		
		$widget_root/vertical/track.visible = true
		$widget_root/in_out.visible = false
		$widget_root/horizontal.visible = false
		$focus.visible = false
		
		set_up_vertical_track()
	if obj == $focus:
		selected_axis = 3
		
		$widget_root/vertical.visible = false
		$widget_root/in_out.visible = false
		$widget_root/horizontal.visible = false
	
	selected_initial_position = camera.camera.unproject_position(pos)
	axis_vector = camera.camera.unproject_position($widget_root/in_out/axis_target.global_position) - camera.camera.unproject_position($widget_root/in_out.global_position)
	axis_unit_vector = axis_vector.normalized()
	initial_world_pos = global_position

func _input(event):
	if not controller.selected_widget == self:
		return
		
	if not camera.camera.is_position_in_frustum(global_position):
		controller.select_widget(null)
		reset_axis_displays()
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
		else:
			is_dragging = false
			reset_axis_displays()
	
	if event is InputEventMouseMotion and is_dragging:
		camera.do_move_in_frame = false
		
		if selected_axis == 0:
			handle_in_out_axis(event.position)
		if selected_axis == 1:
			handle_horizontal_axis(event.position)
		if selected_axis == 2:
			handle_vertical_axis(event.position)
		if selected_axis == 3:
			handle_focus_point(event.position)
			
	if not focus_point == null:
		$focus.global_position = focus_point.global_position
		
	if not connected_light == null:
		connected_light.global_rotation = $widget_root/in_out.global_rotation
		connected_light.global_position = $widget_root/in_out.global_position

func handle_in_out_axis(event_pos : Vector2):
	# The vector from the initial position of the click, to where the cursor currently is
	# (in screen space)
	var movement_vector = event_pos - selected_initial_position
	
	# The movement vector projected onto the axis' vector
	# (in screen space)
	var projected_movement_vector = movement_vector.project(axis_unit_vector)
	
	# The movement direction is the sign of the movement. 
	var movement_direction = -sign(axis_unit_vector.dot(projected_movement_vector))
	
	# The length in world units is calculated by multiplying the ratio of the axis' vectors
	# length in pixels to the world distance it represents, which is 1u/length.
	# By multiplying the length of the projected movement vector, we can find the 
	# world distance it represents.
	var movement_distance = (projected_movement_vector.length() / axis_vector.length()) * movement_direction
	
	#global_position = initial_world_pos + global_transform.basis.z * movement_distance
	var next_global_position = initial_world_pos + $widget_root.transform.basis.z * movement_distance
	
	# If we try to move too close to the focus point, cancel the movement
	if not focus_point == null and focus_point.global_position.distance_to(next_global_position) <= 1:
		return
		
	# If we try to go to the other side of the focus point, cancel the movement
	if not focus_point == null and (focus_point.global_position.direction_to(global_position) - focus_point.global_position.direction_to(next_global_position)).length() >= 0.5:
		return
		
	global_position = next_global_position

func handle_horizontal_axis(event_pos : Vector2):
	if focus_point == null:
		return
		
	# Get the focus point's position on the screen
	var axis_center = camera.camera.unproject_position(focus_point.global_position)
		
	# Get the vector from the axis center to where the mouse cursor is
	var event_pos_difference = axis_center - event_pos
	
	# If the camera is looking down on the rotation disc, then we need to reverse the mouse's x position
	# this (sometimes) works to make the controls work correctly.
	var scale_factor = sign(camera.rotationPoint.rotation_degrees.x - $widget_root.rotation_degrees.x)
	
	# The angle of the vector from the axis center to the mouse pos
	var event_pos_angle = atan2(event_pos_difference.y, scale_factor * event_pos_difference.x)
		
	var result = event_pos_angle
		
	update_rotation(result, vertical_angle)
	$widget_root/horizontal/track.global_position = focus_point.global_position

func handle_vertical_axis(event_pos : Vector2):
	if focus_point == null:
		return
	
	# The disc's center in screen space
	var axis_center = camera.camera.unproject_position(focus_point.global_position)
	
	# the vector from the center to the mouse pos
	var event_pos_difference = axis_center - event_pos
	
	# if the camera is to the right of the rotation disc, then the mouse's x pos needs
	# to be reversed. Works (sometimes) to achieve the correct controls
	var scale_factor = sign(camera.rotationPoint.rotation_degrees.y - $widget_root/vertical.rotation_degrees.y)
	var event_pos_angle = atan2(event_pos_difference.y,scale_factor * event_pos_difference.x)
	
	# rotate the result by 90 degrees to get the correct position
	var result = event_pos_angle - PI
	
	update_rotation(horizontal_angle, result)
	$widget_root/vertical/track.global_position = focus_point.global_position

func handle_focus_point(event_pos : Vector2):
	pass

func reset_axis_displays():
	$widget_root/in_out.visible = true
	$widget_root/in_out/track.visible = false
	
	$widget_root/horizontal.visible = true
	$widget_root/horizontal/track.visible = false
	
	$widget_root/vertical.visible = true
	$widget_root/vertical/track.visible = false
	
	$focus.visible = true

func set_up_horizontal_track():
	$widget_root/horizontal/track.global_position = focus_point.global_position + Vector3(0, $widget_root/horizontal.position.y, 0)
	$widget_root/horizontal/track.outer_radius = focus_point.global_position.distance_to($widget_root/horizontal.global_position)
	$widget_root/horizontal/track.inner_radius = $widget_root/horizontal/track.outer_radius - .01
	$widget_root/horizontal/track.global_rotation = Vector3(0,0,0)

func set_up_vertical_track():
	$widget_root/vertical/track.global_position = focus_point.global_position
	$widget_root/vertical/track.outer_radius = focus_point.global_position.distance_to($widget_root/vertical.global_position)
	$widget_root/vertical/track.inner_radius = $widget_root/vertical/track.outer_radius - .01
	#$vertical/track.global_rotation = global_rotation

func update_rotation(new_horizontal_angle : float, new_vertical_angle : float):
	horizontal_angle = fmod(new_horizontal_angle, 2 * PI)
	vertical_angle = fmod(new_vertical_angle, 2 * PI)
	
	$widget_root.rotation = Vector3(vertical_angle, horizontal_angle, 0)
