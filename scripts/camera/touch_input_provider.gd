extends Node

@export var camera: CameraRig
@export var rotation_rate: float = 0.01

func _ready():
	# If the target camera rig is not manually set, attempt to find one in the scene
	if not is_instance_valid(camera):
		var parent_node = get_parent()
		if parent_node is CameraRig:
			camera = parent_node
		else:
			push_error("Basic Camera Input module at %s could not find, or was not assigned a CameraRig!" % get_path())

func _input(event):
	if event is InputEventScreenDrag:
		camera.apply_yaw(-event.relative.x * rotation_rate)
		camera.apply_pitch(-event.relative.y * rotation_rate)
