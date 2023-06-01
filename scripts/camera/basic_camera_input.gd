extends Node

@export var camera: CameraRig
@export var zoom_rate: float = 1
@export var drag_rate: float = 0.025
@export var rotation_rate: float = 0.01

var dragCamera: bool
var rotateCamera: bool

func _ready():
	# If the target camera rig is not manually set, attempt to find one in the scene
	if not is_instance_valid(camera):
		var parent_node = get_parent()
		if parent_node is CameraRig:
			camera = parent_node
		else:
			push_error("Basic Camera Input module at %s could not find, or was not assigned a CameraRig!" % get_path())

func _input(event):
	if event is InputEventMouseButton:
		# Left Click
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragCamera = false
				rotateCamera = true
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
			camera.apply_zoom(-zoom_rate)
		
		# Zoom Out
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.apply_zoom(zoom_rate)
	
	if event is InputEventMouseMotion:
		if dragCamera:
			camera.apply_drag((event.relative * Vector2(-1, 1)) * drag_rate)
		
		if rotateCamera:
			#camera.apply_rotation(Vector3(-event.relative.y, event.relative.x, 0) * rotation_rate)
			camera.apply_yaw(-event.relative.x * rotation_rate)
			camera.apply_pitch(-event.relative.y * rotation_rate)
