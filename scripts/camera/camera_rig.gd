extends Node3D

class_name CameraRig

@export_category("Camera Rig")
@export var rig_enabled: bool = true
@export_group("Node References")
@export var camera: Camera3D
@export var rotationPoint: Node3D

@export_group("Rotation", "rot_")
@export var rot_enabled: bool = true
@export var rot_interpolate: bool = true
@export_range(0, 10, 0.01) var rot_rate: float = 4
@export var rot_initial_rotation: Vector3
@export_subgroup("Vertical Limits", "rot_vert_limit_")
@export var rot_vert_limit_enabled: bool = true
@export var rot_vert_limit_fix_roll: bool = true
@export var rot_vert_limit_top_angle: float = 5
@export var rot_vert_limit_bottom_angle: float = 5
@onready var rot_limit_min = deg_to_rad(rot_vert_limit_top_angle)
@onready var rot_limit_max = deg_to_rad(180 - rot_vert_limit_bottom_angle)
# Not Implemented
#@export_subgroup("Horizontal Limits", "rot_horiz_limit_")
#@export var rot_horiz_limit_enabled: bool = false
#@export var rot_horiz_limit_minAngle: float
#@export var rot_horiz_limit_maxAngle: float

@export_group("Translation", "drag_")
@export var drag_enabled: bool = true
@export var drag_interpolate: bool = true
@export_range(0, 10, 0.01) var drag_rate: float = 4
@export var drag_initial_translation: Vector3

@export_group("Dolly Zoom", "dolly_")
@export var dolly_enabled: bool = true
@export var dolly_interpolate: bool = true
@export_range(0, 10, 0.01) var dolly_rate: float = 4
@export var dolly_initial_distance: float = 10
@export_subgroup("Limits", "dolly_limit_")
@export var dolly_limit_enabled: bool = true
@export var dolly_limit_minDistance: float = 1
@export var dolly_limit_maxDistance: float = 100

@export_group("FOV Zoom", "fov_")
@export var fov_enabled: bool = false
@export var fov_interpolate: bool = true
@export_range(0, 10, 0.01) var fov_rate: float = 4
@export_range(1, 179, 0.1, "degrees") var fov_initial_fov: float = 75

# Targets
var target_transform: Transform3D
var target_dolly: float
var target_fov: float

func set_fov(new_fov: float):
	target_fov = new_fov

func set_dolly(new_dolly: float):
	target_dolly = new_dolly

func set_zoom(new_zoom: float):
	set_dolly(new_zoom)

func set_rig_transform(new_transform: Transform3D):
	target_transform = new_transform

func set_rig_rotation(new_rotation: Vector3):
	var new_transform = Transform3D(Basis.from_euler(new_rotation), target_transform.origin)
	set_rig_transform(new_transform)

func set_rig_position(new_position: Vector3):
	var new_transform = Transform3D(target_transform.basis, new_position)
	set_rig_transform(new_transform)

func apply_fov(delta_fov: float):
	set_fov(target_fov + delta_fov)

func apply_zoom(delta_zoom: float):
	set_dolly(target_dolly + delta_zoom)

func apply_transform(delta_transform: Transform3D):
	set_rig_transform(delta_transform * target_transform)

func apply_translation(delta_position: Vector3):
	set_rig_transform(target_transform.translated(delta_position))

# Buggy, should probably use apply_pitch() and apply_yaw() instead
func apply_rotation(delta_rotation: Vector3):
	target_transform.basis = Basis.from_euler(delta_rotation) * target_transform.basis

func apply_yaw(delta_yaw: float):
	target_transform.basis = target_transform.basis.rotated(Vector3.UP, delta_yaw).orthonormalized()

func apply_pitch(delta_pitch: float):
	target_transform.basis = target_transform.basis.rotated(target_transform.basis.x, delta_pitch).orthonormalized()

func apply_drag(delta_drag: Vector2):
	apply_translation(target_transform.basis * Vector3(delta_drag.x, delta_drag.y, 0))

func apply_drag_direct(delta_drag: Vector2):
	apply_drag(delta_drag)
	rotationPoint.transform.origin = target_transform.origin

func _ready():
	# Validate variables
	if not is_instance_valid(camera):
		push_error("Camera Rig at %s does not have a valid camera node assigned!" % get_path())
		return
	if not is_instance_valid(rotationPoint):
		push_error("Camera Rig at %s does not have a valid rotation point node assigned!" % get_path())
		return
	
	# Set target variables to initial values
	target_dolly = dolly_initial_distance
	target_fov = fov_initial_fov
	var rot_basis = Basis.from_euler(rot_initial_rotation)
	target_transform = Transform3D(rot_basis, drag_initial_translation)
	
	rotationPoint.transform = target_transform
	camera.position.z = target_dolly
	camera.fov = target_fov
	
func _process(delta):
	if not rig_enabled:
		return
	
	if fov_enabled:
		target_fov = clamp(target_fov, 1, 179)
		var weight = fov_rate * delta if fov_interpolate else 1
		camera.fov = lerp(camera.fov, target_fov, weight)
	
	if dolly_enabled:
		if dolly_limit_enabled:
			target_dolly = clamp(target_dolly, dolly_limit_minDistance, dolly_limit_maxDistance)
		var weight = dolly_rate * delta if dolly_interpolate else 1
		camera.position.z = lerp(camera.position.z, target_dolly, weight)
		
	if rot_enabled:
		if rot_vert_limit_enabled:
			var angle_to_north = acos(target_transform.basis.z.dot(transform.basis.y))
			# Check if Camera is upside down (Limit was overrun in a single frame)
			if target_transform.basis.y.dot(transform.basis.y) < 0:
				# Camera is in northern hemisphere (Overran min angle)
				if target_transform.basis.z.dot(transform.basis.y) > 0:
					var err_angle = angle_to_north + rot_limit_min
					target_transform = target_transform.rotated_local(Vector3.RIGHT, err_angle)
				else: # Camera is in southern hemisphere (Overran max angle)
					var err_angle = angle_to_north-PI + rot_limit_max-PI
					target_transform = target_transform.rotated_local(Vector3.RIGHT, err_angle)
			else: # Do normal limit calculations
				if angle_to_north < rot_limit_min:
					var err_angle = angle_to_north - rot_limit_min
					target_transform = target_transform.rotated_local(Vector3.LEFT, err_angle)
				if angle_to_north > rot_limit_max:
					var err_angle = angle_to_north - rot_limit_max
					target_transform = target_transform.rotated_local(Vector3.LEFT, err_angle)
	
		var new_basis: Basis
		if rot_interpolate:
			new_basis = rotationPoint.transform.basis.slerp(target_transform.basis, rot_rate * delta)
		else:
			new_basis = target_transform.basis
		
		rotationPoint.transform.basis = new_basis
	
	if drag_enabled:
		var weight = drag_rate * delta if drag_interpolate else 1
		rotationPoint.transform.origin = rotationPoint.transform.origin.lerp(target_transform.origin, weight)
