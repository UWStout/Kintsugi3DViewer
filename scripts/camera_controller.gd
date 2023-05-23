# Camera controller script

extends Camera3D

@export var rotationpoint: Node3D
@export var dragModifier: float = 0.01
@export var rotationModifier: float = 0.01
@export var minAngle: float = 6
@export var maxAngle: float = 174

var dragCamera: bool = false
var rotateCamera: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# Check for invalid rotation point parameter
	if (! is_instance_valid(rotationpoint)):
		push_error("Camera controller on node %s has an invalid or unset rotation point!" % get_path())
		
	look_at(rotationpoint.position)
	rotationpoint.rotation = rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if not event is InputEventMouse:
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
