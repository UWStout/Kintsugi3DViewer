extends Node

@export var camera: CameraRig
@export var rotation_rate: float = 0.005
@export var drag_rate: float = 0.01

var fingers = []

enum Mode {NONE, ROTATE, DRAG, ZOOM}
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
	if event is InputEventScreenTouch:
		if event.pressed:
			if not fingers.has(event.index):
				fingers.push_back(event.index)
		else:
			fingers.erase(event.index)
		
		match fingers.size():
			1:
				current_mode = Mode.ROTATE
			2:
				current_mode = Mode.DRAG
			_:
				current_mode = Mode.NONE
		
		print("New touch control mode: %s" % current_mode)
	
	if event is InputEventScreenDrag:
		if fingers.front() == event.index:
			if current_mode == Mode.ROTATE:
				camera.apply_yaw(-event.relative.x * rotation_rate)
				camera.apply_pitch(-event.relative.y * rotation_rate)
			
			if current_mode == Mode.DRAG:
				camera.apply_drag((event.relative * Vector2(-1, 1)) * drag_rate)
