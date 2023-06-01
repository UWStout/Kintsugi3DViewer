extends Node

@export var camera: CameraRig
@export var keyboard_input_provider: Node
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
	if not input_enabled:
		return
	
	if event is InputEventScreenTouch:
		if event.pressed:
			var data = FingerData.new()
			data.os_index = event.index
			data.initial_position = event.position
			data.current_position = event.position
			if fingers.is_empty():
				primary_finger = event.index
			fingers[event.index] = data
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
