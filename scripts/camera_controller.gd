# Camera controller script

extends Camera3D

@export_category("Camera Controller")
@export var controlEnabled: bool = true
@export var rotationpoint: Node3D

@export_group("Drag Control")
@export var dragModifier: float = 0.01

@export_group("Rotation Control")
@export var rotationModifier: float = 0.01
@export var minAngle: float = 6
@export var maxAngle: float = 174

@export_group("Dolly Control")
@export var zoomModifier: float = 1
@export var minZoomDistance: float = 1
@export var maxZoomDistance: float = 100
@export var distanceSpeed: float = 0.1

@export_group("Zoom Control")
@export var maxFov: float = 120
@export var minFov: float = 10
@export var fovModifier: float = 1
@export var fovSpeed: float = 0.1

var dragCamera: bool = false
var rotateCamera: bool = false

var targetDistance: float
var targetFov: float

# Called when the node enters the scene tree for the first time.
func _ready():
	# Check for invalid rotation point parameter
	if (! is_instance_valid(rotationpoint)):
		push_error("Camera controller on node %s has an invalid or unset rotation point!" % get_path())
		
	look_at(rotationpoint.position)
	rotationpoint.rotation = rotation
	
	targetDistance = position.distance_to(rotationpoint.position)
	targetFov = fov


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var current_distance := position.distance_to(rotationpoint.position)
	var delta_distance := (targetDistance - current_distance) * distanceSpeed
	position += (position - rotationpoint.position).normalized() * delta_distance
	
	fov += (targetFov - fov) * fovSpeed

func enable_camera():
	controlEnabled = true

func disable_camera():
	controlEnabled = false
	detatch_control()

# Equivelant to the usage of DisableCamera() in Unity implementation
func detatch_control():
	dragCamera = false
	rotateCamera = false

func _input(event):
	if not event is InputEventMouse:
		return
	
	if not controlEnabled:
		return
	
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
		
		if event.is_command_or_control_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				targetFov = max(minFov, targetFov - fovModifier)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				targetFov = min(maxFov, targetFov + fovModifier)
				
		else:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if targetDistance >= minZoomDistance:
					targetDistance -= zoomModifier
				
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if targetDistance <= maxZoomDistance:
					targetDistance += zoomModifier
			
	
	if event is InputEventMouseMotion:
		if dragCamera:
			var offset := Vector3(-event.relative.x, event.relative.y, 0)
			translate_object_local(offset * dragModifier)
			rotationpoint.translate_object_local(offset * dragModifier)
		
		if rotateCamera:
			var basis := global_transform.basis
			var origin := global_transform.origin - rotationpoint.position
			
			# Rotate on x axis
			basis = basis.rotated(Vector3.UP, -event.relative.x * rotationModifier)
			origin = origin.rotated(Vector3.UP, -event.relative.x * rotationModifier)
			
			# Rotate on y axis
			var yLimited: bool = false
			var forward := -transform.basis.z
			if forward.angle_to(Vector3.UP) < (minAngle * PI / 180):
				if -event.relative.y >= 0:
					yLimited = true
			elif forward.angle_to(Vector3.UP) > (maxAngle * PI / 180):
				if -event.relative.y <= 0:
					yLimited = true
			
			if not yLimited:
				basis = basis.rotated(global_transform.basis.x, -event.relative.y * rotationModifier)
				origin = origin.rotated(global_transform.basis.x, -event.relative.y * rotationModifier)
			
			# Rebuild transform from basis and origin
			global_transform = Transform3D(basis, rotationpoint.position + origin)
			look_at(rotationpoint.position)
			rotationpoint.rotation = rotation;
