extends Node3D

class_name NewLightWidget

var widget_distance : float = 0
var widget_horizontal_angle : float = 0
var widget_vertical_angle : float = 0

@onready var target_point = $target_point
@onready var direction_axis = $target_point/direction
@onready var horizontal_axis = $target_point/horizontal
@onready var vertical_axis = $target_point/vertical

# 0 = Target Point
# 1 = Distance Axis
# 2 = Horizontal Axis
# 3 = Vertical Axis
#
# -1 = None
var selected_widget_part : int = -1

var is_dragging : bool

# TODO: Make this NOT an export variable. Should be supplied in code
# when this object is created.
@export var scene_camera_rig : CameraRig
# TODO: This whole MovableLightingController class should be redone, into a 
# global LightController class. That would eliminate the need for this variable
@export var controller : MovableLightingController

# The selected widget part's world position
# when the part was first selected
var selected_widget_part_initial_position_world : Vector3
# The screen position of the point where the widget was clicked
# when a new manipulation began
var selected_initial_position_screen : Vector2 = Vector2(-1, -1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called when a part of this object is selected by a raycast
func select_widget(clicked_object : Object, clicked_position : Vector3):
	controller.select_new_widget(self)
	
	select_widget_part(clicked_object)
	
	selected_initial_position_screen = scene_camera_rig.camera.unproject_position(clicked_position)

# Called when another widget is selected, or some other action is taken
# that causes this widge to be unselected
func unselect_widget():
	pass

# Select a part of this widget to be manipulated by the user
func select_widget_part(selected_object : Object):
	if selected_object == target_point:
		selected_widget_part = 0
		selected_widget_part_initial_position_world = target_point.global_position
	elif selected_object == direction_axis:
		selected_widget_part = 1
		selected_widget_part_initial_position_world = direction_axis.global_position
	elif selected_object == horizontal_axis:
		selected_widget_part = 2
		selected_widget_part_initial_position_world = horizontal_axis.global_position
	elif selected_object == vertical_axis:
		selected_widget_part = 3
		selected_widget_part_initial_position_world = vertical_axis.global_position
	else:
		selected_widget_part = -1
		
	if not selected_widget_part == -1:
		print("selected " + selected_object.name + "!")
	else:
		print("no valid part could be selected!")
	pass

# Returns the (Object) widget part that was selected
func get_selected_widget_part():
	if selected_widget_part == 0:
		return target_point
	elif selected_widget_part == 1:
		return direction_axis
	elif selected_widget_part == 2:
		return horizontal_axis
	elif selected_widget_part == 3:
		return vertical_axis
	else:
		return null

# Set the camera that controls the current scene
func set_scene_camera_rig(camera_rig : CameraRig):
	scene_camera_rig = camera_rig

func _input(event):
	# if this widget is not selected, do nothing
	if not controller.selected_new_widget == self:
		return
	
	# if the selected part of this widget is outside of the camera's view, do nothing
	if not scene_camera_rig.camera.is_position_in_frustum(get_selected_widget_part().global_position):
		print("The selected part is outside of the screen view. It cannot be manipulated!")
		return
	
	# We only want to manipulate the widget if the cursor is being dragged
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			selected_initial_position_screen = event.position
			
			selected_widget_part_initial_position_world = get_selected_widget_part().global_position
		else:
			is_dragging = false
	
	# If the event is a mouse movement, and the mouse is being dragged, manipulate the widget
	if event is InputEventMouseMotion and is_dragging:
		# If we are manipulating the widget we don't want the camera to rotate or move
		scene_camera_rig.do_move_in_frame = false
		
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
	
	var target_one_screen_pos = scene_camera_rig.camera.unproject_position(selected_widget_part_initial_position_world)
	# The world position of a point one meter to the right of the target_point
	# (relative to the camera). Used to get a scale for moving the point
	var one_meter_screen_pos = scene_camera_rig.camera.unproject_position(selected_widget_part_initial_position_world + scene_camera_rig.camera.global_transform.basis.x)
	
	# The ratio of pixels to meters. (How many pixels in screen space make up one meter of world space)
	var scale_factor = one_meter_screen_pos.distance_to(target_one_screen_pos)
	
	var world_offset = ((scene_camera_rig.camera.global_transform.basis.x * delta_vec.x) + (scene_camera_rig.camera.global_transform.basis.y * -delta_vec.y)) / scale_factor
	
	target_point.global_position = selected_widget_part_initial_position_world + world_offset

# TODO: Need to make it so that dragging the axis beyong the target_point
# stops it, instead of causing it to "bounce" back
func handle_distance_axis(event_pos : Vector2):
	# The vector pointing from the initial selected position to the mouse cursor
	var delta_vec = event_pos - selected_initial_position_screen
	
	var direction_axis_screen_pos = scene_camera_rig.camera.unproject_position(selected_widget_part_initial_position_world)
	# The screen space position of a point one meter infront of the direction axis
	# (the vector from the direction axis position to this position points towards the target point)
	var one_meter_screen_pos = scene_camera_rig.camera.unproject_position(selected_widget_part_initial_position_world - direction_axis.global_transform.basis.z)
	
	# The vector pointing from the direction axis' positon to the 
	# target point (in screen space)
	var axis_vector = (one_meter_screen_pos - direction_axis_screen_pos).normalized()
	var scale_factor = one_meter_screen_pos.distance_to(direction_axis_screen_pos)
	
	# The delta_vec projected onto the axis vector
	var projected_delta_vec = delta_vec.project(axis_vector)
	
	# The direction of the axis' movement
	var movement_direction = -sign(axis_vector.dot(projected_delta_vec))
	var movement_distance = movement_direction * (projected_delta_vec.length() / scale_factor)

	var new_world_pos = selected_widget_part_initial_position_world + (direction_axis.global_transform.basis.z * movement_distance)
	
	var new_dist = target_point.global_position.distance_to(new_world_pos)
	
	update_distance(new_dist)

# TODO: Make it so that when viewing from above, the x-axis the angle_to_event_pos is flipped
# and when viewing from below it is not (OR, more preferably, figure out why that is happening, and fix it)
func handle_horizontal_axis(event_pos : Vector2):
	# The position of the target_point in screen space
	var target_point_screen_pos = scene_camera_rig.camera.unproject_position(target_point.global_position)
	# The position of the target_point, offset by 1 meter in the world forward direction,
	# in screen space
	var target_point_world_forward_screen_pos = scene_camera_rig.camera.unproject_position(target_point.global_position + Vector3.FORWARD)
	
	# The vector pointing from the target_point_screen_pos to the forward direction
	var vector_to_forward = (target_point_world_forward_screen_pos - target_point_screen_pos).normalized()
	
	# The angle we would need to rotate the screen by to face world forward. This will
	# be added to our rotation amount to get the correct position
	var angle_to_forward = atan2(vector_to_forward.x, -vector_to_forward.y) #+ (PI/2)
	
	# The vector from the target_point to the mouse cursor in screen space
	var vector_to_event_pos = (event_pos - target_point_screen_pos).normalized()
	
	# The angle of the mouse cursor on the screen (where 0 would point straight up)
	var angle_to_event_pos = atan2(-vector_to_event_pos.x, -vector_to_event_pos.y) + PI
	
	# The adjusted angle to calculate the world rotation of the axis
	var adjusted_angle = angle_to_event_pos + angle_to_forward
	
	update_rotation(adjusted_angle, widget_vertical_angle)

func handle_vertical_axis(event_pos : Vector2):
	# The position of the target_point in screen space
	var target_point_screen_pos = scene_camera_rig.camera.unproject_position(target_point.global_position)
	
	# The vector from the target_point to the mouse cursor in screen space
	var vector_to_event_pos = (event_pos - target_point_screen_pos).normalized()
	
	# 1 if the axis is on the right of the screen, -1 if it is on the left
	# used to ensure that 0 degrees is always on the horizontal equator of the screen,
	# no matter which side (left or right) the axis is on
	var axis_screen_side = sign(selected_initial_position_screen.x - (get_viewport().get_visible_rect().size.x/2))
	
	var vectors_dot_product = sign(vector_to_event_pos.dot(Vector2(axis_screen_side * 100, 0)))
	
	# If the dot product is -1, then the cursor is on the opposite side of the screen from
	# the vertical axis, would would mean the user is trying to rotate the axis' upside down, which
	# is not allowed
	if(vectors_dot_product == -1):
		return
	
	# The angle of the mouse cursor on the screen (where 0 would point straight to the right)
	var angle_to_event_pos = -atan2(-vector_to_event_pos.y, axis_screen_side * vector_to_event_pos.x) #+ PI
	
	update_rotation(widget_horizontal_angle, angle_to_event_pos)
	
	pass

# TODO: Add clamping to restrict distances
func update_distance(new_distance : float):
	direction_axis.position = Vector3(0, 0, new_distance)
	horizontal_axis.position = Vector3(0, 0, new_distance)
	vertical_axis.position = Vector3(0, 0, new_distance)

# TODO: Add clamping to vertical angles
func update_rotation(new_horizontal_angle : float, new_vertical_angle : float):
	widget_horizontal_angle = fmod(new_horizontal_angle, 2*PI)
	widget_vertical_angle = fmod(new_vertical_angle, 2*PI)
	
	target_point.rotation = Vector3(widget_vertical_angle, widget_horizontal_angle, 0)
