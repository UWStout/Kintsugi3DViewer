extends Node3D

class_name CameraRig

@export_category("Camera Rig")
@export var rig_enabled: bool = true
@export_group("Node References")
@export var camera: Camera3D
@export var rotationPoint: Node3D

@export_group("Rotation", "rot_")
@export var rot_enabled: bool = true
@export_range(0, 10, 0.01) var rot_rate: float = 1
@export var rot_initial_rotation: Vector3
@export_subgroup("Vertical Limits", "rot_vert_limit_")
@export var rot_vert_limit_enabled: bool = true
@export var rot_vert_limit_minAngle: float = -85
@export var rot_vert_limit_maxAngle: float = 85
# Not Implemented
#@export_subgroup("Horizontal Limits", "rot_horiz_limit_")
#@export var rot_horiz_limit_enabled: bool = false
#@export var rot_horiz_limit_minAngle: float
#@export var rot_horiz_limit_maxAngle: float

@export_group("Translation", "drag_")
@export var drag_enabled: bool = true
@export_range(0, 10, 0.01) var drag_rate: float = 1
@export var drag_initial_translation: Vector3

@export_group("Dolly Zoom", "dolly_")
@export var dolly_enabled: bool = true
@export var dolly_initial_distance: float = 10
@export_range(0, 10, 0.01) var dolly_rate: float = 1
@export_subgroup("Limits", "dolly_limit_")
@export var dolly_limit_enabled: bool = true
@export var dolly_limit_minDistance: float = 1
@export var dolly_limit_maxDistance: float = 100

@export_group("FOV Zoom", "fov_")
@export var fov_enabled: bool = false
@export_range(0, 10, 0.01) var fov_rate: float = 1
@export_range(1, 179, 0.1, "degrees") var fov_initial_fov: float = 75

# Targets
var target_transform: Transform3D
var target_dolly: float
var target_fov: float

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
		camera.fov = lerp(camera.fov, target_fov, fov_rate * delta)
	
	if dolly_enabled:
		if dolly_limit_enabled:
			target_dolly = clamp(target_dolly, dolly_limit_minDistance, dolly_limit_maxDistance)
		camera.position.z = lerp(camera.position.z, target_dolly, dolly_rate * delta)
		
	if rot_enabled:
		var new_basis = rotationPoint.transform.basis.slerp(target_transform.basis, rot_rate * delta)
		if rot_vert_limit_enabled:
			var eulers = new_basis.get_euler()
			eulers.x = clamp(eulers.x, deg_to_rad(rot_vert_limit_minAngle), deg_to_rad(rot_vert_limit_maxAngle))
			new_basis = Basis.from_euler(eulers)
		rotationPoint.transform.basis = new_basis
	
	if drag_enabled:
		pass
