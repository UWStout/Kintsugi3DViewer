extends Node3D

class_name CameraRig

@export_category("Camera Rig")
@export_group("Node References")
@export var camera: Camera3D
@export var rotationPoint: Node3D

@export_group("Rotation", "rot_")
@export var rot_vertical_enabled: bool = true
@export var rot_horizontal_enabled: bool = true
@export var rot_initial_rotation: Vector3
@export_subgroup("Vertical Limits", "rot_vert_limit_")
@export var rot_vert_limit_enabled: bool = true
@export var rot_vert_limit_minAngle: float = 6
@export var rot_vert_limit_maxAngle: float = 174
# Not Implemented
#@export_subgroup("Horizontal Limits", "rot_horiz_limit_")
#@export var rot_horiz_limit_enabled: bool = false
#@export var rot_horiz_limit_minAngle: float
#@export var rot_horiz_limit_maxAngle: float

@export_group("Translation", "drag_")
@export var drag_enabled: bool = true
@export var drag_initial_translation: Vector3

@export_group("Dolly Zoom", "dolly_")
@export var dolly_enabled: bool = true
@export var dolly_initial_distance: float = 10
@export_subgroup("Limits", "dolly_limit_")
@export var dolly_limit_enabled: bool = true
@export var dolly_limit_minDistance: float = 1
@export var dolly_limit_maxDistance: float = 100

@export_group("FOV Zoom", "fov_")
@export var fov_enabled: bool = false
@export_range(1, 179, 0.1, "degrees") var fov_initial_fov: float = 75

# Targets
var target_transform: Transform3D
var target_dolly: float
var target_fov: float

func _ready():
	# Set target variables to initial values
	target_dolly = dolly_initial_distance
	target_fov = fov_initial_fov
	var rot_basis = Basis.from_euler(rot_initial_rotation)
	target_transform = Transform3D(rot_basis, drag_initial_translation)
	
func _process(delta):
	pass

